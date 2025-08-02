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
    .family<DocumentSnapshot<Map<String, dynamic>>, String>((ref, seriesId) {
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
      .limit(3) // Sadece ilk 3'i al
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
      .limit(3)
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

/// [POPÜLERLİK] En ÇOK KATEGORİLERDEN serileri listeler.  Popüler kategorileri belirle
final popularCategoriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('series')
      .where('hasPublishedEpisodes', isEqualTo: true)
      .orderBy('viewCount', descending: true)
      .limit(100)
      .get();

  final categoryCount = <String, int>{};

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final category = data['category1'];
    if (category != null && category is String) {
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
  }

  final sorted = categoryCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(4).map((e) => e.key).toList();
});

///  Bu kategorilere göre en iyi serileri çek
final topSeriesGroupedByPopularCategoriesProvider =
    FutureProvider.autoDispose<List<Map<String, List<DocumentSnapshot>>>>(
        (ref) async {
  final popularCategoriesAsync =
      await ref.watch(popularCategoriesProvider.future);
  final firestore = FirebaseFirestore.instance;

  List<Map<String, List<DocumentSnapshot>>> result = [];

  for (final category in popularCategoriesAsync) {
    final snapshot = await firestore
        .collection('series')
        .where('hasPublishedEpisodes', isEqualTo: true)
        .where('category1', isEqualTo: category)
        .orderBy('averageRating', descending: true)
        .limit(3)
        .get();

    result.add({category: snapshot.docs});
  }

  return result;
});

// kategory chiplerini göstermek için listeyi dişnamik hale getirmeye çalışıyoruz
final nonEmptyCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final allCategories = [
    'AKSİYON',
    'FANTEZİ',
    'KOMEDİ',
    'DRAM',
    'ROMANTİZM',
    'BİLİMKURGU',
    'SÜPER KAHRAMAN',
    'GERİLİM',
    'KORKU',
    'ZOMBİ',
    'OKUL',
    'DOĞAÜSTÜ',
    'HAYVAN',
    'SUÇ/GİZEM',
    'TARİHSEL',
    'BİLGİLENDİRİCİ',
    'SPOR',
    'HER YAŞTAN',
    'KIYAMET SONRASI',
  ];

  final List<String> nonEmpty = [];

  for (final category in allCategories) {
    final data = await ref.read(topSeriesByCategoryProvider(category).future);
    if (data.isNotEmpty) {
      nonEmpty.add(category);
    }
  }

  return nonEmpty;
});
