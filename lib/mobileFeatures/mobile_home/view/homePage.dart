// lib/mobileFeatures/mobile_home/view/mobile_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/view/comicDetailsPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/controller/new_content_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/carouselTop_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/carousel_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/cart_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/Popular_series_by_category_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/most_popular_card_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/topSeries_list.dart';

class MobileHomePage extends ConsumerStatefulWidget {
  const MobileHomePage({super.key});

  @override
  ConsumerState<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends ConsumerState<MobileHomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // --- Gerekli tüm provider'ları en başta izle. ---
    final popularSeriesAsync = ref.watch(mostViewedSeriesProvider);
    // Yeni provider'ımızı doğru isimle (`newSeriesControllerProvider`) izliyoruz.
    final newSeriesAsync = ref.watch(newSeriesProvider);
    final completedSeriesAsync = ref.watch(completedSeriesProvider);
    final topFeaturedSeriesAsync = ref.watch(topFeaturedSeriesProvider); // YENİ
    // final selectedCategoryProvider = StateProvider<String>((ref) => 'DRAM');
    final topDramaAsync = ref.watch(topDramaSeriesProvider); // YENİ
    final selectedCategory = ref.watch(selectedCategoryProvider);
    // Seçili kategoriye göre dinamik olarak veri çeken provider'ı izle.
    final filteredSeriesAsync =
        ref.watch(topSeriesByCategoryProvider(selectedCategory));

    final topCategoriesAsync =
        ref.watch(topSeriesGroupedByPopularCategoriesProvider);
    // itemCount hesapla
    int baseCount = 2; // 0 = Haftanın Kitabı, son = Reklam
    int dynamicCount = 0;

