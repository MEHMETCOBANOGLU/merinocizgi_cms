import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Bu provider, oturum açmış kullanıcının takip ettiği kullanıcı ID’lerini verir.
final followedUserIdsProvider =
    FutureProvider.family.autoDispose<List<String>, String?>((ref, uid) async {
  if (uid == null) return const [];

  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("following")
      .get();

  return snapshot.docs.map((doc) => doc.id).toList();
});
