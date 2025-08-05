// lib/mobileFeatures/account/widgets/reading_history_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/series_books_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart'; // Yeni provider'ı import et

// Bu widget, "Okumaya Devam Et" sekmesinin içeriğini çizer.
class ReadingHistoryList extends ConsumerWidget {
  const ReadingHistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);
    final episodesMapAsync = ref.watch(readingHistoryEpisodesMapProvider);

    return historyAsync.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return const Center(
            child: Text("Henüz bir şey okumaya başlamadın!"),
          );
        }

        return episodesMapAsync.when(
          data: (episodesMap) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.docs[index];
                final data = doc.data() as Map<String, dynamic>;

                return _HistoryCard(
                  data: data,
                  allEpisodesMap: episodesMap,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Bölümler yüklenemedi: $e")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Okuma geçmişi yüklenemedi: $e")),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, List<Map<String, dynamic>>> allEpisodesMap;

  const _HistoryCard({
    required this.data,
    required this.allEpisodesMap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String contentId = data['seriesId'] ?? data['booksId'];
    final String lastReadEpisodeId = data['lastReadEpisodeId'] ?? '';
    final List<Map<String, dynamic>> episodeDocs =
        allEpisodesMap[contentId] ?? [];

    final int episodeIndex = episodeDocs.indexWhere(
      (doc) => doc['id'] == lastReadEpisodeId,
    );

    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white30, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          if (contentId.isNotEmpty && lastReadEpisodeId.isNotEmpty) {
            if (data['contentType'] == 'series') {
              context.push('/comic-reader/$contentId/$lastReadEpisodeId');
            } else if (data['contentType'] == 'books') {
              context.push('/book-reader/$contentId/$lastReadEpisodeId');
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['seriesImageUrl'] ?? '',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 60, height: 80, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['seriesTitle'] ?? 'Seri Başlığı Yok',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (data['contentType'] == 'series')
                      Text(
                        data['lastReadEpisodeTitle'] ?? 'Bölüm',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      episodeIndex != -1
                          ? "${episodeIndex + 1}. Bölüm"
                          : "Okumaya Devam Et: ${data['lastReadEpisodeTitle'] ?? ''}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
