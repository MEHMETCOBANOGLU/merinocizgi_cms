import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedUserIdsNotifier extends StateNotifier<List<String>> {
  final String uid;
  late final StreamSubscription _subscription;

  FollowedUserIdsNotifier(this.uid) : super([]) {
    _listenToFollowing();
  }

  void _listenToFollowing() {
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .listen((snapshot) {
      final ids = snapshot.docs.map((doc) => doc.id).toList();
      state = ids;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
