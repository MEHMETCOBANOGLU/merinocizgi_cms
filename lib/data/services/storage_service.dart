import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage’a dosya yüklemek için sarma (wrapper) sınıfı.
class StorageService {
  final FirebaseStorage _storage;
  StorageService(this._storage);

  /// Seri küçük resimleri için: thumbnails/{seriesId}/square.jpg veya vertical.jpg
  Future<String> uploadSeriesThumbnail({
    required Uint8List data,
    required String seriesId,
    required bool isSquare,
  }) async {
    final fileName = isSquare ? 'square.jpg' : 'vertical.jpg';
    final path = 'thumbnails/$seriesId/$fileName';
    final ref = _storage.ref(path);
    await ref.putData(data);
    return ref.getDownloadURL();
  }

  /// Bölüm sayfaları için: pages/{seriesId}/{chapterId}/page_{pageNo}.jpg
  Future<String> uploadPage({
    required Uint8List data,
    required String seriesId,
    required String chapterId,
    required int pageNo,
  }) async {
    final path = 'pages/$seriesId/$chapterId/page_$pageNo.jpg';
    final ref = _storage.ref(path);
    await ref.putData(data);
    return ref.getDownloadURL();
  }
}
