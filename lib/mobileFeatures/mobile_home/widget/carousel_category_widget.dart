// lib/mobileFeatures/mobile_home/widget/carousel_category_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/view/comicDetailsPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/top_cart_widget.dart';

// Provider'ı bu dosyada, sınıfın dışında ve global olarak tanımlıyoruz.
final selectedCategoryProvider =
    StateProvider.autoDispose<String>((ref) => 'AKSİYON');

// Widget'ı ConsumerStatefulWidget'a çeviriyoruz.
class CarouselCategoryWidget extends ConsumerStatefulWidget {
  // Dışarıdan artık sadece başlık alıyor.
  const CarouselCategoryWidget({super.key});

  @override
  ConsumerState<CarouselCategoryWidget> createState() =>
      _CarouselCategoryWidgetState();
}

class _CarouselCategoryWidgetState
    extends ConsumerState<CarouselCategoryWidget> {
  // ScrollController'ı state içinde tanımlıyoruz.
  late final ScrollController _chipScrollController;

  final List<String> _categories = [
    'AKSİYON',
    'FANTEZİ',
    'KOMEDİ',
    'DRAM',
    'ROMANTİZM',
    'BİLİMKURGU',
    'SÜPER KAHRAMAN',
    'GERİLİM',
    'KORKU',
    'ZOMBİ',
    'OKUL',
    'DOĞAÜSTÜ',
    'HAYVAN',
    'SUÇ/GİZEM',
    'TARİHSEL',
    'BİLGİLENDİRİCİ',
    'SPOR',
    'HER YAŞTAN',
    'KIYAMET SONRASI',
  ];

  @override
  void initState() {
    super.initState();
    _chipScrollController = ScrollController();
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Seçili olan kategoriyi izle
    final selectedCategory = ref.watch(selectedCategoryProvider);
    // 2. Seçili kategoriye göre DİNAMİK olarak veri çeken provider'ı izle
    final filteredSeriesAsync =
        ref.watch(topSeriesByCategoryProvider(selectedCategory));

    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BAŞLIK
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Kategorilere Göre Hit Seriler",
            style:
                GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // KATEGORİ CHIP LİSTESİ
        SizedBox(
          height: 40,
          child: ListView.separated(
            controller: _chipScrollController, // <-- Scroll pozisyonunu korur
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              // Sadece bu chip'in kendisini yeniden çizmek için bir Consumer kullanıyoruz.
              // Bu, tüm listenin yeniden çizilmesini engeller.
              return Consumer(
                builder: (context, ref, child) {
                  final isSelected =
                      (category == ref.watch(selectedCategoryProvider));
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary.withOpacity(0.8),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // FİLTRELENMİŞ SERİ LİSTESİ
        filteredSeriesAsync.when(
          data: (series) {
            if (series.isEmpty) {
              return SizedBox(
                  height: size.height * 0.26,
                  child: const Center(
                      child: Text("Bu kategoride seri bulunamadı.")));
            }
            return SizedBox(
              height: size.height * 0.26,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: series.length,
                itemBuilder: (_, index) {
                  final seriesDoc = series[index];
                  return TopCardWidget(
                    viewCount: seriesDoc['viewCount'],
                    imageUrl: seriesDoc['squareImageUrl'],
                    title: seriesDoc['title'],
                    rank: index + 1,
                    onTap: () => context.go('/detail/${seriesDoc.id}'),
                  );
                },
              ),
            );
          },
          loading: () => _buildSectionPlaceholder(size), // Placeholder'ı çağır
          error: (e, st) => SizedBox(
              height: size.height * 0.26,
              child: Center(child: Text("Seriler yüklenemedi: $e"))),
        ),
      ],
    );
  }

  // Placeholder metodunu da bu dosyaya taşıyalım.
  Widget _buildSectionPlaceholder(Size size) {
    final cardHeight = size.height * 0.26;
    const cardWidth = 140.0;
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
