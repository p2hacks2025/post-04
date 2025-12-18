import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _goHome() => Navigator.of(context).pushReplacementNamed('/home');

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _goHome,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Stack(
          children: [
            const _CandyBackdrop(),
            IgnorePointer(child: _StickerConfetti(controller: _c)),
            Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = (sin(_c.value * pi) + 1) / 2; // 0..1
                  final floatY = lerpDouble(8, -8, t)!;
                  return Transform.translate(
                    offset: Offset(0, floatY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // _LogoCard(glow: 0.12 + t * 0.18),
                        const SizedBox(height: 18),
                        const Text(
                          'Sticker Swap',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            color: Color(0xFF4C3B66),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '集めて、交換して、シール帳にぺたっ。',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4C3B66).withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _TapStartPill(pulse: t),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandyBackdrop extends StatelessWidget {
  const _CandyBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFFFFBFF)),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD9F2), // pink
                Color(0xFFE7E2FF), // lilac
                Color(0xFFD7F7FF), // baby blue
              ],
            ),
          ),
        ),
        // ふわっと光る丸
        Positioned(
          left: -120,
          top: -140,
          child: _GlowBlob(color: const Color(0xFFFFF3B0), size: 320),
        ),
        Positioned(
          right: -120,
          bottom: -160,
          child: _GlowBlob(color: const Color(0xFFFFB3D9), size: 360),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.00),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// class _LogoCard extends StatelessWidget {
//   final double glow;
//   const _LogoCard({required this.glow});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 260,
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.82),
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: const Color(0x334C3B66)),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFFF5FAE).withValues(alpha: glow),
//             blurRadius: 28,
//             spreadRadius: 2,
//             offset: const Offset(0, 12),
//           ),
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // ロゴ風バッジ（ステッカーっぽい）
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFEAF6),
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: const Color(0x33FF5FAE), width: 1.2),
//             ),
//             child: const Center(
//               child: Icon(
//                 Icons.auto_awesome_rounded,
//                 size: 34,
//                 color: Color(0xFFFF5FAE),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'シールを\n集めて、交換して、のこそう。',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                      height: 1.12,
//                     color: Color(0xFF4C3B66),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   '',
//                   style: TextStyle(
//                     height: 1.2,
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF4C3B66).withValues(alpha: 0.65),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _TapStartPill extends StatelessWidget {
  final double pulse; // 0..1
  const _TapStartPill({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final scale = 0.98 + pulse * 0.04;
    final a = 0.78 + pulse * 0.18;

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF5FAE).withValues(alpha: a),
              const Color(0xFF7C5CFF).withValues(alpha: a),
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5FAE).withValues(alpha: 0.25 + pulse * 0.20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.touch_app_rounded, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'タップでスタート',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerConfetti extends StatelessWidget {
  final AnimationController controller;
  const _StickerConfetti({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        painter: _StickerPainter(t: controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _StickerPainter extends CustomPainter {
  final double t; // 0..1
  _StickerPainter({required this.t});

  final _rng = const _Seeded(42);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // “散らしたステッカー”の位置（固定）
    final items = <_Sticker>[
      _Sticker(0.12, 0.18, 26, 12, const Color(0xFFFFE27A), Icons.star_rounded),
      _Sticker(0.86, 0.16, 24, -10, const Color(0xFFB9F0FF), Icons.favorite_rounded),
      _Sticker(0.10, 0.78, 28, -14, const Color(0xFFFFB3D9), Icons.local_florist_rounded),
      _Sticker(0.88, 0.78, 30, 10, const Color(0xFFC9FFB8), Icons.bolt_rounded),
      _Sticker(0.22, 0.42, 18, 8, const Color(0xFFE7E2FF), Icons.auto_awesome_rounded),
      _Sticker(0.78, 0.45, 20, -6, const Color(0xFFFFD9F2), Icons.music_note_rounded),
    ];

    for (final s in items) {
      final wobble = sin((t * 2 * pi) + s.x * 7 + s.y * 5) * 6;
      final cx = s.x * size.width;
      final cy = s.y * size.height + wobble;

      final r = Rect.fromCenter(center: Offset(cx, cy), width: s.size * 2.2, height: s.size * 2.2);
      final rot = (s.rotDeg * pi / 180) + sin((t * 2 * pi) + s.x * 9) * 0.06;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.translate(-cx, -cy);

      // ステッカー台紙（丸角）
      final paint = Paint()
        ..color = s.color.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;

      final shadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      final rr = RRect.fromRectAndRadius(r, const Radius.circular(18));
      canvas.drawRRect(rr.shift(const Offset(0, 10)), shadow);
      canvas.drawRRect(rr, paint);

      // キラッとハイライト
      final hi = Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.fill;
      final hiR = Rect.fromCenter(center: Offset(cx - 10, cy - 10), width: s.size * 1.2, height: s.size * 0.7);
      canvas.drawRRect(RRect.fromRectAndRadius(hiR, const Radius.circular(12)), hi);

      // アイコン
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(s.icon.codePoint),
          style: TextStyle(
            fontSize: s.size * 1.25,
            fontFamily: s.icon.fontFamily,
            package: s.icon.fontPackage,
            color: const Color(0xFF4C3B66).withValues(alpha: 0.72),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        Offset(cx - iconPainter.width / 2, cy - iconPainter.height / 2),
      );

      canvas.restore();
    }

    // ふんわりドット（軽量）
    final p = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 18; i++) {
      final x = _rng.next(i * 2) * size.width;
      final y = _rng.next(i * 2 + 1) * size.height;
      final a = 0.03 + 0.05 * (sin((t * 2 * pi) + i) + 1) / 2;
      p.color = const Color(0xFF4C3B66).withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.6, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StickerPainter oldDelegate) => oldDelegate.t != t;
}

class _Sticker {
  final double x, y;
  final double size;
  final double rotDeg;
  final Color color;
  final IconData icon;
  _Sticker(this.x, this.y, this.size, this.rotDeg, this.color, this.icon);
}

/// 疑似乱数（固定）—毎回同じ見た目
class _Seeded {
  final int seed;
  const _Seeded(this.seed);

  double next(int n) {
    // 0..1
    final v = sin((seed + n) * 999.97) * 10000;
    return v - v.floorToDouble();
  }
}
