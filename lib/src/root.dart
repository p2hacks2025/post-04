// lib/src/root.dart
import 'package:flutter/material.dart';
import 'screen/main/main_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        // ここでフォント設定なども行います
      ),
      home: const MainScreen(),
    );
  }
}