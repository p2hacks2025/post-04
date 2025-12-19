import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/sticker_master.dart';
import '../../data/services/sticker_count_store.dart';
import '../widgets/sticker_tile.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  final TextEditingController _controller = TextEditingController();
  
  // シール管理用ストア
  late final StickerCountStore _countStore;
  bool _isStoreReady = false;

  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    // 1. シール管理機能の準備
    _countStore = StickerCountStore(
      stickerMasterData.map((e) => e.assetPath).toList(),
    );
    _initStore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initStore() async {
    await _countStore.loadOrInit();
    if (mounted) {
      setState(() {
        _isStoreReady = true;
      });
    }
  }

  StickerData? _findStickerByAssetPath(String assetPath) {
    try {
      return stickerMasterData.firstWhere((e) => e.assetPath == assetPath);
    } catch (_) {
      return null;
    }
  }

  // あいことば検索 ＆ 受取処理
  Future<void> _searchAndReceive() async {
    final inputPassword = _controller.text;
    if (inputPassword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // 2. Firestoreからあいことばを検索
      final snapshot = await FirebaseFirestore.instance
          .collection('trades')
          .where('password', isEqualTo: inputPassword)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _statusMessage = 'そのあいことばは見つかりませんでした...';
        });
        return;
      }

      // 見つかったデータを取り出す
      final doc = snapshot.docs.first;
      final data = doc.data();
      
      // 保存されているシールのID（assetPath）を取得
      // ※ 保存側で 'sticker_id' というキーで保存している前提
      final String? assetPath = (data['sticker_id'] as String?)?.trim();

      if (assetPath == null || assetPath.isEmpty) {
        setState(() {
          _statusMessage = '受け取るシール情報が不正です';
        });
        return;
      }

      final sticker = _findStickerByAssetPath(assetPath);
      final displayName = sticker?.name ?? 'シール';
      final displayPath = sticker?.iconPath ?? assetPath;

      // 3. 自分のシール帳に +1 する
      await _countStore.inc(assetPath);

      // 4. Firestoreからデータを削除する（「使用済み」にするため）
      await doc.reference.delete();

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
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 12),
              Text('「$displayName」を受け取りました！'),
              const SizedBox(height: 12),
              Center(
                child: StickerTile(
                  assetPath: displayPath,
                  size: 140,
                  showShadow: false,
                  forceStaticImage: true,
                  useModelViewer: false,
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
      setState(() {
        _statusMessage = 'エラーが発生しました: $e';
      });
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
            const Text(
              '友達から聞いた番号を入力してね',
              style: TextStyle(fontSize: 16),
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),

            const SizedBox(height: 20),

            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}