import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData buildTheme() {
    final ThemeData baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC6845A)),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.zenMaruGothicTextTheme(baseTheme.textTheme),
    );
  }
}
