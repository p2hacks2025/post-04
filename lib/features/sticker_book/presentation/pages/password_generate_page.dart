import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/services/sticker_count_store.dart';
import '../../../../features/sticker_book/data/sticker_master.dart';
import '../widgets/sticker_tile.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/constants/app_colors.dart';

class PasswordGeneratePage extends StatefulWidget {
  const PasswordGeneratePage({super.key});

  @override
  State<PasswordGeneratePage> createState() => _PasswordGeneratePageState();
}

class _PasswordGeneratePageState extends State<PasswordGeneratePage> {
  late final StickerCountStore _countStore;
  List<StickerData> _catalog = [];
  bool _isStoreReady = false;

  StickerData? _selectedSticker;

  String? _generatedPassword;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    _catalog = await StickerCatalog.load();
    _countStore = StickerCountStore(
      _catalog.map((e) => e.assetPath).toList(),
    );
    await _countStore.loadOrInit();
    if (mounted) {
      setState(() {
        _isStoreReady = true;
      });
    }
  }

  List<StickerData> get _ownedStickers {
    if (!_isStoreReady) return [];
    return _catalog.where((sticker) {
      return _countStore.getCount(sticker.assetPath) > 0;
    }).toList();
  }

  Future<void> _generateAndSave() async {
    if (_selectedSticker == null) return;

    setState(() {
      _isLoading = true;
    });

    final targetSticker = _selectedSticker!;

    try {
      await _countStore.dec(targetSticker.assetPath);

      final random = Random();
      final newPassword = (1000 + random.nextInt(9000)).toString();

      await FirebaseFirestore.instance.collection('trades').add({
        'password': newPassword,
        'sticker_id': targetSticker.assetPath,
        'created_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _generatedPassword = newPassword;
      });

    } catch (e) {
      // エラーが発生した場合、シールを戻す
      await _countStore.inc(targetSticker.assetPath);
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          e,
          onRetry: () => _generateAndSave(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStoreReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_generatedPassword != null) {
      return _buildResultView();
    }

    return _buildSelectionView();
  }

  Widget _buildSelectionView() {
    final stickers = _ownedStickers;

    return Scaffold(
      appBar: AppBar(title: const Text('あげるシールを選ぶ')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '持っているシールから選んでください。\n発行すると手持ちが1枚減ります。',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: stickers.isEmpty
                ? const Center(child: Text('あげられるシールがありません...'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: stickers.length,
                    itemBuilder: (context, index) {
                      final sticker = stickers[index];
                      final isSelected = _selectedSticker == sticker;
                      final count = _countStore.getCount(sticker.assetPath);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSticker = sticker;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(color: AppColors.accentOrange, width: 4)
                                : Border.all(color: AppColors.borderLight, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: StickerTile(
                                    assetPath: sticker.iconPath,
                                    showShadow: false,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.shadowDark,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '×$count',
                                    style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 12),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Center(
                                  child: Icon(Icons.check_circle, color: AppColors.accentOrange, size: 40),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedSticker == null || _isLoading)
                    ? null
                    : _generateAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                    : const Text('あいことばを発行する', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Scaffold(
      appBar: AppBar(title: const Text('発行完了')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedSticker != null)
              SizedBox(
                height: 100,
                child: StickerTile(
                  assetPath: _selectedSticker!.iconPath,
                  size: 100,
                  showShadow: false,
                ),
              ),
            const SizedBox(height: 20),
            const Text('あなたのあいことば', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              _generatedPassword!,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                    letterSpacing: 8,
                  ),
            ),
            const SizedBox(height: 30),
            const Text(
              '友達にこの番号を入力してもらってください。\n（あなたのシールは既になくなっています）',
              textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('元の画面に戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
