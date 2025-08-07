import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
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
                // 1. Ekran boyutlarını al
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                // 2. Parmağın dokunduğu noktadan menü konumunu ayarla
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromLTWH(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    0,
                    0,
                  ),
                  Offset.zero & overlay.size,
                );

                // 3. Menüyü göster
                final selected = await showMenu<String>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  items: [
                    if (post.userId == FirebaseAuth.instance.currentUser?.uid)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Text('Sil',
                                style: TextStyle(color: Colors.white70)),
                            Spacer(),
                            Icon(Icons.delete, color: Colors.red[400]),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Text('Bildir',
                              style: TextStyle(color: Colors.white70)),
                          Spacer(),
                          Icon(Icons.report, color: Colors.yellow[400]),
                        ],
                      ),
                    ),
                  ],
                );

                HapticFeedback.lightImpact(); // tıklama hissi

                // 4. Gelen değere göre işlem yap

                if (selected == 'delete') {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Gönderi Sil'),
                      content: const Text(
                          'Bu gönderiyi silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true && context.mounted) {
                    final ref = ProviderScope.containerOf(context);
                    await ref.read(deletePostProvider(post.id).future);
                  }
                }
                if (selected == 'report') {
                  showReportDialog(
                    context,
                    ref,
                    seriesId: post.id,
                    contentType: 'post',
                  );
                }
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
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              icon: const Icon(Icons.favorite_border_outlined),
              color: Colors.white38,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(AntDesign.comment_outline),
              color: Colors.white38,
              onPressed: () {},
            ),
          ])
        ],
      ),
      isThreeLine: true,
    );
  }
}
