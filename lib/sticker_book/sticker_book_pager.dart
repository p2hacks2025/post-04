import 'package:flutter/material.dart';

import 'draggable_sticker.dart';
import 'models.dart';

class StickerBookPager extends StatelessWidget {
  const StickerBookPager({
    super.key,
    required this.controller,
    required this.gradients,
    required this.boardKeys,
    required this.getPlaced,
    required this.pageScrollEnabled,
    required this.onInteractionToggle,
    required this.selectedId,
    required this.pendingStickerAsset,
    required this.pendingSlotIndex,
    required this.onPlace,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
  });

  final PageController controller;
  final List<List<Color>> gradients;
  final List<GlobalKey> boardKeys;
  final List<PlacedSticker> Function(int page) getPlaced;
  final bool pageScrollEnabled;
  final ValueChanged<bool> onInteractionToggle;
  final String? selectedId;
  final String? pendingStickerAsset;
  final int? pendingSlotIndex;
  final void Function(
    String asset,
    int slotIndex,
    Offset position,
    Size boardSize,
    int page,
  ) onPlace;
  final void Function(String id) onSelect;
  final void Function(
    String id,
    Offset position,
    double rotation,
    Size boardSize,
    int page,
  ) onUpdate;
  final void Function(String id, int page) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      child: PageView.builder(
        controller: controller,
        itemCount: gradients.length,
        physics: pageScrollEnabled
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _StickerBoardPage(
            gradient: gradients[index % gradients.length],
            boardKey: boardKeys[index],
            placed: getPlaced(index),
            selectedId: selectedId,
            pendingStickerAsset: pendingStickerAsset,
            pendingSlotIndex: pendingSlotIndex,
            onPlace: (asset, slot, pos, size) => onPlace(asset, slot, pos, size, index),
            onSelect: onSelect,
            onUpdate: (id, pos, rot, size) => onUpdate(id, pos, rot, size, index),
            onRemove: (id) => onRemove(id, index),
            onInteractionToggle: onInteractionToggle,
          );
        },
      ),
    );
  }
}

class _StickerBoardPage extends StatelessWidget {
  const _StickerBoardPage({
    required this.gradient,
    required this.boardKey,
    required this.placed,
    required this.selectedId,
    required this.pendingStickerAsset,
    required this.pendingSlotIndex,
    required this.onPlace,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
    required this.onInteractionToggle,
  });

  final List<Color> gradient;
  final GlobalKey boardKey;
  final List<PlacedSticker> placed;
  final String? selectedId;
  final String? pendingStickerAsset;
  final int? pendingSlotIndex;
  final void Function(String asset, int slotIndex, Offset position, Size boardSize)
      onPlace;
  final void Function(String id) onSelect;
  final void Function(String id, Offset position, double rotation, Size boardSize)
      onUpdate;
  final void Function(String id) onRemove;
  final ValueChanged<bool> onInteractionToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest;
        return DragTarget<InventoryPayload>(
          onAcceptWithDetails: (details) {
            final renderBox =
                boardKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null) return;
            final local = renderBox.globalToLocal(details.offset);
            onPlace(details.data.asset, details.data.slotIndex, local, boardSize);
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                onInteractionToggle(true);
                if (pendingStickerAsset != null && pendingSlotIndex != null) {
                  onPlace(
                    pendingStickerAsset!,
                    pendingSlotIndex!,
                    d.localPosition,
                    boardSize,
                  );
                } else {
                  onSelect('');
                }
              },
              child: Container(
                key: boardKey,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 32,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  6,
                                  (_) => const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black38,
                                                blurRadius: 0,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final sticker in placed)
                      PlacedStickerWidget(
                        sticker: sticker,
                        isSelected: sticker.id == selectedId,
                        boardKey: boardKey,
                        onSelect: onSelect,
                        onUpdate: onUpdate,
                        onRemove: onRemove,
                        onInteractionToggle: onInteractionToggle,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
