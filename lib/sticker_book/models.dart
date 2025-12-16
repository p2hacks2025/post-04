import 'dart:ui';

class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.asset,
    required this.inventoryIndex,
    required this.position,
    required this.rotation,
    required this.size,
  });

  final String id;
  final String asset;
  final int inventoryIndex;
  final Offset position;
  final double rotation;
  final Size size;

  PlacedSticker copyWith({
    int? inventoryIndex,
    Offset? position,
    double? rotation,
    Size? size,
  }) {
    return PlacedSticker(
      id: id,
      asset: asset,
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
