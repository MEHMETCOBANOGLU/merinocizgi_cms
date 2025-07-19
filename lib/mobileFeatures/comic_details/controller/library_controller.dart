// lib/mobileFeatures/comic_details/controller/library_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

// Controller'ın provider'ı
final libraryControllerProvider =
    StateNotifierProvider.autoDispose<LibraryController, AsyncValue<void>>(
        (ref) {
  return LibraryController(ref);
});

// Kullanıcının okuma listesi (kütüphane) verisini getiren provider. // "Okuma Listelerim"
final userLibrariesProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) return const Stream.empty();

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('libraries')
      .orderBy('createdAt', descending: false)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs);
});

class LibraryController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LibraryController(this._ref) : super(const AsyncData(null));

  // Yeni bir kütüphane listesi oluşturur.
  Future<String?> createNewLibrary(String name, bool isPrivate) async {
    final user = _ref.read(authStateProvider).value?.user;
    if (user == null) return null;

    // add() metodu bir DocumentReference döndürür.
    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('libraries')
        .add({
      'name': name,
      'isPrivate': isPrivate,
      'seriesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Oluşturulan dökümanın ID'sini geri döndür.
    return docRef.id;
  }

  // Bir seriyi, seçilen bir veya daha fazla listeye ekler.
  Future<void> addSeriesToLibraries(
      String seriesId, List<String> libraryIds) async {
    final user = _ref.read(authStateProvider).value?.user;
    if (user == null || libraryIds.isEmpty) return;

    final seriesDoc = await _firestore.collection('series').doc(seriesId).get();
    if (!seriesDoc.exists) return;
    final seriesData = seriesDoc.data()!;

    final writeBatch = _firestore.batch();

    for (final libraryId in libraryIds) {
      final seriesInLibraryRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(libraryId)
          .collection('series')
          .doc(seriesId);

      writeBatch.set(seriesInLibraryRef, {
        'addedAt': FieldValue.serverTimestamp(),
        'seriesTitle': seriesData['title'],
        'seriesImageUrl': seriesData['squareImageUrl'],
      });

      // Sayaçları güncellemek için Cloud Function kullanmak en doğrusu,
      // ama şimdilik istemciden yapalım.
      final libraryRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(libraryId);
      writeBatch.update(libraryRef, {'seriesCount': FieldValue.increment(1)});
    }
    await writeBatch.commit();
  }

  /// Belirli bir kütüphanenin (okuma listesinin) içindeki belirli bir seriyi silen provider.
  Future<void> removeSeriesFromLibrary(
      String libraryId, String seriesId) async {
    final user = _ref.read(authStateProvider).value?.user;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('libraries')
        .doc(libraryId)
        .collection('series')
        .doc(seriesId)
        .delete();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('libraries')
        .doc(libraryId)
        .update({'seriesCount': FieldValue.increment(-1)});
  }

  /// Belirli bir kütüphanenin (okuma listesinin) silen provider.
  Future<void> deleteLibrary(String libraryId) async {
    final user = _ref.read(authStateProvider).value?.user;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('libraries')
        .doc(libraryId)
        .delete();
  }
}

/// Belirli bir çizgi romanın, kullanıcının HERHANGİ bir kütüphanesine (okuma listesine)
/// eklenip eklenmediğini kontrol eden provider.
final isComicInAnyLibraryProvider =
    FutureProvider.family<bool, String>((ref, comicId) async {
  final user = ref.watch(authStateProvider).value?.user;

  // Kullanıcı giriş yapmamışsa veya comicId boşsa, işlem yapma.
  if (user == null || comicId.isEmpty) {
    return false;
  }

  // Collection Group sorgusu: 'users' koleksiyonu altındaki TÜM 'comics'
  // koleksiyonlarını sorgulamamızı sağlar.
  final querySnapshot = await FirebaseFirestore.instance
      .collectionGroup(
          'comics') // ÖNEMLİ: Bu koleksiyonun adının 'comics' olduğundan emin olun.
      // Sadece mevcut kullanıcıya ait olanları filtrele
      .where('userId', isEqualTo: user.uid)
      // ve sadece aradığımız çizgi romanı filtrele
      .where('comicId',
          isEqualTo: comicId) // Dokümanlarınızda 'comicId' alanı olmalı
      .limit(1) // Sadece 1 tane bulmamız yeterli, daha fazla aramaya gerek yok.
      .get();

  // Eğer sorgu sonucu boş değilse (yani en az 1 eşleşme varsa),
  // çizgi roman bir kütüphaneye eklenmiş demektir.
  return querySnapshot.docs.isNotEmpty;
});

/// Belirli bir kütüphanenin (okuma listesinin) içindeki serileri getiren provider.
final seriesInLibraryProvider = StreamProvider.autoDispose
    .family<List<DocumentSnapshot>, String>((ref, libraryId) {
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('libraries')
      .doc(libraryId)
      .collection('series') // Koleksiyon adınızın bu olduğundan emin olun
      .orderBy('addedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});
