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
      appBar: AppBar(
        title: const Text('あつめる'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MenuCardButton(
              icon: Icons.casino,
              label: 'ガチャであつめる',
              color: AppColors.accentOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GachaPage()),
                );
              },
            ),
            const SizedBox(height: 40),
            _MenuCardButton(
              icon: Icons.swap_horiz,
              label: '交換であつめる',
              color: AppColors.accentBlue,
              onTap: () {
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

class _MenuCardButton extends StatelessWidget {
  const _MenuCardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
