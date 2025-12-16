import 'package:flutter/material.dart';
import 'package:seal_app/sticker_book/models.dart';
import 'package:seal_app/sticker_book/sticker_book_pager.dart';
import 'package:seal_app/sticker_book/sticker_list_bottom_sheet.dart';
import 'package:seal_app/sticker_book/repository.dart'; // ★追加: Repositoryをインポート

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> {
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  int _selectedCategoryIndex = 0;

  // ★変更: ここにFirebaseから取った画像URLが入る
  List<String?> _inventorySlots = [];
  
  // ★追加: データの読み込み中かどうかを管理するフラグ
  bool _isLoading = true; 

  List<List<PlacedSticker>> _placedByPage = [];
  String? _selectedStickerId;
  String? _pendingStickerAsset;
  int? _pendingSlotIndex;
  List<GlobalKey> _boardKeys = [];
  bool _pageScrollEnabled = true;

  final PageController _pageController = PageController();

  final List<List<Color>> _boardGradients = const [
    [Color(0xFFD888FF), Color(0xFFF9C4E6)],
    [Color(0xFFB2E0FF), Color(0xFFFBD3FF)],
    [Color(0xFFFFE5B5), Color(0xFFF8C4E1)],
    [Color(0xFFBFE3D0), Color(0xFFD8C8FF)],
  ];

  @override
  void initState() {
    super.initState();
    // ★変更: 初期値はダミーではなく空にしておく（またはロード中画像）
    _inventorySlots = []; 
    _initializePageCollections();
    
    // ★追加: データ取得を開始！
    _fetchStickerData();
  }

  // ★追加: Firebaseからデータを取ってきて下駄箱を作る処理
  Future<void> _fetchStickerData() async {
    try {
      final repository = StickerRepository();
      
      // 1. Firebaseからマスタデータを取得（repository側でsort済み）
      final masters = await repository.fetchMasters();

      // 2. 画面表示用のリストを作る
      // 今回は「マスタにある画像」をそのままリストに入れる
      // (将来はここで「持っているか？」の判定を入れる)
      final slots = masters.map((m) => m.image).toList();

      if (mounted) {
        setState(() {
          _inventorySlots = slots; // データを反映
          _isLoading = false;      // ロード完了
        });
      }
    } catch (e) {
      debugPrint('エラーが発生しました: $e');
      // エラー時はとりあえずロード完了にして空の状態にするなどの処理
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initializePageCollections(); // ※ここは本来buildの度でなくinitStateだけで良いかも

    // ★追加: ロード中はぐるぐるを表示する
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
          inventorySlots: _inventorySlots, // ★ここでFirebaseの画像リストが渡る
          onTapSticker: _handleStickerTap,
        ),
      ],
    );
  }

  // ... (以下、_handleStickerTap などのメソッドは変更なしでOK)
  // ただし、_inventorySlotsの中身が実際のURLになるので、
  // StickerListBottomSheet側がネットワーク画像(Image.network)に対応している必要があります。
  // もしasset画像しか表示できない作りだと、修正が必要です。

  void _handleStickerTap(String asset, int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _inventorySlots.length) return;
    // nullチェックを追加
    final slotAsset = _inventorySlots[slotIndex];
    if (slotAsset == null || slotAsset != asset) return;
    
    setState(() {
      _pendingStickerAsset = asset;
      _pendingSlotIndex = slotIndex;
      _selectedStickerId = null;
    });
  }

  void _placeSticker(
    String asset,
    int slotIndex,
    Offset position,
    Size boardSize, [
    int page = 0,
  ]) {
    if (slotIndex < 0 || slotIndex >= _inventorySlots.length) return;
    // nullチェック
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
      // ★注意: ここでnullにすると「消費」される動きになる
      // ユーザー所持情報と連動させるなら、ここは「所持数を減らす」ロジックに変わる
      // 今回はとりあえずそのままnull（空席）にする
      _inventorySlots[slotIndex] = null;
      _placedByPage[page].add(sticker);
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
      _selectedStickerId = sticker.id;
    });
  }

  // _updateSticker, _selectSticker, _removeSticker, _initializePageCollections
  // これらのメソッドはそのままのコードで貼り付けてください
  // （長くなるので省略しましたが、元のコードと同じです）
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
            position.dx.clamp(stickerSize / 2, boardSize.width - stickerSize / 2),
            position.dy.clamp(stickerSize / 2, boardSize.height - stickerSize / 2),
          );
          _placedByPage[page][i] = _placedByPage[page][i].copyWith(
            position: clamped,
            rotation: rotation,
          );
          break;
        }
      }
    });
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
      if (sticker.inventoryIndex >= 0 &&
          sticker.inventoryIndex < _inventorySlots.length) {
        _inventorySlots[sticker.inventoryIndex] = sticker.asset;
      }
      if (_selectedStickerId == id) {
        _selectedStickerId = null;
      }
    });
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
}