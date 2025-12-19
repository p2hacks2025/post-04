import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../nameplate/domain/models/models.dart';

class PublicPlacedSticker {
  const PublicPlacedSticker({
    required this.asset,
    required this.dx,
    required this.dy,
    required this.rotation,
  });

  final String asset; // 画像/バイナリは保存しない（アセット参照のみ）
  final double dx;
  final double dy;
  final double rotation;

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'dx': dx,
        'dy': dy,
        'rotation': rotation,
      };

  factory PublicPlacedSticker.fromJson(Map<String, dynamic> json) {
    return PublicPlacedSticker(
      asset: (json['asset'] as String?) ?? '',
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
    );
  }
}

class PublicBoardSnapshot {
  const PublicBoardSnapshot({
    required this.gradientArgb,
    required this.boardWidth,
    required this.boardHeight,
    required this.stickers,
  });

  final List<int> gradientArgb;
  final double boardWidth;
  final double boardHeight;
  final List<PublicPlacedSticker> stickers;

  Map<String, dynamic> toJson() => {
        'gradientArgb': gradientArgb,
        'boardWidth': boardWidth,
        'boardHeight': boardHeight,
        'stickers': stickers.map((e) => e.toJson()).toList(),
      };

  factory PublicBoardSnapshot.fromJson(Map<String, dynamic> json) {
    return PublicBoardSnapshot(
      gradientArgb: ((json['gradientArgb'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      boardWidth: (json['boardWidth'] as num).toDouble(),
      boardHeight: (json['boardHeight'] as num).toDouble(),
      stickers: ((json['stickers'] as List?) ?? const [])
          .map((e) => PublicPlacedSticker.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PublicBoardPost {
  const PublicBoardPost({
    required this.id,
    required this.uid,
    required this.page,
    required this.nameplate,
    required this.board,
    required this.likeCount,
    required this.updatedAt,
  });

  final String id;
  final String uid;
  final int page;
  final NameplateData nameplate;
  final PublicBoardSnapshot board;
  final int likeCount;
  final DateTime? updatedAt;

  factory PublicBoardPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final ts = data['updatedAt'];

    return PublicBoardPost(
      id: doc.id,
      uid: (data['uid'] as String?) ?? '',
      page: (data['page'] as num?)?.toInt() ?? 0,
      nameplate:
          NameplateData.fromJson((data['nameplate'] as Map<String, dynamic>?) ?? const {}),
      board: PublicBoardSnapshot.fromJson((data['board'] as Map<String, dynamic>?) ?? const {}),
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      updatedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
