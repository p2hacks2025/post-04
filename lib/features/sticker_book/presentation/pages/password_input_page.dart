import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/sticker_master.dart';
import '../../data/services/sticker_count_store.dart';
import '../widgets/sticker_tile.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/constants/app_colors.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  final TextEditingController _controller = TextEditingController();

  // シール管理用ストア
  late final StickerCountStore _countStore;
  List<StickerData> _catalog = [];
  bool _isStoreReady = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. シール管理機能の準備
    _initStore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  StickerData? _findStickerByAssetPath(String assetPath) {
    try {
      return _catalog.firstWhere((e) => e.assetPath == assetPath);
    } catch (_) {
      return null;
    }
  }

  // あいことば検索 ＆ 受取処理
  Future<void> _searchAndReceive() async {
    final inputPassword = _controller.text.trim();
    if (inputPassword.isEmpty) {
      ErrorHandler.showWarningSnackBar(context, 'あいことばを入力してください');
      return;
    }

    // 4桁の数字チェック
    if (!RegExp(r'^\d{4}$').hasMatch(inputPassword)) {
      ErrorHandler.showWarningSnackBar(context, 'あいことばは4桁の数字です');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Firestoreからあいことばを検索
      final snapshot = await FirebaseFirestore.instance
          .collection('trades')
          .where('password', isEqualTo: inputPassword)
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ErrorHandler.showWarningSnackBar(
          context,
          'そのあいことばは見つかりませんでした\nもう一度確認してください',
        );
        return;
      }

      // 見つかったデータを取り出す
      final doc = snapshot.docs.first;
      final data = doc.data();

      // 保存されているシールのID（assetPath）を取得
      // ※ 保存側で 'sticker_id' というキーで保存している前提
      final String? assetPath = (data['sticker_id'] as String?)?.trim();

      if (assetPath == null || assetPath.isEmpty) {
        if (!mounted) return;
        ErrorHandler.showErrorSnackBar(context, 'あいことばは使用済みか無効です');
        return;
      }

      final normalizedAsset = StickerCatalog.normalizeAssetPath(assetPath);
      final sticker = _findStickerByAssetPath(normalizedAsset);
      final displayName = sticker?.name ?? 'シール';
      final displayPath = sticker?.iconPath ?? normalizedAsset;

      // 3. 自分のシール帳に +1 する
      await _countStore.inc(normalizedAsset);

      // 4. Firestoreからデータを削除する（「使用済み」にするため）
      try {
        await doc.reference.delete();
      } catch (deleteError) {
        debugPrint('Trade削除エラー: $deleteError');
      }

      if (!mounted) return;

      // 5. 成功ダイアログを表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('シールゲット！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 60),
              const SizedBox(height: 12),
              Text('「$displayName」を受け取りました！'),
              const SizedBox(height: 12),
              Center(
                child: StickerTile(
                  assetPath: displayPath,
                  size: 140,
                  showShadow: false,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // 前の画面に戻る
              },
              child: const Text('完了'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        onRetry: () => _searchAndReceive(),
      );
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
    // ストアの準備ができるまではローディング
    if (!_isStoreReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('あいことば入力')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('友達から聞いた番号を入力してね', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '0000',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _searchAndReceive, // ボタンを押すと検索＆受取
                icon: const Icon(Icons.download),
                label: const Text('シールを受け取る'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
