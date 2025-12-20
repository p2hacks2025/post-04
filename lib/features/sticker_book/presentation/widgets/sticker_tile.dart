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
    const boxShadow = <BoxShadow>[];
    final padding = const EdgeInsets.all(0);

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: boxShadow,
    );

    final imagePath = _resolveImagePath(assetPath);
    final iconSize = size != null ? size! * 0.6 : 48.0;

    Widget imageWidget;
    if (size != null) {
      imageWidget = SizedBox(
        width: size,
        height: size,
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
    } else {
      imageWidget = Image.asset(
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
      );
    }

    final content = Container(
      width: size,
      height: size,
      decoration: decoration,
      padding: padding,
      alignment: Alignment.center,
      child: imageWidget,
    );

    return content;
  }

  String _resolveImagePath(String path) {
    if (path.toLowerCase().endsWith('.glb')) {
      return path.replaceAll(RegExp(r'\.glb$', caseSensitive: false), '.png');
    }
    return path;
  }
}
