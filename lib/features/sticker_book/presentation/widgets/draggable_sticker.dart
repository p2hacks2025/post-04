import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/models.dart';
import 'sticker_tile.dart';

class PlacedStickerWidget extends StatelessWidget {
  const PlacedStickerWidget({
    super.key,
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
  final Future<void> Function(String id) onRemove;
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
    super.key,
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
  final Future<void> Function(String id) onRemove;
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
    final displayPath = (widget.sticker.displayAsset ?? widget.sticker.asset);
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
        
        // 選択中のみ回転を適用
        double newRotation = _localRotation;
        if (widget.isSelected) {
          final rotationDelta = details.rotation - _lastRotation;
          newRotation += rotationDelta;
        }
        
        _dragStartOffset = details.focalPoint;
        _lastRotation = details.rotation;
        setState(() {
          _localRotation = newRotation;
        });
        widget.onUpdate(
          widget.sticker.id,
          newPos,
          _localRotation,
          renderBox.size,
        );
      },
      onScaleEnd: (_) => widget.onInteractionToggle(true),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: _localRotation,
            child: StickerTile(
              assetPath: displayPath,
              size: widget.sticker.size.width,
            ),
          ),
          if (widget.isSelected) ...[
            // 削除ボタン（左上）
            Positioned(
              top: -28,
              left: -28,
              child: GestureDetector(
                onTap: () => widget.onRemove(widget.sticker.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _ActionBadge(
                    color: Colors.redAccent,
                    icon: Icons.close,
                  ),
                ),
              ),
            ),
          ],
        ],
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
            color: Colors.black.withValues(alpha: 0.15),
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
