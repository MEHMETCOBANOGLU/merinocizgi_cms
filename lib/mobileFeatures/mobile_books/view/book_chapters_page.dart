// lib/features/books/view/book_chapters_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class BookChaptersPage extends ConsumerWidget {
  final String bookId;
  const BookChaptersPage({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(bookChaptersProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text("Bölümleri Yönet")),
      body: chaptersAsync.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Center(child: Text("Henüz hiç bölüm eklenmemiş."));
          }
          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final chapterDoc = snapshot.docs[index];
              final data = chapterDoc.data() as Map<String, dynamic>;
              final String status = data['status'] ?? 'draft';
              final bool isPublished = status == 'published';

              return ListTile(
                // Bölüm durumu için bir ikon
                leading: Icon(
                  isPublished ? Icons.visibility : Icons.visibility_off,
                  color: isPublished ? Colors.green : Colors.grey,
                ),
                title: Text(data['title'] ?? 'Başlıksız Bölüm'),
                subtitle:
                    Text("Durum: ${isPublished ? 'Yayınlandı' : 'Taslak'}"),

                // --- YENİ EKLENEN "YAYINLA/TASLAĞA AL" BUTONU ---
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Yayınla/Geri Al butonu
                    TextButton(
                      onPressed: () {
                        ref
                            .read(bookControllerProvider.notifier)
                            .toggleChapterStatus(
                              bookId: bookId,
                              chapterId: chapterDoc.id,
                              currentStatus: status,
                            );
                      },
                      child: Text(isPublished ? 'Taslağa Al' : 'Yayınla'),
                    ),
                    // Düzenle butonu
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () {
                        context.push(
                            '/myAccount/books/$bookId/chapters/${chapterDoc.id}/edit');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Bölümler yüklenemedi: $e")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Yeni bölüm eklemek için Bölüm Editörü'ne git
          context.push('/myAccount/books/$bookId/chapters/new');
        },
        label: const Text("Yeni Bölüm Ekle"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
