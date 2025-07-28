import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class BookReaderPage extends ConsumerStatefulWidget {
  final String bookId;
  final String chapterId;

  const BookReaderPage({
    Key? key,
    required this.bookId,
    required this.chapterId,
  }) : super(key: key);

  @override
  ConsumerState<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends ConsumerState<BookReaderPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _chapterKeys = {};
  bool _didScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToChapter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _chapterKeys[widget.chapterId];
      print('Trying to scroll to: ${widget.chapterId}');
      if (key == null) {
        print('❌ GlobalKey not found for chapterId');
      } else if (key.currentContext == null) {
        print('❌ Key found, but context is null (not yet laid out?)');
      } else {
        print('✅ Scrolling to chapter ${widget.chapterId}');
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookProvider(widget.bookId));
    final chaptersAsync = ref.watch(chaptersProvider(widget.bookId));

    return Scaffold(
      appBar: AppBar(
        title: bookAsync.when(
          data: (data) => Text(data['title']),
          loading: () => const Text("Yükleniyor..."),
          error: (_, __) => const Text("Hata"),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Bölümler
            chaptersAsync.when(
              data: (chapters) {
                if (chapters.isEmpty) {
                  return const Text("Bu kitapta henüz bölüm yok.");
                }

                // Bölüm key'lerini oluştur (benzersiz anahtarlarla)
                for (int i = 0; i < chapters.length; i++) {
                  final chapter = chapters[i];
                  final rawId = chapter['id'];
                  final id = (rawId == null || rawId.toString().isEmpty)
                      ? 'chapter_$i'
                      : rawId.toString();

                  _chapterKeys.putIfAbsent(id, () => GlobalKey());
                }

                // İlk build sonrasında yalnızca bir kez scroll
                if (!_didScroll) {
                  _didScroll = true;
                  _scrollToChapter(); // Future.microtask gerek yok
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(chapters.length, (i) {
                    final chapter = chapters[i];
                    final rawId = chapter['id'];
                    final id = (rawId == null || rawId.toString().isEmpty)
                        ? 'chapter_$i'
                        : rawId.toString();

                    return Column(
                      key: _chapterKeys[id], // güvenli şekilde key eklenmiş
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          "${chapter['chapterNumber']}. Bölüm",
                          style: AppTextStyles.text.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            chapter['title'] ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(chapter['content'] ?? ''),
                      ],
                    );
                  }),
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
