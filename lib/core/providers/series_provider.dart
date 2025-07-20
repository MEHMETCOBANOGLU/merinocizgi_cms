// lib/core/providers/series_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

//==============================================================================
// TEKİL VERİ ÇEKME PROVIDER'LARI
//==============================================================================

/// Tek bir serinin verisini ANLIK OLARAK (stream) getirir.
/// Bu, bir serinin detaylarını gösteren tüm sayfalar için temel provider'dır.
final seriesProvider = StreamProvider.autoDispose
    .family<DocumentSnapshot, String>((ref, seriesId) {
  if (seriesId.isEmpty) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('series')
      .doc(seriesId)
      .snapshots();
});

/// Bir serinin TÜM bölümlerini ANLIK OLARAK (stream) getirir.
/// Yazar ve Admin panelleri gibi, bir serinin tüm bölümlerinin (pending, approved vs.)
/// görülmesi gereken yerlerde kullanılır.
final allEpisodesForSeriesProvider = StreamProvider.autoDispose
    .family<List<QueryDocumentSnapshot>, String>((ref, seriesId) {
  // Önce ana serinin durumunu izleyerek "yarış durumu" hatalarını önler.
  final seriesAsyncValue = ref.watch(seriesProvider(seriesId));

  // Ana seri verisi henüz gelmediyse veya hata varsa, bölüm sorgusu yapmaz.
  if (seriesAsyncValue is! AsyncData ||
      !(seriesAsyncValue.value?.exists ?? false)) {
    return const Stream.empty();
  }

  final stream = FirebaseFirestore.instance
      .collection('series')
      .doc(seriesId)
      .collection('episodes')
      .orderBy('createdAt', descending: false)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

//==============================================================================
// ROL BAZLI LİSTELEME PROVIDER'LARI
//==============================================================================

/// OKUYUCULAR için: Ana sayfada gösterilecek, yayınlanmış serileri listeler.
final approvedSeriesProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots();
});

/// OKUYUCULAR için: Bir serinin sadece ONAYLANMIŞ bölümlerini listeler.
final approvedEpisodesProvider = StreamProvider.autoDispose
    .family<List<QueryDocumentSnapshot>, String>((ref, seriesId) {
  final stream = FirebaseFirestore.instance
      .collection('series')
      .doc(seriesId)
      .collection('episodes')
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: false)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

/// YAZARLAR için: Bir kullanıcının kendi sahip olduğu serilerin sayısını getirir.
final userSeriesCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('authorId', isEqualTo: userId) // sadece o kullanıcıya ait veriler
      .snapshots()
      .map((snapshot) => snapshot.size); // belge sayısını alıyoruz
});

/// YAZARLAR için: Bir kullanıcının kendi sahipği serilerini listeler.
final userSeriesProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('authorId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots();
});

/// YAZARLAR için: Oturum açmış kullanıcının kendi sahip olduğu tüm serileri listeler.
final authorSeriesProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('series')
      .where('authorId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
});

//==============================================================================
// ÖZELLİK BAZLI PROVIDER'LAR (Footer vb.)
//==============================================================================

/// Footer'daki "Haftanın Serisi" kartı için öne çıkan seriyi getirir.
final featuredSeriesProvider =
    FutureProvider.autoDispose<DocumentSnapshot?>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('series')
        .where('hasPublishedEpisodes', isEqualTo: true)
        .orderBy('approvedEpisodes',
            descending: true) // En çok onaylı bölümü olanı öne çıkar
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  } catch (e) {
    print("featuredSeriesProvider Hata: $e");
    return null;
  }
});

/// Footer'daki "Yeni Sanatçı" kartı için en son katılan kullanıcıyı getirir.
final newArtistProvider =
    FutureProvider.autoDispose<DocumentSnapshot?>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  } catch (e) {
    print("newArtistProvider Hata: $e");
    return null;
  }
});

//==============================================================================
// UI STATE PROVIDER'LARI (Genellikle kendi feature dosyalarında olmaları daha iyidir)
//==============================================================================

// Önizleme kısmında bölümler alanındaki ikonun durumunu tutar.
final arrowProvider = StateProvider<bool>((ref) => false);

//==============================================================================
// Mobilde KULLANILAN PROVIDER'LARI
//==============================================================================

/// Sadece TAMAMLANMIŞ serileri listeler.
final completedSeriesProvider =
    StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true) // En az bir bölümü olmalı
      .where('completionStatus',
          isEqualTo: 'completed') // Durumu 'tamamlandı' olmalı
      .orderBy('createdAt', descending: true)
      .snapshots();
});

// 1. Haftanın Serisi (En Yüksek Puanlı İlk 5)
// Bu provider, 'averageRating' alanına göre sıralama yapar.
final topFeaturedSeriesProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  final stream = FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      // 'averageRating' alanının Firestore'da olduğundan emin olun.
      .orderBy('averageRating', descending: true)
      .limit(5) // Sadece ilk 5'i al
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

// 2. Top 5 Drama Serisi
// Bu provider, kategoriye göre filtreler ve puana göre sıralar.
final topDramaSeriesProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  final stream = FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      // Kategori 1 veya Kategori 2'nin 'DRAM' olup olmadığını kontrol eder.
      // Firestore'da OR sorgusu yapmak zordur, bu yüzden genellikle tek bir kategori alanına odaklanılır.
      .where('category1', isEqualTo: 'DRAM')
      .orderBy('averageRating', descending: true)
      .limit(5)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

/// [DİNAMİK] Verilen bir kategoriye göre en yüksek puanlı 5 seriyi getirir.
/// Bu, 'ref.watch(topSeriesByCategoryProvider("DRAMA"))' gibi çağrılır.
final topSeriesByCategoryProvider = StreamProvider.autoDispose
    .family<List<DocumentSnapshot>, String>((ref, category) {
  // Eğer kategori boşsa, sorgu yapma.
  if (category.isEmpty) {
    return const Stream.empty();
  }

  final stream = FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      // 'category1' veya 'category2' alanlarından birinin seçilen kategoriyle eşleşmesini kontrol et.
      // Firestore, tek bir sorguda iki farklı alan için 'OR' koşulunu doğrudan desteklemez.
      // En yaygın çözüm, 'tags' veya 'categories' adında bir dizi (array) alanı kullanmaktır.
      // Örnek: .where('categories', arrayContains: category)
      // Şimdilik, sadece 'category1'e göre filtreleyelim.
      .where('category1', isEqualTo: category)
      .orderBy('averageRating', descending: true) // Puana göre sırala
      .limit(5)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

/// [POPÜLERLİK] En YÜKSEK PUANA sahip serileri listeler.
final highestRatedSeriesProvider =
    StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      .orderBy('averageRating', descending: true) // Ana sıralama kriteri
      .limit(10) // Performans için bir limit koyalım
      .snapshots();
});

/// [POPÜLERLİK] En ÇOK GÖRÜNTÜLENEN serileri listeler.
final mostViewedSeriesProvider =
    StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      .orderBy('viewCount', descending: true) // Ana sıralama kriteri
      .limit(10)
      .snapshots();
});
