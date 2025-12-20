import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/models.dart';
import '../../data/repositories/sticker_book_data.dart';
import '../../data/services/sticker_count_store.dart';
import '../../data/sticker_master.dart';
import '../widgets/sticker_book_pager.dart';
import '../widgets/sticker_list_bottom_sheet.dart';

import '../../../nameplate/data/repositories/nameplate_storage.dart';
import '../../../nameplate/domain/constants/nameplate_constants.dart';
import '../../../nameplate/domain/models/models.dart' as np;
import '../../../timeline/data/repositories/public_board_repository.dart';
import '../../../timeline/domain/models/public_board.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> with WidgetsBindingObserver {
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  int _selectedCategoryIndex = 0;

  final List<StickerData> _catalog = stickerMasterData;
  List<String?> _inventorySlots = [];
  late final StickerCountStore _countStore = StickerCountStore(
    _catalog.map((e) => e.assetPath).toList(growable: false),
  );
  late final Map<String, String> _iconByAsset = {
    for (final s in _catalog) s.assetPath: s.iconPath,
  };
  Map<String, int> _counts = {};

  List<List<PlacedSticker>> _placedByPage = [];
  String? _selectedStickerId;
  String? _pendingStickerAsset;
  int? _pendingSlotIndex;
  List<GlobalKey> _boardKeys = [];
  bool _pageScrollEnabled = true;
  bool _isLoading = true;

  final PageController _pageController = PageController();

  final PublicBoardRepository _publicRepo = PublicBoardRepository();
  Set<int> _publishedPages = <int>{};
  int _currentPage = 0;

  static const int _inventorySize = 20;
  static const int _pageCount = 4;

  final List<List<Color>> _boardGradients = AppColors.stickerBookGradients;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePageCollections();
    _pageController.addListener(_onPageChanged);
    _loadData();
  }

  void _onPageChanged() {
    final p = (_pageController.page ?? 0).round().clamp(0, _boardKeys.length - 1);
    if (p != _currentPage && mounted) {
      setState(() => _currentPage = p);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    // アプリ終了前にデータを保存
    _saveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveData();
    } else if (state == AppLifecycleState.resumed) {
      _reloadCounts();
    }
  }

  Future<void> reloadCounts() async {
    await _countStore.loadOrInit();
    _counts = Map<String, int>.from(_countStore.counts);
    if (mounted) {
      setState(() {
        _rebuildInventoryFromCounts();
      });
    }
  }

  Future<void> _reloadCounts() async {
    await reloadCounts();
  }

  @override
  Widget build(BuildContext context) {
    _initializePageCollections();
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final published = _publishedPages.contains(_currentPage);

    return Stack(
      children: [
        Column(
          children: [
            StickerBookPager(
              controller: _pageController,
              gradients: _boardGradients,
              boardKeys: _boardKeys,
              getPlaced: (page) => _placedByPage[page],
              pageScrollEnabled: _pageScrollEnabled,
              onInteractionToggle: (enabled) {
                if (_pageScrollEnabled != enabled) {
                  setState(() => _pageScrollEnabled = enabled);
                }
              },
              selectedId: _selectedStickerId,
              pendingStickerAsset: _pendingStickerAsset,
              pendingSlotIndex: _pendingSlotIndex,
              onPlace: (asset, slotIndex, pos, size, page) async =>
                  await _placeSticker(asset, slotIndex, pos, size, page),
              onSelect: _selectSticker,
              onUpdate: (id, pos, rot, size, page) =>
                  _updateSticker(id, pos, rot, size, page),
              onRemove: (id, page) => _removeSticker(id, page),
            ),
            const SizedBox(height: 12),
            const Spacer(),
          ],
        ),
        StickerListBottomSheet(
          categories: _categories,
          selectedIndex: _selectedCategoryIndex,
          onCategorySelected: (index) {
            setState(() => _selectedCategoryIndex = index);
          },
          inventorySlots: _inventorySlots,
          onTapSticker: _handleStickerTap,
          onDropSticker: _handleDropFromList,
          displayAssetResolver: (asset) => _iconByAsset[asset] ?? asset,
        ),

        Positioned(
          top: 12,
          right: 12,
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: _togglePublishDialog,
              icon: Icon(published ? Icons.public : Icons.lock),
              label: Text(published ? '公開中' : '公開'),
              style: ElevatedButton.styleFrom(
                backgroundColor: published ? Colors.green : const Color(0xFFC6845A),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleStickerTap(String asset, int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _inventorySlots.length) return;
    if (_inventorySlots[slotIndex] != asset) return;
    setState(() {
      _pendingStickerAsset = asset;
      _pendingSlotIndex = slotIndex;
      _selectedStickerId = null;
    });
  }

  Future<void> _handleDropFromList(InventoryPayload payload, Offset globalPosition) async {
    final page = (_pageController.page ?? 0).round().clamp(
      0,
      _boardKeys.length - 1,
    );
    final boardKey = _boardKeys[page];
    final renderBox = boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    final rect = topLeft & renderBox.size;
    if (!rect.contains(globalPosition)) return;

    final local = renderBox.globalToLocal(globalPosition);
    await _placeSticker(
      payload.asset,
      payload.slotIndex,
      local,
      renderBox.size,
      page,
    );
  }

  Future<void> _placeSticker(
    String asset,
    int slotIndex,
    Offset position,
    Size boardSize, [
    int page = 0,
  ]) async {
    if (slotIndex < 0 || slotIndex >= _inventorySlots.length) return;
    if (_inventorySlots[slotIndex] != asset) return;
    const stickerSize = 72.0;
    final clamped = Offset(
      position.dx.clamp(stickerSize / 2, boardSize.width - stickerSize / 2),
      position.dy.clamp(stickerSize / 2, boardSize.height - stickerSize / 2),
    );
    final sticker = PlacedSticker(
      id: '${DateTime.now().microsecondsSinceEpoch}-$page',
      asset: asset,
      displayAsset: _iconByAsset[asset] ?? asset,
      inventoryIndex: slotIndex,
      position: clamped,
      rotation: 0,
      size: const Size(stickerSize, stickerSize),
    );
    await _countStore.dec(asset);
    _counts = Map<String, int>.from(_countStore.counts);
    setState(() {
      _rebuildInventoryFromCounts();
      _placedByPage[page].add(sticker);
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
      _selectedStickerId = sticker.id;
    });
    _saveData();
    await _syncIfPublished(page);
  }

  void _updateSticker(
    String id,
    Offset position,
    double rotation,
    Size boardSize,
    int page,
  ) {
    const stickerSize = 72.0;
    setState(() {
      for (var i = 0; i < _placedByPage[page].length; i++) {
        if (_placedByPage[page][i].id == id) {
          final clamped = Offset(
            position.dx.clamp(
              stickerSize / 2,
              boardSize.width - stickerSize / 2,
            ),
            position.dy.clamp(
              stickerSize / 2,
              boardSize.height - stickerSize / 2,
            ),
          );
          _placedByPage[page][i] = _placedByPage[page][i].copyWith(
            position: clamped,
            rotation: rotation,
          );
          break;
        }
      }
    });
    _saveData();
    _syncIfPublished(page);
  }

  void _selectSticker(String id) {
    setState(() {
      _selectedStickerId = id.isEmpty ? null : id;
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
    });
  }

  Future<void> _removeSticker(String id, int page) async {
    final sticker = _placedByPage[page].firstWhere((s) => s.id == id);
    final asset = sticker.asset;
    await _countStore.inc(asset);
    _counts = Map<String, int>.from(_countStore.counts);
    setState(() {
      _placedByPage[page].removeWhere((s) => s.id == id);
      _rebuildInventoryFromCounts();
      if (_selectedStickerId == id) {
        _selectedStickerId = null;
      }
    });
    _saveData();
    await _syncIfPublished(page);
  }

  void _initializePageCollections() {
    final pageCount = _boardGradients.length;
    if (_boardKeys.length != pageCount) {
      _boardKeys = List.generate(pageCount, (_) => GlobalKey());
    }
    if (_placedByPage.length != pageCount) {
      _placedByPage = List.generate(pageCount, (_) => <PlacedSticker>[]);
    }
  }

  /// データを読み込む
  Future<void> _loadData() async {
    final data = await StickerBookStorage.loadData(
      defaultInventorySize: _inventorySize,
      defaultPageCount: _pageCount,
    );

    if (data != null) {
      _placedByPage = data.placedByPage
          .map((page) => List<PlacedSticker>.from(page))
          .toList();
    } else {
      _placedByPage = List.generate(_pageCount, (_) => <PlacedSticker>[]);
    }
    //初期値リセット（開発用なので、後で消す）
    _countStore.resetAllTo(7);
    // シール枚数のDBをロード（なければ4種を1枚で初期化）
    await _countStore.loadOrInit(defaultCount: 1);
    // // シール枚数のDBをロード（開発中: 強制的に0枚スタートにリセット）
    // await _countStore.loadOrInit(defaultCount: 0, forceReset: true);
    _counts = Map<String, int>.from(_countStore.counts);
    _rebuildInventoryFromCounts();

    await _loadPublishedPages();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPublishedPages() async {
    // 未ログインの可能性はほぼ無いが、念のため
    if (FirebaseAuth.instance.currentUser == null) return;
    final pages = await _publicRepo.fetchMyPublishedPages();
    if (!mounted) return;
    setState(() => _publishedPages = pages);
  }

  Future<np.NameplateData> _loadMyNameplateOrDefault() async {
    final saved = await NameplateStorage.load();
    if (saved != null) return saved;
    return np.NameplateData(
      shape: np.NameplateShape.roundedSquare,
      backgroundColor: NameplateColors.backgroundColors[0],
      name: '',
      fontType: np.FontType.rounded,
      textColor: const Color(0xFFFF6FAE),
      hasOutline: true,
      hasShadow: true,
      decorations: const [],
    );
  }

  Future<void> _togglePublishDialog() async {
    final page = _currentPage;
    final now = _publishedPages.contains(page);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('公開設定'),
          content: Text(
            now
                ? 'このページは公開中です。\n非公開にすると、データベースから削除されます。'
                : 'このページを公開しますか？\n公開すると「みんなの」に表示されます。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (now) {
                  await _unpublish(page);
                } else {
                  await _publish(page);
                }
              },
              child: Text(now ? '非公開にする' : '公開する'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _publish(int page) async {
    final key = _boardKeys[page];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('公開に失敗しました（台紙サイズ取得不可）')));
      }
      return;
    }

    final boardSize = renderBox.size;
    final gradient = _boardGradients[page % _boardGradients.length];
    final nameplate = await _loadMyNameplateOrDefault();

    // 画像/バイナリは一切アップロードしない: アセット参照 + 座標のみ
    final stickers = _placedByPage[page]
        .map(
          (s) => PublicPlacedSticker(
            asset: s.asset,
            dx: s.position.dx,
            dy: s.position.dy,
            rotation: s.rotation,
          ),
        )
        .toList(growable: false);

    final snapshot = PublicBoardSnapshot(
      gradientArgb: gradient.map((c) => c.toARGB32()).toList(growable: false),
      boardWidth: boardSize.width,
      boardHeight: boardSize.height,
      stickers: stickers,
    );

    await _publicRepo.publishPage(page: page, nameplate: nameplate, board: snapshot);

    if (!mounted) return;
    setState(() => _publishedPages = {..._publishedPages, page});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('公開しました')));
  }

  Future<void> _unpublish(int page) async {
    await _publicRepo.unpublishPage(page: page);
    if (!mounted) return;
    setState(() => _publishedPages = _publishedPages.where((p) => p != page).toSet());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('非公開にしました（DBから削除）')));
  }

  Future<void> _syncIfPublished(int page) async {
    if (!_publishedPages.contains(page)) return;
    if (page != _currentPage) return;
    await _publish(page);
  }

  void _rebuildInventoryFromCounts() {
    _inventorySlots = _catalog
        .map((s) => (_counts[s.assetPath] ?? 0) > 0 ? s.assetPath : null)
        .toList(growable: false);
  }

  /// データを保存する
  Future<void> _saveData() async {
    final data = StickerBookData(
      inventorySlots: _inventorySlots,
      placedByPage: _placedByPage,
    );
    await StickerBookStorage.saveData(data);
  }
}
