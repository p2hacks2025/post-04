import 'package:flutter/material.dart';

/// カラーパレット（背景用）
class NameplateColors {
  static const List<Color> backgroundColors = [
    Color(0xFFFFE6F0), // bg.pink
    Color(0xFFEAF6FF), // bg.blue
    Color(0xFFFFF4D6), // bg.yellow
    Color(0xFFE9F7EF), // bg.green
    Color(0xFFF2ECFF), // bg.purple
  ];

  static const Color accentPrimary = Color(0xFFFF6FAE);
  static const Color accentSecondary = Color(0xFF7B9CFF);
  static const Color accentSuccess = Color(0xFF7ED9A4);

  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color textSubtle = Color(0xFF9A9A9A);
}

/// デコレーションの最大数
const int maxDecorations = 10;

/// 名前の最大文字数（ひらがな5文字）
const int maxNameLength = 5;
