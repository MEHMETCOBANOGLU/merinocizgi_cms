// lib/mobileFeatures/account/widgets/reading_history_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart'; // Yeni provider'ı import et

// Bu widget, "Okumaya Devam Et" sekmesinin içeriğini çizer.
class ReadingHistoryList extends ConsumerWidget {
  const ReadingHistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return historyAsync.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return const Center(
            child: Text("Henüz bir şey okumaya başlamadın!"),
          );
        }

        // Dikey bir liste ile okunan serileri göster.
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Her bir okuma kaydı için özel bir kart widget'ı
            return _HistoryCard(data: data);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        print("ReadingHistoryList Hata: $e");
        return Center(child: Text("Okuma geçmişi yüklenemedi: $e"));
      },
    );
  }
}

// Tek bir okuma geçmişi elemanını gösteren kart.
// class _HistoryCard extends StatelessWidget {
//   final Map<String, dynamic> data;
//   const _HistoryCard({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12.0),
//       child: InkWell(
//         onTap: () {
//           // Kullanıcıyı, kaldığı bölümü okumaya devam etmesi için ReaderPage'e yönlendir.
//           context
//               .push('/reader/${data['seriesId']}/${data['lastReadEpisodeId']}');
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   data['seriesImageUrl'] ?? '',
//                   width: 60,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (c, e, s) =>
//                       Container(width: 60, height: 80, color: Colors.grey[200]),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['seriesTitle'] ?? 'Seri Başlığı Yok',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Okumaya Devam Et: ${data['lastReadEpisodeTitle'] ?? 'Bölüm'}",
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),      Text(
//                       "Okumaya Devam Et: ${data['lastReadEpisodeTitle'] ?? 'Bölüm'}",
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _HistoryCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gerekli ID'leri veriden alalım.
    final String seriesId = data['seriesId'] ?? '';
    final String lastReadEpisodeId = data['lastReadEpisodeId'] ?? '';

    // Bu seriye ait TÜM bölümlerin listesini izle.
    final episodesAsync = ref.watch(allEpisodesForSeriesProvider(seriesId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Tıklama mantığı aynı, kullanıcıyı kaldığı bölüme yönlendirir.
          if (seriesId.isNotEmpty && lastReadEpisodeId.isNotEmpty) {
            context.push('/reader/$seriesId/$lastReadEpisodeId');
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
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      "${data['lastReadEpisodeTitle'] ?? 'Bölüm'}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // --- ANA DEĞİŞİKLİK BURADA ---
                    // Bölüm listesinin durumuna göre metni göster.
                    episodesAsync.when(
                      data: (episodeDocs) {
                        // Son okunan bölümün listedeki index'ini (sırasını) bul.
                        final int episodeIndex = episodeDocs
                            .indexWhere((doc) => doc.id == lastReadEpisodeId);

                        // Eğer bölüm bulunduysa (index -1 değilse), numarasını göster.
                        if (episodeIndex != -1) {
                          // index 0'dan başladığı için, bölüm numarası index + 1 olur.
                          return Text(
                            "${episodeIndex + 1}. Bölüm",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          );
                        }

                        // Eğer bir sebepten bölüm bulunamazsa (silinmiş olabilir), başlığını göster.
                        return Text(
                          "Okumaya Devam Et: ${data['lastReadEpisodeTitle'] ?? ''}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        );
                      },
                      // Bölümler yüklenirken veya hata olduğunda gösterilecek metin.
                      loading: () => Text("Bölüm bilgisi yükleniyor...",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      error: (e, st) => Text("Bölüm bilgisi alınamadı.",
                          style: TextStyle(color: Colors.red, fontSize: 14)),
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
