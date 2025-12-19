import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../gacha/presentation/pages/gacha_page.dart';
import '../../../../features/sticker_book/presentation/pages/trade_menu_page.dart';

class CollectPage extends StatelessWidget {
  const CollectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            const SizedBox(height: 12),
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
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