import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

class PostTile extends ConsumerWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (post.userPhoto != null && post.userPhoto!.isNotEmpty)
            ? NetworkImage(post.userPhoto!)
            : null,
        child: post.userPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Row(
        children: [
          Text(post.userName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(
            '· ${timeAgoTr(post.createdAt)}',
            style: AppTextStyles.oswaldText.copyWith(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
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
              final value = await showMenu<String>(
                context: context,
                position: position,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                items: [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Text('Sil', style: TextStyle(color: Colors.white70)),
                        Spacer(),
                        Icon(Icons.delete, color: Colors.red[400]),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Text('Bildir', style: TextStyle(color: Colors.white70)),
                        Spacer(),
                        Icon(Icons.report, color: Colors.yellow[400]),
                      ],
                    ),
                  ),
                ],
              );

              HapticFeedback.lightImpact(); // tıklama hissi

              // 4. Gelen değere göre işlem yap
              if (value == 'delete') {
                // TODO: Silme işlemini burada yap
              } else if (value == 'report') {
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
