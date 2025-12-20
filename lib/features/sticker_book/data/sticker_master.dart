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
];
