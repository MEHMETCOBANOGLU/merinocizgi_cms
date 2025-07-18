// lib/mobileFeatures/account/widgets/reading_history_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Her satırda 3 öğe
            mainAxisSpacing: 6,
            crossAxisSpacing: 14,
            childAspectRatio: 1, // Genişlik/yükseklik oranı
            mainAxisExtent: 210, // Satır genişligi mainAxisExtent,
          ),
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Her bir seri kartı için özel bir kart widget'ı
            return _HistoryCard(data: data);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        print("MySeriesyList Hata: $e");
        return Center(child: Text("Seriler yüklenemedi: $e"));
      },
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.white30, // Kenar rengi
          width: 2, // Kenar kalınlığı
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // color: AppColors.card,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['squareImageUrl'] ?? '',
                  width: 105,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 60, height: 80, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  data['title'] ?? 'Seri Başlığı Yok',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
