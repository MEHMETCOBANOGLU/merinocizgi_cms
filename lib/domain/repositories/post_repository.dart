import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/domain/entities/post.dart';

class PostRepository {
  final FirebaseFirestore _db;

  PostRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('posts');

  /// Gönderi ekle (yeni bir post)
  Future<void> addPost(Post post) async {
    final doc = _col.doc(post.id);
    await doc.set(post.toFirestore());
  }

  /// Tüm gönderileri izler (sıralı)
  Stream<List<Post>> watchAll({int limit = 50}) {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(Post.fromDoc).toList());
  }

  /// Belirli kullanıcıların gönderilerini izler (takip ettiklerim)
  Stream<List<Post>> watchByUserIds(List<String> userIds, {int limit = 50}) {
    if (userIds.isEmpty) return const Stream.empty();
    return _col
        .where('userId', whereIn: userIds)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(Post.fromDoc).toList());
  }

  /// Gönderiyi beğen / geri al (toggle)
  Future<void> toggleLike(String postId, String uid) async {
    final likeRef = _col.doc(postId).collection('likes').doc(uid);
    final postRef = _col.doc(postId);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) return;

      final increment = FieldValue.increment(likeSnap.exists ? -1 : 1);

      if (likeSnap.exists) {
        tx.delete(likeRef);
      } else {
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
      }

      tx.update(postRef, {'likeCount': increment});
    });
  }

  /// Kullanıcı bu gönderiyi beğenmiş mi
  Stream<bool> isLiked(String postId, String uid) {
    return _col
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((s) => s.exists);
  }
}
