import 'dart:convert';
import 'package:flutter/services.dart';

import '../../domain/models/models.dart';
import '../sticker_assets.dart';

class SealMetadataService {
  static const String _metadataPath = 'assets/seals/seal_metadata.json';
  static Map<String, SealMetadata>? _cache;

  /// シールのメタデータを読み込む
  static Future<Map<String, SealMetadata>> loadMetadata() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_metadataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> sealsJson = jsonData['seals'] as List<dynamic>;

      _cache = {
        for (var sealJson in sealsJson)
          StickerAssetPaths.normalizeToPng(
            sealJson['assetPath'] as String,
          ): SealMetadata.fromJson(
            sealJson as Map<String, dynamic>,
          )
      };

      return _cache!;
    } catch (e) {
      // エラー時は空のマップを返す
      return {};
    }
  }

  /// アセットパスからシールのメタデータを取得
  static Future<SealMetadata?> getMetadata(String assetPath) async {
    final metadata = await loadMetadata();
    return metadata[StickerAssetPaths.normalizeToPng(assetPath)];
  }

  /// キャッシュをクリア
  static void clearCache() {
    _cache = null;
  }
}
