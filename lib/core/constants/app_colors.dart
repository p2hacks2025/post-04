import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== プライマリカラー =====
  static const Color primary = Color(0xFFC6845A);
  static const Color primaryLight = Color(0xFFFFE8D9);
  static const Color primaryDark = Color(0xFF8A4F34);

  // ===== セカンダリカラー =====
  static const Color secondary = Color(0xFFFFBBD1);
  static const Color secondaryLight = Color(0xFFFFF0F5);

  // ===== 背景色 =====
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ===== テキストカラー =====
  static const Color textPrimary = Color(0xFF334155);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // ===== 状態カラー =====
  static const Color success = Color(0xFF7ED9A4);
  static const Color successLight = Color(0xFFE6FFFB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ===== ボーダー・グリッド =====
  static const Color border = Color(0xFFCBD5E1);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color gridLine = Color(0xFFD9DDE3);

  // ===== カテゴリ =====
  static const Color categorySelected = Color(0xFFFFE8D9);
  static const Color categoryUnselected = Color(0xFFF1F5F9);
  static const Color categoryBorder = Color(0xFFCBD5E1);

  // ===== アクセント =====
  static const Color accentOrange = Color(0xFFFF9F40);
  static const Color accentBlue = Color(0xFF7B9CFF);
  static const Color accentPurple = Color(0xFFD888FF);

  // ===== シャドウ =====
  static const Color shadow = Color(0x1A000000); // 10% opacity
  static const Color shadowDark = Color(0x40000000); // 25% opacity

  // ===== ステッカーブック用グラデーション =====
  static const List<List<Color>> stickerBookGradients = [
    [Color(0xFFD888FF), Color(0xFFF9C4E6)],
    [Color(0xFFB2E0FF), Color(0xFFFBD3FF)],
    [Color(0xFFFFE5B5), Color(0xFFF8C4E1)],
    [Color(0xFFBFE3D0), Color(0xFFD8C8FF)],
  ];

  // ===== ガチャ用 =====
  static const Color gachaBoxGradientStart = Color(0xFFFFD9A8);
  static const Color gachaBoxGradientEnd = Color(0xFFFFBBD1);
  static const Color gachaGlow = Color(0xFFE91E63);

  // ===== ヘルパーメソッド =====
  /// エラーSnackBar用の色
  static Color get errorSnackBar => error;

  /// 成功SnackBar用の色
  static Color get successSnackBar => success;

  /// 警告SnackBar用の色
  static Color get warningSnackBar => warning;

  /// 情報SnackBar用の色
  static Color get infoSnackBar => info;
}
