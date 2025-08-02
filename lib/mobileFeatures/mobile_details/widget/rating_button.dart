import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/controller/userRatingProvider.dart';

class RatingButton extends ConsumerWidget {
  final String id;
  final bool isBook;
  final double averageRating;

  const RatingButton({
    super.key,
    required this.id,
    required this.isBook,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece auth durumunu izliyoruz (giriş kontrolü için)
    final auth = ref.watch(authStateProvider).value;

    // Kullanıcının bu içerik için verdiği puanı izleyelim
    final ratingAsync = ref.watch(
      userRatingProvider((id: id, type: isBook ? 'books' : 'series')),
    );

    return ratingAsync.when(
      data: (ratingValue) {
        final bool hasUserRating = ratingValue != null;

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (auth?.user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Puanlamak için giriş yapmalısınız.')),
              );
              context.push('/landingLogin');
              return;
            }

            showRatingDialog(context, id, ref);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasUserRating ? Icons.star : Icons.star_border,
                color: hasUserRating ? Colors.yellow : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
    );
  }

  Future<void> submitRating(String seriesId, double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.error('Kullanıcı oturum açılmamış.');
    }
    final ratingRef = FirebaseFirestore.instance
        .collection('series')
        .doc(seriesId)
        .collection('ratings')
        .doc(user.uid);

    await ratingRef.set({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
  }

  Future<void> showRatingDialog(
    BuildContext context,
    String seriesId,
    WidgetRef ref,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final contentType = isBook ? 'books' : 'series';
    final contentId = id;

    final doc = await FirebaseFirestore.instance
        .collection(contentType)
        .doc(contentId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    final initialRating = (doc.data()?['rating'] as num?)?.toDouble() ?? 0.0;

    // if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Center(child: Text('Puanla')),
        content: RatingBar.builder(
          initialRating: initialRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) async {
            await ref
                .read(userRatingProvider((id: contentId, type: contentType))
                    .notifier)
                .submitRating(rating);

            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Puanınız kaydedildi.")),
            );
          },
        ),
      ),
    );
  }
}
