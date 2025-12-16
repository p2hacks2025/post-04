import 'package:flutter/material.dart';

class StickerTile extends StatelessWidget {
  const StickerTile({
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (size != null)
            SizedBox(
              width: size,
              height: size,
              child: Image.asset(assetPath, filterQuality: FilterQuality.high),
            )
          else
            Expanded(
              child: Image.asset(assetPath, filterQuality: FilterQuality.high),
            ),
        ],
      ),
    );
  }
}
