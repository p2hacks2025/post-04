import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'sticker_tile.dart';

class PlacedStickerWidget extends StatelessWidget {
  const PlacedStickerWidget({
    required this.sticker,
    required this.isSelected,
    required this.boardKey,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
    required this.onInteractionToggle,
  });

  final PlacedSticker sticker;
  final bool isSelected;
  final GlobalKey boardKey;
  final void Function(String id) onSelect;
  final void Function(String id, Offset position, double rotation, Size boardSize)
      onUpdate;
  final void Function(String id) onRemove;
  final ValueChanged<bool> onInteractionToggle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: sticker.position.dx - sticker.size.width / 2,
      top: sticker.position.dy - sticker.size.height / 2,
      child: DraggableSticker(
        sticker: sticker,
        isSelected: isSelected,
        boardKey: boardKey,
        onSelect: onSelect,
        onUpdate: onUpdate,
        onRemove: onRemove,
        onInteractionToggle: onInteractionToggle,
      ),
    );
  }
}

class DraggableSticker extends StatefulWidget {
  const DraggableSticker({
    required this.sticker,
    required this.isSelected,
    required this.boardKey,
    required this.onSelect,
    required this.onUpdate,
    required this.onRemove,
    required this.onInteractionToggle,
  });

  final PlacedSticker sticker;
  final bool isSelected;
  final GlobalKey boardKey;
  final void Function(String id) onSelect;
  final void Function(String id, Offset position, double rotation, Size boardSize)
      onUpdate;
  final void Function(String id) onRemove;
  final ValueChanged<bool> onInteractionToggle;

  @override
  State<DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  double _localRotation = 0;
  Offset _dragStartOffset = Offset.zero;
  double _lastRotation = 0;

  @override
  void initState() {
    super.initState();
    _localRotation = widget.sticker.rotation;
  }

  @override
  void didUpdateWidget(covariant DraggableSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sticker.rotation != widget.sticker.rotation) {
      _localRotation = widget.sticker.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelect(widget.sticker.id),
      onTapDown: (_) => widget.onInteractionToggle(false),
      onTapUp: (_) => widget.onInteractionToggle(true),
      onTapCancel: () => widget.onInteractionToggle(true),
      onScaleStart: (details) {
        widget.onInteractionToggle(false);
        _dragStartOffset = details.focalPoint;
        _lastRotation = 0;
        HapticFeedback.lightImpact();
      },
      onScaleUpdate: (details) {
        final renderBox =
            widget.boardKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final deltaPosition = details.focalPoint - _dragStartOffset;
        final newPos = widget.sticker.position + deltaPosition;
        final rotationDelta = details.rotation - _lastRotation;
        _dragStartOffset = details.focalPoint;
        _lastRotation = details.rotation;
        setState(() {
          _localRotation += rotationDelta;
        });
        widget.onUpdate(
          widget.sticker.id,
          newPos,
          _localRotation,
          renderBox.size,
        );
      },
      onScaleEnd: (_) => widget.onInteractionToggle(true),
      child: Transform.rotate(
        angle: _localRotation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            StickerTile(
              assetPath: widget.sticker.asset,
              size: widget.sticker.size.width,
            ),
            if (widget.isSelected) ...[
              Positioned(
                top: -14,
                right: -14,
                child: GestureDetector(
                  onTap: () => widget.onRemove(widget.sticker.id),
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: _ActionBadge(
                      color: Colors.redAccent,
                      icon: Icons.close,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -22,
                right: -22,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      _localRotation += details.delta.dx * 0.02;
                    });
                    final renderBox = widget.boardKey.currentContext
                        ?.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    widget.onUpdate(
                      widget.sticker.id,
                      widget.sticker.position,
                      _localRotation,
                      renderBox.size,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _ActionBadge(
                      color: Colors.orangeAccent,
                      icon: Icons.rotate_right,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}
