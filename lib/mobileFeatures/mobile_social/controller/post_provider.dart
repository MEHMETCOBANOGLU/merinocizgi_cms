import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/domain/repositories/post_repository.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/followed_user_notifier.dart';

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
final followedPostsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();

  final followedIds = ref.watch(followedUserIdsProvider(user.user!.uid));
  final repo = ref.watch(postRepositoryProvider);
  return repo.watchByUserIds(followedIds);
});

final followedUserIdsProvider =
    StateNotifierProvider.family<FollowedUserIdsNotifier, List<String>, String>(
  (ref, uid) => FollowedUserIdsNotifier(uid),
);

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

// Post silme
final deletePostProvider =
    FutureProvider.family.autoDispose<void, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  await repo.deletePost(postId);
});
