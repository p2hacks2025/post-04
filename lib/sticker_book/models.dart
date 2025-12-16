import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

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

// 1. Firebaseの「stickers」コレクションのデータを受け取る型
class StickerMaster {
  final String id;
  final int orderIndex;   // 図鑑番号
  final String name;
  final String image;
  final String category;

  StickerMaster({
    required this.id,
    required this.orderIndex,
    required this.name,
    required this.image,
    required this.category,
  });

  // Firestoreのドキュメントから変換する工場
  factory StickerMaster.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StickerMaster(
      id: doc.id,
      orderIndex: data['index'] ?? 999, // データがない場合は後ろへ
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      category: data['category'] ?? 'その他',
    );
  }
}

// 2. 画面表示用に「マスタ」と「持ってるか」をセットにした型（下駄箱の1マス）
class StickerSlotData {
  final StickerMaster? master; // そのマスに入るべきシール情報
  final bool hasSticker;       // 持っているか？

  StickerSlotData({this.master, this.hasSticker = false});
}