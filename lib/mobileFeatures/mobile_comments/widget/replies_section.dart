import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';
import 'package:merinocizgi/domain/entities/comment.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

typedef ReplyTap = void Function(Comment c);

class RepliesSection extends ConsumerStatefulWidget {
  final String parentId;
  final ReplyTap onReplyTap;
  const RepliesSection({
    super.key,
    required this.parentId,
    required this.onReplyTap,
  });

  @override
  ConsumerState<RepliesSection> createState() => _RepliesSectionState();
}

class _RepliesSectionState extends ConsumerState<RepliesSection>
    with TickerProviderStateMixin {
  bool _expanded = false;
  static const int _previewCount = 0; // kapalıyken kaç reply gösterilsin?

  @override
  Widget build(BuildContext context) {
    final replies = ref.watch(repliesProvider(widget.parentId));
    final repo = ref.watch(commentRepositoryProvider);
    final uid = ref.watch(authStateProvider).asData?.value?.user?.uid ?? '';

    return replies.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        final total = list.length;
        final shown = _expanded ? list : list.take(_previewCount).toList();
        final remaining = (total - _previewCount).clamp(0, total);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                children: shown.map((r) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 40.0, top: 12, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              (r.userPhoto != null && r.userPhoto!.isNotEmpty)
                                  ? NetworkImage(r.userPhoto!)
                                  : null,
                          child: (r.userPhoto == null || r.userPhoto!.isEmpty)
                              ? const Icon(Icons.person, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // üst satır: isim + zaman
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      r.userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    ' · ${timeAgoTr(r.createdAt)}',
                                    style: AppTextStyles.oswaldText.copyWith(
                                      color: Colors.white38,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.clip, // İstersen ekle
                                  ),
                                ],
                              ),

                              if (r.text.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  r.text,
                                  style: AppTextStyles.oswaldText.copyWith(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],

                              const SizedBox(height: 4),
                              // Aksiyonlar: solda "Yanıtla", sağda like
                              Row(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1, vertical: 0),
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => widget.onReplyTap(r),
                                    child: Text(
                                      'Yanıtla',
                                      style: AppTextStyles.oswaldText.copyWith(
                                          color: Colors.white38,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  // StreamBuilder<bool>(
                                  //   stream: repo.isLiked(r.id, uid),
                                  //   builder: (context, snap) {
                                  //     final isLiked = snap.data ?? false;
                                  //     return InkWell(
                                  //       borderRadius: BorderRadius.circular(30),
                                  //       onTap: uid.isEmpty
                                  //           ? null
                                  //           : () => repo.toggleLike(r.id, uid),
                                  //       child: Container(
                                  //         width: 51,
                                  //         height: 51,
                                  //         color: Colors.transparent,
                                  //         child: Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               top: 15.0),
                                  //           child: Column(
                                  //             mainAxisSize: MainAxisSize.min,
                                  //             children: [
                                  //               Text('${r.likeCount}',
                                  //                   style: AppTextStyles
                                  //                       .oswaldText
                                  //                       .copyWith(
                                  //                           fontSize: 9,
                                  //                           color: Colors
                                  //                               .white38)),
                                  //               IconButton(
                                  //                 padding: EdgeInsets.zero,
                                  //                 constraints:
                                  //                     const BoxConstraints(
                                  //                         minWidth: 28,
                                  //                         minHeight: 28),
                                  //                 icon: Icon(isLiked
                                  //                     ? Icons.favorite
                                  //                     : Icons.favorite_border),
                                  //                 color: isLiked
                                  //                     ? Colors.redAccent
                                  //                     : Colors.white54,
                                  //                 onPressed: uid.isEmpty
                                  //                     ? null
                                  //                     : () => repo.toggleLike(
                                  //                         r.id, uid),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<bool>(
                          stream: repo.isLiked(r.id, uid),
                          builder: (context, snap) {
                            final isLiked = snap.data ?? false;
                            return InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: uid.isEmpty
                                  ? null
                                  : () => repo.toggleLike(r.id, uid),
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
                                      if (r.likeCount > 0)
                                        Text('${r.likeCount}',
                                            style: AppTextStyles.oswaldText
                                                .copyWith(
                                                    fontSize: 9,
                                                    color: Colors.white38)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 4),

            // Göster/Gizle butonu
            TextButton(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded
                        ? 'Yanıtları gizle'
                        : (remaining > 0
                            ? '$remaining diğer yanıtı gör'
                            : 'Yanıtları gör ($total)'),
                    style: AppTextStyles.oswaldText.copyWith(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(left: 40.0),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Text('Cevaplar yüklenemedi: $e'),
      ),
    );
  }
}
