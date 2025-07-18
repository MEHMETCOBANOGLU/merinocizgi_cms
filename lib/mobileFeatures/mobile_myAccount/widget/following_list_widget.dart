// lib/mobileFeatures/account/widgets/following_list_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart'; // Provider'ların olduğu dosya

class FollowingListWidget extends ConsumerWidget {
  final String userId;
  const FollowingListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // İlgili kullanıcının takip ettiklerini dinle
    final followingAsync = ref.watch(followingProvider(userId));

    return followingAsync.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return const Center(child: Text("Henüz kimseyi takip etmiyorsun."));
        }
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final followedUserDoc = snapshot.docs[index];
            final followedUserId = followedUserDoc.id;

            // Takip edilen her bir yazar için bir kart göster.
            // Bu kartın verisini, yazarın kendi profilinden çekmeliyiz.
            return UserCard(userId: followedUserId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Takip edilenler yüklenemedi: $e")),
    );
  }
}

// Tek bir kullanıcıyı gösteren, tekrar kullanılabilir kart.
// Bu widget hem 'following' hem de 'followers' listeleri için kullanılabilir.
class UserCard extends ConsumerWidget {
  final String userId;
  const UserCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kartın, göstereceği kullanıcının profil bilgilerini çekmesi gerekiyor.
    final userProfileAsync = ref.watch(userProfileProvider(userId));

    return userProfileAsync.when(
      data: (userDoc) {
        if (userDoc == null || !userDoc.exists) {
          return const ListTile(title: Text("Kullanıcı bulunamadı."));
        }
        final userData = userDoc.data() as Map<String, dynamic>;
        return Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.white30, // Kenar rengi
              width: 2, // Kenar kalınlığı
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.transparent,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: userData['profileImageUrl'] != null
                  ? NetworkImage(userData['profileImageUrl'])
                  : null,
              child: userData['profileImageUrl'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(userData['mahlas'] ?? 'İsimsiz'),
            // subtitle:
            // Text("@${userData['mahlas']?.toLowerCase() ?? 'kullanici'}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Kullanıcının profil sayfasına yönlendir (eğer varsa)
              // context.push('/profile/$userId');
            },
          ),
        );
      },
      loading: () => const ListTile(title: Text("Yükleniyor...")),
      error: (e, st) => const ListTile(
          title: Text("Hata", style: TextStyle(color: Colors.red))),
    );
  }
}
