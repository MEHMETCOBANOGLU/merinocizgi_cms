import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/widget/chapter_card_widget.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/widget/detail_header_widget.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/widget/title_chapters_witget.dart';
// import 'package:manga_webtoon/src/detail/components/detail_header_widget.dart';

// import '../home/components/bottom_bar_widget.dart';
// import 'components/chapter_card_widget.dart';
// import 'components/title_chapters_witget.dart';

class DetailPageArguments {
  final String seriesId;
  final String authorName;
  final String authorId;
  final String urlImage;
  final String title;
  final String synopsis;
  final double rating;

  DetailPageArguments({
    required this.seriesId,
    required this.authorName,
    required this.authorId,
    required this.urlImage,
    required this.title,
    required this.synopsis,
    required this.rating,
  });
}

class MobileComicDetailsPage extends ConsumerStatefulWidget {
  final DetailPageArguments arguments;

  const MobileComicDetailsPage({
    super.key,
    required this.arguments,
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
        ref.watch(approvedEpisodesProvider(widget.arguments.seriesId));

    return approvedEpisodesAsync.when(data: (episodes) {
      if (episodes.isEmpty) {
        return const Center(child: Text("Hiç seri bulunamadı."));
      }

      return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailHeaderWidget(
                  authorName: widget.arguments.authorName,
                  authorId: widget.arguments.authorId,
                  urlImage: widget.arguments.urlImage,
                  title: widget.arguments.title,
                  synopsis: widget.arguments.synopsis,
                  rating: widget.arguments.rating,
                  seriesId: widget.arguments.seriesId,
                ),
                const TitleChaptersWidget(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80,
                    ),
                    children: episodes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final episodesDoc = entry.value;

                      return ChapterCardWidget(
                        episodeId: episodesDoc.id,
                        seriesId: widget.arguments.seriesId,
                        title: episodesDoc['title'],
                        chapter: (index + 1)
                            .toString(), // 👈 sadece sayıyı gönderiyoruz
                        urlImage: episodesDoc['imageUrl'],
                      );
                    }).toList(),

                    // return ChapterCardWidget(
                    //   SeriesId: widget.arguments.seriesId,
                    // ),
                    // const ChapterCardWidget(
                    //   title: 'Chapter 2',
                    //   chapter: '1',
                    //   urlImage: 'assets/comics/comic2.jpg',
                    // ),
                    // const ChapterCardWidget(
                    //   title: 'Chapter 3',
                    //   chapter: '1',
                    //   urlImage: 'assets/comics/comic2.jpg',
                    // ),
                    // const ChapterCardWidget(
                    //   title: 'Chapter 4',
                    //   chapter: '1',
                    //   urlImage: 'assets/comics/comic2.jpg',
                    // ),
                    // const ChapterCardWidget(
                    //   title: 'Chapter 4',
                    //   chapter: '1',
                    //   urlImage: 'assets/comics/comic2.jpg',
                    // ),
                    // const ChapterCardWidget(
                    //   title: 'Chapter 4',
                    //   chapter: '1',
                    //   urlImage: 'assets/comics/comic2.jpg',
                    // ),
                  ),
                ),
              ],
            ),
            // BottomBarWidget(
            //   items: [
            //     BottomBarItem(
            //       icon: Icons.home_outlined,
            //       onTap: () {},
            //     ),
            //     BottomBarItem(
            //       icon: Icons.favorite_border,
            //       onTap: () {},
            //     ),
            //     BottomBarItem(
            //       icon: Icons.search_outlined,
            //       onTap: () {},
            //     ),
            //     BottomBarItem(
            //       icon: Icons.explore_outlined,
            //       onTap: () {},
            //     ),
            //   ],
            // )
          ],
        ),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return Center(child: Text(error.toString()));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
