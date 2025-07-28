import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class BookReaderPage extends ConsumerWidget {
  final String bookId;
  final String chapterId;

  const BookReaderPage(
      {Key? key, required this.bookId, required this.chapterId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookProvider(bookId));
    final chaptersAsync = ref.watch(chaptersProvider(bookId));
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_add))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            bookAsync.when(
                data: (data) {
                  return Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: Image.network(data['coverImageUrl'],
                                    fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(data['title'], style: AppTextStyles.oswaldSubtitle),
                      const SizedBox(height: 4),
                      Text('@${data['authorName']}',
                          style: AppTextStyles.oswaldText
                              .copyWith(color: Colors.white54)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[800],
                        ),
                        child: Text(
                            data['status'] == 'ongoing'
                                ? 'Devam Ediyor'
                                : 'Tamamlandı',
                            style: AppTextStyles.oswaldText
                                .copyWith(color: Colors.white54)),
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) => const Text('Hata'),
                loading: () => const CircularProgressIndicator()),

            // Bölümler
            chaptersAsync.when(
              data: (chapters) {
                if (chapters.isEmpty) {
                  return const Text("Bu kitapta henüz bölüm yok.");
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: chapters.map((chapter) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter['title'],
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chapter['content'],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text("Bölümler yüklenemedi: $e"),
            ),
          ],
        ),
      ),
    );
  }
}
