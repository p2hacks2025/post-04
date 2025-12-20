import 'dart:convert';
import 'package:flutter/services.dart';

import 'sticker_assets.dart';
import 'services/seal_metadata_service.dart';

class StickerData {
  final int number;
  final String id;
  final String name;
  final String assetPath;
  final String iconPath;
  final int rarity;
  final double? size;

  const StickerData({
    required this.number,
    required this.id,
    required this.name,
    required this.assetPath,
    required this.iconPath,
    this.rarity = 1,
    this.size,
  });
}

class StickerCatalog {
  static const String _manifestPath = 'AssetManifest.json';
  static List<StickerData>? _cache;
  static Set<String>? _pngAssets;
  static Set<String>? _glbAssets;

  static Future<List<StickerData>> load() async {
    if (_cache != null) return _cache!;

    final pngAssets = await _loadPngAssets();
    final metadata = await SealMetadataService.loadMetadata();
    var number = 1;

    final list = pngAssets.map((path) {
      final meta = metadata[path];
      final id = StickerAssetPaths.baseName(path);
      return StickerData(
        number: number++,
        id: id,
        name: meta?.name ?? id,
        assetPath: path,
        iconPath: path,
        rarity: meta?.rarity ?? 1,
        size: meta?.size,
      );
    }).toList(growable: false);

    _cache = list;
    return list;
  }

  static Future<List<String>> loadAssetPaths() async {
    final list = await load();
    return list.map((e) => e.assetPath).toList(growable: false);
  }

  static Future<bool> hasGlbForPng(String pngPath) async {
    await _loadGlbAssets();
    final glbPath = StickerAssetPaths.toGlb(pngPath);
    if (_glbAssets!.contains(glbPath)) return true;
    try {
      await rootBundle.load(glbPath);
      _glbAssets!.add(glbPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String glbPathForPng(String pngPath) =>
      StickerAssetPaths.toGlb(pngPath);

  static String normalizeAssetPath(String path) =>
      StickerAssetPaths.normalizeToPng(path);

  static void clearCache() {
    _cache = null;
    _pngAssets = null;
    _glbAssets = null;
    SealMetadataService.clearCache();
  }

  static Future<List<String>> _loadPngAssets() async {
    await _loadManifestAssets();
    if (_pngAssets!.isEmpty) {
      final metadata = await SealMetadataService.loadMetadata();
      final fromMeta = metadata.keys.where((path) {
        return StickerAssetPaths.isSealAsset(path) &&
            StickerAssetPaths.isPng(path);
      }).toSet();
      if (fromMeta.isNotEmpty) {
        _pngAssets = fromMeta;
      }
    }
    return _pngAssets!.toList()..sort();
  }

  static Future<void> _loadManifestAssets() async {
    if (_pngAssets != null && _glbAssets != null) return;

    try {
      final jsonString = await rootBundle.loadString(_manifestPath);
      final Map<String, dynamic> manifest = jsonDecode(jsonString);
      final keys = manifest.keys;

      _pngAssets = {
        for (final path in keys)
          if (StickerAssetPaths.isSealAsset(path) &&
              StickerAssetPaths.isPng(path))
            path,
      };

      _glbAssets = {
        for (final path in keys)
          if (StickerAssetPaths.isSealAsset(path) &&
              StickerAssetPaths.isGlb(path))
            path,
      };
    } catch (_) {
      _pngAssets = <String>{};
      _glbAssets = <String>{};
    }
  }

  static Future<void> _loadGlbAssets() async {
    await _loadManifestAssets();
  }
}
