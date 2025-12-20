import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/models.dart';
import '../sticker_assets.dart';

/// シール帳のデータを管理するクラス
class StickerBookData {
  StickerBookData({
    required this.inventorySlots,
    required this.placedByPage,
  });

  final List<String?> inventorySlots;
  final List<List<PlacedSticker>> placedByPage;

  Map<String, dynamic> toJson() {
    return {
      'inventorySlots': inventorySlots,
      'placedByPage': placedByPage
          .map((page) => page.map((sticker) => sticker.toJson()).toList())
          .toList(),
    };
  }

  factory StickerBookData.fromJson(Map<String, dynamic> json) {
    return StickerBookData(
      inventorySlots: (json['inventorySlots'] as List?)
              ?.map((e) => e as String?)
              .toList() ??
          [],
      placedByPage: (json['placedByPage'] as List?)
              ?.map((page) => (page as List)
                  .map((sticker) => PlacedSticker.fromJson(
                      sticker as Map<String, dynamic>))
                  .toList())
              .toList() ??
          [],
    );
  }

  factory StickerBookData.empty({required int inventorySize, required int pageCount}) {
    return StickerBookData(
      inventorySlots: List<String?>.filled(inventorySize, null),
      placedByPage: List.generate(pageCount, (_) => <PlacedSticker>[]),
    );
  }
}

/// シール帳のデータを永続化するサービス
class StickerBookStorage {
  static const String _fileName = 'sticker_book_data.json';

  /// データを保存する
  static Future<void> saveData(StickerBookData data) async {
    try {
      final file = await _getLocalFile();
      final jsonString = jsonEncode(data.toJson());
      await file.writeAsString(jsonString);
      debugPrint('シール帳データを保存しました');
    } catch (e) {
      debugPrint('データ保存エラー: $e');
    }
  }

  /// データを読み込む
  static Future<StickerBookData?> loadData({
    required int defaultInventorySize,
    required int defaultPageCount,
  }) async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        debugPrint('保存データが見つかりません。初期データを返します。');
        return null;
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = StickerBookData.fromJson(json);
      final normalized = _normalizeAssetPaths(data);

      // データの整合性をチェック
      if (normalized.inventorySlots.length != defaultInventorySize ||
          normalized.placedByPage.length != defaultPageCount) {
        debugPrint('データのサイズが一致しません。初期データを返します。');
        return null;
      }

      debugPrint('シール帳データを読み込みました');
      return normalized;
    } catch (e) {
      debugPrint('データ読み込みエラー: $e');
      return null;
    }
  }

  /// データを削除する（リセット用）
  static Future<void> clearData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        await file.delete();
        debugPrint('シール帳データを削除しました');
      }
    } catch (e) {
      debugPrint('データ削除エラー: $e');
    }
  }

  /// ローカルファイルのパスを取得
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static StickerBookData _normalizeAssetPaths(StickerBookData data) {
    final slots = data.inventorySlots
        .map((asset) => asset == null ? null : StickerAssetPaths.normalizeToPng(asset))
        .toList(growable: false);
    final pages = data.placedByPage
        .map((page) => page
            .map((sticker) => sticker.copyWith(
                  displayAsset: sticker.displayAsset == null
                      ? null
                      : StickerAssetPaths.normalizeToPng(sticker.displayAsset!),
                ))
            .map((sticker) => PlacedSticker(
                  id: sticker.id,
                  asset: StickerAssetPaths.normalizeToPng(sticker.asset),
                  displayAsset: sticker.displayAsset,
                  inventoryIndex: sticker.inventoryIndex,
                  position: sticker.position,
                  rotation: sticker.rotation,
                  size: sticker.size,
                ))
            .toList(growable: false))
        .toList(growable: false);
    return StickerBookData(inventorySlots: slots, placedByPage: pages);
  }
}
