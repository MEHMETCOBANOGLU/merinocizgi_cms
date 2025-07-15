import 'entities/series.dart';

/// Domain katmanındaki soyut repository arayüzü.
/// Veritabanı teknolojisinden bağımsız; sadece iş kurallarını tanımlar.
abstract class SeriesRepository {
  /// Yazarın serilerini getirir
  Future<List<Series>> fetchByAuthor(String authorId);

  /// Yeni bir seri oluşturur
  Future<void> createSeries(Series series);

  /// Varolan bir seriyi günceller
  Future<void> updateSeries(Series series);

  /// Bir seriyi siler
  Future<void> deleteSeries(String seriesId);
}
