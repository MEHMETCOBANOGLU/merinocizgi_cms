import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/controller/userRatingProvider.dart';

class RatingButton extends ConsumerWidget {
  final String id;
  final bool isBook;
  final double averageRating;
  final VoidCallback onRate;

  const RatingButton({
    super.key,
    required this.id,
    required this.isBook,
    required this.averageRating,
    required this.onRate,
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
            onRate(); // parent'taki showRatingDialog'u çağır
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
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
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
    );
  }
}
