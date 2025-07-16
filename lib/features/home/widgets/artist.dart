import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class ArtistsSection extends StatefulWidget {
  const ArtistsSection({super.key});

  @override
  _ArtistsSectionState createState() => _ArtistsSectionState();
}

class _ArtistsSectionState extends State<ArtistsSection> {
  final List<Map<String, String>> _artists = const [
    {'image': 'assets/comics/comic1.jpg', 'name': 'Zeynep Kara'},
    {'image': 'assets/comics/comic2.jpg', 'name': 'Mehmet Demir'},
    {'image': 'assets/comics/comic3.jpg', 'name': 'Elif Yılmaz'},
    {'image': 'assets/comics/comic4.jpg', 'name': 'Can Öz'},
    // {'image': 'assets/comics/comic6.jpg', 'name': 'Ayşe Ak'},
  ];

  late final PageController _pageController;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    const String frameAsset = 'assets/images/tablet_frame.png';
    // Her bir item'ın genişliği
    final double itemW = screenW * 0.20;
    // Tablet çerçevesi oranı 16:9 örneğiyle
    final double itemH = itemW * (16 / 9);

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text('SANATÇILAR', style: AppTextStyles.heading),
          // const SizedBox(height: 10),

          // Avatar carousel + mouse drag
          SizedBox(
            height: itemH,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                // Mouse veya touchpad sürüklemesini PageView'e ilet
                final newOffset =
                    _pageController.position.pixels - details.delta.dx;
                if (newOffset >= _pageController.position.minScrollExtent &&
                    newOffset <= _pageController.position.maxScrollExtent) {
                  _pageController.jumpTo(newOffset);
                }
              },
              onHorizontalDragEnd: (_) {
                // Bıraktığında PageView snap davranışı kendiliğinden çalışır
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _artists.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, index) {
                  final bool active = index == _current;

                  return Center(
                    child: SizedBox(
                      width: itemW,
                      height: itemH,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1) Tablet çerçevesi: sadece aktif öğe
                          if (active)
                            Transform.scale(
                              scale: 1, // %10 büyüt
                              alignment: Alignment.center,

                              child: Image.asset(
                                frameAsset,
                                width: itemW,
                                height: itemH,
                                fit: BoxFit.contain,
                              ),
                            ),

                          // 2) Avatar
                          Positioned(
                            bottom: itemW * (active ? 0.7 : 0.65),
                            child: Container(
                              width: itemW * (active ? 0.7 : 0.65),
                              height: itemW * (active ? 0.7 : 0.65),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: active
                                      ? AppColors.textSecondary
                                      : Colors.transparent,
                                  width: active ? 3 : 0,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(_artists[index]['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // 3) İsim: sadece aktif öğe için
                          if (active)
                            Positioned(
                              bottom: itemW * (active ? 0.4 : 0.65),
                              child: Text(
                                _artists[index]['name']!,
                                style: AppTextStyles.subheading.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: itemW * 0.12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
