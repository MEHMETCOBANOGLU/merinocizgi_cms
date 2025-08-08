import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/controller/reply_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/view/comment_composer.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/comment_list.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/widget/post_header.dart';

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
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: const Text('Gönderi')),
          body: SafeArea(
            child: Column(
              children: [
                // 👇 Tüm içerik tek bir scroll'a taşındı
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Header'ı (eski ListTile) ListView içine al
                      PostHeader(
                          post: post,
                          countAsync: countAsync,
                          ref: ref,
                          context: context),

                      const SizedBox(height: 12),

                      // Yorum listesi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CommentList(
                          contentType: 'post',
                          contentId: post.id,
                        ),
                      ),

                      // const SizedBox(height: 80), // composer için nefes payı
                    ],
                  ),
                ),

                // 👇 Composer altta, klavyeye göre yukarı kalksın
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
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }
}
