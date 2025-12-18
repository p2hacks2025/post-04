class StickerData {
  final int number; // 図鑑番号
  final String id; // システム用ID
  final String name; // 表示名
  final String assetPath; // 3Dモデル or 画像本体
  final String iconPath; // 一覧用サムネイル（無い場合は同一パス）
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

// 今あるアセット（assets/seals/*.glb）を使った暫定のマスターデータ。
// アイコン画像が無いものは assetPath と同一にしています（GLBがそのまま表示されます）。
const List<StickerData> stickerMasterDb = [
  StickerData(
    number: 1,
    id: 'heart_001',
    name: 'ハート',
    assetPath: 'assets/seals/heart.glb',
    iconPath: 'assets/seals/heart.glb',
    rarity: 1,
  ),
  StickerData(
    number: 2,
    id: 'cat_001',
    name: 'ねこ',
    assetPath: 'assets/seals/cat.glb',
    iconPath: 'assets/icons/cat.png',
    rarity: 2,
  ),
  StickerData(
    number: 3,
    id: 'circle_001',
    name: 'まる',
    assetPath: 'assets/seals/circle.glb',
    iconPath: 'assets/seals/circle.glb',
    rarity: 1,
  ),
  StickerData(
    number: 4,
    id: 'star_001',
    name: 'ほし',
    assetPath: 'assets/seals/star.glb',
    iconPath: 'assets/seals/star.glb',
    rarity: 3,
  ),
];
