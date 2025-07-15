// lib/domain/usecases/get_series.dart

import '../entities/series.dart';
import '../repositories.dart';

/// “GetSeries” use-case: Belirli bir yazarın (authorId) serilerini getirir.
class GetSeries {
  final SeriesRepository _repository;

  /// Constructor’da, dışarıdan (DI ile) bir [SeriesRepository] enjekte edeceğiz.
  GetSeries(this._repository);

  /// call() metodu, authorId alıp Future<List<Series>> dönecek:
  Future<List<Series>> call(String authorId) {
    // İleride buraya ek validasyon ya da iş kuralı gelebilir.
    return _repository.fetchByAuthor(authorId);
  }
}
