import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/widget/more_menu_horiz.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

class PostTile extends ConsumerWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(
      commentCountProvider((contentType: 'posts', contentId: post.id)),
    );
    final authUser = ref.watch(authStateProvider).asData?.value?.user;
    final uid = authUser?.uid ?? '';

    final isLikedAsync = ref.watch(
      isPostLikedProvider((postId: post.id, uid: uid)),
    );

    Future<void> toggle() async {
      if (authUser == null) {
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 150));
        if (context.mounted) context.push('/landingLogin');
        return;
      }
      HapticFeedback.selectionClick();
      await ref
          .read(togglePostLikeProvider((postId: post.id, uid: uid)).future);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (post.userPhoto != null && post.userPhoto!.isNotEmpty)
            ? NetworkImage(post.userPhoto!)
            : null,
        child: post.userPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Row(
        children: [
          // USERNAME + ZAMAN birlikte: tek blok
          Expanded(
            child: Row(
              children: [
                // USERNAME
                Flexible(
                  child: Text(
                    post.userName,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),

                Text(
                  ' · ${timeAgoTr(post.createdAt)}',
                  style: AppTextStyles.oswaldText.copyWith(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip, // İstersen ekle
                ),
              ],
            ),
          ),

          // EN SAĞDA sabit ikon
          MoreMenu(post: post, ref: ref),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(post.text),
            ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onDoubleTap: toggle, // çift tıkla beğen
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.imageUrl!, fit: BoxFit.cover),
                ),
              ),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            // LIKE (ikon + sayı)
            isLikedAsync.when(
              data: (isLiked) => Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(isLiked
                        ? Icons.favorite
                        : Icons.favorite_border_outlined),
                    color: isLiked ? Colors.redAccent : Colors.white38,
                    onPressed: toggle,
                  ),
                  Text('${post.likeCount}',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              loading: () => const Row(
                children: [
                  Text('…',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ],
              ),
              error: (_, __) => Row(
                children: [
                  Text('${post.likeCount}',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.favorite_border_outlined),
                    color: Colors.white38,
                    onPressed: toggle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // YORUM (ikon + sayı)

            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              color: Colors.white38,
              onPressed: () {
                context.push('/post-detail/${post.id}');
                // _commentWidget(
                // ref, authUser, context, widget.seriesOrBookId, contentType);
              },
              icon: const Icon(
                AntDesign.comment_outline,
              ),
            ),
            Text(
              countAsync.when(
                data: (commentCount) => '$commentCount',
                loading: () => '…',
                error: (_, __) => '-',
              ),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            )
          ])
        ],
      ),
      isThreeLine: true,
    );
  }
}
