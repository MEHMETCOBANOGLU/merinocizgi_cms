// lib/features/books/view/book_chapters_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class BookChaptersPage extends ConsumerWidget {
  final String bookId;
  const BookChaptersPage({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(bookChaptersProvider(bookId));
    final BooksAsync = ref.watch(bookProvider(bookId));

    return Scaffold(
        appBar: AppBar(
          title: const Text("Bölümleri Yönet"),
          leading: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: chaptersAsync.when(
          data: (snapshot) {
            if (snapshot.docs.isEmpty) {
              return const Center(child: Text("Henüz hiç bölüm eklenmemiş."));
            }
            return Column(
              children: [
                _buildBookStatusDropdown(context, ref),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      final chapterDoc = snapshot.docs[index];
                      final data = chapterDoc.data() as Map<String, dynamic>;
                      final String status = data['status'] ?? 'draft';
                      final bool isPublished = status == 'published';

                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: ListTile(
                          // Bölüm durumu için bir ikon
                          leading: Icon(
                            isPublished
                                ? LineAwesome.dot_circle
                                : LineAwesome.dot_circle,
                            color: isPublished ? Colors.green : Colors.red,
                          ),
                          title: Text(data['title'] ?? 'Başlıksız Bölüm'),
                          subtitle: Text(
                              "Durum: ${isPublished ? 'Yayınlandı' : 'Taslak'}"),

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
                                child: Text(
                                    isPublished ? 'Taslağa Al' : 'Yayınla'),
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
                        ),
                      );
                    },
                  ),
                ),
                // _buildBookStatusDropdown(context, ref),
                // const Divider(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Bölümler yüklenemedi: $e")),
        ),
        floatingActionButton: Tooltip(
          message: "Yeni Bölüm Ekle",
          child: FloatingActionButton.small(
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            onPressed: () {
              context.push('/myAccount/books/$bookId/chapters/new');
            },
            child: const Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,

              children: [
                Positioned(
                    bottom: 6,
                    right: 4,
                    child: Icon(MingCute.quill_pen_line, color: Colors.white)),
                Positioned(
                    left: 7,
                    top: 5,
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    )),
              ], // Row(
            ),
          ),
        ));
  }

  Widget _buildBookStatusDropdown(BuildContext context, WidgetRef ref) {
    final singleBookAsync = ref.watch(bookProvider(bookId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: singleBookAsync.when(
        data: (bookSnapshot) {
          final data = bookSnapshot.data() as Map<String, dynamic>?;
          final currentStatus = data?['status'] ?? 'ongoing';

          return Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Kitap Durumu: ", style: TextStyle(fontSize: 14)),
              DropdownButton<String>(
                value: currentStatus,
                style: const TextStyle(fontSize: 14),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(8),
                items: const [
                  DropdownMenuItem(
                      value: 'ongoing', child: Text('Devam Ediyor')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Tamamlandı')),
                ],
                onChanged: (newValue) async {
                  if (newValue != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('books')
                          .doc(bookId)
                          .update({'status': newValue});

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Kitap durumu güncellendi."),
                        backgroundColor: Colors.green,
                      ));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Hata: $e"),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, st) => Center(child: Text("Kitap durumu yüklenemedi: $e")),
      ),
    );
  }
}
