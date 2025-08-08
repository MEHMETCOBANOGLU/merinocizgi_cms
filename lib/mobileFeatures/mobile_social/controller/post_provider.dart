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
// final followedPostsProvider =
//     StreamProvider.family.autoDispose<List<Post>, List<String>>((ref, userIds) {
//   final repo = ref.watch(postRepositoryProvider);
//   return repo.watchByUserIds(userIds);
// });
// Change the StateNotifierProvider's state type to AsyncValue<List<String>>
final followedUserIdsProvider = StateNotifierProvider.family<
    FollowedUserIdsNotifier, AsyncValue<List<String>>, String>(
  (ref, uid) => FollowedUserIdsNotifier(uid),
);

// Belirli kullanıcıların postları (takip edilenler)
// Also, update the followedPostsProvider to correctly handle the AsyncValue.
// Use .when() or .asData?.value to safely access the data.
// Belirli kullanıcıların postları (takip edilenler)
final followedPostsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null || user.user?.uid == null) {
    return const Stream.empty();
  }

  final followedIdsAsync = ref.watch(followedUserIdsProvider(user.user!.uid));
  final repo = ref.watch(postRepositoryProvider);

  // Burada when metodunu kullanarak followedIdsAsync'in durumunu kontrol ediyoruz.
  return followedIdsAsync.when(
    data: (followedIds) {
      // Data geldiğinde, bu listeyi watchByUserIds'e gönderiyoruz.
      return repo.watchByUserIds(followedIds);
    },
    // Loading veya error durumlarında ne yapacağımızı belirtiyoruz.
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
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

// Post silme
final deletePostProvider =
    FutureProvider.family.autoDispose<void, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  await repo.deletePost(postId);
});

final getPostByIdProvider =
    FutureProvider.family.autoDispose<Post?, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  return await repo.getPostById(postId);
});

// Liste sayfasında zaten watchAll() ile akış var, sorun yok.
//Detay sayfasında bunu kullanacağız ki likeCount anında güncellensin.
final watchPostByIdProvider =
    StreamProvider.family.autoDispose<Post?, String>((ref, postId) {
  final repo = ref.watch(postRepositoryProvider);
  return repo.watchById(postId);
});
