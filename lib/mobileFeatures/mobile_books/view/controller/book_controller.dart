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
        status: 'draft', // Yeni bölümler taslak olarak başlar
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
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Oturum açılmamış.");

    try {
      final bookRef = _firestore.collection('books').doc(bookId);
      final chapterRef = bookRef.collection('chapters').doc(chapterId);

      final writeBatch = _firestore.batch();
      // Bölümü güncelle
      writeBatch.update(chapterRef, {'title': title, 'content': content});
      // Ana kitaptaki son güncelleme tarihini güncelle
      writeBatch
          .update(bookRef, {'lastUpdatedAt': FieldValue.serverTimestamp()});

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
