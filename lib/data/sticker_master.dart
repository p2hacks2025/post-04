class StickerData {
  final int number; // 図鑑番号
  final String id; // システム用ID
  final String name; // 表示名
  final String assetPath; // glb or png のパス
  final String iconPath; // png のパス
  final int rarity; // レア度（1=ノーマル〜5=レア）

  const StickerData({
    required this.number,
    required this.id,
    required this.name,
    required this.assetPath,
    required this.iconPath,
    this.rarity = 1,
  });
}

const List<StickerData> stickerMasterDb = [
  StickerData(
    number: 1,
    id: 'nikukyu_001',
    name: 'にくきゅう',
    assetPath: 'assets/seals/nikukyu.glb',
    iconPath: 'assets/seals/nikukyu.png',
    rarity: 1,
  ),
  StickerData(
    number: 2,
    id: 'cat_001',
    name: 'ねこ',
    assetPath: 'assets/seals/cat.png',
    iconPath: 'assets/seals/cat.png',
    rarity: 2,
  ),
];
