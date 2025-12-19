import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/navigation_bar.dart';
import 'features/collect/presentation/pages/collect_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/sticker_book/presentation/pages/sticker_book_page.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 追加
import 'firebase_options.dart'; // 自動生成されたファイルをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    return AppTheme.buildTheme();
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
      backgroundColor: AppColors.background,
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
