import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // UID確認用

// 同じフォルダにあるはずの2つの画面をインポート
import 'password_generate_page.dart';
import 'password_input_page.dart';

class TradeMenuPage extends StatelessWidget {
  const TradeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 現在のユーザーUIDを取得（デバッグ・確認用）
    // final user = FirebaseAuth.instance.currentUser;
    // final uid = user?.uid ?? 'ログインしていません';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // 全体の背景色（クリーム色）
      appBar: AppBar(
        title: const Text(
          'シール交換',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFC6845A), // 茶色っぽいオレンジ
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 上のボタン：シールをあげる
            _MenuButton(
              icon: Icons.vpn_key, // 鍵アイコン
              label: 'シールをあげる\n(あいことばを発行)',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordGeneratePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // 下のボタン：シールをもらう
            _MenuButton(
              icon: Icons.keyboard, // 入力アイコン
              label: 'シールをもらう\n(あいことばを入力)',
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordInputPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // child: SelectableText(
              //   uid,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     color: Colors.grey,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 12,
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}

// ボタンの見た目を定義するクラス（このファイル内だけで使うのでprivate）
class _MenuButton extends StatelessWidget {
  const _MenuButton({
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
          // withValuesに変更して警告を回避
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
