import 'dart:ui';

class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.asset,
    this.displayAsset,
    required this.inventoryIndex,
    required this.position,
    required this.rotation,
    required this.size,
  });

  final String id;
  final String asset;
  final String? displayAsset; // 表示用（PNGなど）。未指定なら asset を使用
  final int inventoryIndex;
  final Offset position;
  final double rotation;
  final Size size;

  PlacedSticker copyWith({
    int? inventoryIndex,
    Offset? position,
    double? rotation,
    Size? size,
    String? displayAsset,
  }) {
    return PlacedSticker(
      id: id,
      asset: asset,
      displayAsset: displayAsset ?? this.displayAsset,
      inventoryIndex: inventoryIndex ?? this.inventoryIndex,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset': asset,
      'displayAsset': displayAsset,
      'inventoryIndex': inventoryIndex,
      'position': {'dx': position.dx, 'dy': position.dy},
      'rotation': rotation,
      'size': {'width': size.width, 'height': size.height},
    };
  }

  factory PlacedSticker.fromJson(Map<String, dynamic> json) {
    return PlacedSticker(
      id: json['id'] as String,
      asset: json['asset'] as String,
      displayAsset: json['displayAsset'] as String?,
      inventoryIndex: json['inventoryIndex'] as int,
      position: Offset(
        (json['position'] as Map<String, dynamic>)['dx'] as double,
        (json['position'] as Map<String, dynamic>)['dy'] as double,
      ),
      rotation: (json['rotation'] as num).toDouble(),
      size: Size(
        (json['size'] as Map<String, dynamic>)['width'] as double,
        (json['size'] as Map<String, dynamic>)['height'] as double,
      ),
    );
  }
}

class InventoryPayload {
  const InventoryPayload({required this.asset, required this.slotIndex});

  final String asset;
  final int slotIndex;
}

class SealMetadata {
  const SealMetadata({
    required this.assetPath,
    required this.name,
    required this.rarity,
  });

  final String assetPath;
  final String name;
  final int rarity; // 1-5

  factory SealMetadata.fromJson(Map<String, dynamic> json) {
    return SealMetadata(
      assetPath: json['assetPath'] as String,
      name: json['name'] as String,
      rarity: json['rarity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'name': name,
      'rarity': rarity,
    };
  }
}
