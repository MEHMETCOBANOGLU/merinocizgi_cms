import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/domain/entities/comment.dart';

class CommentRepository {
  final FirebaseFirestore _db;
  CommentRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('comments');

  Future<Comment> addComment({
    required String contentType,
    required String contentId,
    String? parentId,
    required String userId,
    required String userName,
    String? userPhoto,
    required String text,
  }) async {
    final doc = _col.doc();
    final entity = Comment(
      id: doc.id,
      contentType: contentType,
      contentId: contentId,
      parentId: parentId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      text: text.trim(),
      likeCount: 0,
      createdAt: DateTime.now(),
    );
    await doc.set(entity.toFirestore());
    return entity;
  }

  /// Üst yorumlar (parentId null)
  Stream<List<Comment>> watchTopLevel({
    required String contentType,
    required String contentId,
    int limit = 20,
  }) {
    final q = _col
        .where('contentType', isEqualTo: contentType)
        .where('contentId', isEqualTo: contentId)
        .where('parentId', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    return q.snapshots().map((s) => s.docs.map(Comment.fromDoc).toList());
  }

  /// Cevaplar
  Stream<List<Comment>> watchReplies(String parentId, {int limit = 50}) {
    final q = _col
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: false)
        .limit(limit);

    return q.snapshots().map((s) => s.docs.map(Comment.fromDoc).toList());
  }

  /// Beğeni arttır / azalt (idempotent değilse sunucu tarafında guard’la—basit örnek)
  Future<void> like(String commentId, {int delta = 1}) async {
    final ref = _col.doc(commentId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final cur = (snap.data()!['likeCount'] as num?)?.toInt() ?? 0;
      tx.update(ref, {'likeCount': (cur + delta).clamp(0, 1 << 31)});
    });
  }

  Future<void> delete(String commentId,
      {required String byUserId, required bool isAdmin}) async {
    final ref = _col.doc(commentId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final owner = doc.data()!['userId'] as String? ?? '';
    if (isAdmin || owner == byUserId) {
      await ref.delete();
    } else {
      throw Exception('Bu yorumu silme yetkiniz yok.');
    }
  }
}
