// lib/mobileFeatures/mobile_home/controller/new_series_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newSeriesControllerProvider = StateNotifierProvider.autoDispose<
    NewSeriesController, AsyncValue<List<DocumentSnapshot>>>((ref) {
  return NewSeriesController();
});

class NewSeriesController
    extends StateNotifier<AsyncValue<List<DocumentSnapshot>>> {
  NewSeriesController() : super(const AsyncValue.loading()) {
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final List<DocumentSnapshot> finalSeries = [];
      final Set<String> addedIds = {};
      const int requiredCount = 3; // En az 3 seri göstermek istiyoruz

      // 1. ADIM: Son 7 gün içindeki serileri çek.
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentSnapshot = await firestore
          .collection('series')
          .where('hasPublishedEpisodes', isEqualTo: true)
          .where('createdAt', isGreaterThanOrEqualTo: oneWeekAgo)
          .orderBy('createdAt', descending: true)
          .get();

      // Bulunanları listeye ekle.
      for (var doc in recentSnapshot.docs) {
        finalSeries.add(doc);
        addedIds.add(doc.id);
      }

      // 2. ADIM: Eğer 3'ten az serimiz varsa, en yakın tarihli eskilerle tamamla.
      if (finalSeries.length < requiredCount) {
        final needed = requiredCount -
            finalSeries.length; // Kaç tane daha gerektiğini hesapla

        final olderSnapshot = await firestore
            .collection('series')
            .where('hasPublishedEpisodes', isEqualTo: true)
            // Bu sefer 1 haftadan ESKİ olanları alıyoruz.
            .where('createdAt', isLessThan: oneWeekAgo)
            .orderBy('createdAt',
                descending:
                    true) // Yine en yeni olanlar (ama 1 haftadan eski) en üstte
            .limit(needed) // Sadece ihtiyacımız olan kadarını çek.
            .get();

        // Çekilen eski serileri de listeye ekle.
        for (var doc in olderSnapshot.docs) {
          // Zaten eklenmiş olma ihtimali olmasa da, bu kontrol güvenliği artırır.
          if (!addedIds.contains(doc.id)) {
            finalSeries.add(doc);
            addedIds.add(doc.id);
          }
        }
      }

      // State'i son liste ile güncelle.
      state = AsyncValue.data(finalSeries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
