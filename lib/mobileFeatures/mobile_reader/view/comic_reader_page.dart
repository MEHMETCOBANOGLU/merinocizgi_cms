// lib/mobileFeatures/mobile_reader/view/reader_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';

class ComicReaderPage extends ConsumerStatefulWidget {
  final String seriesId;
  final String episodeId;

  const ComicReaderPage({
    Key? key,
    required this.seriesId,
    required this.episodeId,
  }) : super(key: key);

  @override
  ConsumerState<ComicReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ComicReaderPage> {
  // Sadece bir kez çalışmasını sağlamak için bayraklar
  bool _historyUpdateInitiated = false;
  bool _viewCountTriggered = false;

  @override
  void initState() {
    super.initState();
    // initState'te, bir sonraki frame çizildikten sonra işlemleri başlat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Artık argüman olmadan çağırıyoruz.
      _updateHistory();
      _triggerViewEvent();
    });
  }

  /// Okuma geçmişini GÜVENLİ bir şekilde güncelleyen metot.
  Future<void> _updateHistory() async {
    // Eğer işlem zaten başlatıldıysa, tekrar çalıştırma.
    if (_historyUpdateInitiated || !mounted) return;
    setState(
        () => _historyUpdateInitiated = true); // Tekrar çağrılmasını engelle

    try {
      // Gerekli verileri doğrudan ref.read ile al.
      // addPostFrameCallback içinde olduğumuz için 'read' kullanmak güvenlidir.
      final seriesDoc = await ref.read(seriesProvider(widget.seriesId).future);
      final episodeDocs =
          await ref.read(allEpisodesForSeriesProvider(widget.seriesId).future);

      if (!seriesDoc.exists || episodeDocs.isEmpty) {
        print("Seri veya bölüm verisi bulunamadı.");
        return;
      }

      final seriesData = seriesDoc.data() as Map<String, dynamic>;
      final episodeDoc =
          episodeDocs.firstWhere((doc) => doc.id == widget.episodeId);
      final episodeData = episodeDoc.data() as Map<String, dynamic>;

      // Controller'daki metodu çağırarak geçmişi güncelle.
      await ref
          .read(MyAccountControllerProvider.notifier)
          .updateUserReadingHistory(
            seriesId: widget.seriesId,
            seriesTitle: seriesData['title'] ?? '',
            seriesImageUrl: seriesData['squareImageUrl'] ?? '',
            episodeId: widget.episodeId,
            episodeTitle: episodeData['title'] ?? '',
          );
      print("Okuma geçmişi güncellendi.");
    } catch (e) {
      print("Geçmiş güncellenirken hata (ama UI etkilenmez): $e");
    }
  }

  // --- YENİ FONKSİYON: OKUMA OLAYINI KAYDETME ---
  Future<void> _triggerViewEvent() async {
    // Eğer bu olay zaten tetiklendiyse, tekrar çalıştırma.
    if (_viewCountTriggered) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 'readEvents' koleksiyonuna yeni bir olay kaydı ekle.
      await FirebaseFirestore.instance.collection('readEvents').add({
        'userId': user.uid,
        'seriesId': widget.seriesId,
        'episodeId': widget.episodeId,
        'readAt': FieldValue.serverTimestamp(),
        // Platform (web, android, ios) gibi ek bilgiler de eklenebilir.
      });

      // Bayrağı true yap ki bu sayfada tekrar tetiklenmesin.
      if (mounted) {
        setState(() {
          _viewCountTriggered = true;
        });
      }
    } catch (e) {
      // Bu işlem kullanıcıyı etkilemediği için hata göstermeye gerek yok.
      print("Okuma olayı kaydedilirken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bölüm sayfalarını getiren provider'ı izle.
    final episodeAsync =
        ref.watch(allEpisodesForSeriesProvider(widget.seriesId));

    return Scaffold(
      appBar: AppBar(
          // ... (AppBar'ı istediğin gibi doldurabilirsin)
          ),
      body: episodeAsync.when(
        data: (episodeDocs) {
          // İlgili bölümün sayfalarını bul
          final episodeDoc = episodeDocs.firstWhere(
              (doc) => doc.id == widget.episodeId,
              orElse: () => throw "Bölüm bulunamadı");
          final pages = List<String>.from(
              (episodeDoc.data() as Map<String, dynamic>)['pages'] ?? []);

          if (pages.isEmpty) {
            return const Center(child: Text("Bu bölüm için sayfa bulunamadı."));
          }

          return ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Image.network(pages[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Sayfalar yüklenemedi: $e")),
      ),
    );
  }
}
