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
}

class InventoryPayload {
  const InventoryPayload({required this.asset, required this.slotIndex});

  final String asset;
  final int slotIndex;
}
