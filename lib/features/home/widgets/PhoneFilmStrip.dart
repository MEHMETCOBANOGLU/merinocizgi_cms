import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class PhoneFilmStrip extends StatefulWidget {
  const PhoneFilmStrip({Key? key}) : super(key: key);

  @override
  State<PhoneFilmStrip> createState() => _PhoneFilmStripState();
}

class _PhoneFilmStripState extends State<PhoneFilmStrip> {
  final List<String> _comics = [
    'assets/comics/comic1.jpg',
    'assets/comics/comic2.jpg',
    'assets/comics/comic3.jpg',
    'assets/comics/comic4.jpg',
    // 'assets/comics/comic6.jpg',
  ];

  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    // Frame asset’in iç ekran oranı (örneğin genişlik 200, yükseklik 400 → 0.5)
    const double frameAspect = 200 / 400;
    // Eski kodunda kullandığın gibi:
    final double frameW = screenW * 0.2;
    final double frameH = frameW / frameAspect;

    return Center(
      child: MouseRegion(
          cursor: SystemMouseCursors.click, // ← burası: parmak imleci
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
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: SizedBox(
                  width: frameW,
                  height: frameH,
                  child: Listener(
                    // Mouse tekerleği ile akıcı kaydırma
                    onPointerSignal: (ps) {
                      if (ps is PointerScrollEvent) {
                        final newOffset = (_scroll.offset + ps.scrollDelta.dy)
                            .clamp(0.0, _scroll.position.maxScrollExtent);
                        _scroll.jumpTo(newOffset);
                      }
                    },
                    child: GestureDetector(
                      // Dokunmatik drag
                      onVerticalDragUpdate: (d) {
                        final newOffset = (_scroll.offset - d.delta.dy)
                            .clamp(0.0, _scroll.position.maxScrollExtent);
                        _scroll.jumpTo(newOffset);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1) Uç uca döşenmiş, akıcı kayan film şeridi
                          OverflowBox(
                            maxWidth: frameW * 0.9,
                            maxHeight: frameH * 1.14,
                            child: ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
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
                                  itemCount: _comics.length,
                                  itemBuilder: (ctx, i) {
                                    return Image.asset(
                                      _comics[i],
                                      width: frameW, // ② her resim tam frameW
                                      height: frameH, // ② her resim tam frameH
                                      fit: BoxFit
                                          .cover, // ② taşmayı cover ile kes
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // 2) Telefon çerçevesi (üstte sabit)
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
          )),
    );
  }
}
