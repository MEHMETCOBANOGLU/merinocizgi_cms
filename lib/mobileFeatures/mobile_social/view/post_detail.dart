import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/controller/reply_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/view/comment_composer.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/comment_list.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

// post_detail_page.dart (ilgili parçalar)
class PostDetailPage extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _composerFocus = FocusNode();

  @override
  void dispose() {
    _composerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).asData?.value;
    final postAsync = ref.watch(getPostByIdProvider(widget.postId));
    final countAsync = ref.watch(
        commentCountProvider((contentType: 'post', contentId: widget.postId)));

    return postAsync.when(
      data: (post) {
        if (post == null)
          return const Center(child: Text('Gönderi bulunamadı.'));
        return Scaffold(
          resizeToAvoidBottomInset: true, // 👈 önemli
          appBar: AppBar(title: const Text('Gönderi')),
          body: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (post.userPhoto != null && post.userPhoto!.isNotEmpty)
                          ? NetworkImage(post.userPhoto!)
                          : null,
                  child:
                      post.userPhoto == null ? const Icon(Icons.person) : null,
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
                          final RenderBox overlay = Overlay.of(context)
                              .context
                              .findRenderObject() as RenderBox;

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
                              if (post.userId ==
                                  FirebaseAuth.instance.currentUser?.uid)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Text('Sil',
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      Spacer(),
                                      Icon(Icons.delete,
                                          color: Colors.red[400]),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Text('Bildir',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                    Spacer(),
                                    Icon(Icons.report,
                                        color: Colors.yellow[400]),
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
                              await ref
                                  .read(deletePostProvider(post.id).future);
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
                          child:
                              Image.network(post.imageUrl!, fit: BoxFit.cover),
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
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
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
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      )
                    ])
                  ],
                ),
                isThreeLine: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CommentList(
                    contentType: 'post',
                    contentId: post.id,
                  ),
                ),
              ),
              CommentComposer(
                externalFocusNode: _composerFocus,
                onSend: (text) async {
                  if (authUser == null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    await Future.delayed(const Duration(milliseconds: 150));
                    if (context.mounted) context.push('/landingLogin');
                    return;
                  }
                  final reply = ref.read(replyStateProvider);
                  await ref.read(addCommentProvider((
                    contentType: 'post',
                    contentId: post.id,
                    parentId: reply?.commentId,
                    userId: authUser.user!.uid,
                    userName: authUser.user!.displayName ?? 'Kullanıcı',
                    userPhoto: authUser.user!.photoURL,
                    text: text,
                  )).future);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }
}
