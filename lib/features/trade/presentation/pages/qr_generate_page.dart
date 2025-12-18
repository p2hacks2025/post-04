import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../sticker_book/data/sticker_master.dart';
import '../../../sticker_book/data/services/sticker_count_store.dart';

class QrGeneratePage extends StatefulWidget {
  const QrGeneratePage({super.key});

  @override
  State<QrGeneratePage> createState() => _QrGeneratePageState();
}

class _QrGeneratePageState extends State<QrGeneratePage> {
  late final StickerCountStore _countStore;
  late final List<StickerData> _catalog;
  bool _loading = true;

  StickerData? _selected;

  @override
  void initState() {
    super.initState();
    _catalog = List.of(stickerMasterData)..sort((a, b) => a.number.compareTo(b.number));
    _countStore = StickerCountStore(_catalog.map((e) => e.assetPath).toList());
    _init();
  }

  Future<void> _init() async {
    await _countStore.loadOrInit();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('シールをあげる')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('あげるシールを選んでください（在庫1枚以上）', style: TextStyle(fontSize: 18)),
                ),
                // シール選択リスト（在庫>=1のみ）
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _catalog
                        .where((s) => _countStore.getCount(s.assetPath) > 0)
                        .map((s) {
                      final selected = _selected?.id == s.id;
                      final count = _countStore.getCount(s.assetPath);
                      return GestureDetector(
                        onTap: () => setState(() => _selected = s),
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected ? theme.colorScheme.primary.withValues(alpha: 0.06) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? theme.colorScheme.primary : Colors.grey.shade400,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildThumb(s),
                              ),
                              const SizedBox(height: 6),
                              Text('${s.number}. ${s.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('所持: $count', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 32),
                // QRコード表示エリア
                Expanded(
                  child: Center(
                    child: _selected == null
                        ? const Text('シールを選択するとQRコードが表示されます')
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '「${_selected!.name}」をあげる',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: jsonEncode({
                                  'type': 'sticker_transfer',
                                  'id': _selected!.id,
                                  'name': _selected!.name,
                                  'asset': _selected!.assetPath,
                                  'number': _selected!.number,
                                }),
                                version: QrVersions.auto,
                                size: 260,
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  '相手にこのQRを読み取ってもらってください。\n受け取り側は「確認QR」を送り返すと、あなたの在庫も-1できます。',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildThumb(StickerData s) {
    final path = s.iconPath;
    if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.webp')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return const Icon(Icons.auto_awesome, size: 60, color: Colors.orange);
  }
}