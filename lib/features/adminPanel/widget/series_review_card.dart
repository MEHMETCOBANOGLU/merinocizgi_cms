import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/features/adminPanel/widget/episode_review_tile.dart';

class SeriesReviewCard extends ConsumerWidget {
  final String seriesId;
  const SeriesReviewCard({Key? key, required this.seriesId}) : super(key: key);

  Widget _buildSeriesHeader(
      BuildContext context,
      String title,
      String authorName,
      String? authorEmail,
      String? imageUrl,
      DateTime? createdAt,
      String summary,
      String category1,
      String category2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(imageUrl,
                width: 180, height: 260.0, fit: BoxFit.cover),
          ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.title.copyWith(color: Colors.black)),
              SizedBox(height: 4.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Yazar: ",
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                    TextSpan(
                      text: authorName,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "E-posta: ",
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                    TextSpan(
                      text: authorEmail ?? 'Bilinmiyor',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              if (createdAt != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Yayın Tarihi: ",
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: DateFormat('dd.MM.yyyy').format(createdAt!),
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Flexible(
                    child: Tooltip(
                      message: category1,
                      child: Chip(
                          label: Text(
                            category1,
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  if (category2.isNotEmpty) const SizedBox(width: 8.0),
                  if (category2.isNotEmpty)
                    Flexible(
                      child: Tooltip(
                        message: category2,
                        child: Chip(
                            label: Text(
                              category2,
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (context.isTablet)
                Text("Özet:",
                    style: AppTextStyles.subtitle.copyWith(color: Colors.grey)),
              const SizedBox(height: 4.0),
              if (context.isTablet)
                Text(summary,
                    style: AppTextStyles.text.copyWith(color: Colors.black)),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesProvider(seriesId));

    return seriesAsync.when(
      data: (seriesDoc) {
        if (!seriesDoc.exists) {
          return const Card(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Seri verisi silinmiş olabilir.")));
        }
        // ... (data çekme ve UI oluşturma mantığı önceki cevaptaki gibi)
        // Sadece _buildEpisodesSection'ı değiştireceğiz.
        final data = seriesDoc.data() as Map<String, dynamic>;

        final title = data['title'] as String? ?? 'Başlık Yok';
        final authorName = data['authorName'] as String? ?? 'Bilinmiyor';
        final squareImageUrl = data['squareImageUrl'] as String?;
        final summary = data['summary'] as String? ?? 'Özet Yok';
        final category1 = data['category1'] as String? ?? 'N/A';
        final category2 = data['category2'] as String? ?? '';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        final authorId = data['authorId'] as String? ?? 'Bilinmiyor';
        final authorDataAsync = ref.watch(authorProfileProvider(authorId));

        final authorEmail = authorDataAsync.when(
          data: (authorData) => authorData?['email'] as String? ?? 'Bilinmiyor',
          loading: () => 'Bilinmiyor',
          // error: (e, st) => ' authorEmail hata: $e',
          error: (e, st) {
            print('authorEmail hata: $e');
            return 'authorEmail hata';
          },
        ); // => ' authorEmail hata: $e'});
        return Card(
          color: AppColors.bg,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSeriesHeader(context, title, authorName, authorEmail,
                    squareImageUrl, createdAt, summary, category1, category2),
                const SizedBox(height: 16.0),
                // _buildSeriesDetails(context, summary, category1, category2),
                // const SizedBox(height: 20.0),
                if (!context.isTablet)
                  Text("Özet:",
                      style:
                          AppTextStyles.subtitle.copyWith(color: Colors.grey)),
                if (!context.isTablet) _buildSummarySection(ref, summary),
                // const SizedBox(height: 16.0),

                const Divider(height: 25.0),
                Text("Bölümler",
                    style:
                        AppTextStyles.subheading.copyWith(color: Colors.black)),
                const SizedBox(height: 16.0),
                // Bölümler listesi, artık direkt seri ID'sini kullanıyor.r
                _buildEpisodesSection(ref, seriesId),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Card(child: Center(child: CircularProgressIndicator())),
      error: (e, st) => Card(child: Text("Hata: $e")),
    );
  }

  Widget _buildEpisodesSection(WidgetRef ref, String seriesId) {
    final episodesAsync = ref.watch(allEpisodesForSeriesProvider(seriesId));
    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return const Text("Bu seriye ait bölüm bulunmuyor.");
        }
        return Container(
          decoration: BoxDecoration(
              color: AppColors.bg, borderRadius: BorderRadius.circular(8.0)),
          child: Column(
            children: episodes
                .map((doc) => EpisodeReviewTile(episodeDoc: doc))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text("Bölümler yüklenemedi: $e"),
    );
  }

  Widget _buildSummarySection(WidgetRef ref, String summary) {
    return Text(
      summary,
      style: AppTextStyles.text.copyWith(color: Colors.black),
    );
  }
}
