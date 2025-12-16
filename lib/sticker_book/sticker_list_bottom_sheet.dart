import 'package:flutter/material.dart';

import 'models.dart';
import 'sticker_tile.dart';

class StickerListBottomSheet extends StatelessWidget {
  const StickerListBottomSheet({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.inventorySlots,
    required this.onTapSticker,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final List<String?> inventorySlots;
  final void Function(String asset, int slotIndex) onTapSticker;

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
                  onTapSticker: onTapSticker,
                ),
              ),
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
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < categories.length; i++)
              _FileTab(
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
    required this.onTapSticker,
  });

  final ScrollController scrollController;
  final List<String?> inventorySlots;
  final void Function(String asset, int slotIndex) onTapSticker;

  @override
  Widget build(BuildContext context) {
    final visibleStickers = List<String?>.from(inventorySlots);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(right: 1),
            child: _GridBackground(),
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
          itemCount: visibleStickers.length,
          itemBuilder: (context, index) {
            final asset = visibleStickers[index];
            return _InventoryStickerTile(
              assetPath: asset,
              slotIndex: index,
              onTap: asset != null ? () => onTapSticker(asset, index) : null,
            );
          },
        ),
      ],
    );
  }
}

class _InventoryStickerTile extends StatelessWidget {
  const _InventoryStickerTile({
    required this.assetPath,
    required this.slotIndex,
    required this.onTap,
  });

  final String? assetPath;
  final int slotIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return const _EmptySlot();
    }
    return LongPressDraggable<InventoryPayload>(
      data: InventoryPayload(asset: assetPath!, slotIndex: slotIndex),
      maxSimultaneousDrags: 1,
      feedback: StickerTile(
        assetPath: assetPath!,
        size: 60,
        showShadow: false,
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: StickerTile(
          assetPath: assetPath!,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: StickerTile(
          assetPath: assetPath!,
        ),
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _GridBackgroundPainter());
  }
}

class _GridBackgroundPainter extends CustomPainter {
  const _GridBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 24;
    final paint = Paint()
      ..color = const Color(0xFFD9DDE3)
      ..strokeWidth = 1;

    final double width = size.width;
    final double height = size.height;

    for (double x = 0; x <= width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    for (double y = 0; y <= height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FileTab extends StatelessWidget {
  const _FileTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE8D9) : const Color(0xFFF1F5F9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border(
            top: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
            left: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
            right: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFC6845A)
                : const Color(0xFF334155),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.add,
        color: Color(0xFFCBD5E1),
      ),
    );
  }
}
