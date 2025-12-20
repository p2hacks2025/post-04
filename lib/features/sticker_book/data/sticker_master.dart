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
const List<StickerData> stickerMasterData = [
  StickerData(
    number: 5,
    id: 'heart_blue_holo_001',
    name: 'ハート（ブルーホロ）',
    assetPath: 'assets/seals/hurt_blue_holo.glb',
    iconPath: 'assets/seals/hurt_blue_holo.png',
    rarity: 3,
  ),
  StickerData(
    number: 6,
    id: 'heart_green_holo_001',
    name: 'ハート（グリーンホロ）',
    assetPath: 'assets/seals/hurt_gre_holo.glb',
    iconPath: 'assets/seals/hurt_gre_holo.png',
    rarity: 3,
  ),
  StickerData(
    number: 7,
    id: 'heart_pink_holo_001',
    name: 'ハート（ピンクホロ）',
    assetPath: 'assets/seals/hurt_pink_holo.glb',
    iconPath: 'assets/seals/hurt_pink_holo.png',
    rarity: 3,
  ),
  StickerData(
    number: 8,
    id: 'heart_purple_holo_001',
    name: 'ハート（パープルホロ）',
    assetPath: 'assets/seals/hurt_pur_holo.glb',
    iconPath: 'assets/seals/hurt_pur_holo.png',
    rarity: 3,
  ),
  StickerData(
    number: 9,
    id: 'heart_yellow_holo_001',
    name: 'ハート（イエローホロ）',
    assetPath: 'assets/seals/hurt_yell_holo.glb',
    iconPath: 'assets/seals/hurt_yell_holo.png',
    rarity: 3,
  ),
  StickerData(
    number: 10,
    id: 'star_black_001',
    name: 'ほし（ブラック）',
    assetPath: 'assets/seals/hosi_black.glb',
    iconPath: 'assets/seals/hosi_black.png',
    rarity: 3,
  ),
  StickerData(
    number: 11,
    id: 'star_blue_001',
    name: 'ほし（ブルー）',
    assetPath: 'assets/seals/hosi_blue.glb',
    iconPath: 'assets/seals/hosi_blue.png',
    rarity: 3,
  ),
  StickerData(
    number: 12,
    id: 'star_orange_001',
    name: 'ほし（オレンジ）',
    assetPath: 'assets/seals/hosi_oren.glb',
    iconPath: 'assets/seals/hosi_oren.png',
    rarity: 3,
  ),
  StickerData(
    number: 13,
    id: 'star_pink_001',
    name: 'ほし（ピンク）',
    assetPath: 'assets/seals/hosi_pink.glb',
    iconPath: 'assets/seals/hosi_pink.png',
    rarity: 3,
  ),
  StickerData(
    number: 14,
    id: 'heart_blue_002',
    name: 'ハート（ブルー）',
    assetPath: 'assets/seals/hurt_blue.glb',
    iconPath: 'assets/seals/hurt_blue.png',
    rarity: 2,
  ),
  StickerData(
    number: 15,
    id: 'heart_green_002',
    name: 'ハート（グリーン）',
    assetPath: 'assets/seals/hurt_gre.glb',
    iconPath: 'assets/seals/hurt_gre.png',
    rarity: 2,
  ),
  StickerData(
    number: 16,
    id: 'heart_pink_002',
    name: 'ハート（ピンク）',
    assetPath: 'assets/seals/hurt_pink.glb',
    iconPath: 'assets/seals/hurt_pink.png',
    rarity: 2,
  ),
  StickerData(
    number: 17,
    id: 'heart_purple_002',
    name: 'ハート（パープル）',
    assetPath: 'assets/seals/hurt_pur.glb',
    iconPath: 'assets/seals/hurt_pur.png',
    rarity: 2,
  ),
  StickerData(
    number: 18,
    id: 'heart_yellow_002',
    name: 'ハート（イエロー）',
    assetPath: 'assets/seals/hurt_yell.glb',
    iconPath: 'assets/seals/hurt_yell.png',
    rarity: 2,
  ),
];
