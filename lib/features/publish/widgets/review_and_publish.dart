import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/publish/widgets/publishingIndicator.dart';
import 'package:merinocizgi/features/publish/controller/episode_draft_model.dart';
import 'package:merinocizgi/features/publish/controller/publish_controller.dart';
import 'package:merinocizgi/features/publish/controller/series_draft_provider.dart';
import 'package:merinocizgi/features/publish/widgets/comicFilmStrip.dart';
import 'package:merinocizgi/features/publish/widgets/series_info_card.dart';
import 'package:merinocizgi/features/publish/widgets/step_%C4%B0ndicator.dart';

final episodeExpandProvider =
    StateProvider.family<bool, String>((ref, id) => false);

class UnifiedEpisode {
  final String id;
  final String title;
  final dynamic thumbnail;
  final List<dynamic> pages; // List<String> veya List<Uint8List> olabilir
  final DateTime? createdAt;
  final int episodeNumber;
  final bool isDraft;

  UnifiedEpisode({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.pages,
    required this.createdAt,
    required this.episodeNumber,
    this.isDraft = false,
  });
}

class ReviewAndPublishView extends ConsumerWidget {
  // final String seriesId;
  final VoidCallback onPublishComplete;
  final void Function(int step) onStepTapped;

  const ReviewAndPublishView({
    Key? key,
    // required this.seriesId,
    required this.onPublishComplete,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final episodesAsync = ref.watch(episodesProvider(seriesId));
    final seriesDraft = ref.watch(seriesDraftProvider);
    final selectedSeriesId = seriesDraft.seriesId; // "doğruluk kaynağımız"

    final widthH = MediaQuery.of(context).size.width;

    // --- DEĞİŞİKLİK 2: Hangi senaryoda olduğumuza göre provider'ları çağırıyoruz ---
    // `episodesProvider`'ı sadece var olan bir seriyi inceliyorsak kullanacağız.
    final episodesAsync =
        (selectedSeriesId != null && selectedSeriesId.isNotEmpty)
            ? ref.watch(allEpisodesForSeriesProvider(selectedSeriesId))
            : null; // Yeni seri ise null

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen =
              constraints.maxWidth >= AppBreakpoints.tabletB;

          var episodesSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Bölümler',
                  style: AppTextStyles.subheading.copyWith(color: Colors.black),
                ),
              ),
              // --- DEĞİŞİKLİK 4: Bölüm listesini dinamik olarak oluştur ---
              // Eğer var olan seri ise, when bloğunu kullan.
              if (episodesAsync != null)
                episodesAsync.when(
                  data: (publishedDocs) => _buildCombinedEpisodeList(
                      context, ref, publishedDocs, seriesDraft.episodes),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text("Bölümler yüklenemedi: $e"),
                )
              // Eğer yeni seri ise, sadece taslak bölümleri göster.
              else
                _buildCombinedEpisodeList(
                    context, ref, [], seriesDraft.episodes),
            ],
          );
          return Flex(
              direction: isWideScreen ? Axis.horizontal : Axis.vertical,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: StepIndicator(
                        steps: const [
                          'Seri Detayları',
                          'Bölümleri Ekle',
                          'İncele ve Yayınla'
                        ],
                        currentStep: 2,
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey.shade300,
                        circleSize: 36,
                        borderWidth: 4,
                        lineThickness: 5,
                        // onStepTapped: onStepTapped,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- DEĞİŞİKLİK 3: Seri bilgilerini dinamik olarak göster ---
                        _buildSeriesInfo(context, ref, selectedSeriesId),

                        const SizedBox(width: 32),
                        if (isWideScreen) episodesSection,
                      ],
                    ),
                    if (!isWideScreen) episodesSection,
                    if (!isWideScreen) SizedBox(height: 32),
                    if (!isWideScreen)
                      publishButton(
                          widthH: widthH,
                          onPublishComplete: onPublishComplete,
                          ref: ref),
                  ],
                )
              ]);
        },
      ),
    );
  }

  /// Seri bilgi kartını oluşturan yardımcı widget.
  Widget _buildSeriesInfo(
      BuildContext context, WidgetRef ref, String? seriesId) {
    // Senaryo 1: Var olan bir seriyi inceliyoruz.
    if (seriesId != null && seriesId.isNotEmpty) {
      final seriesAsync = ref.watch(seriesProvider(seriesId));
      return seriesAsync.when(
        data: (doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return const Text("Seri verisi bulunamadı.");
          return SeriesInfoCard(
            title: data['title'] ?? 'Başlık Yok',
            summary: data['summary'] ?? 'Özet Yok',
            category1: data['category1'] ?? '',
            category2: data['category2'] ?? '',
            squareImage: data['squareImageUrl'], // Bu bir URL (String)
            verticalImage: data['verticalImageUrl'],
            onPublishComplete: () {
              context.go("/");
            }, // Bu bir URL (String)
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, st) => const Text("Seri bilgisi yüklenemedi."),
      );
    }
    // Senaryo 2: Yeni bir seri oluşturuyoruz.
    else {
      final seriesDraft = ref.watch(seriesDraftProvider);
      return SeriesInfoCard(
        title: seriesDraft.title,
        summary: seriesDraft.summary,
        category1: seriesDraft.category1 ?? '',
        category2: seriesDraft.category2 ?? '',
        squareImage: seriesDraft.squareImage, // Bu bir Uint8List
        verticalImage: seriesDraft.verticalImage,
        onPublishComplete: () {
          context.go("/");
        }, // Bu bir Uint8List
      );
    }
  }

  /// Firestore ve taslak bölümlerini birleştiren ve listeleyen widget.
  Widget _buildCombinedEpisodeList(
    BuildContext context,
    WidgetRef ref,
    List<QueryDocumentSnapshot> publishedDocs,
    List<EpisodeDraftModel> draftEpisodesList,
  ) {
    final List<UnifiedEpisode> allEpisodes =
        publishedDocs.asMap().entries.map((entry) {
      final data = entry.value.data() as Map<String, dynamic>;
      return UnifiedEpisode(
        id: entry.value.id,
        title: data['title'] ?? 'Başlık Yok',
        thumbnail: data['imageUrl'] as String?,
        pages: List<String>.from(data['pages'] ?? []),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        episodeNumber: entry.key + 1,
        isDraft: false,
      );
    }).toList();

    final draftEpisodes = draftEpisodesList.asMap().entries.map((entry) {
      final draft = entry.value;
      return UnifiedEpisode(
        id: 'draft_${entry.key}',
        title: draft.title,
        thumbnail: draft.thumbnail,
        pages: draft.pages,
        createdAt: null,
        episodeNumber: publishedDocs.length + entry.key + 1,
        isDraft: true,
      );
    });

    allEpisodes.addAll(draftEpisodes);

    if (allEpisodes.isEmpty) {
      return const Text("Henüz bölüm eklenmemiş.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allEpisodes
          .map((episode) => _buildEpisodeCard(context, ref, episode))
          .toList(),
    );
  }

  // ... (Mevcut _buildEpisodeCard ve _buildImageError metodlarınız burada)
  // Bu metodlarda değişiklik yapmaya gerek yok, UnifiedEpisode kullandıkları için esnekler.
}

/// Sadece UI'ı oluşturan, state'ten bağımsız bir seri kartı widget'ı.
/// Bu, kod tekrarını önler.

class publishButton extends StatelessWidget {
  final WidgetRef ref;
  const publishButton({
    super.key,
    required this.widthH,
    required this.onPublishComplete,
    required this.ref,
  });

  final double widthH;
  final VoidCallback onPublishComplete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthH * 0.4,
      child: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              iconColor: Colors.white,
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          icon: const Icon(Icons.cloud_upload),
          label: Text("Yayınla", style: AppTextStyles.subtitle),
          onPressed: () {
            // --- YENİ VE NİHAİ onPressed MANTIĞI ---

            // 1. Controller'daki asenkron işlemi bir değişkene ata.
            //    Henüz ÇALIŞTIRMA, sadece referansını al.
            final publishingProcess = ref
                .read(publishControllerProvider.notifier)
                .publishFullSeries(ref.read(seriesDraftProvider));

            // 2. Bu işlemi (Future'ı) diyaloğumuza parametre olarak ver.
            //    Diyalog artık kendi kendini yönetecek.
            showPublishingDialog(context, publishingProcess);

            // 3. Şimdi, işlem bittikten sonra ne olacağını tanımla.
            //    .then() metodu, Future başarıyla bittiğinde çalışır.
            publishingProcess.then((_) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Tebrikler! Çizgi romanınız incelenmek üzere gönderildi 🚀"),
                backgroundColor: Colors.green,
              ));
              ref.read(seriesDraftProvider.notifier).reset();

              // Üst widget'a haber ver.
              onPublishComplete();
            }).catchError((e) {
              // .catchError metodu, Future hata ile bittiğinde çalışır.
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Yayınlama hatası: $e"),
                    backgroundColor: Colors.red),
              );
            });
          },
        ),
      ),
    );
  }
}

