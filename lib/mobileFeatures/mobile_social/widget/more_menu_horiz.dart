import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';

class MoreMenu extends StatelessWidget {
  final Post post;
  final WidgetRef ref;
  const MoreMenu({required this.post, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: GestureDetector(
        onTapDown: (TapDownDetails details) async {
          final overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final position = RelativeRect.fromRect(
            Rect.fromLTWH(
                details.globalPosition.dx, details.globalPosition.dy, 0, 0),
            Offset.zero & overlay.size,
          );
          final selected = await showMenu<String>(
            context: context,
            position: position,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            items: [
              if (post.userId == FirebaseAuth.instance.currentUser?.uid)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Text('Sil',
                          style: TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Icon(Icons.delete, color: Colors.red[400]),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Text('Bildir',
                        style: TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Icon(Icons.report, color: Colors.yellow[400]),
                  ],
                ),
              ),
            ],
          );
          HapticFeedback.lightImpact();
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
                      child: const Text('İptal')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sil')),
                ],
              ),
            );
            if (shouldDelete == true && context.mounted) {
              final scope = ProviderScope.containerOf(context);
              await scope.read(deletePostProvider(post.id).future);
            }
          }
          if (selected == 'report') {
            showReportDialog(context, ref,
                seriesId: post.id, contentType: 'post');
          }
        },
        child: const Icon(Icons.more_horiz),
      ),
    );
  }
}
