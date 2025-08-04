import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/domain/entities/comment.dart';
import 'package:merinocizgi/domain/repositories/comment_repository.dart';

// Firestore
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Repository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return CommentRepository(db);
});

// Üst yorumlar (series/books/episodes için)
final topCommentsProvider = StreamProvider.family
    .autoDispose<List<Comment>, ({String contentType, String contentId})>(
        (ref, args) {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.watchTopLevel(
      contentType: args.contentType, contentId: args.contentId);
});

// Cevaplar
final repliesProvider =
    StreamProvider.family.autoDispose<List<Comment>, String>((ref, parentId) {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.watchReplies(parentId);
});

// Ekleme (kompozisyon için)
final addCommentProvider = FutureProvider.family.autoDispose<
    void,
    ({
      String contentType,
      String contentId,
      String? parentId,
      String userId,
      String userName,
      String? userPhoto,
      String text,
    })>((ref, args) async {
  final repo = ref.watch(commentRepositoryProvider);
  await repo.addComment(
    contentType: args.contentType,
    contentId: args.contentId,
    parentId: args.parentId,
    userId: args.userId,
    userName: args.userName,
    userPhoto: args.userPhoto,
    text: args.text,
  );
});

// lile

final isLikedProvider =
    StreamProvider.family<bool, ({String commentId, String uid})>((ref, p) {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.isLiked(p.commentId, p.uid);
});
