import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/widget/more_menu_horiz.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

class PostHeader extends StatelessWidget {
  final Post post;
  final AsyncValue<int> countAsync;
  final WidgetRef ref;
  final BuildContext context;

  const PostHeader({
    required this.post,
    required this.countAsync,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
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
          // SizedBox(width: 8),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              icon: const Icon(Icons.favorite_border_outlined),
              color: Colors.white38,
              onPressed: () {},
            ),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              color: Colors.white38,
              onPressed: () {
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
