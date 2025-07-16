import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ComicFilmStrip extends StatefulWidget {
  final List<dynamic> pages;

  const ComicFilmStrip({super.key, required this.pages});

  @override
  State<ComicFilmStrip> createState() => _ComicFilmStripState();
}

class _ComicFilmStripState extends State<ComicFilmStrip> {
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    const double frameAspect = 200 / 400;
    final double frameW = screenW * 0.11;
    final double frameH = frameW / frameAspect;

    if (widget.pages.isEmpty) {
      return const Center(child: Text("Sayfa görselleri yok."));
    }

    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onVerticalDragUpdate: (d) {
            final newOffset = (_scroll.offset - d.delta.dy)
                .clamp(0.0, _scroll.position.maxScrollExtent);
            _scroll.jumpTo(newOffset);
          },
          child: Listener(
            onPointerSignal: (ps) {
              if (ps is PointerScrollEvent) {
                final newOffset = (_scroll.offset + ps.scrollDelta.dy)
                    .clamp(0.0, _scroll.position.maxScrollExtent);
                _scroll.jumpTo(newOffset);
              }
            },
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: frameW,
                height: frameH,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    OverflowBox(
                      maxWidth: frameW * 0.9,
                      maxHeight: frameH * 1.14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.3, 0.5, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ListView.builder(
                            controller: _scroll,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: widget.pages.length,
                            itemBuilder: (context, index) {
                              final pageData = widget.pages[index];
                              Widget imageWidget;

                              if (pageData is String) {
                                imageWidget = Image.network(
                                  pageData,
                                  // --- DEĞİŞİKLİK 1: Boyut ve fit eklendi ---
                                  width: frameW,
                                  height: frameH,
                                  fit: BoxFit
                                      .cover, // Contain yerine cover kullanıyoruz
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                );
                              } else if (pageData is Uint8List) {
                                imageWidget = Image.memory(
                                  pageData,
                                  // --- DEĞİŞİKLİK 2: Boyut ve fit eklendi ---
                                  width: frameW,
                                  height: frameH,
                                  fit: BoxFit
                                      .cover, // Contain yerine cover kullanıyoruz
                                );
                              } else {
                                imageWidget = const Icon(Icons.error);
                              }

                              return imageWidget;
                            },
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/frame.png',
                      width: frameW,
                      height: frameH,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
