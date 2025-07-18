import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final String authorId;
  const ProfileHeader({required this.authorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userProfile = ref.watch(currentUserProfileProvider);
    final userProfile = ref.watch(userProfileProvider(authorId));
    final userSeriesCount = ref.watch(userSeriesCountProvider(authorId));

    return userProfile.when(
      // AsyncValue.data geldiğinde bu blok çalışır. 'snapshot' DocumentSnapshot'ı temsil eder.
      data: (snapshot) {
        if (!snapshot!.exists || snapshot.data() == null) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(
                    count: (userData['followersCount'] ?? 0).toString(),
                    label: "Takipçi",
                    onTap: () => context.push('/followers/$authorId'),
                  ),
                  _StatColumn(
                    count: (userData['followingCount'] ?? 0).toString(),
                    label: "Takip Edilen",
                    onTap: () => context.push('/following/$authorId'),
                  ),
                  _StatColumn(
                    count: userSeriesCount.when(
                      data: (count) => count.toString(),
                      loading: () => "...",
                      error: (e, st) {
                        print("Error: $e");
                        return "e";
                      },
                    ),
                    label: "Seriler",
                    onTap: () => print("Seriler"),
                  ),
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
  final VoidCallback onTap;
  const _StatColumn({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(count,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
