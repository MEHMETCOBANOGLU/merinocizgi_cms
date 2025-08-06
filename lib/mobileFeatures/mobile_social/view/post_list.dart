import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/post_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/controller/user_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/view/post_composer_sheet.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/widget/post_tile.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/home_app_bar_widget.dart';

class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Giriş yapmanız gerekiyor."));
    }

    final followedIdsAsync = ref.watch(followedUserIdsProvider(user.uid));

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
        // Sana Özel (tüm postlar)
        ref.watch(allPostsProvider).when(
              data: (posts) => _PostListView(posts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Hata: $e")),
            ),

        // Takip Ettiklerin
        followedIdsAsync.when(
          data: (ids) {
            return ref.watch(followedPostsProvider(ids)).when(
                  data: (posts) => _PostListView(posts),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Hata: $e")),
                );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Hata: $e")),
        )
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
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => PostTile(post: posts[index]),
      ),
    );
  }
}
