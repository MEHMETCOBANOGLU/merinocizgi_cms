import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

/// Oturum açmış kullanıcının okuma geçmişini ('En Son' sekmesi için) getirir.
/// En son okuduğu seriye göre sıralar.
final readingHistoryProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  // Önce kullanıcı durumunu izle
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) {
    // Giriş yapılmamışsa boş stream döndür.
    return const Stream.empty();
  }

  // Kullanıcının okuma geçmişi koleksiyonuna anlık olarak bağlan.
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('readingHistory')
      .orderBy('lastReadAt', descending: true) // En son okunan en üstte
      .limit(20) // Performans için bir limit koyalım
      .snapshots();
});

// Kullanıcının takip ettiği kişilerin listesini getirir.
final followingProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('following')
      .orderBy('followedAt', descending: true)
      .snapshots();
});

// Kullanıcıyı takip eden kişilerin listesini getirir.
final followersProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('followers')
      .orderBy('followedAt', descending: true)
      .snapshots();
});

// Oturum açmış kullanıcının, verilen bir yazarı takip edip etmediğini kontrol eder.
final isFollowingProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, authorId) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) return Stream.value(false);

  final docStream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('following')
      .doc(authorId)
      .snapshots();

  return docStream.map((snapshot) => snapshot.exists);
});
