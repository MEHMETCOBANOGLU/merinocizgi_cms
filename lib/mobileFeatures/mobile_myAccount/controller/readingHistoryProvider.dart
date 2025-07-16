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
