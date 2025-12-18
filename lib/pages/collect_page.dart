import 'package:flutter/material.dart';
import 'package:seal_app/trade/trade_menu_page.dart';
import 'package:seal_app/pages/gacha_page.dart';

class CollectPage extends StatelessWidget {
  const CollectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CollectButton(
              label: 'ガチャであつめる',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GachaPage()),
                );
              },
            ),
            // Container(
            //   width: 4,
            //   height: 4,
            //   decoration: const BoxDecoration(
            //     color: Color(0xFFC6845A),
            //     shape: BoxShape.circle,
            //   ),
            // ),
            const SizedBox(height: 28),
            _CollectButton(
              label: '交換であつめる',
              onPressed: () {
                // 交換メニューへ遷移（QR生成/読み取りなど）
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TradeMenuPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectButton extends StatelessWidget {
  const _CollectButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC6845A),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
