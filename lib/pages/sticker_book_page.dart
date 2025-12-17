import 'package:flutter/material.dart';

import 'package:seal_app/sticker_book/models.dart';
import 'package:seal_app/sticker_book/sticker_book_data.dart';
import 'package:seal_app/sticker_book/sticker_book_pager.dart';
import 'package:seal_app/sticker_book/sticker_list_bottom_sheet.dart';
import 'package:seal_app/services/sticker_count_store.dart';
import 'package:seal_app/data/sticker_master.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> with WidgetsBindingObserver {
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  int _selectedCategoryIndex = 0;

  final List<StickerData> _catalog = stickerMasterDb;
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

  static const int _inventorySize = 20;
  static const int _pageCount = 4;

  final List<List<Color>> _boardGradients = const [
    [Color(0xFFD888FF), Color(0xFFF9C4E6)],
    [Color(0xFFB2E0FF), Color(0xFFFBD3FF)],
    [Color(0xFFFFE5B5), Color(0xFFF8C4E1)],
    [Color(0xFFBFE3D0), Color(0xFFD8C8FF)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePageCollections();
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    // アプリ終了前にデータを保存
    _saveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // アプリがバックグラウンドに移行した時、または終了する前にデータを保存
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveData();
    }
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
              onPlace: (asset, slotIndex, pos, size, page) =>
                  _placeSticker(asset, slotIndex, pos, size, page),
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

  void _handleDropFromList(InventoryPayload payload, Offset globalPosition) {
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
    _placeSticker(
      payload.asset,
      payload.slotIndex,
      local,
      renderBox.size,
      page,
    );
  }

  void _placeSticker(
    String asset,
    int slotIndex,
    Offset position,
    Size boardSize, [
    int page = 0,
  ]) {
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
      inventoryIndex: slotIndex,
      position: clamped,
      rotation: 0,
      size: const Size(stickerSize, stickerSize),
    );
    setState(() {
      // 枚数を1枚消費し、一覧を再構築
      final current = (_counts[asset] ?? 0);
      if (current > 0) {
        _counts[asset] = current - 1;
      }
      _rebuildInventoryFromCounts();
      _placedByPage[page].add(sticker);
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
      _selectedStickerId = sticker.id;
    });
    _saveData();
    _countStore.save();
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
  }

  void _selectSticker(String id) {
    setState(() {
      _selectedStickerId = id.isEmpty ? null : id;
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
    });
  }

  void _removeSticker(String id, int page) {
    setState(() {
      final sticker = _placedByPage[page].firstWhere((s) => s.id == id);
      _placedByPage[page].removeWhere((s) => s.id == id);
      // 枚数を1枚戻し、一覧を再構築
      final asset = sticker.asset;
      _counts[asset] = (_counts[asset] ?? 0) + 1;
      _rebuildInventoryFromCounts();
      if (_selectedStickerId == id) {
        _selectedStickerId = null;
      }
    });
    _saveData();
    _countStore.save();
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

    // シール枚数のDBをロード（なければ4種を1枚で初期化）
    await _countStore.loadOrInit(defaultCount: 1);
    _counts = Map<String, int>.from(_countStore.counts);
    _rebuildInventoryFromCounts();

    setState(() {
      _isLoading = false;
    });
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
