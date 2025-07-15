import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/adminPanel/controller/admin_dashboard_controller.dart';

class EpisodeReviewTile extends ConsumerWidget {
  final DocumentSnapshot episodeDoc;
  const EpisodeReviewTile({super.key, required this.episodeDoc});

  void _showPagesDialog(BuildContext context, List<String> pageUrls) {
    showDialog(
      context: context,
      // barrierColor: Colors.black.withOpacity(0.85), // Arka planı daha koyu yapabiliriz
      builder: (BuildContext context) {
        return Dialog(
          // Kenar boşluklarını azaltarak daha fazla alan kullanalım
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Column(
            children: [
              // Diyalog başlığı ve kapatma butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bölüm Sayfaları (${pageUrls.length})",
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Kaydırılabilir sayfa listesi
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pageUrls.length,
                  itemBuilder: (context, index) {
                    final pageUrl = pageUrls[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            "Sayfa ${index + 1}",
                          ),
                          const SizedBox(height: 4.0),
                          Image.network(
                            pageUrl,
                            // Yüklenirken bir placeholder göster
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            // Hata durumunda bir ikon göster
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  color: Colors.red, size: 50);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = episodeDoc.data() as Map<String, dynamic>;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final List<String> pageUrls = List<String>.from(data['pages'] ?? []);
    final status = data['status'] as String? ?? 'unknown';
    Color statusColor = Colors.grey;
    String statusText = "Bilinmiyor";
    String hoverText = "Bilinmiyor";
    final bool needsAction = (status == 'pending');

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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showPagesDialog(
          context,
          pageUrls,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          margin: const EdgeInsets.only(bottom: 8.0), // Kartlar arasına boşluk
          decoration: BoxDecoration(
            color:
                AppColors.bg, // AppColors.accent yerine beyaz daha iyi olabilir
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          // --- ANA DEĞİŞİKLİK: ListTile YERİNE Row KULLANIYORUZ ---
          child: Row(
            // crossAxisAlignment:
            //     CrossAxisAlignment.start, // Elemanları yukarı hizala
            children: [
              // 1. RESİM BÖLÜMÜ
              // Resim artık doğrudan Row'un çocuğu, bu yüzden boyutları geçerli olacak.
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Image.network(
                  data['imageUrl'],
                  width: 70, // Genişliği biraz azaltalım
                  height: 85, // İSTEDİĞİN YÜKSEKLİK
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      width: 70,
                      height: 85,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image)),
                ),
              ),
              const SizedBox(width: 16.0),
              // 2. BİLGİ BÖLÜMÜ
              // ListTile'ın title ve subtitle'ını taklit etmek için Column kullanıyoruz.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Bölüm Başlığı Yok',
                      style: AppTextStyles.subtitle.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    if (createdAt != null)
                      Text(
                        DateFormat('dd.MM.yyyy').format(createdAt),
                        style: AppTextStyles.text
                            .copyWith(color: Colors.black, fontSize: 16.0),
                      ),
                    const SizedBox(height: 2.0),
                    Text(
                      "${(data['pages'] as List?)?.length ?? 0} sayfa",
                      style: AppTextStyles.text
                          .copyWith(color: Colors.black, fontSize: 16.0),
                    ),
                  ],
                ),
              ),

              // 3. AKSİYON BUTONLARI / CHIP BÖLÜMÜ
              Align(
                alignment: Alignment.center,
                child: needsAction
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: "Reddet",
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              final success = await ref
                                  .read(
                                      adminDashboardControllerProvider.notifier)
                                  .updateEpisodeStatus(
                                    episodeId: episodeDoc.id,
                                    episodeRef: episodeDoc.reference,
                                    seriesId:
                                        episodeDoc.reference.parent.parent!.id,
                                    newStatus: 'rejected',
                                  );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Bölüm reddedildi.")),
                                );
                              }
                            },
                          ),
                          IconButton(
                            tooltip: "Onayla",
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              final success = await ref
                                  .read(
                                      adminDashboardControllerProvider.notifier)
                                  .updateEpisodeStatus(
                                    episodeId: episodeDoc.id,
                                    episodeRef: episodeDoc.reference,
                                    seriesId:
                                        episodeDoc.reference.parent.parent!.id,
                                    newStatus: 'approved',
                                  );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Bölüm onaylandı.")),
                                );
                              }
                            },
                          ),
                        ],
                      )
                    : Chip(
                        label: Text(
                          hoverText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: statusColor,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: statusColor),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