Widget _buildEpisodeCard(
    BuildContext context, WidgetRef ref, UnifiedEpisode episode) {
  final widthH = MediaQuery.of(context).size.width;
  final heightH = MediaQuery.of(context).size.height;
  final isExpanded = ref.watch(episodeExpandProvider(episode.id));
  final bool isWideScreen = widthH >= AppBreakpoints.tabletB;

  Widget thumbnailWidget;
  if (episode.thumbnail is String) {
    thumbnailWidget = Image.network(episode.thumbnail,
        height: 90,
        width: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageError(context));
  } else if (episode.thumbnail is Uint8List) {
    thumbnailWidget = Image.memory(episode.thumbnail,
        height: 90, width: 90, fit: BoxFit.cover);
  } else {
    thumbnailWidget = _buildImageError(context);
  }

  return Card(
    color: AppColors.bg,
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isWideScreen ? 400 : 500,
      height: isExpanded ? heightH * 0.73 : heightH * 0.15,
      // height: isExpanded ? heightH * 0.73 : heightH * 0.22,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          physics: isExpanded
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: thumbnailWidget),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (episode.isDraft)
                          Chip(
                            label: Text('Yeni',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        Text(episode.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title
                                .copyWith(color: Colors.black)),
                        if (episode.createdAt != null)
                          Text(
                              DateFormat('dd.MM.yyyy')
                                  .format(episode.createdAt!),
                              style: AppTextStyles.text
                                  .copyWith(color: Colors.black, fontSize: 12)),
                        Text('Bölüm ${episode.episodeNumber}',
                            style: AppTextStyles.text
                                .copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref
                        .read(episodeExpandProvider(episode.id).notifier)
                        .state = !isExpanded,
                    icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // --- YENİDEN ENTEGRE EDİLEN KISIM ---
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: (episode.pages.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        // Güncellenmiş ComicFilmStrip widget'ını çağırıyoruz.
                        child: ComicFilmStrip(pages: episode.pages),
                      )
                    : const Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text("Bu bölüme ait sayfa yok."))),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(key: bottomKey, child: bottomChild),
                      Positioned(key: topKey, child: topChild),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildImageError(BuildContext context) {
  final heightH = MediaQuery.of(context).size.height;
  final widthH = MediaQuery.of(context).size.width;
  return Container(
    height: heightH * 0.18,
    width: widthH * 0.06,
    decoration: BoxDecoration(
        color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
    child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
  );
}
