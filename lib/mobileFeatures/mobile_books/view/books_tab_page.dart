// lib/mobileFeatures/mobile_home/view/books_tab_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/controller/new_content_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/Popular_books_by_category_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/carouselTop_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/carousel_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/cart_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/most_popular_card_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/topSeries_list.dart';

class BooksTabPage extends ConsumerWidget {
  const BooksTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    // --- KİTAPLARA ÖZEL PROVIDER'LARI İZLE ---
    final completedBooksAsync = ref.watch(completedBooksProvider);
    final popularBooksAsync = ref.watch(highestRatedBooksProvider);
    final newBooksAsync = ref.watch(newBooksProvider);
    // ... (Tamamlanmış kitaplar için de bir provider oluşturulabilir)

    final topFeaturedBooks = ref.watch(topFeaturedBooksProvider); // YENİ
    final topCategoriesAsync =
        ref.watch(topBooksGroupedByPopularCategoriesProvider);

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
          // --- BÖLÜM 1: En Popüler Kitaplar ---
          popularBooksAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox.shrink();

              return CarouselWidget(
                title: "En Popüler Kitaplar",
                height: size.height * 0.28,
                children: books
                    .map((bookDoc) => MostPopularCardWidget(
                          imageUrl: bookDoc['coverImageUrl'], // okey
                          title: bookDoc['title'],
                          chapters: bookDoc['chapterCount'],
                          rating:
                              (bookDoc['averageRating'] as num?)?.toDouble() ??
                                  0.0,
                          onTap: () =>
                              context.push('/book-detail/${bookDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => _buildSectionPlaceholder(size, isPopular: true),
            error: (e, st) => Text("Popüler kitaplar yüklenemedi: $e"),
          ),
          const SizedBox(height: 24),

          // --- BÖLÜM 2: Yeni Kitaplar ---
          newBooksAsync.when(
            data: (newBooksList) {
              if (newBooksList.isEmpty) return const SizedBox.shrink();
              return CarouselWidget(
                title: "Yeni Kitaplar",
                height: size.height * 0.26,
                children: newBooksList
                    .map((bookDoc) => CardWidget(
                          imageUrl: bookDoc['coverImageUrl'],
                          title: bookDoc['title'],
                          onTap: () =>
                              context.push('/book-detail/${bookDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => _buildSectionPlaceholder(size),
            error: (e, st) => Text("Yeni kitaplar yüklenemedi: $e"),
          ),
          const SizedBox(height: 24),

          // --- BÖLÜM 3: Haftanın Kitapları / en iyi (katagory) drama ---

          SizedBox(
            height: 370, // Yüksekliği sabit tutuyoruz
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
                  currentPage = topFeaturedBooks.when(
                    data: (featuredBooks) {
                      if (featuredBooks.isEmpty) {
                        print("Haftanın Kitapları Yok");
                        return const SizedBox.shrink();
                      }
                      return CarouselTopWidget(
                        title: "Haftanın Kitapları",
                        // children listesini oluştururken index'i de kullanıyoruz.
                        children: featuredBooks.asMap().entries.map((entry) {
                          int index = entry.key;
                          DocumentSnapshot booksDoc = entry.value;

                          final data = booksDoc.data() as Map<String, dynamic>;

                          // Bu, her bir satır için yeni widget'ımızı oluşturur.
                          return TopSeriesListItem(
                            rank: index + 1, // Sıralama 1'den başlasın diye
                            imageUrl: data['coverImageUrl'] ?? '',
                            title: data['title'] ?? 'Başlık Yok',
                            category: data['category'] ?? 'Kategori Yok',
                            onTap: () =>
                                context.push('/book-detail/${booksDoc.id}'),
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
                      if (index - 1 >= categoryLists.length) {
                        return const SizedBox(); // Güvenli fallback
                      }
                      final categoryMap = categoryLists[index - 1];
                      final category = categoryMap.keys.first;
                      final booksList = categoryMap[category]!;

                      return CarouselTopWidget(
                        title: "$category",
                        children: booksList.asMap().entries.map((entry) {
                          final i = entry.key;
                          final doc = entry.value;
                          final data = doc.data() as Map<String, dynamic>;
                          return TopSeriesListItem(
                            rank: i + 1,
                            imageUrl: data['coverImageUrl'],
                            title: data['title'],
                            category: data['category'],
                            onTap: () => context.push('/book-detail/${doc.id}'),
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
          const SizedBox(height: 24),

          // --- BÖLÜM 4: Tamamlanmış kitaplar ---

          completedBooksAsync.when(
            data: (books) {
              if (books.docs.isEmpty) {
                print("Tamamlanmış Kitaplar Yok");
                return const SizedBox.shrink();
              }
              // if (books.docs.isEmpty) return const SizedBox.shrink();
              return CarouselWidget(
                title: "Tamamlanmış Kitaplar",
                height: size.height * 0.26,
                children: books.docs
                    .map((booksDoc) => CardWidget(
                          imageUrl: booksDoc['coverImageUrl'],
                          title: booksDoc['title'],
                          onTap: () =>
                              context.push('/book-detail/${booksDoc.id}'),
                        ))
                    .toList(),
              );
            },
            loading: () => _buildSectionPlaceholder(
              size,
              isPopular: true,
            ),
            error: (e, st) =>
                Center(child: Text("Tamamlanmış kitaplar yüklenemedi: $e")),
          ),

          // ---  BÖLÜM 5: Kategorilerine göre popüler Kitaplar ---
          const SizedBox(height: 24),
          PopularBooksByCategoryWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Bu yardımcı metotlar, MobileHomePage'den kopyalanabilir veya
  // paylaşılan bir 'utils' dosyasına taşınabilir.
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
