import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/domain/entities/comment.dart';

class CommentRepository {
  final FirebaseFirestore _db;
  CommentRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('comments');

  DocumentReference<Map<String, dynamic>> _commentRef(String id) =>
      _col.doc(id);

  DocumentReference<Map<String, dynamic>> _likeRef(
          String commentId, String uid) =>
      _commentRef(commentId).collection('likes').doc(uid);

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

  /// Kullanıcı bu yorumu like’lamış mı?
  Stream<bool> isLiked(String commentId, String uid) {
    return _likeRef(commentId, uid).snapshots().map((s) => s.exists);
  }

  /// Toggle: varsa sil (unlike), yoksa oluştur (like)
  Future<void> toggleLike(String commentId, String uid) async {
    final likeRef = _likeRef(commentId, uid);
    final commentRef = _commentRef(commentId);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final commentSnap = await tx.get(commentRef);
      if (!commentSnap.exists) return;

      if (likeSnap.exists) {
        // UNLIKE
        tx.delete(likeRef);
      } else {
        // LIKE
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
      }
    });
  }
}
