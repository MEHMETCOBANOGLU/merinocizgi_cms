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
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Her satırda 3 öğe
            mainAxisSpacing: 6,
            crossAxisSpacing: 14,
            childAspectRatio: 1, // Genişlik/yükseklik oranı
            mainAxisExtent: 210, // Satır genişligi mainAxisExtent,
          ),
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Her bir seri kartı için özel bir kart widget'ı
            return _HistoryCard(data: data, bookId: doc.id);
          },
        );
      },
      //     itemCount: snapshot.docs.length,
      //     itemBuilder: (context, index) {
      //       final bookDoc = snapshot.docs[index];
      //       final data = bookDoc.data() as Map<String, dynamic>;

      //       return Card(
      //         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //         child: ListTile(
      //           leading: Image.network(data['coverImageUrl'],
      //               width: 50, fit: BoxFit.cover),
      //           title: Text(data['title']),
      //           subtitle: Text(
      //               "${data['chapterCount'] ?? 0} Bölüm - ${data['status']}"),
      //           trailing: const Icon(Icons.arrow_forward_ios),
      //           onTap: () {
      //             // Kullanıcıyı "Bölümleri Yönet" sayfasına yönlendir.
      //             context.push('/myAccount/books/${bookDoc.id}/chapters');
      //           },
      //         ),
      //       );
      //     },
      //   );
      // },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Kitaplar yüklenemedi: $e")),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  final String bookId;

  const _HistoryCard({required this.data, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.white30, // Kenar rengi
          width: 2, // Kenar kalınlığı
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // color: AppColors.card,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          context.push('/detail/$bookId');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['coverImageUrl'] ?? '',
                  width: 105,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) {
                    print(e);
                    return Container(
                        width: 105, height: 140, color: Colors.grey[200]);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  data['title'] ?? 'Seri Başlığı Yok',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
