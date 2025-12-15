// lib/src/screen/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../widget/presentation/orange_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OrangeButton(
            label: '部屋をつくる',
            onPressed: () {
              print("部屋をつくる処理");
              // 将来ここから Navigator.push で作成画面へ
            },
          ),
          const SizedBox(height: 80),
          OrangeButton(
            label: '部屋にはいる',
            onPressed: () {
              print("部屋にはいる処理");
            },
          ),
        ],
      ),
    );
  }
}