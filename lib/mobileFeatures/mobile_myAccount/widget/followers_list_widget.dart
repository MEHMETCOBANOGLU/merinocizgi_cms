// lib/mobileFeatures/account/widgets/followers_list_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/following_list_widget.dart';
// _UserCard'ı import etmek için, onu ya kendi dosyasına taşıyabilir ya da
// 'following_list_widget.dart' dosyasını import edebiliriz.

class FollowersListWidget extends ConsumerWidget {
  final String userId;
  const FollowersListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bu sefer 'followersProvider'ı dinliyoruz.
    final followersAsync = ref.watch(followersProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text("Takipciler")),
      body: followersAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Center(child: Text("Henüz hiç takipçin yok."));
          }
          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final followerDoc = snapshot.docs[index];
              final followerId = followerDoc.id;

              // Aynı _UserCard'ı burada da yeniden kullanıyoruz.
              return UserCard(userId: followerId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Takipçiler yüklenemedi: $e")),
      ),
    );
  }
}
