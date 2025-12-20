import '../../domain/models/models.dart';
import '../sticker_master.dart';

class SealMetadataService {
  static Map<String, SealMetadata>? _cache;

  /// シールのメタデータを読み込む
  static Future<Map<String, SealMetadata>> loadMetadata() async {
    if (_cache != null) {
      return _cache!;
    }

    _cache = {
      for (final sticker in stickerMasterData)
        sticker.assetPath: SealMetadata(
          assetPath: sticker.assetPath,
          name: sticker.name,
          rarity: sticker.rarity,
        ),
    };

    return _cache!;
  }

  /// アセットパスからシールのメタデータを取得
  static Future<SealMetadata?> getMetadata(String assetPath) async {
    final metadata = await loadMetadata();
    return metadata[assetPath];
  }

  /// キャッシュをクリア
  static void clearCache() {
    _cache = null;
  }
}
