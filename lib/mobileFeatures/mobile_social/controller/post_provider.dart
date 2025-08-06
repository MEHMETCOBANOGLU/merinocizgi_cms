import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/domain/repositories/post_repository.dart';

// Firestore erişimi
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Repository
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  return PostRepository(db);
});

// Tüm postlar (sıralı)
final allPostsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.watchAll();
});

// Belirli kullanıcıların postları (takip edilenler)
final followedPostsProvider =
    StreamProvider.family.autoDispose<List<Post>, List<String>>((ref, userIds) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.watchByUserIds(userIds);
});

// Post ekleme
final addPostProvider =
    FutureProvider.family.autoDispose<void, Post>((ref, post) async {
  final repo = ref.watch(postRepositoryProvider);
  await repo.addPost(post);
});

// Beğenmiş mi
final isPostLikedProvider =
    StreamProvider.family<bool, ({String postId, String uid})>((ref, args) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.isLiked(args.postId, args.uid);
});

// Toggle Like
final togglePostLikeProvider = FutureProvider.family
    .autoDispose<void, ({String postId, String uid})>((ref, args) async {
  final repo = ref.watch(postRepositoryProvider);
  await repo.toggleLike(args.postId, args.uid);
});
