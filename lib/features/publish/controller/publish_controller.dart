import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:merinocizgi/features/publish/controller/episode_draft_model.dart';
import 'package:merinocizgi/features/publish/controller/series_draft_provider.dart';
import 'package:image/image.dart' as img;

class PublishController extends StateNotifier<AsyncValue<void>> {
  PublishController() : super(const AsyncData(null));
  Future<Uint8List> compressWebImage(Uint8List originalBytes) async {
    final image = img.decodeImage(originalBytes);
    if (image == null) throw Exception("Görsel okunamadı");

    final compressed = img.encodeJpg(image, quality: 30);
    final compressedBytes = Uint8List.fromList(compressed);

    // Sıkıştırma sonrası daha büyükse orijinalini kullan
    return compressedBytes.lengthInBytes < originalBytes.lengthInBytes
        ? compressedBytes
        : originalBytes;
  }

  // Future<String> _uploadImage(Uint8List imageData, String path) async {
  //   final ref = FirebaseStorage.instance.ref().child(path);
  //   final uploadTask = await ref.putData(imageData);
  //   return await uploadTask.ref.getDownloadURL();
  // }
  Future<String> _uploadImage(Uint8List imageData, String path) async {
    // print("Önce: ${imageData.lengthInBytes / 1024} KB");
    final compressedData = await compressWebImage(imageData); // Sıkıştır
    // print("Sonra: ${compressedData.lengthInBytes / 1024} KB");
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await ref.putData(compressedData);

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> publishFullSeries(SeriesDraft draft) async {
    state = const AsyncLoading();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AsyncError(Exception("Oturum açılmamış."), StackTrace.current);
      throw Exception("Oturum açılmamış.");
    }

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Hangi senaryoda olduğumuzu kontrol ediyoruz.
      if (draft.seriesId != null && draft.seriesId!.isNotEmpty) {
        // Senaryo 2: Var olan bir seriye bölüm ekleniyor.
        await _addEpisodesToExistingSeries(batch, draft);
      } else {
        // Senaryo 1: Yeni bir seri oluşturuluyor.
        await _createNewSeries(batch, draft, user);
      }

      // Tüm işlemleri tek seferde veritabanına yaz.
      await batch.commit();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // --- YARDIMCI ÖZEL METOD 1: YENİ SERİ OLUŞTURMA ---
  Future<void> _createNewSeries(
      WriteBatch batch, SeriesDraft draft, User user) async {
    if (draft.squareImage == null || draft.verticalImage == null) {
      throw Exception("Yeni seri için kapak görselleri eksik.");
    }

    // Yeni seri için bir döküman referansı oluştur.
    final seriesRef = FirebaseFirestore.instance.collection("series").doc();
    final seriesId = seriesRef.id;

    // Seri görsellerini Storage'a yükle.
    final squareImageUrl =
        await _uploadImage(draft.squareImage!, 'series/$seriesId/square.jpg');
    final verticalImageUrl = await _uploadImage(
        draft.verticalImage!, 'series/$seriesId/vertical.jpg');

    // Seri verisini batch'e ekle.
    batch.set(seriesRef, {
      'id': seriesId,
      'title': draft.title,
      'summary': draft.summary,
      'category1': draft.category1,
      'category2': draft.category2,
      'authorId': user.uid,
      'authorName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'squareImageUrl': squareImageUrl,
      'verticalImageUrl': verticalImageUrl,
      // 'published': true,
      'totalEpisodes': 0,
      'approvedEpisodes': 0,
      'hasPublishedEpisodes': false,
      // 'status': 'pending', // KALDIRILDI
      'completionStatus': 'ongoing',
      'averageRating': 0.0,
      'ratingCount': 0,
      'viewCount': 0
    });

    // Bu yeni serinin bölümlerini ekle.
    await _uploadAndBatchEpisodes(batch, seriesId, draft.episodes);
  }

  // --- YARDIMCI ÖZEL METOD 2: VAR OLAN SERİYE BÖLÜM EKLEME ---
  Future<void> _addEpisodesToExistingSeries(
      WriteBatch batch, SeriesDraft draft) async {
    // Sadece yeni bölümleri ekliyoruz.
    await _uploadAndBatchEpisodes(batch, draft.seriesId!, draft.episodes);
  }

  // --- ORTAK KULLANILAN YARDIMCI METOD: BÖLÜMLERİ YÜKLEME VE BATCH'E EKLEME ---
  Future<void> _uploadAndBatchEpisodes(WriteBatch batch, String seriesId,
      List<EpisodeDraftModel> episodeDrafts) async {
    // Her bir bölüm taslağı için işlemleri tekrarla.
    for (final episodeDraft in episodeDrafts) {
      // Bölüm için yeni döküman referansı.
      final episodeRef = FirebaseFirestore.instance
          .collection("series")
          .doc(seriesId)
          .collection("episodes")
          .doc();

      // Bölüm kapağını yükle.
      final thumbnailUrl = await _uploadImage(
        episodeDraft.thumbnail,
        'series/$seriesId/episodes/${episodeRef.id}/thumbnail.jpg',
      );

      // Bölüm sayfalarını yükle ve URL'lerini topla.
      final List<String> pageUrls = [];
      for (int i = 0; i < episodeDraft.pages.length; i++) {
        final pageUrl = await _uploadImage(
          episodeDraft.pages[i],
          'series/$seriesId/episodes/${episodeRef.id}/page_$i.jpg',
        );
        pageUrls.add(pageUrl);
      }

      // Bölüm verisini batch'e ekle.
      batch.set(episodeRef, {
        'id': episodeRef.id,
        'title': episodeDraft.title,
        'imageUrl': thumbnailUrl,
        'pages': pageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        // 'published': true,
        'status': 'pending',
      });
    }
  }
}

// --- ADD THIS LINE ---
// This creates the provider that your UI will use to access the PublishController.
final publishControllerProvider =
    StateNotifierProvider<PublishController, AsyncValue<void>>((ref) {
  return PublishController();
});
