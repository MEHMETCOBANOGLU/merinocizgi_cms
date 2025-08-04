// Liste (üst yorumlar + istenirse cevapları açma)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/domain/entities/comment.dart';

class CommentList extends ConsumerWidget {
  final String contentType; // "series" | "books" | "episodes"
  final String contentId;
  final void Function(Comment c)? onReplyTap;
  final void Function(Comment c)? onLikeTap;

  const CommentList({
    super.key,
    required this.contentType,
    required this.contentId,
    this.onReplyTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
        topCommentsProvider((contentType: contentType, contentId: contentId)));

    return async.when(
      data: (comments) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (_, i) => _CommentTile(
          comment: comments[i],
          onReplyTap: onReplyTap,
          onLikeTap: onLikeTap,
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Yorumlar yüklenemedi: $e'),
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  final Comment comment;
  final void Function(Comment c)? onReplyTap;
  final void Function(Comment c)? onLikeTap;

  const _CommentTile({
    required this.comment,
    this.onReplyTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isLikedAsync = ref.watch(
        isLikedProvider((commentId: comment.id, uid: user?.uid ?? '_guest')));

    final replies = ref.watch(repliesProvider(comment.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
                radius: 16,
                backgroundImage:
                    (comment.userPhoto != null && comment.userPhoto!.isNotEmpty)
                        ? NetworkImage(comment.userPhoto!)
                        : null),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${comment.userName} · ${DateFormat('dd.MM.yyyy HH:mm').format(comment.createdAt)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            IconButton(
              icon: isLikedAsync.when(
                data: (liked) => Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.redAccent : Colors.white70,
                ),
                loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Icon(Icons.error, color: Colors.red),
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  context.push('/mobileLogin');
                  return;
                }
                await ref
                    .read(commentRepositoryProvider)
                    .toggleLike(comment.id, user.uid);
              },
            ),
            Text('${comment.likeCount}'),
          ],
        ),
        const SizedBox(height: 4),
        Text(comment.text),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => onReplyTap?.call(comment),
          child: const Text('Cevapla'),
        ),
        replies.when(
          data: (list) => Column(
            children: list.map((r) {
              return Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${r.userName} · ${DateFormat('dd.MM HH:mm').format(r.createdAt)}',
                              style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 2),
                          Text(r.text),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: LinearProgressIndicator(minHeight: 2),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text('Cevaplar yüklenemedi: $e'),
          ),
        ),
      ],
    );
  }
}
