import 'package:flutter/material.dart';

import 'package:seal_app/sticker_book/models.dart';
import 'package:seal_app/sticker_book/sticker_book_pager.dart';
import 'package:seal_app/sticker_book/sticker_list_bottom_sheet.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> {
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  int _selectedCategoryIndex = 0;

  List<String?> _inventorySlots = [];

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
    _inventorySlots = List<String?>.filled(20, 'assets/icons/home_icon.png');
    _initializePageCollections();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initializePageCollections();
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
      _inventorySlots[slotIndex] = null;
      _placedByPage[page].add(sticker);
      _pendingStickerAsset = null;
      _pendingSlotIndex = null;
      _selectedStickerId = sticker.id;
    });
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
