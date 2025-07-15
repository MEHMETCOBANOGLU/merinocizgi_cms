import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore koleksiyonlarına kolay erişim için sarma (wrapper) sınıfı.
class FirestoreService {
  final FirebaseFirestore _firestore;
  FirestoreService(this._firestore);

  /// /series koleksiyonu
  CollectionReference<Map<String, dynamic>> get series =>
      _firestore.collection('series');

  /// /series/{seriesId}/chapters alt koleksiyonu
  CollectionReference<Map<String, dynamic>> chapters(String seriesId) =>
      series.doc(seriesId).collection('chapters');

  /// /series/{seriesId}/chapters/{chapterId}/pages alt koleksiyonu
  CollectionReference<Map<String, dynamic>> pages(
          String seriesId, String chapterId) =>
      chapters(seriesId).doc(chapterId).collection('pages');
}
