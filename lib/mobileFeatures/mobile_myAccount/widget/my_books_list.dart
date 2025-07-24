// lib/mobileFeatures/account/widgets/my_books_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

// lib/mobileFeatures/account/widgets/my_books_list.dart

class MyBooksList extends ConsumerWidget {
  const MyBooksList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(authorBooksProvider);

    return booksAsync.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return const Center(child: Text("Henüz hiç kitap oluşturmadın."));
        }
        // GridView yerine Wrap kullanalım.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0, // Kartlar arası yatay boşluk
            runSpacing: 16.0, // Kartlar arası dikey boşluk
            children: snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              // Kartların genişliğini ekran boyutuna göre ayarlayalım
              final cardWidth = (MediaQuery.of(context).size.width / 3) - 22;

              return SizedBox(
                width: cardWidth,
                child: _HistoryCard(data: data, bookId: doc.id),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Kitaplar yüklenemedi: $e")),
    );
  }
}

// _HistoryCard (Card olarak yeniden adlandırılabilir)
class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String bookId;
  const _HistoryCard({required this.data, required this.bookId});

  @override
  Widget build(BuildContext context) {
    // InkWell ve Card yapısı zaten iyi.
    return InkWell(
      onTap: () => context.push('/book-detail/$bookId'),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              // En-boy oranını korur
              aspectRatio: 2 / 3, // Tipik kapak oranı
              child: Image.network(
                data['coverImageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['title'] ?? 'Başlık Yok',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
