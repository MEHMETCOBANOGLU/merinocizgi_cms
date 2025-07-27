// lib/mobileFeatures/mobile_home/controller/new_content_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- YENİ JENERİK CONTROLLER ---
// Bu controller artık dışarıdan hangi koleksiyonda çalışacağını alıyor.
class NewContentController
    extends StateNotifier<AsyncValue<List<DocumentSnapshot>>> {
  final String collectionName; // 'series' veya 'books'

  NewContentController({required this.collectionName})
      : super(const AsyncValue.loading()) {
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final List<DocumentSnapshot> finalContent = [];
      final Set<String> addedIds = {};
      const int requiredCount = 3;

      // 1. ADIM: Son 7 gün içindeki içeriği çek.
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      // 'hasPublishedEpisodes' filtresini her iki koleksiyon için de ortak yapalım.
      // Kitaplar için de 'hasPublishedChapters' gibi bir alan eklemek en doğrusu.
      // Şimdilik bu filtrenin her ikisinde de olduğunu varsayalım.
      final recentSnapshot = await firestore
          .collection(collectionName) // <-- Dinamik koleksiyon adı
          .where('hasPublishedEpisodes',
              isEqualTo: true) // Bu alan her iki koleksiyonda da olmalı
          .where('createdAt', isGreaterThanOrEqualTo: oneWeekAgo)
          .orderBy('createdAt', descending: true)
          .get();

      for (var doc in recentSnapshot.docs) {
        finalContent.add(doc);
        addedIds.add(doc.id);
      }

      // 2. ADIM: Eğer 3'ten az içerik varsa, en yakın tarihli eskilerle tamamla.
      if (finalContent.length < requiredCount) {
        final needed = requiredCount - finalContent.length;

        final olderSnapshot = await firestore
            .collection(collectionName) // <-- Dinamik koleksiyon adı
            .where('hasPublishedEpisodes', isEqualTo: true)
            .where('createdAt', isLessThan: oneWeekAgo)
            .orderBy('createdAt', descending: true)
            .limit(needed)
            .get();

        for (var doc in olderSnapshot.docs) {
          if (!addedIds.contains(doc.id)) {
            finalContent.add(doc);
            addedIds.add(doc.id);
          }
        }
      }

      state = AsyncValue.data(finalContent);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- YENİ PROVIDER'LAR ---

// 1. YENİ ÇİZGİ ROMANLAR (SERIES) İÇİN PROVIDER
// Bu, eski 'newSeriesControllerProvider'ın yerine geçer.
final newSeriesProvider = StateNotifierProvider.autoDispose<
    NewContentController, AsyncValue<List<DocumentSnapshot>>>((ref) {
  // Controller'ı 'series' koleksiyonu için başlat.
  return NewContentController(collectionName: 'series');
});

// 2. YENİ KİTAPLAR (BOOKS) İÇİN PROVIDER
final newBooksProvider = StateNotifierProvider.autoDispose<NewContentController,
    AsyncValue<List<DocumentSnapshot>>>((ref) {
  // Controller'ı 'books' koleksiyonu için başlat.
  return NewContentController(collectionName: 'books');
});
