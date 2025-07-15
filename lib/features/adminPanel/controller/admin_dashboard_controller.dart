import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardController extends StateNotifier<AsyncValue<void>> {
  AdminDashboardController() : super(const AsyncData(null));

  Future<bool> updateEpisodeStatus({
    required String seriesId,
    required String episodeId,
    required DocumentReference episodeRef,
    required String newStatus,
  }) async {
    state = const AsyncLoading();
    final firestore = FirebaseFirestore.instance;
    final writeBatch = firestore.batch();

    // 1. Bölümün status'unu güncelle
    writeBatch.update(episodeRef, {'status': newStatus});
    // 2. İnceleme görevinin status'unu 'completed' yap
    writeBatch.update(firestore.collection('reviews').doc(episodeId),
        {'status': 'completed'});

    try {
      await writeBatch.commit();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final adminDashboardControllerProvider =
    StateNotifierProvider<AdminDashboardController, AsyncValue<void>>((ref) {
  return AdminDashboardController();
});
