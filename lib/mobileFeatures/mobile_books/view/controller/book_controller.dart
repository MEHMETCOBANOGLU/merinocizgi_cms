// lib/features/books/controller/book_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/domain/entities/book.dart';
import 'package:merinocizgi/domain/entities/chapter.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/create_book_page.dart'; // Book modelimizi import ediyoruz

// Bu provider, UI'ın BookController'a erişmesini sağlar.
final bookControllerProvider =
    StateNotifierProvider.autoDispose<BookController, AsyncValue<String?>>(
        (ref) {
  return BookController();
});

// Kitap oluşturma, güncelleme, silme işlemlerini yöneten ana sınıf.
// State'i, oluşturulan yeni kitabın ID'sini (String?) tutacak.
class BookController extends StateNotifier<AsyncValue<String?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  BookController() : super(const AsyncData(null));

  /// Yeni bir kitap oluşturur, kapağı yükler ve Firestore'a kaydeder.
  /// Başarılı olursa oluşturulan kitabın ID'sini döndürür.
  Future<String?> createBook(BookFormState formState) async {
    state = const AsyncLoading();

    final user = _auth.currentUser;
    if (user == null) {
      state = AsyncError(Exception("Oturum açılmamış."), StackTrace.current);
      return null;
    }

    // Form validasyonu (Controller seviyesinde de yapmak güvenlidir)
    if (formState.title.isEmpty ||
        formState.category == null ||
        formState.copyright == null ||
        formState.coverImage == null) {
      state = AsyncError(
          ("Zorunlu alanlar eksik. Lütfen doldurun."), StackTrace.current);
      return null;
    }

    try {
      // 1. Yeni bir döküman referansı oluştur ve ID'sini al.
      final bookDocRef = _firestore.collection('books').doc();
      final bookId = bookDocRef.id;

      // 2. Kapak resmini Firebase Storage'a yükle.
      final storageRef = _storage.ref().child('book_covers/$bookId/cover.jpg');
      final uploadTask = await storageRef.putData(formState.coverImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // 3. Modeli (Entity) oluştur.
      final newBook = Book(
        bookId: bookId,
        authorId: user.uid,
        authorName: user.displayName ?? 'Bilinmeyen Yazar',
        title: formState.title,
        description: formState.description,
        coverImageUrl: imageUrl,
        category: formState.category!,
        copyright: formState.copyright!,
        tags: formState.tags,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        hasPublishedEpisodes: true,
      );

      // 4. Modeli JSON'a çevirip Firestore'a yaz.
      await bookDocRef.set(newBook.toJson());

      // 5. Başarılı state'ini, yeni oluşturulan bookId ile birlikte ayarla.
      state = AsyncData(bookId);
      return bookId;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

// --- YENİ METOTLAR ---

  /// Bir kitap için yeni bir bölüm oluşturur.
  Future<void> createChapter({
    required String bookId,
    required String title,
    required String content,
    required String status,
  }) async {
    // Bu işlem, state'i doğrudan etkilemediği için loading ayarlamasına gerek yok.
    // UI kendi loading durumunu yönetebilir.
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    try {
      final bookRef = _firestore.collection('books').doc(bookId);
      final chaptersRef = bookRef.collection('chapters');

      // Yeni bölüm numarasını belirlemek için mevcut bölüm sayısını al.
      final chapterCountSnapshot = await chaptersRef.count().get();
      final newChapterNumber = chapterCountSnapshot.count! + 1;

      // Yeni bölüm dökümanı oluştur.
      final newChapter = Chapter(
        chapterNumber: newChapterNumber,
        title: title,
        content: content,
        status: status, // Yeni bölümler taslak olarak başlar
        publishedAt: null,
      );

      final writeBatch = _firestore.batch();
      // Bölümü ekle
      writeBatch.set(chaptersRef.doc(), newChapter.toJson());
      // Ana kitaptaki sayaçları ve son güncelleme tarihini güncelle
      writeBatch.update(bookRef, {
        'chapterCount': FieldValue.increment(1),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await writeBatch.commit();
    } catch (e) {
      // Hata olursa UI'a bildirmek için yeniden fırlat.
      rethrow;
    }
  }

  /// Mevcut bir bölümü günceller.
  Future<void> updateChapter({
    required String bookId,
    required String chapterId,
    required String title,
    required String content,
    String? status, // status artık opsiyonel
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    try {
      final bookRef = _firestore.collection('books').doc(bookId);
      final chapterRef = bookRef.collection('chapters').doc(chapterId);

      final writeBatch = _firestore.batch();

      // Güncellenecek alanlar
      final Map<String, dynamic> updateData = {
        'title': title,
        'content': content,
      };

      if (status != null) {
        updateData['status'] = status;
      }

      // Bölümü güncelle
      writeBatch.update(chapterRef, updateData);

      // Kitabın son güncelleme tarihini güncelle
      writeBatch.update(bookRef, {
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await writeBatch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChapter({
    required String bookId,
    required String chapterId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    try {
      final bookRef = _firestore.collection('books').doc(bookId);
      final chapterRef = bookRef.collection('chapters').doc(chapterId);

      final writeBatch = _firestore.batch();

      // 1. Bölümü sil
      writeBatch.delete(chapterRef);

      // 2. Kitaptaki bölüm sayısını azalt ve son güncellemeyi güncelle
      writeBatch.update(bookRef, {
        'chapterCount': FieldValue.increment(-1),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await writeBatch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // --- YENİ METOT: BÖLÜMÜ YAYINLA/TASLAĞA GERİ AL ---
  /// Bir bölümün durumunu değiştirir ('draft' <-> 'published').
  Future<void> toggleChapterStatus({
    required String bookId,
    required String chapterId,
    required String currentStatus,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    // Yeni durum, mevcut durumun tersi olacak.
    final newStatus = currentStatus == 'draft' ? 'published' : 'draft';
    // Eğer yayınlanıyorsa, yayınlanma tarihini de set et.
    final updateData = {
      'status': newStatus,
      'publishedAt':
          newStatus == 'published' ? FieldValue.serverTimestamp() : null,
    };

    try {
      await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .doc(chapterId)
          .update(updateData);
    } catch (e) {
      rethrow;
    }
  }
}

/// Oturum açmış yazarın sahip olduğu tüm kitapları listeler.
final authorBooksProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('books')
      .where('authorId', isEqualTo: user.uid)
      .orderBy('lastUpdatedAt', descending: true)
      .snapshots();
});

/// Bir kitaba ait tüm bölümleri (taslak ve yayınlanmış) listeler.
final bookChaptersProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, bookId) {
  return FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .collection('chapters')
      .orderBy('chapterNumber', descending: false)
      .snapshots();
});

// --- BÖLÜM VERİSİNİ ÇEKMEK İÇİN YENİ PROVIDER ---
/// ID'si verilen tek bir bölümün verisini anlık olarak getirir.
final chapterProvider = StreamProvider.autoDispose
    .family<DocumentSnapshot, ({String bookId, String chapterId})>((ref, ids) {
  if (ids.bookId.isEmpty || ids.chapterId.isEmpty) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('books')
      .doc(ids.bookId)
      .collection('chapters')
      .doc(ids.chapterId)
      .snapshots();
});

// Tek bir kitabın verisini getirir.
final bookProvider =
    StreamProvider.autoDispose.family<DocumentSnapshot, String>((ref, bookId) {
  if (bookId.isEmpty) return const Stream.empty();
  return FirebaseFirestore.instance.collection('books').doc(bookId).snapshots();
});

/// OKUYUCULAR için: Bir kitabın sadece yayınlanmış bölümlerini listeler.
final publishedChaptersProvider = StreamProvider.autoDispose
    .family<List<QueryDocumentSnapshot>, String>((ref, bookId) {
  final stream = FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .collection('chapters')
      .where('status', isEqualTo: 'published')
      .orderBy('chapterNumber', descending: false)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

///////////////////
///
/// OKUYUCULAR için ana sayfada gösterilecek ONAYLANMIŞ kitapları listeler.
final publicBooksProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      // Kitaplar için 'hasPublishedChapters' gibi bir alan olmalı.
      // Şimdilik olmadığını varsayarak devam edelim.
      // .where('isPublished', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots();
});

/// En YÜKSEK PUANA sahip kitapları listeler.
final highestRatedBooksProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      .orderBy('averageRating', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// 1. Haftanın Kitapları (En Yüksek Puanlı İlk 3)
// Bu provider, 'averageRating' alanına göre sıralama yapar.
final topFeaturedBooksProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  final stream = FirebaseFirestore.instance
      .collection('books')
      .where('hasPublishedEpisodes', isEqualTo: true)
      // 'averageRating' alanının Firestore'da olduğundan emin olun.
      .orderBy('averageRating', descending: true)
      .limit(3) // Sadece ilk 3'i al
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

/// [POPÜLERLİK] En ÇOK KATEGORİLERDEN kitapları listeler.  Popüler kategorileri belirle
final popularCategoriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('books')
      .where('hasPublishedEpisodes', isEqualTo: true)
      .where('averageRating', isGreaterThan: 0)
      .orderBy('viewCount', descending: true)
      .limit(100)
      .get();

  final categoryCount = <String, int>{};

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final category = data['category'];
    if (category != null && category is String) {
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
  }

  final sorted = categoryCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(4).map((e) => e.key).toList();
});

///  Bu kategorilere göre en iyi kitapları çek
final topBooksGroupedByPopularCategoriesProvider =
    FutureProvider.autoDispose<List<Map<String, List<DocumentSnapshot>>>>(
        (ref) async {
  final popularCategoriesAsync =
      await ref.watch(popularCategoriesProvider.future);
  final firestore = FirebaseFirestore.instance;

  List<Map<String, List<DocumentSnapshot>>> result = [];

  for (final category in popularCategoriesAsync) {
    final snapshot = await firestore
        .collection('books')
        .where('hasPublishedEpisodes', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('averageRating', descending: true)
        .where('chapterCount', isGreaterThan: 0)
        .limit(3)
        .get();

    result.add({category: snapshot.docs});
  }

  return result;
});

/// Sadece TAMAMLANMIŞ KITAPLARI listeler.
final completedBooksProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      .where('hasPublishedEpisodes', isEqualTo: true) // En az bir bölümü olmalı
      .where('status', isEqualTo: 'completed') // Durumu 'tamamlandı' olmalı
      .orderBy('createdAt', descending: true)
      .snapshots();
});

/// [DİNAMİK] Verilen bir kategoriye göre en yüksek puanlı 5 seriyi getirir.
/// Bu, 'ref.watch(topSeriesByCategoryProvider("DRAMA"))' gibi çağrılır.
final topBooksByCategoryProvider = StreamProvider.autoDispose
    .family<List<DocumentSnapshot>, String>((ref, category) {
  // Eğer kategori boşsa, sorgu yapma.
  if (category.isEmpty) {
    return const Stream.empty();
  }

  final stream = FirebaseFirestore.instance
      .collection('books')
      .where('hasPublishedEpisodes', isEqualTo: true)
      // 'category1' veya 'category2' alanlarından birinin seçilen kategoriyle eşleşmesini kontrol et.
      // Firestore, tek bir sorguda iki farklı alan için 'OR' koşulunu doğrudan desteklemez.
      // En yaygın çözüm, 'tags' veya 'categories' adında bir dizi (array) alanı kullanmaktır.
      // Örnek: .where('categories', arrayContains: category)
      // Şimdilik, sadece 'category1'e göre filtreleyelim.
      .where('category', isEqualTo: category)
      .orderBy('averageRating', descending: true) // Puana göre sırala
      .limit(5)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

// kategory chiplerini göstermek için listeyi dişnamik hale getirmeye çalışıyoruz
final nonEmptyCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final allCategories = [
    'Aksiyon',
    'Askeri',
    'Bilim Kurgu',
    'Deneme',
    'Dini',
    'Drama',
    'Fantastik',
    'Genel Kurgu',
    'Genç Kurgu',
    'Gerilim',
    'Gizem',
    'Kısa Hikaye',
    'Klasikler',
    'Korku',
    'Macera',
    'Polisiye',
    'Roman',
    'Romantik Gerilim',
    'Senaryo',
    'Siyasi',
    'Spiritüel',
    'Şiir',
    'Tarih',
    'Türk Klasikleri',
    'Vampir',
    'Diğer'
  ];

  final List<String> nonEmpty = [];

  for (final category in allCategories) {
    final data = await ref.read(topBooksByCategoryProvider(category).future);
    if (data.isNotEmpty) {
      nonEmpty.add(category);
    }
  }

  return nonEmpty;
});
