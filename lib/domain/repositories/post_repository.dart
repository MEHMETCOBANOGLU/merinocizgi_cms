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

  /// Post sil
  Future<void> deletePost(String postId) async {
    final docRef = _col.doc(postId);
    await docRef.delete();
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
// PostRepository
  Future<void> toggleLike(String postId, String uid) async {
    final likeRef = _col.doc(postId).collection('likes').doc(uid);
    final likeSnap = await likeRef.get();
    if (likeSnap.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
    }
    // NOT: likeCount'ı burada güncellemiyoruz.
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

  Future<Post?> getPostById(String postId) async {
    final doc = await _col.doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromDoc(doc);
  }

  Stream<Post?> watchById(String postId) {
    return _col.doc(postId).snapshots().map(
          (d) => d.exists ? Post.fromDoc(d) : null,
        );
  }
}
