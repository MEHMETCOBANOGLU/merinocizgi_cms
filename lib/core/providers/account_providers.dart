import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart'; // authStateProvider'a bağımlı

/// Oturum açmış olan MEVCUT KULLANICININ profilini anlık olarak dinler.
final currentUserProfileProvider =
    StreamProvider.autoDispose<DocumentSnapshot?>((ref) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots();
});

/// ID'si verilen HERHANGİ BİR kullanıcının profilini anlık olarak dinler.
final userProfileProvider =
    StreamProvider.autoDispose.family<DocumentSnapshot?, String>((ref, userId) {
  if (userId.isEmpty) throw Exception("Kullanıcı ID'si boş olamaz.");
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
});
