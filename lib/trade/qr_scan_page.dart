import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:seal_app/data/sticker_master.dart';
import 'package:seal_app/services/sticker_count_store.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isScanned = false; // 連続読み取り防止フラグ
  late final StickerCountStore _countStore;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _countStore = StickerCountStore(
      stickerMasterDb.map((e) => e.assetPath).toList(),
    );
    _init();
  }

  Future<void> _init() async {
    await _countStore.loadOrInit();
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('シールをもらう / 確認スキャン')),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : MobileScanner(
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
      final String? type = data['type'];
      if (type == 'sticker_transfer' ||
          (type == null && data['asset'] != null)) {
        final String asset = data['asset'];
        final String name = (data['name'] as String?) ?? 'シール';
        _handleReceive(context, name, asset);
      } else if (type == 'transfer_confirm') {
        final String asset = data['asset'];
        _handleConfirmForSender(context, asset);
      } else {
        throw Exception('unsupported');
      }
    } catch (e) {
      // JSONじゃなかった場合などのエラー
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('シールのQRコードではありません')));
      setState(() => _isScanned = false); // ロック解除して再スキャン可能に
    }
  }

  Future<void> _handleReceive(
    BuildContext context,
    String name,
    String asset,
  ) async {
    await _countStore.inc(asset);
    if (!context.mounted) return;
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
            Text('「$name」を受け取りました！'),
            const SizedBox(height: 12),
            const Text(
              '送り主に在庫を-1してもらう場合は、\n確認QRを見せてあげてください。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 確認QR（送信者がこれを読み取ると-1される）
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: jsonEncode({'type': 'transfer_confirm', 'asset': asset}),
                version: QrVersions.auto,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('完了'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmForSender(
    BuildContext context,
    String asset,
  ) async {
    await _countStore.dec(asset);
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('送信側 在庫更新'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.remove_circle, color: Colors.redAccent, size: 60),
            SizedBox(height: 12),
            Text('相手の確認QRを受け取りました。\n在庫を1つ減らしました。', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
