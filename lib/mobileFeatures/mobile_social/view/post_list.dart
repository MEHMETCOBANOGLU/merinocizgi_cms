// lib/mobileFeatures/mobile_social/view/post_list.dart

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
    // Kullanıcının oturum açıp açmadığını kontrol et
    final user = ref.watch(authStateProvider).asData?.value;
    final bool isLoggedIn = user?.user?.uid != null;

    if (!isLoggedIn) {
      // Eğer kullanıcı oturum açmadıysa, takip edilenler listesi boş bir AsyncValue olarak kabul edilebilir.
      return const SocialTabBarView(followedIds: []);
    }

    // Kullanıcı oturum açtıysa, takip edilen ID'lerini asenkron olarak dinle
    final followedIdsAsync =
        ref.watch(followedUserIdsProvider(user!.user!.uid));

    // followedIdsAsync'in durumuna göre UI'ı render et
    return followedIdsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Hata: $e")),
      data: (followedIds) {
        // Veri geldiğinde (boş veya dolu), SocialTabBarView'ı oluştur
        return SocialTabBarView(followedIds: followedIds);
      },
    );
  }
}

class SocialTabBarView extends ConsumerWidget {
  final List<String> followedIds;

  const SocialTabBarView({
    Key? key,
    required this.followedIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        // 1. sekme: "Sana Özel" (Tüm postlar)
        ref.watch(allPostsProvider).when(
              data: (posts) => _PostListView(posts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Hata: $e")),
            ),

        // 2. sekme: "Takip Ettiklerin"
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
