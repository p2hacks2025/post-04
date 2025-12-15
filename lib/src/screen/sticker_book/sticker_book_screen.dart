import 'package:flutter/material.dart';

class StickerBookScreen extends StatelessWidget {
  const StickerBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'シール帳の画面',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}