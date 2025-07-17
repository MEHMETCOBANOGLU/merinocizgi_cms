import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart'; // AccountController için
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String seriesId;
  final String episodeId;

  const ReaderPage({
    Key? key,
    required this.seriesId,
    required this.episodeId,
  }) : super(key: key);

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  // Okuma geçmişinin güncellenip güncellenmediğini takip eden bir state.
  bool _historyUpdated = false;

  /// Okuma geçmişini GÜVENLİ bir şekilde güncelleyen metot.
  void _updateHistory(
      Map<String, dynamic> seriesData, Map<String, dynamic> episodeData) {
    // Controller'daki metodu çağırarak geçmişi güncelle.
    ref.read(MyAccountControllerProvider.notifier).updateUserReadingHistory(
          seriesId: widget.seriesId,
          seriesTitle: seriesData['title'] ?? '',
          seriesImageUrl: seriesData['squareImageUrl'] ?? '',
          episodeId: widget.episodeId,
          episodeTitle: episodeData['title'] ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Hem serinin hem de bölümlerin verisini aynı anda izle.
    final seriesAsync = ref.watch(seriesProvider(widget.seriesId));
    final episodesAsync =
        ref.watch(allEpisodesForSeriesProvider(widget.seriesId));

    return Scaffold(
      appBar: AppBar(
        // Başlığı göstermek için de verinin yüklenmesini bekleyelim
        title: seriesAsync.when(
          data: (doc) => Text((doc.data() as Map?)?['title'] ?? 'Okuyucu'),
          loading: () => const Text('Yükleniyor...'),
          error: (e, s) => const Text('Hata'),
        ),
      ),
      body: seriesAsync.when(
        data: (seriesDoc) {
          // Seri verisi geldi, şimdi bölümleri kontrol et.
          return episodesAsync.when(
            data: (episodeDocs) {
              // Gerekli bölümü listeden bul.
              final episodeDoc = episodeDocs.firstWhere(
                (doc) => doc.id == widget.episodeId,
                // Eğer bulunamazsa bir hata durumu oluştur.
                orElse: () => throw Exception(
                    "Bölüm ID'si bulunamadı: ${widget.episodeId}"),
              );

              final seriesData = seriesDoc.data() as Map<String, dynamic>;
              final episodeData = episodeDoc.data() as Map<String, dynamic>;
              final pages = List<String>.from(episodeData['pages'] ?? []);

              // --- ANA ÇÖZÜM: GÜNCELLEMEYİ build İÇİNDE YAPMAK ---
              // Eğer geçmiş henüz güncellenmediyse, şimdi güncelle.
              if (!_historyUpdated) {
                // build metodu sırasında doğrudan state değiştirmek hatalara yol açabilir.
                // Bu yüzden işlemi bir sonraki frame'e erteliyoruz.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateHistory(seriesData, episodeData);
                  // İşlemin tekrar tekrar çağrılmaması için bayrağı true yap.
                  if (mounted) {
                    setState(() {
                      _historyUpdated = true;
                    });
                  }
                });
              }

              if (pages.isEmpty) {
                return const Center(
                    child: Text("Bu bölüm için sayfa bulunamadı."));
              }

              // Sayfaları gösteren ListView
              return ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    pages[index],
                    // Yüklenirken ve hata durumunda placeholder'lar göster.
                    loadingBuilder: (c, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (c, e, s) =>
                        const Center(child: Icon(Icons.error)),
                  );
                },
              );
            },
            // Bölümler yüklenirken veya hata verdiğinde...
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) {
              print("Bölümler yüklenemedi: $e");
              Center(child: Text("Bölümler yüklenemedi: $e"));
            },
          );
        },
        // Seri yüklenirken veya hata verdiğinde...
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Seri yüklenemedi: $e")),
      ),
    );
  }
}
