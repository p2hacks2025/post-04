import 'package:flutter/material.dart';

class StickerTile extends StatelessWidget {
  const StickerTile({
    super.key,
    required this.assetPath,
    this.size,
    this.showShadow = true,
  });

  final String assetPath;
  final double? size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final boxShadow = showShadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];
    final bgColor = showShadow ? Colors.white : Colors.transparent;
    final padding = const EdgeInsets.all(8);

    final child = _buildContent();
    final decoration = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: boxShadow,
    );

    if (size != null) {
      return Container(
        width: size,
        height: size,
        decoration: decoration,
        padding: padding,
        alignment: Alignment.center,
        child: child,
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildContent() {
    final childSize = size ?? double.infinity;
    final imagePath = _resolveImagePath(assetPath);
    final iconSize = childSize == double.infinity ? 48.0 : childSize * 0.6;
    return SizedBox(
      width: childSize,
      height: childSize,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image_outlined,
            size: iconSize,
            color: Colors.grey.shade500,
          );
        },
      ),
    );
  }

  String _resolveImagePath(String path) {
    if (path.toLowerCase().endsWith('.glb')) {
      return path.replaceAll(RegExp(r'\.glb$', caseSensitive: false), '.png');
    }
    return path;
  }
}
