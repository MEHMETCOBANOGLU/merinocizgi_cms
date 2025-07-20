// user_rating_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userRatingProvider = StateNotifierProvider.family<UserRatingNotifier,
    AsyncValue<double?>, String>(
  (ref, seriesId) => UserRatingNotifier(seriesId),
);

class UserRatingNotifier extends StateNotifier<AsyncValue<double?>> {
  final String seriesId;

  UserRatingNotifier(this.seriesId) : super(const AsyncValue.loading()) {
    _fetchUserRating();
  }

  Future<void> _fetchUserRating() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('series')
          .doc(seriesId)
          .collection('ratings')
          .doc(user.uid)
          .get();

      final rating = (doc.data()?['rating'] as num?)?.toDouble();
      state = AsyncValue.data(rating);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitRating(double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('series')
        .doc(seriesId)
        .collection('ratings')
        .doc(user.uid);

    await docRef.set({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });

    state = AsyncValue.data(rating);
  }
}
