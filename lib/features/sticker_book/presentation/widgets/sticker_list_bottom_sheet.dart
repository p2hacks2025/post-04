import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/models.dart';
import 'package:seal_app/core/widgets/category_tab.dart';
import 'package:seal_app/core/widgets/grid_background.dart';
import 'seal_detail_overlay.dart';
import 'sticker_tile.dart';

class StickerListBottomSheet extends StatelessWidget {
  const StickerListBottomSheet({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.inventorySlots,
    required this.onTapSticker,
    required this.onDropSticker,
    this.displayAssetResolver,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final List<String?> inventorySlots;
  final void Function(String asset, int slotIndex) onTapSticker;
  final void Function(InventoryPayload payload, Offset globalPosition)
  onDropSticker;
  final String Function(String assetPath)? displayAssetResolver;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
          child: Column(
            children: [
              _StickerTabs(
                categories: categories,
                selectedIndex: selectedIndex,
                onCategorySelected: onCategorySelected,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _StickerGridArea(
                  scrollController: scrollController,
                  inventorySlots: inventorySlots,
                  selectedCategoryIndex: selectedIndex,
                  onTapSticker: onTapSticker,
                  onShowDetail: (assetPath) {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => SealDetailOverlay(
                        assetPath: assetPath,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  onDropSticker: onDropSticker,
                  displayAssetResolver: displayAssetResolver,
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        );
      },
    );
  }
}

class _StickerTabs extends StatelessWidget {
  const _StickerTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < categories.length; i++)
              CategoryTab(
                label: categories[i],
                isSelected: selectedIndex == i,
                onTap: () => onCategorySelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _StickerGridArea extends StatelessWidget {
  const _StickerGridArea({
    required this.scrollController,
    required this.inventorySlots,
    required this.selectedCategoryIndex,
    required this.onTapSticker,
    required this.onShowDetail,
    required this.onDropSticker,
    this.displayAssetResolver,
  });

  final ScrollController scrollController;
  final List<String?> inventorySlots;
  final int selectedCategoryIndex;
  final void Function(String asset, int slotIndex) onTapSticker;
  final void Function(String assetPath) onShowDetail;
  final void Function(InventoryPayload payload, Offset globalPosition)
  onDropSticker;
  final String Function(String assetPath)? displayAssetResolver;

  /// アセットパスからファイル名を取得
  String _getFileName(String assetPath) {
    final fileName = assetPath.split('/').last;
    final lastDotIndex = fileName.lastIndexOf('.');
    return lastDotIndex >= 0 ? fileName.substring(0, lastDotIndex) : fileName;
  }

  /// アセットがカテゴリに一致するかチェック
  bool _matchesCategory(String asset, int categoryIndex) {
    final fileName = _getFileName(asset).toLowerCase();

    switch (categoryIndex) {
      case 1: // マーク：heart*, star*, kira*で始まるもの
        return fileName.startsWith('heart') ||
            fileName.startsWith('star') ||
            fileName.startsWith('kira');

      case 2: // はこだて：FUN, hakodateが含まれるもの
        return fileName.contains('fun') || fileName.contains('hakodate');

      case 3: // ほか：上記以外のもの
        final isMark =
            fileName.startsWith('heart') ||
            fileName.startsWith('star') ||
            fileName.startsWith('kira');
        final isHakodate =
            fileName.contains('fun') || fileName.contains('hakodate');
        return !isMark && !isHakodate;

      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(right: 1),
            child: GridBackground(),
          ),
        ),
        GridView.builder(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          // nullも含めてスロット数ぶん描画し、消費後に後ろが詰まらないようにする
          itemCount: inventorySlots.length,
          itemBuilder: (context, index) {
            final rawAsset = inventorySlots[index];
            final asset =
                (rawAsset != null &&
                    (selectedCategoryIndex == 0 ||
                        _matchesCategory(rawAsset, selectedCategoryIndex)))
                ? rawAsset
                : null;
            final displayAsset = (asset != null && displayAssetResolver != null)
                ? displayAssetResolver!(asset)
                : asset;
            return _InventoryStickerTile(
              assetPath: asset,
              displayAssetPath: displayAsset,
              slotIndex: index,
              onTap: asset != null ? () => onShowDetail(asset) : null,
              onDropSticker: onDropSticker,
            );
          },
        ),
      ],
    );
  }
}

class _InventoryStickerTile extends StatefulWidget {
  const _InventoryStickerTile({
    required this.assetPath,
    this.displayAssetPath,
    required this.slotIndex,
    required this.onTap,
    required this.onDropSticker,
  });

  final String? assetPath;
  final String? displayAssetPath; // 表示用（サムネイル等）。未指定なら assetPath
  final int slotIndex;
  final VoidCallback? onTap;
  final void Function(InventoryPayload payload, Offset globalPosition)
  onDropSticker;

  @override
  State<_InventoryStickerTile> createState() => _InventoryStickerTileState();
}

class _InventoryStickerTileState extends State<_InventoryStickerTile> {
  OverlayEntry? _overlayEntry;
  Offset _overlayPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDragging = false;
  }

  void _showOverlay(
    BuildContext context,
    String assetPath,
    Offset globalPosition,
  ) {
    _overlayPosition = globalPosition;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isGlb = assetPath.toLowerCase().endsWith('.glb');
        return Positioned(
          left: _overlayPosition.dx - 30,
          top: _overlayPosition.dy - 30,
          child: Material(
            color: Colors.transparent,
            child: StickerTile(
              assetPath: assetPath,
              size: 60,
              showShadow: false,
              showBackground: false,
              forceStaticImage: false,
              useModelViewer: isGlb,
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetPath == null) {
      return const _EmptySlot();
    }

    final assetPath = widget.assetPath!; // 本体（配置に使う）
    final tileAssetPath = widget.displayAssetPath ?? assetPath; // 表示に使う
    final isGlb = tileAssetPath.toLowerCase().endsWith('.glb');

    final tile = StickerTile(
      assetPath: tileAssetPath,
      forceStaticImage: false,
      useModelViewer: isGlb,
      showBackground: false,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPressStart: (details) {
        if (_isDragging) return;
        HapticFeedback.lightImpact();
        setState(() => _isDragging = true);
        _showOverlay(context, tileAssetPath, details.globalPosition);
      },
      onLongPressMoveUpdate: (details) {
        if (_overlayEntry == null) return;
        _overlayPosition = details.globalPosition;
        _overlayEntry!.markNeedsBuild();
      },
      onLongPressEnd: (details) {
        final payload = InventoryPayload(
          asset: assetPath,
          slotIndex: widget.slotIndex,
        );
        final dropPosition = details.globalPosition;
        _removeOverlay();
        setState(() {});
        widget.onDropSticker(payload, dropPosition);
      },
      child: Opacity(opacity: _isDragging ? 0.5 : 1, child: tile),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(Icons.add, color: Color(0xFFCBD5E1)));
  }
}