    if (topCategoriesAsync is AsyncData) {
      dynamicCount = topCategoriesAsync.value!.length;
    }
    final itemCount = baseCount + dynamicCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BÖLÜM 1: En Popüler ---
          popularSeriesAsync.when(
            data: (series) {
              if (series.docs.isEmpty) return const SizedBox.shrink();

              return CarouselWidget(
                title: "En Popüler",
                height: size.height * 0.28, // Yüksekliği biraz artıralım
                children: series.docs
                    .map((seriesDoc) => MostPopularCardWidget(
                          imageUrl: seriesDoc['squareImageUrl'],
                          title: seriesDoc['title'],
                          chapters: seriesDoc['totalEpisodes'],
                          rating: (seriesDoc['averageRating'] as num?)
                                  ?.toDouble() ??
                              0.0,
                          onTap: () => context.push('/detail/${seriesDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => _buildSectionPlaceholder(size, isPopular: true),
            error: (e, st) => Text("Popüler seriler yüklenemedi: $e"),
          ),
          const SizedBox(height: 24),

          // --- BÖLÜM 2: Yeni Hikayeler ---
          newSeriesAsync.when(
            data: (newSeriesList) {
              if (newSeriesList.isEmpty) return const SizedBox.shrink();
              return CarouselWidget(
                title: "Yeni Seriler",
                height: size.height * 0.26,
                children: newSeriesList
                    .map((seriesDoc) => CardWidget(
                          imageUrl: seriesDoc['squareImageUrl'],
                          title: seriesDoc['title'],
                          onTap: () => context.push('/detail/${seriesDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => _buildSectionPlaceholder(size),
            error: (e, st) => Text("Yeni hikayeler yüklenemedi: $e"),
          ),
          const SizedBox(height: 24),

          // --- BÖLÜM 3: Haftanın Serisi   /  en iyi dramalar vs ---
          SizedBox(
            height: 380, // Yüksekliği sabit tutuyoruz
            child: PageView.builder(
              // .builder constructor'ını kullanmak daha verimli
              // Controller'ı burada oluşturuyoruz.
              controller: PageController(
                // viewportFraction'ı küçülterek sonraki sayfanın daha çok görünmesini sağla
                viewportFraction: 0.88, // Örneğin %75 yapalım
              ),
              // --- SOL BOŞLUĞU KALDIRAN AYAR ---
              // PageView'ın içeriğinin, kendi sınırlarının dışına çizilmesine izin ver.
              clipBehavior: Clip.none,
              padEnds:
                  false, // İlk elemanın başına ve son elemanın sonuna padding ekleme

              // PageView'in çocuklarını bir listeyle tanımlayalım
              itemCount: itemCount,
              itemBuilder: (context, index) {
                Widget currentPage;

                // index'e göre doğru sayfayı oluştur
                if (index == 0) {
                  // SAYFA 1: Haftanın Serisi
                  currentPage = topFeaturedSeriesAsync.when(
                    data: (featuredSeries) {
                      if (featuredSeries.isEmpty) {
                        return const Center(child: Text("Haftanın Serisi Yok"));
                      }
                      return CarouselTopWidget(
                        title: "Haftanın Serisi",
                        // children listesini oluştururken index'i de kullanıyoruz.
                        children: featuredSeries.asMap().entries.map((entry) {
                          int index = entry.key;
                          DocumentSnapshot seriesDoc = entry.value;

                          final data = seriesDoc.data() as Map<String, dynamic>;

                          // Bu, her bir satır için yeni widget'ımızı oluşturur.
                          return TopSeriesListItem(
                            rank: index + 1, // Sıralama 1'den başlasın diye
                            imageUrl: data['squareImageUrl'] ?? '',
                            title: data['title'] ?? 'Başlık Yok',
                            category: data['category1'] ?? 'Kategori Yok',
                            onTap: () =>
                                context.push('/detail/${seriesDoc.id}'),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => _buildSectionPlaceholder(
                      size,
                    ),
                    error: (e, st) => Center(child: Text("Hata: $e")),
                  );
                } else if (index > 0 && index < itemCount - 1) {
                  currentPage = topCategoriesAsync.when(
                    data: (categoryLists) {
                      final categoryMap = categoryLists[index - 1];
                      final category = categoryMap.keys.first;
                      final seriesList = categoryMap[category]!;

                      return CarouselTopWidget(
                        title: "$category",
                        children: seriesList.asMap().entries.map((entry) {
                          final i = entry.key;
                          final doc = entry.value;
                          final data = doc.data() as Map<String, dynamic>;
                          return TopSeriesListItem(
                            rank: i + 1,
                            imageUrl: data['squareImageUrl'],
                            title: data['title'],
                            category: data['category1'],
                            onTap: () => context.push('/detail/${doc.id}'),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => _buildSectionPlaceholder(
                      size,
                    ),
                    error: (e, st) =>
                        Center(child: Text("Dramalar yüklenemedi: $e")),
                  );
                } else {
                  currentPage = const Text(
                    "REKLAMM",
                  );
                }

                // Her sayfaya, sayfalar arası boşluk için sağ tarafa padding ekle
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: currentPage,
                );
              },
            ),
          ),
          // const SizedBox(height: 24),

          // --- BÖLÜM 4: Tamamlanmış Hikayeler  ---
          completedSeriesAsync.when(
            data: (series) {
              if (series.docs.isEmpty) return const SizedBox.shrink();
              return CarouselWidget(
                title: "Tamamlanmış Seriler",
                height: size.height * 0.26,
                children: series.docs
                    .map((seriesDoc) => CardWidget(
                          imageUrl: seriesDoc['squareImageUrl'],
                          title: seriesDoc['title'],
                          onTap: () => context.push('/detail/${seriesDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          // - BÖLÜM 5:  Kategorilerine göre popüler seriler ---
          const PopularSeriesByCategoryWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Yükleniyor durumunda gösterilecek placeholder widget'ı
  Widget _buildSectionPlaceholder(Size size, {bool isPopular = false}) {
    // isPopular flag'ine göre MostPopularCard veya normal Card placeholder'ı seçilir.
    final cardHeight = isPopular ? size.height * 0.28 : size.height * 0.26;
    final cardWidth = isPopular ? size.width * 0.6 : 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 150,
            height: 24,
            color: Colors.white70,
            margin: const EdgeInsets.only(bottom: 12)),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
