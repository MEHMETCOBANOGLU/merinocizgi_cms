import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/user_provider.dart';
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

    final followedIdsAsync = ref.watch(followedUserIdsProvider(user.user?.uid));

    return SocialTabBarView(ref: ref, followedIdsAsync: followedIdsAsync);
  }
}

class SocialTabBarView extends StatelessWidget {
  const SocialTabBarView({
    super.key,
    required this.ref,
    required this.followedIdsAsync,
  });
  final WidgetRef ref;
  final AsyncValue<List<String>> followedIdsAsync;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // SEKME 1: Sana Özel (tüm postlar)
        ref.watch(allPostsProvider).when(
              data: (posts) => _PostListView(posts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Hata: $e")),
            ),

        // SEKME 2: Takip Ettiklerin
        followedIdsAsync.when(
          data: (ids) {
            if (ids.isEmpty) {
              return const Center(
                child: Text("Takip ettiğiniz kimse yok."),
              );
            }

            return ref.watch(followedPostsProvider(ids)).when(
                  data: (posts) => _PostListView(posts),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Gönderi hatası: $e")),
                );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Takip listesi hatası: $e")),
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
