import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/widget/post_tile.dart';

class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;

    if (user == null) {
      return const Center(
          child: Text("Sosyal sayfayı görüntülemek için giriş yapmalısınız."));
    }

    final followedIdsAsync = ref.watch(followedUserIdsProvider(user.user!.uid));

    return SocialTabBarView(ref: ref, followedIds: followedIdsAsync);
  }
}

// Önce AsyncValue’ı kaldırıyoruz:
class SocialTabBarView extends StatelessWidget {
  final WidgetRef ref;
  final List<String> followedIds; // <- artık AsyncValue değil, direkt List

  const SocialTabBarView({
    Key? key,
    required this.ref,
    required this.followedIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // 1. sekme: tüm postlar
        ref.watch(allPostsProvider).when(
              data: (posts) => _PostListView(posts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Hata: $e")),
            ),

        // 2. sekme: takip ettiklerim
        if (followedIds.isEmpty)
          const Center(child: Text("Takip ettiğiniz kimse yok."))
        else
          ref.watch(followedPostsProvider).when(
                data: (posts) => _PostListView(posts),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Gönderi hatası: $e")),
              ),
      ],
    );
  }
}

// Postları listeleyen widget
class _PostListView extends StatelessWidget {
  final List<Post> posts;
  const _PostListView(this.posts);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text("Henüz gönderi yok."));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: ListView.separated(
        itemCount: posts.length,
        separatorBuilder: (_, __) => const Divider(
          // height: 1,
          thickness: 0.5,
          color: Colors.white10,
        ),
        itemBuilder: (context, index) => PostTile(post: posts[index]),
      ),
    );
  }
}
