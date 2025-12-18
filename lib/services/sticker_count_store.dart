import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StickerCountStore {
  StickerCountStore(this._catalogAssets);

  static const _fileName = 'sticker_counts.json';
  final List<String> _catalogAssets; // カタログ順のアセットパス
  Map<String, int> _counts = {};

  Map<String, int> get counts => _counts;
  //シール数の読み込み
  Future<void> loadOrInit({int defaultCount = 1}) async {
  // Future<void> loadOrInit({int defaultCount = 0, bool forceReset = false}) async {
    final file = await _getFile();
    if (await file.exists()) {
    // if (await file.exists() && !forceReset) {
      try {
        final jsonMap = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final map = (jsonMap['counts'] as Map<String, dynamic>?) ?? {};
        _counts = {
          for (final a in _catalogAssets)
            a: (map[a] as num?)?.toInt() ?? 0,
        };
        return;
      } catch (_) {}
    }
    // 初期化（全カタログを defaultCount で初期化）
    _counts = {
      for (final a in _catalogAssets) a: defaultCount,
    };
    await save();
  }

  /// 保存済みの在庫ファイルを削除（次回 loadOrInit で defaultCount で再作成されます）
  Future<void> deleteSavedFile() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// すべての在庫を指定値にリセットして保存（開発・デバッグ用）
  Future<void> resetAllTo(int value) async {
    _counts = {for (final a in _catalogAssets) a: value};
    await save();
  }

  Future<void> save() async {
    final file = await _getFile();
    final data = {
      'counts': _counts,
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  int getCount(String assetPath) => _counts[assetPath] ?? 0;

  Future<void> setCount(String assetPath, int value) async {
    _counts[assetPath] = value < 0 ? 0 : value;
    await save();
  }

  Future<void> inc(String assetPath) async {
    _counts[assetPath] = (_counts[assetPath] ?? 0) + 1;
    await save();
  }

  Future<void> dec(String assetPath) async {
    final v = (_counts[assetPath] ?? 0) - 1;
    _counts[assetPath] = v < 0 ? 0 : v;
    await save();
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}
