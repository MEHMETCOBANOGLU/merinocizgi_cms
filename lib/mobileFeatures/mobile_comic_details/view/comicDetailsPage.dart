import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/chapter_card_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/detail_header_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/title_chapters_witget.dart';
// import 'package:manga_webtoon/src/detail/components/detail_header_widget.dart';

// import '../home/components/bottom_bar_widget.dart';
// import 'components/chapter_card_widget.dart';
// import 'components/title_chapters_witget.dart';

class MobileComicDetailsPage extends ConsumerStatefulWidget {
  final String seriesOrBookId;
  const MobileComicDetailsPage({
    super.key,
    required this.seriesOrBookId,
    // required String seriesId,
  });

  @override
  ConsumerState<MobileComicDetailsPage> createState() =>
      _MobileComicDetailsPageState();
}

class _MobileComicDetailsPageState
    extends ConsumerState<MobileComicDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final approvedEpisodesAsync =
        ref.watch(approvedEpisodesProvider(widget.seriesOrBookId));

    // return approvedEpisodesAsync.when(data: (episodes) {
    //   if (episodes.isEmpty) {
    //     return const Center(child: Text("Hiç seri bulunamadı."));
    //   }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Sliver: Header Bölümü
          // SliverToBoxAdapter, normal bir widget'ı sliver'a dönüştürür.
          SliverToBoxAdapter(
            child: DetailHeaderWidget(
              seriesOrBookId: widget.seriesOrBookId,
              isBook: false,
            ),
          ),

          // 2. Sliver: "Bölümler" Başlığı
          // Bu, kaydırıldığında yukarıya yapışabilir veya normal kayabilir.

          SliverToBoxAdapter(
            child: const TitleChaptersWidget(),
          ),

          // 3. Sliver: Bölümlerin Listesi
          approvedEpisodesAsync.when(
            data: (episodes) {
              if (episodes.isEmpty) {
                return const SliverFillRemaining(
                    child: Center(
                        child: Text("Henüz yayınlanmış bölüm bulunmuyor.")));
              }
              // ListView yerine SliverList kullanıyoruz.
              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final episodesDoc = episodes[index];
                      final data = episodesDoc.data() as Map<String, dynamic>?;

                      return ChapterCardWidget(
                        episodeId: episodesDoc.id,
                        seriesId: widget.seriesOrBookId,
                        title: data?['title'],
                        chapter: (index + 1)
                            .toString(), // 👈 sadece sayıyı gönderiyoruz
                        urlImage: data?['imageUrl'],
                        isBook: false,
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
    );
  }
}
