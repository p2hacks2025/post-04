import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isScanned = false; // 連続読み取り防止フラグ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('シールをもらう')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return; // 既に読んでたら無視
          
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _onDetect(context, barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }

  void _onDetect(BuildContext context, String jsonString) {
    setState(() => _isScanned = true); // ロックする

    try {
      final data = jsonDecode(jsonString);
      final String name = data['name'];
      
      // ★ここで本来は自分のインベントリに追加する処理を書く
      // (今回はダイアログを出すだけ)

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('シールゲット！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text('「$name」を受け取りました！'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // ダイアログ閉じる
                Navigator.of(context).pop(); // スキャン画面も閉じる
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // JSONじゃなかった場合などのエラー
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('シールのQRコードではありません')),
      );
      setState(() => _isScanned = false); // ロック解除して再スキャン可能に
    }
  }
}