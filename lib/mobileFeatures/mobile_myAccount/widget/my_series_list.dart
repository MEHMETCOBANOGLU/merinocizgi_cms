// lib/mobileFeatures/account/widgets/reading_history_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';

// Bu widget, "Serilerim" sekmesinin içeriğini çizer.
class MySeriesyList extends ConsumerWidget {
  final String userId;
  const MySeriesyList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mySeriesAsync = ref.watch(userSeriesProvider(userId));

    return mySeriesAsync.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return const Center(
            child: Text("Henüz bir seri paylaşmadınız!"),
          );
        }

        // Dikey bir liste ile  serileri göster.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0, // Kartlar arası yatay boşluk
            runSpacing: 16.0, // Kartlar arası dikey boşluk
            children: snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              // Kartların genişliğini ekran boyutuna göre ayarlayalım
              final cardWidth = (MediaQuery.of(context).size.width / 3) - 22;

              return SizedBox(
                width: cardWidth,
                child: _HistoryCard(
                  data: data,
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        print("MySeriesyList Hata: $e");
        return Center(child: Text("Seriler yüklenemedi1: $e"));
      },
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final seriesId = data['id'];
          context.push('/detail/$seriesId');
        },
        borderRadius: BorderRadius.circular(12),
        splashColor:
            Colors.white.withValues(alpha: 0.1), // Hafif bir beyaz dalga efekti
        highlightColor:
            Colors.grey.withValues(alpha: 0.05), // Basılı tutunca hafif renk
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  data['squareImageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 60, height: 80, color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                data['title'] ?? 'Seri Başlığı Yok',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
