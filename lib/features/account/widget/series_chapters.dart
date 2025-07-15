// lib/features/dashboard/widgets/author_series_dashboard.dart (veya uygun bir yola koyun)

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/features/publish/widgets/comicFilmStrip.dart';

/// Bu ana widget, yazarın tüm serilerini listeler.
class AuthorSeriesDashboard extends ConsumerWidget {
  const AuthorSeriesDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yeni oluşturduğumuz provider'ı izliyoruz.
    final authorSeriesAsync = ref.watch(authorSeriesProvider);

    return authorSeriesAsync.when(
      data: (seriesSnapshot) {
        if (seriesSnapshot.docs.isEmpty) {
          return const Center(
            child: Text(
              'Henüz yayınlanmış bir seriniz bulunmuyor.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // ListView.separated ile her seri arasına bir ayırıcı (Divider) koyuyoruz.
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: seriesSnapshot.docs.length,
          separatorBuilder: (context, index) => const Divider(
            height: 50,
            thickness: 1.5,
            color: Colors.black12,
          ),
          itemBuilder: (context, index) {
            final seriesDoc = seriesSnapshot.docs[index];
            // Her bir seri için _SingleSeriesView widget'ını oluşturuyoruz.
            return _SingleSeriesView(seriesDoc: seriesDoc);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        // ı want to print error message as log
        print("Seriler yüklenirken bir hata oluştu: $e");
        return Center(child: Text("Seriler yüklenirken bir hata oluştu: $e"));
      },
    );
  }
}

/// Bu alt widget, TEK BİR seriyi ve onun bölümlerini gösterir.
class _SingleSeriesView extends ConsumerWidget {
  final DocumentSnapshot seriesDoc;

  const _SingleSeriesView({super.key, required this.seriesDoc});

  @override
  // _SingleSeriesView içinde

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Responsive durumu ve verileri al.
    final bool isWideScreen = context.isTablet; // responsive.dart dosyanızdan
    final seriesId = seriesDoc.id;
    final seriesData = seriesDoc.data() as Map<String, dynamic>;
    final episodesAsync = ref.watch(allEpisodesForSeriesProvider(seriesId));

    // 2. Ana layout widget'ı olarak Flex kullan.
    return Flex(
      // Geniş ekran ise yatay (Row), değilse dikey (Column) dizilim.
      direction: isWideScreen ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Her iki durumda da elemanları başa hizala
      children: [
        // 1. Parça: Seri Bilgileri
        // Bu bölümün esnek olmasını istiyoruz, bu yüzden Flexible kullanıyoruz.
        Flexible(
          // Geniş ekranda flex değeri önemli, dar ekranda daha az önemli.
          flex: isWideScreen ? 3 : 0, // Dar ekranda flex'e gerek yok
          child: _buildSeriesInfoCard(seriesData, context),
        ),

        // Geniş ekranda araya boşluk koy.
        if (isWideScreen) const SizedBox(width: 32),
        // Dar ekranda araya dikey boşluk koy.
        if (!isWideScreen) const SizedBox(height: 24),

        // 2. Parça: Bölümler
        Flexible(
          flex: isWideScreen ? 3 : 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Bölümler',
                    style:
                        AppTextStyles.subheading.copyWith(color: Colors.black)),
              ),
              episodesAsync.when(
                data: (publishedDocs) {
                  if (publishedDocs.isEmpty) {
                    return const Text("Bu seriye ait bölüm bulunmuyor.");
                  }
                  // Dar ekranda (Column içinde Column), bu iç Column'un
                  // dikeyde esnememesi için shrinkWrap: true kullanmak iyidir.
                  // Ama şu anki yapıda doğrudan Column kullanıyoruz.
                  return Column(
                    children: publishedDocs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      return _buildEpisodeCard(context, ref, doc, index + 1);
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text("Bölümler yüklenemedi: $e"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sadece seri bilgilerini gösteren kart
  Widget _buildSeriesInfoCard(Map<String, dynamic> data, BuildContext context) {
    DateTime? createdAt = data['createdAt']?.toDate();
    String currentStatus = data['completionStatus'] ?? 'ongoing';
    String seriesId = data['id'];

    final String status = data['status'] as String? ?? 'unknown';
    Color statusColor = Colors.grey;
    String statusText = "Bilinmiyor";
    String hoverText = "Bilinmiyor";

    // Status'e göre renk ve metin belirle
    switch (status) {
      case 'pending':
        statusColor = AppColors.accent;
        statusText = "•••";
        hoverText = "Onay Bekliyor";
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = "✔";
        hoverText = "Onaylandı";
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = "✘";
        hoverText = "Reddedildi";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text('Seri',
              style: AppTextStyles.subheading.copyWith(color: Colors.black)),
        ),
        Card(
          color: AppColors.bg,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['squareImageUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(data['squareImageUrl'],
                        width: 180,
                        height: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.error, size: 80)),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${data['title'] ?? 'Başlık Yok'}',
                                style: AppTextStyles.title
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Text(
                            '${data['category1'] ?? 'Kategori Yok'} • ${data['category2'] ?? ''}',
                            style: AppTextStyles.text
                                .copyWith(color: Colors.black, fontSize: 12)),
                        const SizedBox(height: 4),
                        if (createdAt != null)
                          Text(DateFormat('dd.MM.yyyy').format(createdAt),
                              style: AppTextStyles.text
                                  .copyWith(color: Colors.black, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('${data['authorName'] ?? 'Yazar Yok'}',
                            style: AppTextStyles.text
                                .copyWith(color: Colors.black, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          data['summary'] ?? 'Özet Yok',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text
                              .copyWith(color: Colors.black87, fontSize: 14),
                        ),
                        // const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Seri ",
                              style: TextStyle(fontSize: 14),
                            ),
                            DropdownButton<String>(
                              style: const TextStyle(fontSize: 14),
                              underline: const SizedBox(),
                              focusColor: Colors.transparent,
                              // dropdownColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              value: currentStatus,
                              items: const [
                                DropdownMenuItem(
                                    value: 'ongoing',
                                    child: Text('Devam Ediyor')),
                                DropdownMenuItem(
                                    value: 'completed',
                                    child: Text('Tamamlandı')),
                              ],
                              onChanged: (newValue) async {
                                if (newValue != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('series')
                                        .doc(seriesId)
                                        .update({'completionStatus': newValue});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Seri durumu güncellendi."),
                                          backgroundColor: Colors.green),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Hata: $e"),
                                          backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Bölüm Kartı Widget'ı (Sizin kodunuzdan, küçük bir değişiklikle) ----

// `UnifiedEpisode` sınıfına artık gerek yok, doğrudan dökümanı kullanabiliriz.
final episodeExpandProvider =
    StateProvider.family<bool, String>((ref, id) => false);

Widget _buildEpisodeCard(BuildContext context, WidgetRef ref,
    QueryDocumentSnapshot episodeDoc, int i) {
  final widthH = MediaQuery.of(context).size.width;
  final heightH = MediaQuery.of(context).size.height;
  final isExpanded = ref.watch(episodeExpandProvider(episodeDoc.id));

  final data = episodeDoc.data() as Map<String, dynamic>;
  final title = data['title'] ?? 'Başlık Yok';
  final thumbnail = data['imageUrl'] as String?;
  final pages = List<String>.from(data['pages'] ?? []);
  final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

  final String status = data['status'] as String? ?? 'unknown';
  Color statusColor = Colors.grey;
  String hoverText = "Bilinmiyor";

  // Status'e göre renk ve metin belirle
  switch (status) {
    case 'pending':
      statusColor = AppColors.accent;
      hoverText = "Onay Bekliyor";
      break;
    case 'approved':
      statusColor = Colors.green;

      hoverText = "Onaylandı";
      break;
    case 'rejected':
      statusColor = Colors.red;
      hoverText = "Reddedildi";
      break;
  }

  // Bölüm numarasını almak için bir yol (eğer veritabanında yoksa)
  // Bu daha karmaşık bir mantık gerektirebilir, şimdilik statik bırakalım.
  // Gerçek bir numara için üst widget'tan index geçmek gerekir.
  final episodeNumberText = i.toString();

  Widget thumbnailWidget;
  if (thumbnail != null) {
    thumbnailWidget = Image.network(thumbnail,
        height: heightH * 0.18,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _buildImageError(context));
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
      height: isExpanded ? heightH * 0.73 : heightH * 0.22,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title
                                      .copyWith(color: Colors.black)),
                            ),
                            Tooltip(
                              message: hoverText,
                              child: Chip(
                                label: Icon(
                                  status == 'pending'
                                      ? Icons.pending_actions
                                      : status == 'approved'
                                          ? Icons.check
                                          : Icons.close,
                                  color: Colors.white,
                                ),
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: statusColor,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 1, vertical: 0),
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null)
                          Text(DateFormat('dd.MM.yyyy').format(createdAt),
                              style: AppTextStyles.text
                                  .copyWith(color: Colors.black, fontSize: 12)),
                        Text('Bölüm $episodeNumberText',
                            style: AppTextStyles.text
                                .copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref
                        .read(episodeExpandProvider(episodeDoc.id).notifier)
                        .state = !isExpanded,
                    icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: (pages.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ComicFilmStrip(pages: pages))
                    : const Center(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text("Bu bölüme ait sayfa yok."))),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                  return Stack(clipBehavior: Clip.none, children: <Widget>[
                    Positioned(key: bottomKey, child: bottomChild),
                    Positioned(key: topKey, child: topChild)
                  ]);
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
