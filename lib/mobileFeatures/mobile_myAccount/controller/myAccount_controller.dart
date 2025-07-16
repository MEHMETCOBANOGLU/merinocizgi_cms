// lib/features/account/controller/account_controller.dart

// ... (importlar)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAccountController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  MyAccountController(this._ref) : super(const AsyncData(null));

  // --- YENİ METOT: OKUMA GEÇMİŞİNİ GÜNCELLEME ---
  /// Kullanıcının bir serideki okuma ilerlemesini Firestore'a kaydeder.
  Future<void> updateUserReadingHistory({
    required String seriesId,
    required String seriesTitle,
    required String seriesImageUrl,
    required String episodeId,
    required String episodeTitle,
  }) async {
    // Sadece giriş yapmış kullanıcılar için çalışır.
    final user = _ref.read(authStateProvider).value?.user;
    if (user == null) return; // Giriş yapılmamışsa hiçbir şey yapma.

    // Kullanıcının okuma geçmişi koleksiyonundaki ilgili seri dökümanının referansı.
    final historyDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('readingHistory')
        .doc(seriesId); // Döküman ID'si olarak seri ID'sini kullanıyoruz.

    try {
      // .set() ve { merge: true } kullanarak, eğer bu seri için bir kayıt yoksa
      // yenisini oluşturur, varsa mevcut kaydı günceller.
      await historyDocRef.set({
        'seriesId': seriesId,
        'lastReadEpisodeId': episodeId,
        'lastReadEpisodeTitle': episodeTitle,
        'lastReadAt':
            FieldValue.serverTimestamp(), // En son okuma zamanını güncelle
        'seriesTitle': seriesTitle,
        'seriesImageUrl': seriesImageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      // Bu işlem arka planda çalıştığı için kullanıcıya hata göstermeye gerek yok.
      // Ancak geliştirme sırasında sorunu anlamak için loglamak iyi bir fikirdir.
      print("Okuma geçmişi güncellenirken hata oluştu: $e");
    }
  }
}

final MyaccountControllerProvider =
    StateNotifierProvider.autoDispose<MyAccountController, AsyncValue<void>>(
        (ref) {
  return MyAccountController(ref);
});
