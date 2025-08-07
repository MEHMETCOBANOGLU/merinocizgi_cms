// Liste (üst yorumlar + istenirse cevapları açma)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/comment.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/delete_comment_undo.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/replies_section.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

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
        separatorBuilder: (_, __) => const SizedBox(height: 16),
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

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) async {
        HapticFeedback
            .lightImpact(); // veya mediumImpact / heavyImpact / selectionClick

        // Ekran (overlay) boyutunu al
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        // Parmağın global konumundan bir dikdörtgen oluştur
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromLTWH(
            details.globalPosition.dx,
            details.globalPosition.dy,
            0,
            0,
          ),
          Offset.zero & overlay.size, // ekranın tamamı referans dikdörtgeni
        );

        final value = await showMenu<String>(
          context: context,
          position: position,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          items: [
            if (comment.userId == FirebaseAuth.instance.currentUser?.uid)
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Text('Sil', style: TextStyle(color: Colors.red)),
                      Spacer(),
                      Icon(Icons.delete, color: Colors.red),
                    ],
                  )),
          ],
        );

        if (value == 'delete') {
          await deleteCommentWithUndo(context, ref,
              comment: comment, isAdmin: false);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 16,
                    backgroundImage: (comment.userPhoto != null &&
                            comment.userPhoto!.isNotEmpty)
                        ? NetworkImage(comment.userPhoto!)
                        : null),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${comment.userName}',
                            style: AppTextStyles.oswaldText
                                .copyWith(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timeAgoTr(comment.createdAt)}',
                            style: AppTextStyles.oswaldText
                                .copyWith(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        comment.text,
                        style: AppTextStyles.oswaldText
                            .copyWith(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => onReplyTap?.call(comment),
                        child: Text(
                          'Yanıtla',
                          style: AppTextStyles.oswaldText.copyWith(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                          horizontal: -4, vertical: -4), // ←
                      icon: isLikedAsync.when(
                        data: (liked) => Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.redAccent : Colors.white70,
                          size: 18,
                        ),
                        loading: () => const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        error: (_, __) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          context.push('/landingLogin');
                          return;
                        }
                        await ref
                            .read(commentRepositoryProvider)
                            .toggleLike(comment.id, user.uid);
                      },
                    ),
                    if (comment.likeCount > 0)
                      Text('${comment.likeCount}',
                          style: AppTextStyles.oswaldText
                              .copyWith(fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ],
            ),
            RepliesSection(parentId: comment.id),
          ],
        ),
      ),
    );
  }
}

// // Küçük onay diyaloğu
// Future<bool?> _confirm(BuildContext context) {
//   return showDialog<bool>(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text('Silinsin mi?'),
//       content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Vazgeç')),
//         FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Sil')),
//       ],
//     ),
//   );
// }
