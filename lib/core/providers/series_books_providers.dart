import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/MyAccount_providers.dart';

enum ContentType { series, books }

final dynamicContentEpisodesProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, ({String id, ContentType type})>(
  (ref, params) {
    final id = params.id;
    final type = params.type;

    final collection = type == ContentType.series ? 'series' : 'books';
    final subCollection = type == ContentType.series ? 'episodes' : 'chapters';

    print("📡 Fetching from Firestore: /$collection/$id/$subCollection");

    final snapshots = FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .collection(subCollection)
        .orderBy('createdAt', descending: false)
        .snapshots();

    return snapshots.map((snapshot) {
      print("📥 Fetched ${snapshot.docs.length} docs");

      for (var doc in snapshot.docs) {
        print('📝 ${doc.id} → ${doc.data()}');
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  },
);

final readingHistoryEpisodesMapProvider =
    FutureProvider.autoDispose<Map<String, List<Map<String, dynamic>>>>(
        (ref) async {
  final historySnapshot = await ref.watch(readingHistoryProvider.future);

  final Map<String, List<Map<String, dynamic>>> result = {};

  for (final doc in historySnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;

    final String contentId = data['seriesId'] ?? data['booksId'];
    final String typeString = data['contentType'] ?? 'books'; // fallback
    final ContentType type =
        typeString == 'series' ? ContentType.series : ContentType.books;

    // Koleksiyon adları
    final collection = type == ContentType.series ? 'series' : 'books';
    final subCollection = type == ContentType.series ? 'episodes' : 'chapters';
    final orderField =
        type == ContentType.series ? 'createdAt' : 'chapterNumber';

    // Bölümleri Firestore'dan çek
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .doc(contentId)
        .collection(subCollection)
        .orderBy(orderField)
        .get();

    final episodes = snapshot.docs.map((doc) {
      final episodeData = doc.data();
      episodeData['id'] = doc.id;
      return episodeData;
    }).toList();

    result[contentId] = episodes;
  }

  return result;
});
