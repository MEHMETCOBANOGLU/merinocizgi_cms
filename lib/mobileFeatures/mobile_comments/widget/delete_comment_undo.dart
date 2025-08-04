import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/domain/entities/comment.dart';

Future<void> deleteCommentWithUndo(
  BuildContext context,
  WidgetRef ref, {
  required Comment comment,
  bool isAdmin = false,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Gerekirse login’e yönlendir
    context.push('/landingLogin');
    return;
  }

  // 1) VERİYİ YEDEKLE (geri al için)
  // Comment entity’nizde toFirestore varsa onu kullanın:
  final Map<String, dynamic> backup = comment.toFirestore();

  // 2) SİL
  await ref
      .read(commentRepositoryProvider)
      .delete(comment.id, byUserId: user.uid, isAdmin: isAdmin);

  // 3) SNACKBAR + GERİ AL
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // üst üste binmesin

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      content: const Text('1 yorum silindi. Geri almak için tıklayın'),
      action: SnackBarAction(
        label: 'Geri al',
        onPressed: () async {
          // Aynı ID ile geri yükle
          await FirebaseFirestore.instance
              .collection('comments')
              .doc(comment.id)
              .set(backup, SetOptions(merge: false));
          // Not: likes alt koleksiyonu geri gelmez; isterseniz ayrıca kopyalama yapmalısınız.
        },
      ),
    ),
  );
}
