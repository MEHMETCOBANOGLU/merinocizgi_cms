// lib/mobileFeatures/account/view/myAccountPage.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_auth/view/loginPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/bottom_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/followers_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/following_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/reading_history_list.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

// Seçili olan profil sekmesinin (Okumaya Devam Et, Serilerim vb.) state'ini tutar.
final _selectedProfileTabIndexProvider =
    StateProvider.autoDispose<int>((ref) => 0);

class UserProfilePage extends ConsumerWidget {
  final String authorId; // Görüntülenen yazarın ID'si
  const UserProfilePage({super.key, required this.authorId});

  // Sabit verileri build metodu dışında tanımlamak en iyi pratiktir.
  static const List<String> _tabs = [
    'Takip',
    'Takipçi',
    'Serilerim',
    'Yorumlar',
    'Süper Beğeni',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state'ini ve seçili sekme index'ini izle.
    final authStateAsync = ref.watch(authStateProvider);
    final selectedTabIndex = ref.watch(_selectedProfileTabIndexProvider);
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);

    final isFollowingAsync = ref.watch(isFollowingProvider(authorId));
    final myAccountController = ref.read(MyAccountControllerProvider.notifier);

    // Auth state'i hala yükleniyorsa veya hata varsa, bir bekleme ekranı göster.
    if (authStateAsync is! AsyncData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Kullanıcı giriş yapmamışsa, login sayfasını göster.
    if (authStateAsync.value?.user == null) {
      return const MobileLoginPage();
    }

    // DefaultTabController, TabBar ve TabBarView'ın senkronize çalışmasını sağlar.
    // Bu, sekmeli yapılar için en doğru ve performanslı yöntemdir.
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        // AppBar ve BottomNavigationBar artık MobileMainLayout'tan (ShellRoute) geliyor.
        // Bu sayfanın kendi AppBar'ına ihtiyacı var.
        appBar: AppBar(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. Profilin üst bilgilerini (Avatar, isim, takipçi sayısı) içeren bölüm.
              SliverToBoxAdapter(
                child: _ProfileHeader(authorId: authorId),
              ),
              // 2. Sekmelerin üst bölümü
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60.0,
                  ),
                  child: isFollowingAsync.when(
                    data: (isFollowing) {
                      if (isFollowing) {
                        // Eğer takip ediyorsa, "Takipten Çık" butonu göster
                        return OutlinedButton(
                          onPressed: () =>
                              myAccountController.unfollowUser(authorId),
                          child: const Text("Takipten Çık"),
                        );
                      } else {
                        // Eğer takip etmiyorsa, "Takip Et" butonu göster
                        return SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent),
                            onPressed: () =>
                                myAccountController.followUser(authorId),
                            child: const Text("Takip Et"),
                          ),
                        );
                      }
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // 2. Sekmelerin olduğu, kaydırıldığında yukarıya yapışan bar.
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    onTap: (index) => ref
                        .read(_selectedProfileTabIndexProvider.notifier)
                        .state = index,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: _tabs.map((label) => Tab(text: label)).toList(),
                  ),
                ),
                pinned: true, // Bu, TabBar'ın yukarıya yapışmasını sağlar.
              ),
            ];
          },
          // 3. Sekmelere karşılık gelen içerik.
          body: TabBarView(
            children: [
              const ReadingHistoryList(), // En Son
              FollowingListWidget(
                  userId: authStateAsync.value!.user!.uid), // Takip
              FollowersListWidget(
                  userId: authStateAsync.value!.user!.uid), // Takipçi
              // AuthorSeriesDashboard(), // Serilerim
              // const UserCommentsWidget(), // Yorumlar
              // const UserSuperLikesWidget(),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            child: BottomBarWidget(
              items: [
                BottomBarItem(
                  icon: Icons.home_outlined,
                  color: selectedBottomBarIndex == 0
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 0;
                    context.go('/');
                  },
                ),
                BottomBarItem(
                  icon: Icons.favorite_border,
                  color: selectedBottomBarIndex == 1
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 1;
                  },
                ),
                BottomBarItem(
                  icon: Icons.search_outlined,
                  color: selectedBottomBarIndex == 2
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 2;
                  },
                ),
                BottomBarItem(
                  icon: Icons.person_outlined,
                  color: selectedBottomBarIndex == 3
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 3;
                    context.push('/myAccount');
                  },
                ),
              ],
            )),
      ),
    );
  }
}

// --- BU SAYFAYA ÖZEL ALT WIDGET'LAR ---

// --- BU SAYFAYA ÖZEL ALT WIDGET'LAR ---

class _ProfileHeader extends ConsumerWidget {
  final String authorId;
  const _ProfileHeader({required this.authorId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userProfileProvider'ı izlemeye devam ediyoruz.
    final userProfile = ref.watch(userProfileProvider(authorId));

    return userProfile.when(
      // AsyncValue.data geldiğinde bu blok çalışır. 'snapshot' DocumentSnapshot'ı temsil eder.
      data: (snapshot) {
        print("authorIddddddddddddd:    $authorId");
        // --- ÇÖZÜM BURADA ---
        // Veriyi kullanmadan ÖNCE belgenin var olup olmadığını kontrol et.
        if (!snapshot!.exists || snapshot.data() == null) {
          // Eğer belge yoksa, kullanıcı bulunamadı mesajı göster.
          return const SizedBox(
              height: 200,
              child: Center(child: Text("Kullanıcı profili bulunamadı.")));
        }

        // Kontrolü geçtiysek, belge verisi güvenle kullanılabilir.
        // Veriyi bir Map'e cast ederek daha güvenli erişim sağlayalım.
        final userData = snapshot.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                // Artık 'userData' map'ini kullanıyoruz.
                backgroundImage: userData['profileImageUrl'] != null
                    ? NetworkImage(userData['profileImageUrl'])
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                "@${userData['mahlas'] ?? 'kullanici'}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(count: "1.2K", label: "Takipçi"),
                  _StatColumn(count: "150", label: "Takip Edilen"),
                  _StatColumn(count: "7", label: "Seri"),
                ],
              )
            ],
          ),
        );
      },
      loading: () => const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, st) {
        // Hata ayıklama için hatayı yazdırmak iyi bir pratiktir.
        print('Profile Header Error: $e');
        return const SizedBox(
            height: 200, child: Center(child: Text("Profil yüklenemedi")));
      },
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
