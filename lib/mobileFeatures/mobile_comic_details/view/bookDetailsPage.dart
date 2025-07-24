import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/chapter_card_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/detail_header_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/title_chapters_witget.dart';

class MobileBookDetailsPage extends ConsumerStatefulWidget {
  final String seriesOrBookId;
  const MobileBookDetailsPage({
    super.key,
    required this.seriesOrBookId,
    // required String seriesId,
  });

  @override
  ConsumerState<MobileBookDetailsPage> createState() =>
      _MobileComicDetailsPageState();
}

class _MobileComicDetailsPageState
    extends ConsumerState<MobileBookDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final publishedChaptersAsync =
        ref.watch(publishedChaptersProvider(widget.seriesOrBookId));

    // return publishedChaptersAsync.when(data: (episodes) {
    //   if (episodes.isEmpty) {
    //     return const Center(child: Text("Hiç seri bulunamadı."));
    //   }

    return Scaffold(
        body: CustomScrollView(
          slivers: [
            // 1. Sliver: Header Bölümü
            // SliverToBoxAdapter, normal bir widget'ı sliver'a dönüştürür.
            // kaydırılabilir listenin bir parçası yapar.
            SliverToBoxAdapter(
              child: DetailHeaderWidget(
                seriesOrBookId: widget.seriesOrBookId,
                isBook: true,
              ),
            ),

            // 2. Sliver: "Bölümler" Başlığı
            // Bu, kaydırıldığında yukarıya yapışabilir (pinned) veya normal kayabilir.
            // Şimdilik normal kayan bir başlık yapalım.
            // const SliverToBoxAdapter(
            //   child: TitleChaptersWidget(),
            // ),
            // 2. Sliver: "Bölümler" Başlığı (Artık Pinned)
            SliverPersistentHeader(
              // Delegate'imize TitleChaptersWidget'ı veriyoruz.
              delegate: SliverChapterHeaderDelegate(
                child: const TitleChaptersWidget(),
              ),
              // Bu, başlığın yukarıya yapışmasını sağlar.
              pinned: true,
            ),

            // 3. Sliver: Bölümlerin Listesi
            // 'chaptersAsync.when' bloğunu buraya taşıyoruz ve SliverList kullanıyoruz.

            publishedChaptersAsync.when(
              data: (episodes) {
                if (episodes.isEmpty) {
                  // SliverFillRemaining, liste boş olduğunda kalan tüm alanı doldurur.
                  return const SliverFillRemaining(
                    child: Center(
                        child: Text("Henüz yayınlanmış bölüm bulunmuyor.")),
                  );
                }
                // ListView yerine SliverList kullanıyoruz. Bu, iç içe kaydırma sorunlarını önler.
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final episodesDoc = episodes[index];
                        return ChapterCardWidget(
                          episodeId: episodesDoc.id,
                          seriesId: widget.seriesOrBookId,
                          title: episodesDoc['title'],
                          chapter: (index + 1)
                              .toString(), // 👈 sadece sayıyı gönderiyoruz
                          urlImage: (episodesDoc.data()
                              as Map<String, dynamic>)['imageUrl'],
                        );
                      },
                      childCount: episodes.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, st) => SliverToBoxAdapter(
                  child: Center(child: Text("Bölümler yüklenemedi: $e"))),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          onPressed: () {},
          child: const Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,

            children: [
              Positioned(
                  bottom: 6,
                  right: 4,
                  child: Icon(MingCute.quill_pen_line, color: Colors.white)),
              Positioned(
                  left: 7,
                  top: 5,
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  )),
            ], // Row(
          ),
        ));
  }
}



      // body: Stack(
      //   alignment: Alignment.center,
      //   children: [
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         DetailHeaderWidget(
      //             seriesOrBookId: widget.seriesOrBookId, isBook: true),
      //         const TitleChaptersWidget(),
      //         publishedChaptersAsync.when(
      //           data: (episodes) {
      //             if (episodes.isEmpty) {
      //               return const Center(child: Text("Hiç seri bulunamadı."));
      //             }
      //             return Expanded(
      //               child: ListView(
      //                 padding: const EdgeInsets.only(
      //                   left: 16,
      //                   right: 16,
      //                   bottom: 80,
      //                 ),
      //                 children: episodes.asMap().entries.map((entry) {
      //                   final index = entry.key;
      //                   final episodesDoc = entry.value;

      //                   return ChapterCardWidget(
      //                     episodeId: episodesDoc.id,
      //                     seriesId: widget.seriesOrBookId,
      //                     title: episodesDoc['title'],
      //                     chapter: (index + 1)
      //                         .toString(), // 👈 sadece sayıyı gönderiyoruz
      //                     urlImage: (episodesDoc.data()
      //                         as Map<String, dynamic>)['imageUrl'],
      //                   );
      //                 }).toList(),
      //               ),
      //             );
      //           },
      //           error: (Object error, StackTrace stackTrace) {
      //             return Center(child: Text(error.toString()));
      //           },
      //           loading: () {
      //             return const Center(child: CircularProgressIndicator());
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    
