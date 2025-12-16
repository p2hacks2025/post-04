import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seal_app/sticker_book/models.dart';

class StickerRepository {
  final _db = FirebaseFirestore.instance;

  // マスタデータ（図鑑の定義）を全部とってくる
  Future<List<StickerMaster>> fetchMasters() async {
    final snapshot = await _db.collection('stickers')
        .orderBy('index') // ★ここで図鑑番号順に並べる！
        .get();

    return snapshot.docs.map((doc) => StickerMaster.fromFirestore(doc)).toList();
  }

  // ※将来的にはここに「ユーザーの所持データ取得」も追加します
}