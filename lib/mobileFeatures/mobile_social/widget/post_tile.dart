import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

class PostTile extends ConsumerWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
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
          SizedBox(width: 8),
          SizedBox(
            width: 24,
            height: 24,
            child: GestureDetector(
              onTapDown: (TapDownDetails details) async {
                // menü kodların
              },
              child: const Icon(Icons.more_horiz),
            ),
          ),
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
        ],
      ),
      isThreeLine: true,
    );
  }
}
