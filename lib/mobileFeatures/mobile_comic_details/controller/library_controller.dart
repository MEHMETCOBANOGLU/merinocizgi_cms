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

/// Belirli bir çizgi romanın, kullanıcının HERHANGİ bir kütüphanesine (okuma listesine)
/// eklenip eklenmediğini kontrol eden provider.
/// '.family' ile dışarıdan 'seriesId' parametresi alır.
final isComicInAnyLibraryProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, seriesId) {
  // 1. Mevcut kullanıcıyı al. Giriş yapmamışsa, seri kayıtlı değildir (false).
  final user = ref.watch(authStateProvider).value?.user;
  if (user == null) {
    return Stream.value(false);
  }

  // 2. Kullanıcının TÜM kütüphanelerini (okuma listelerini) dinle.
  final librariesStream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('libraries')
      .snapshots();

  // 3. Bu stream'i, asenkron bir map'e dönüştürerek işliyoruz.
  return librariesStream.asyncMap((librariesSnapshot) async {
    // Eğer kullanıcının hiç kütüphanesi yoksa, seri kayıtlı olamaz.
    if (librariesSnapshot.docs.isEmpty) {
      return false;
    }

    // 4. Her bir kütüphanenin içinde, aradığımız serinin olup olmadığını KONTROL ET.
    // Bu kontrol işlemlerini paralel olarak yapmak performansı artırır.
    final checks = librariesSnapshot.docs.map((libraryDoc) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('libraries')
          .doc(libraryDoc.id)
          .collection('series')
          .doc(seriesId)
          .get()
          .then((seriesDoc) =>
              seriesDoc.exists); // Sadece var olup olmadığına (true/false) bak.
    }).toList();

    // 5. Tüm bu kontrol işlemlerinin (Future'ların) sonuçlarını bekle.
    final results = await Future.wait(checks);

    // 6. Sonuçlardan HERHANGİ BİRİ 'true' ise, seri en az bir listeye kaydedilmiştir.
    // 'any' metodu, listedeki elemanlardan en az biri koşulu sağlıyorsa 'true' döner.
    return results.any((isFound) => isFound == true);
  });
});
