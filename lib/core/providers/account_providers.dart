import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart'; // authStateProvider'a bağımlı

/// Oturum açmış KULLANICININ KENDİ profilini Firestore'dan çeker.
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) {
    return null;
  }
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data();
});

/// ID'si verilen herhangi bir YAZARIN profilini Firestore'dan çeker.
final authorProfileProvider = StreamProvider.autoDispose
    .family<DocumentSnapshot?, String>((ref, authorId) {
  if (authorId.isEmpty) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(authorId)
      .snapshots();
});
