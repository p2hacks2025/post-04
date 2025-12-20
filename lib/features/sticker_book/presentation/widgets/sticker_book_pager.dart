import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import 'draggable_sticker.dart';

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
  final Future<void> Function(
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
  final Future<void> Function(String id, int page) onRemove;

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

class _StickerBoardPage extends StatefulWidget {
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
  final Future<void> Function(String id) onRemove;
  final ValueChanged<bool> onInteractionToggle;

  @override
  State<_StickerBoardPage> createState() => _StickerBoardPageState();
}

class _StickerBoardPageState extends State<_StickerBoardPage> {
  double _lastRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest;
        return DragTarget<InventoryPayload>(
          onAcceptWithDetails: (details) {
            final renderBox =
                widget.boardKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null) return;
            final local = renderBox.globalToLocal(details.offset);
            widget.onPlace(details.data.asset, details.data.slotIndex, local, boardSize);
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                widget.onInteractionToggle(true);
                if (widget.pendingStickerAsset != null && widget.pendingSlotIndex != null) {
                  widget.onPlace(
                    widget.pendingStickerAsset!,
                    widget.pendingSlotIndex!,
                    d.localPosition,
                    boardSize,
                  );
                } else {
                  widget.onSelect('');
                }
              },
              onScaleStart: (details) {
                // 選択中のシールがある場合のみ回転操作を開始
                if (widget.selectedId != null) {
                  widget.onInteractionToggle(false);
                  _lastRotation = 0.0;
                }
              },
              onScaleUpdate: (details) {
                // 選択中のシールがある場合のみ回転を適用
                if (widget.selectedId != null) {
                  try {
                    final selectedSticker = widget.placed.firstWhere(
                      (s) => s.id == widget.selectedId,
                    );
                    
                    final rotationDelta = details.rotation - _lastRotation;
                    _lastRotation = details.rotation;
                    
                    widget.onUpdate(
                      selectedSticker.id,
                      selectedSticker.position,
                      selectedSticker.rotation + rotationDelta,
                      boardSize,
                    );
                  } catch (e) {
                    // 選択中のシールが見つからない場合は何もしない
                  }
                }
              },
              onScaleEnd: (_) {
                widget.onInteractionToggle(true);
                _lastRotation = 0.0;
              },
              child: Container(
                key: widget.boardKey,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradient,
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
                    for (final sticker in widget.placed)
                      PlacedStickerWidget(
                        sticker: sticker,
                        isSelected: sticker.id == widget.selectedId,
                        boardKey: widget.boardKey,
                        onSelect: widget.onSelect,
                        onUpdate: widget.onUpdate,
                        onRemove: widget.onRemove,
                        onInteractionToggle: widget.onInteractionToggle,
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
