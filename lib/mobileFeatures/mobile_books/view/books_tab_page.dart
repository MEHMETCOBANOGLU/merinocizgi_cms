// lib/mobileFeatures/mobile_home/view/books_tab_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart'; // publicBooksProvider için

class BooksTabPage extends ConsumerWidget {
  const BooksTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(publicBooksProvider);

    return booksAsync.when(
      data: (books) {
        if (books.docs.isEmpty) {
          return const Center(child: Text("Henüz hiç kitap bulunmuyor."));
        }
        // Kitaplar için de benzer karusel yapıları kullanabilirsin.
        return ListView.builder(
          itemCount: books.docs.length,
          itemBuilder: (context, index) {
            final bookDoc = books.docs[index];
            // Kitaplar için özel bir kart widget'ı (BookCardWidget)
            return ListTile(title: Text(bookDoc['title']));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Kitaplar yüklenemedi: $e")),
    );
  }
}
