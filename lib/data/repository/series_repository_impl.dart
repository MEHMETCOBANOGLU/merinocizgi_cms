import '../../domain/entities/series.dart';
import '../../domain/repositories.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// `SeriesRepository` arayüzünü Firestore + Storage kullanarak implement eder.
class SeriesRepositoryImpl implements SeriesRepository {
  final FirestoreService firestore;
  final StorageService storage;

  SeriesRepositoryImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<Series>> fetchByAuthor(String authorId) async {
    final snap = await firestore.series
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Freezed modelin id alanı için
      return Series.fromJson(data);
    }).toList();
  }

  @override
  Future<void> createSeries(Series series) async {
    final docRef = firestore.series.doc();
    final payload =
        series.copyWith(id: docRef.id, createdAt: DateTime.now()).toJson();
    await docRef.set(payload);
  }

  @override
  Future<void> updateSeries(Series series) async {
    final payload = Map<String, dynamic>.from(series.toJson())
      ..remove('id'); // id zaten belge kimliği
    await firestore.series.doc(series.id).update(payload);
  }

  @override
  Future<void> deleteSeries(String seriesId) async {
    // Dilersen önce alt koleksiyonları temizle, sonra seriyi sil
    await firestore.series.doc(seriesId).delete();
  }
}
