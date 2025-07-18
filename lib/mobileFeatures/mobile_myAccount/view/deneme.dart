import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';

class UserProfilePage extends ConsumerWidget {
  final String authorId; // Görüntülenen yazarın ID'si
  const UserProfilePage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Oturum açmış kullanıcının bu yazarı takip edip etmediğini anlık olarak izle.
    final isFollowingAsync = ref.watch(isFollowingProvider(authorId));
    final myAccountController = ref.read(MyAccountControllerProvider.notifier);

    final userProfile = ref.watch(currentUserProfileProvider);
    return userProfile.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
                radius: 50,
                backgroundImage: data?['profileImageUrl'] != null
                    ? NetworkImage(data!['profileImageUrl'])
                    : null),
            const SizedBox(height: 12),
            Text("@${data?['mahlas'] ?? 'kullanici'}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(count: "1.2K", label: "Takipçi"),
                _StatColumn(count: "150", label: "Takip Edilen"),
                _StatColumn(count: "7", label: "Seri"),
              ],
            ),
            isFollowingAsync.when(
              data: (isFollowing) {
                if (isFollowing) {
                  // Eğer takip ediyorsa, "Takipten Çık" butonu göster
                  return OutlinedButton(
                    onPressed: () => myAccountController.unfollowUser(authorId),
                    child: const Text("Takipten Çık"),
                  );
                } else {
                  // Eğer takip etmiyorsa, "Takip Et" butonu göster
                  return ElevatedButton(
                    onPressed: () => myAccountController.followUser(authorId),
                    child: const Text("Takip Et"),
                  );
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => const SizedBox.shrink(),
            )
          ],
        ),
      ),
      loading: () => const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox(
          height: 200, child: Center(child: Text("Profil yüklenemedi"))),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// TabBar'ı yapışkan hale getirmek için gereken delegate sınıfı.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Arka plan rengi
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
