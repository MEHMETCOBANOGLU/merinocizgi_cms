// lib/domain/entities/chapter.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart'; // Bir önceki dosyadan yardımcı fonksiyonları almak için

part 'chapter.freezed.dart';
part 'chapter.g.dart';

// Firestore'dan gelen Timestamp'ı DateTime'a çeviren bir yardımcı fonksiyon
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
// DateTime'ı Firestore için Timestamp'a çeviren bir yardımcı fonksiyon
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

@freezed
abstract class Chapter with _$Chapter {
  const factory Chapter({
    @JsonKey(includeIfNull: false) String? chapterId,
    required int chapterNumber,
    required String content,
    @Default('draft') String status, // Varsayılan olarak 'taslak'

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? publishedAt,
    @Default(0) int wordCount,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
