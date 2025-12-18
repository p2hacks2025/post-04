import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
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
    return GestureDetector(
      onTap: _goHome,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Stack(
          children: [
            const _CandyBackdrop(),
            IgnorePointer(child: _StickerConfetti(controller: _c)),

            SafeArea(
              // ← 追加：ノッチ等を除いた領域で中央
              child: Center(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final t = (sin(_c.value * pi) + 1) / 2;
                    final floatY = lerpDouble(8, -8, t)!;
                    final lift = -10.0; // 全体を少し上に持ち上げる

                    return Transform.translate(
                      offset: Offset(0, floatY + lift),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          const Text(
                            'タイトル未定',
                            textAlign: TextAlign.center,
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
                            textAlign: TextAlign.center, // ← 明示
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFF4C3B66,
                              ).withValues(alpha: 0.65),
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
              color: const Color(
                0xFFFF5FAE,
              ).withValues(alpha: 0.25 + pulse * 0.20),
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


  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // “散らしたステッカー”の位置（固定）
    final items = <_Sticker>[
      _Sticker(0.12, 0.18, 26, 12, const Color(0xFFFFE27A), Icons.star_rounded),
      _Sticker(
        0.86,
        0.16,
        24,
        -10,
        const Color(0xFFB9F0FF),
        Icons.favorite_rounded,
      ),
      _Sticker(
        0.10,
        0.78,
        28,
        -14,
        const Color(0xFFFFB3D9),
        Icons.local_florist_rounded,
      ),
      _Sticker(0.88, 0.78, 30, 10, const Color(0xFFC9FFB8), Icons.bolt_rounded),
      _Sticker(
        0.20,
        0.42,
        18,
        8,
        const Color(0xFFE7E2FF),
        Icons.auto_awesome_rounded,
      ),
      _Sticker(
        0.83,
        0.45,
        20,
        -6,
        const Color(0xFFFFD9F2),
        Icons.music_note_rounded,
      ),
    ];

    for (final s in items) {
      final wobble = sin((t * 2 * pi) + s.x * 7 + s.y * 5) * 6;
      final cx = s.x * size.width;
      final cy = s.y * size.height + wobble;

      final r = Rect.fromCenter(
        center: Offset(cx, cy),
        width: s.size * 2.2,
        height: s.size * 2.2,
      );
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


  }

  @override
  bool shouldRepaint(covariant _StickerPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _Sticker {
  final double x, y;
  final double size;
  final double rotDeg;
  final Color color;
  final IconData icon;
  _Sticker(this.x, this.y, this.size, this.rotDeg, this.color, this.icon);
}
