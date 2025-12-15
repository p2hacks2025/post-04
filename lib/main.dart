import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/sticker_book_page.dart';
import 'widgets/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seal App',
      theme: _buildTheme(),
      home: const MainScreen(),
    );
  }

  ThemeData _buildTheme() {
    final ThemeData baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC6845A)),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.zenMaruGothicTextTheme(baseTheme.textTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StickerBookPage(),
    const Center(child: Text('みんなの', style: TextStyle(fontSize: 24))),
    const Center(child: Text('こうかん', style: TextStyle(fontSize: 24))),
    const Center(child: Text('せってい', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: CustomNavigationBar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
