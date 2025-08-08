// lib/mobileFeatures/mobile_social/controller/followed_user_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedUserIdsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final String uid;
  late final StreamSubscription _subscription;

  FollowedUserIdsNotifier(this.uid) : super(const AsyncLoading()) {
    _listenToFollowing();
  }

  void _listenToFollowing() {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .listen(
      (snapshot) {
        final ids = snapshot.docs.map((doc) => doc.id).toList();
        state = AsyncValue.data(
            ids); // Boş da olsa, dolu da olsa data durumunu yayınlar.
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
