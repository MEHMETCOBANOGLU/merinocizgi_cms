import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/colors.dart';
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
  Timer? _autoScrollTimer;
  double _scrollSpeed = 1.0; // px per tick (metin kaydrıma birim hız)
  bool _isAutoScrolling = false; // ilgili bölüme scroll
  bool _userInteracted =
      false; //Kullanıcının dokunup dokunmadığını anlayabilmek için

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToChapter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _chapterKeys[widget.chapterId];
      if (key == null) {
        print('GlobalKey not found for chapterId');
      } else if (key.currentContext == null) {
        print('Key found, but context is null (not yet laid out?)');
      } else {
        print('Scrolling to chapter ${widget.chapterId}');
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      // kullanıcı müdahale ettiyse → 2 saniye kaydırmayı duraklat
      if (_userInteracted) {
        _userInteracted = false;
        return; // bu tick atla
      }

      if (current >= maxScroll) {
        _stopAutoScroll();
        return;
      }

      _scrollController.animateTo(
        (current + _scrollSpeed).clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });

    setState(() {
      _isAutoScrolling = true;
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    setState(() {
      _isAutoScrolling = false;
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () async {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset position =
                  button.localToGlobal(Offset.zero, ancestor: overlay);

              await showMenu<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                context: context,
                position: RelativeRect.fromLTRB(
                  position.dx + button.size.width,
                  position.dy + AppBar().preferredSize.height + 18,
                  0,
                  0,
                ),
                items: [
                  const PopupMenuItem<String>(
                      padding: EdgeInsets.zero,
                      value: 'auto_scroll',
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(EvaIcons.play_circle_outline,
                              size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Otomatik Kaydırma'),
                        ],
                      )),
                ],
              ).then((value) {
                if (value == 'auto_scroll') {
                  _showAutoScrollMenu();
                }
              });
            },
          ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction != ScrollDirection.idle) {
            _userInteracted = true; // kullanıcı dokundu
          }
          return false;
        },
        child: SingleChildScrollView(
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
                        key: _chapterKeys[id],
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
      ),
    );
  }

  void _showAutoScrollMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Kaydırma Hızı: ${_scrollSpeed.toStringAsFixed(1)} px/sn"),
                  Slider(
                    value: _scrollSpeed,
                    min: 0.5,
                    max: 10.0,
                    divisions: 20,
                    label: "${_scrollSpeed.toStringAsFixed(1)}",
                    onChanged: (value) {
                      setModalState(() => _scrollSpeed = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon:
                        Icon(_isAutoScrolling ? Icons.pause : Icons.play_arrow),
                    label: Text(_isAutoScrolling
                        ? "Kaydırmayı Durdur"
                        : "Kaydırmayı Başlat"),
                    onPressed: () {
                      if (_isAutoScrolling) {
                        _stopAutoScroll();
                      } else {
                        _startAutoScroll();
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
