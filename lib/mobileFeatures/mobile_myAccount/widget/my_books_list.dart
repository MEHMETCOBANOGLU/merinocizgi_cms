// lib/mobileFeatures/account/widgets/my_books_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

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
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final bookDoc = snapshot.docs[index];
            final data = bookDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Image.network(data['coverImageUrl'],
                    width: 50, fit: BoxFit.cover),
                title: Text(data['title']),
                subtitle: Text(
                    "${data['chapterCount'] ?? 0} Bölüm - ${data['status']}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Kullanıcıyı "Bölümleri Yönet" sayfasına yönlendir.
                  context.push('/myAccount/books/${bookDoc.id}/chapters');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Kitaplar yüklenemedi: $e")),
    );
  }
}
