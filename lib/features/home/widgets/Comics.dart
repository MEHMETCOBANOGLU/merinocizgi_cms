import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class ComicsSection extends StatefulWidget {
  const ComicsSection({Key? key}) : super(key: key);

  @override
  State<ComicsSection> createState() => _ComicsSectionState();
}

class _ComicsSectionState extends State<ComicsSection> {
  final List<String> _comics = [
    'assets/comics/comic1.jpg',
    'assets/comics/comic2.jpg',
    'assets/comics/comic3.jpg',
    'assets/comics/comic4.jpg',
    // 'assets/comics/comic6.jpg',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final CarouselSliderController _carouselController =
        CarouselSliderController();
    final double screenWidth = MediaQuery.of(context).size.width;
    // Frame PNG'in iç ekran oranı (ör. 300x450)
    const double frameAspectRatio = 2.7;
    // Frame genişliği ekranın %60'ı kadar olsun:
    final double frameWidth = screenWidth * 0.9;
    final double frameHeight = frameWidth / frameAspectRatio;

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // 1) Başlık
          Semantics(
              header: true,
              headingLevel: 1,
              child: Text('Çizgi Romanlar', style: AppTextStyles.heading)),
          const SizedBox(height: 30),
          Center(
              // ı want to add text

              child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _comics.length,
            options: CarouselOptions(
              height: frameHeight,
              viewportFraction: 0.2,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, real) {
              final bool active = index == _currentIndex;

              // Ölçek değerlerin
              final double scaleX = active ? 0.8 : 1.0;
              final double scaleY = active ? 1.13 : 0.75;

              // Dinamik radius ve border
              final double radius = active ? 100 : 16;
              // final Border? border =
              //     active ? Border.all(color: Colors.transparent, width: 3) : null;

              return SizedBox(
                width: screenWidth * 0.2,
                height: frameHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1) Transform + dekorasyon
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                      child: Container(
                        width: screenWidth * 0.18,
                        height: frameHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            radius,
                          ),
                          // border: border,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          _comics[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // 2) Sadece aktif öğeye çerçeve PNG'si
                    if (active)
                      Image.asset(
                        'assets/images/frame.png',
                        width: screenWidth * 0.18,
                        height: frameHeight,
                        fit: BoxFit.contain,
                      ),
                  ],
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
