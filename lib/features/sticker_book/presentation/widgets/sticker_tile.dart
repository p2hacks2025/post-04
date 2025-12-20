import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class StickerTile extends StatelessWidget {
  const StickerTile({
    super.key,
    required this.assetPath,
    this.size,
    this.showShadow = true,
    this.showBackground = true,
    this.forceStaticImage = false,
    this.useModelViewer = true,
  });

  final String assetPath;
  final double? size;
  final bool showShadow;
  final bool showBackground;
  final bool forceStaticImage;
  final bool useModelViewer;

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

    final isGlb = assetPath.toLowerCase().endsWith('.glb');
    final useModelForGlb = isGlb && useModelViewer && !forceStaticImage;
    final glbLike = isGlb;
    final bgColor = (!showBackground || useModelForGlb || glbLike)
        ? Colors.transparent
        : Colors.white;
    final padding = (!showBackground || useModelForGlb || glbLike)
        ? EdgeInsets.zero
        : const EdgeInsets.all(8);
    final effectiveShadow = (!showBackground || useModelForGlb || glbLike)
        ? <BoxShadow>[]
        : boxShadow;

    final child = _buildContent();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: effectiveShadow,
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _buildContent() {
    final isGlb = assetPath.toLowerCase().endsWith('.glb');
    final childSize = size ?? double.infinity;
    if (isGlb && !forceStaticImage && useModelViewer) {
      return SizedBox(
        width: childSize,
        height: childSize,
        child: IgnorePointer(
          ignoring: true,
          child: ModelViewer(
            src: assetPath,
            alt: '3D sticker',
            autoRotate: false,
            disableZoom: true,
            cameraControls: false,
            backgroundColor: Colors.transparent,
            interactionPrompt: InteractionPrompt.none,
          ),
        ),
      );
    }
    if (isGlb || forceStaticImage) {
      final iconSize = childSize == double.infinity ? 48.0 : childSize * 0.6;
      final previewPath = assetPath.replaceAll(
        RegExp(r'\.glb$', caseSensitive: false),
        '.png',
      );
      return SizedBox(
        width: childSize,
        height: childSize,
        child: Image.asset(
          previewPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.threed_rotation,
              size: iconSize,
              color: Colors.grey.shade500,
            );
          },
        ),
      );
    }
    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(assetPath, filterQuality: FilterQuality.high),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(assetPath, filterQuality: FilterQuality.high),
        ),
      ],
    );
  }
}
