// lib/domain/entities/series.dart

// dosyasının tamamını bulabilirsin. Freezed + JSON serializable kullanarak Series entity’sini tanımlıyor,
//  böylece hem tip güvenli hem de kolay dönüştürülebilir bir model elde etmiş olacaksın.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'series.freezed.dart';
part 'series.g.dart';

@freezed
class Series with _$Series {
  const Series._();

  factory Series({
    required String id,
    required String authorId,
    required String title,
    String? summary,
    String? squareThumbUrl,
    String? verticalThumbUrl,
    String? category1,
    String? category2,

    /// İçerik puanlarını tek bir JSONB/Map olarak saklıyoruz

    required DateTime createdAt,
  }) = _Series;

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

  @override
  // TODO: implement authorId
  String get authorId => throw UnimplementedError();

  @override
  // TODO: implement category1
  String? get category1 => throw UnimplementedError();

  @override
  // TODO: implement category2
  String? get category2 => throw UnimplementedError();

  @override
  // TODO: implement createdAt
  DateTime get createdAt => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement squareThumbUrl
  String? get squareThumbUrl => throw UnimplementedError();

  @override
  // TODO: implement summary
  String? get summary => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement verticalThumbUrl
  String? get verticalThumbUrl => throw UnimplementedError();
}
