import 'package:flutter/material.dart';

import '../../../sticker_book/presentation/widgets/sticker_tile.dart';
import '../../domain/models/public_board.dart';

class StickerBoardSnapshotWidget extends StatelessWidget {
  const StickerBoardSnapshotWidget({super.key, required this.snapshot});

  final PublicBoardSnapshot snapshot;

  static const double _stickerBaseSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final gradientColors = snapshot.gradientArgb
        .map((v) => Color(v))
        .toList(growable: false);

    final safeBoardWidth = snapshot.boardWidth <= 0 ? 1.0 : snapshot.boardWidth;
    final safeBoardHeight = snapshot.boardHeight <= 0
        ? 1.0
        : snapshot.boardHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final boardHeight = 480.0;
        final boardWidth = availableWidth - 32.0;

        final originalAspectRatio = safeBoardWidth / safeBoardHeight;
        final displayWidth = boardWidth;
        final displayHeight = boardWidth / originalAspectRatio;

        final finalWidth = displayHeight > boardHeight
            ? boardHeight * originalAspectRatio
            : displayWidth;
        final finalHeight = displayHeight > boardHeight
            ? boardHeight
            : displayHeight;

        final sx = finalWidth / safeBoardWidth;
        final sy = finalHeight / safeBoardHeight;
        final scale = (sx + sy) / 2.0;
        final size = _stickerBaseSize * scale;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: finalWidth,
          height: finalHeight,
          child: ClipRRect(
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
                          padding: EdgeInsets.only(left: 12 * scale),
                          child: SizedBox(
                            width: 32 * scale,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                6,
                                (_) => SizedBox(
                                  width: 16 * scale,
                                  height: 16 * scale,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 0,
                                        ),
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
                          forceStaticImage: true,
                          useModelViewer: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
