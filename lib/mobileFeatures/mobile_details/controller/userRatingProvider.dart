// lib/mobileFeatures/comic_details/controller/user_rating_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- YENİ TİP TANIMI (RECORD) ---
// Provider'a parametre olarak geçeceğimiz yapıyı tanımlıyoruz.
typedef ContentIdentifier = ({String id, String type});

// --- GÜNCELLENMİŞ PROVIDER ---
// .family artık String değil, 'ContentIdentifier' kaydını alıyor.
final userRatingProvider = StateNotifierProvider.autoDispose
    .family<UserRatingNotifier, AsyncValue<double?>, ContentIdentifier>(
  (ref, content) =>
      UserRatingNotifier(contentId: content.id, contentType: content.type),
);

class UserRatingNotifier extends StateNotifier<AsyncValue<double?>> {
  final String contentId;
  final String contentType; // 'series' veya 'books'

  UserRatingNotifier({required this.contentId, required this.contentType})
      : super(const AsyncValue.loading()) {
    _fetchUserRating();
  }

  // Firestore koleksiyon yolunu dinamik olarak belirleyen yardımcı bir metot.
  String get _collectionPath => contentType == 'series' ? 'series' : 'books';

  Future<void> _fetchUserRating() async {
    state = const AsyncLoading(); // Her zaman yükleniyor ile başla
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath) // Dinamik koleksiyon yolu
          .doc(contentId)
          .collection('ratings')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final rating = (doc.data()?['rating'] as num?)?.toDouble();
        state = AsyncValue.data(rating);
      } else {
        state = const AsyncValue.data(null); // Oy vermemişse null
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitRating(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Hata fırlatarak UI'ın haberdar olmasını sağlayabiliriz.
      throw Exception("Oy vermek için giriş yapmalısınız.");
    }

    final docRef = FirebaseFirestore.instance
        .collection(_collectionPath) // Dinamik koleksiyon yolu
        .doc(contentId)
        .collection('ratings')
        .doc(user.uid);

    // İşlemden önce state'i optimistic olarak güncelleyebiliriz
    // veya sadece işlem bittikten sonra güncelleyebiliriz.
    // Şimdilik işlemden sonra güncelleyelim.
    await docRef.set({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });

    // Firestore'a yazdıktan sonra state'i güncelle.
    state = AsyncValue.data(rating);
  }
}
