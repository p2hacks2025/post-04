// lib/src/screen/main/main_screen.dart
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../sticker_book/sticker_book_screen.dart';
import '../collection/collection_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // 初期値は「あつめる(Home)」

  // 各画面の実体をリスト化
  final List<Widget> _pages = [
    const StickerBookScreen(), // Index 0
    const HomeScreen(),        // Index 1 (メイン)
    const CollectionScreen(),  // Index 2
    const SettingsScreen(),    // Index 3
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _pages[_currentIndex]),
            // ナビゲーションバー（前回作成したもの）
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(label: 'シール帳', isSelected: _currentIndex == 0, onTap: () => _onTabTapped(0)),
          _NavItem(label: 'あつめる', isSelected: _currentIndex == 1, onTap: () => _onTabTapped(1)),
          _NavItem(label: 'みんなの', isSelected: _currentIndex == 2, onTap: () => _onTabTapped(2)),
          _NavItem(label: 'せってい', isSelected: _currentIndex == 3, onTap: () => _onTabTapped(3)),
        ],
      ),
    );
  }
}

// ナビゲーションアイテム（必要なら別ファイルへ切り出し）
class _NavItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[400] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}