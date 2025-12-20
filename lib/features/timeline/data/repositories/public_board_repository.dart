import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../nameplate/domain/models/models.dart';
import '../../domain/models/public_board.dart';

class PublicBoardRepository {
  PublicBoardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('public_boards');

  String get _uid => _auth.currentUser!.uid;

  String docIdFor({required String uid, required int page}) => '${uid}_$page';

  Future<Set<int>> fetchMyPublishedPages() async {
    final snap = await _col.where('uid', isEqualTo: _uid).get();
    return snap.docs
        .map((d) => ((d.data()['page'] as num?)?.toInt() ?? 0))
        .toSet();
  }

  Stream<List<PublicBoardPost>> streamAll({int limit = 50}) {
    return _col
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => PublicBoardPost.fromDoc(d)).toList());
  }

  Stream<List<PublicBoardPost>> streamByUid(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => PublicBoardPost.fromDoc(d)).toList());
  }

  Future<void> publishPage({
    required int page,
    required NameplateData nameplate,
    required PublicBoardSnapshot board,
  }) async {
    final id = docIdFor(uid: _uid, page: page);
    await _col.doc(id).set({
      'uid': _uid,
      'page': page,
      'nameplate': nameplate.toJson(),
      'board': board.toJson(),
      'likeCount': FieldValue.increment(0),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> unpublishPage({required int page}) async {
    final id = docIdFor(uid: _uid, page: page);
    await _col.doc(id).delete();
  }

  DocumentReference<Map<String, dynamic>> _likeDoc(String postId) {
    return _col.doc(postId).collection('likes').doc(_uid);
  }

  Stream<bool> streamIsLiked(String postId) {
    return _likeDoc(postId).snapshots().map((d) => d.exists);
  }

  Future<void> toggleLike(String postId) async {
    final postRef = _col.doc(postId);
    final likeRef = _likeDoc(postId);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);

      if (!postSnap.exists) {
        // 投稿が消えていたら何もしない
        return;
      }

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        tx.set(likeRef, {
          'uid': _uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(postRef, {
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }
}
