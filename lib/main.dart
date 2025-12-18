import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/sticker_book_page.dart';
import 'pages/settings_page.dart';
import 'pages/collect_page.dart';
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
  final GlobalKey<State<StickerBookPage>> _stickerBookKey = GlobalKey<State<StickerBookPage>>();

  List<Widget> get _pages => [
    StickerBookPage(key: _stickerBookKey),
    const Center(child: Text('みんなの', style: TextStyle(fontSize: 24))),
    const CollectPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _pages),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: CustomNavigationBar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  final previousIndex = _selectedIndex;
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (index == 0 && previousIndex != 0) {
                    final state = _stickerBookKey.currentState;
                    if (state != null) {
                      (state as dynamic).reloadCounts();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
