// comment_tile.dart
// CommentList: Üst yorumları ve yanıtlarını listeler (indentli). “Yanıtla” tıklanınca replyState setlenir, composer fokuslanır.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
// senin entity & repo importların:
import 'package:merinocizgi/domain/entities/comment.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/delete_comment_undo.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

class CommentTile extends ConsumerWidget {
  final Comment comment;
  final bool isReply;
  final int depth; // 0 parent, 1 reply
  final VoidCallback onReplyTap;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onReplyTap,
    this.isReply = false,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarSize = isReply ? 28.0 : 36.0;
    final nameSize = isReply ? 13.0 : 14.5;
    final textSize = isReply ? 13.0 : 14.0;
    final metaSize = isReply ? 11.0 : 12.0;
    final indent = 16.0 * depth + (isReply ? 10.0 : 0.0);

    final uid = ref.watch(authStateProvider).asData?.value?.user?.uid ?? '';
    final repo = ref
        .read(commentRepositoryProvider); // Provider’ını senin adınla değiştir

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) async {
        HapticFeedback
            .lightImpact(); // veya mediumImpact / heavyImpact / selectionClick

        // 🔹 UID’i Riverpod’dan al
        final authUser = ref.read(authStateProvider).asData?.value?.user;
        final myUid = authUser?.uid;
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
            if (comment.userId == myUid)
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
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: 8, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // avatar
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage:
                    (comment.userPhoto != null && comment.userPhoto!.isNotEmpty)
                        ? NetworkImage(comment.userPhoto!)
                        : null,
                child: (comment.userPhoto == null || comment.userPhoto!.isEmpty)
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 10),

              // içerik + aksiyonlar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // üst satır: isim + zaman
                    Row(
                      children: [
                        // USERNAME
                        Flexible(
                          child: Text(
                            comment.userName,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          ' · ${timeAgoTr(comment.createdAt)}',
                          style: AppTextStyles.oswaldText.copyWith(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip, // İstersen ekle
                        ),
                      ],
                    ),

                    if (comment.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(comment.text, style: TextStyle(fontSize: textSize)),
                    ],

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 0),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onReplyTap,
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
              // like state + count
              StreamBuilder<bool>(
                stream: repo.isLiked(comment.id, uid),
                builder: (context, snap) {
                  final isLiked = snap.data ?? false;
                  return InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: uid.isEmpty
                        ? null
                        : () => repo.toggleLike(comment.id, uid),
                    child: Container(
                      width: 51,
                      height: 51,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: isLiked
                                    ? Colors.redAccent
                                    : Colors.white54),
                            const SizedBox(height: 2),
                            if (comment.likeCount > 0)
                              Text('${comment.likeCount}',
                                  style: AppTextStyles.oswaldText.copyWith(
                                      fontSize: 9, color: Colors.white38)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
