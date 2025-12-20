import 'package:flutter/material.dart';

import '../../../sticker_book/presentation/widgets/sticker_tile.dart';
import '../../domain/models/public_board.dart';

class StickerBoardSnapshotWidget extends StatelessWidget {
  const StickerBoardSnapshotWidget({
    super.key,
    required this.snapshot,
  });

  final PublicBoardSnapshot snapshot;

  static const double _stickerBaseSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final gradientColors = snapshot.gradientArgb.map((v) => Color(v)).toList(growable: false);

    final safeBoardWidth = snapshot.boardWidth <= 0 ? 1.0 : snapshot.boardWidth;
    final safeBoardHeight = snapshot.boardHeight <= 0 ? 1.0 : snapshot.boardHeight;

    return AspectRatio(
      aspectRatio: safeBoardWidth / safeBoardHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          final sx = w / safeBoardWidth;
          final sy = h / safeBoardHeight;
          final scale = (sx + sy) / 2.0;
          final size = _stickerBaseSize * scale;

          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors.length >= 2
                      ? gradientColors
                      : const [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  for (final s in snapshot.stickers)
                    Positioned(
                      left: s.dx * sx - size / 2,
                      top: s.dy * sy - size / 2,
                      child: Transform.rotate(
                        angle: s.rotation,
                        child: StickerTile(
                          assetPath: s.asset,
                          size: size,
                          showShadow: false,
                          forceStaticImage: false,
                          useModelViewer: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
