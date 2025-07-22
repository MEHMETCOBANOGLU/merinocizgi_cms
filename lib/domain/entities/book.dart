// lib/domain/entities/book.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

// Firestore'dan gelen Timestamp'ı DateTime'a çeviren bir yardımcı fonksiyon
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
// DateTime'ı Firestore için Timestamp'a çeviren bir yardımcı fonksiyon
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

@freezed
abstract class Book with _$Book {
  const factory Book({
    // @JsonKey(includeIfNull: false) bu, Firestore'a yazarken alan null ise onu eklemez.
    @JsonKey(includeIfNull: false) String? bookId,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    String? coverImageUrl,
    required String category,
    required String copyright,
    // Etiketler için varsayılan olarak boş bir liste atayalım.
    @Default([]) List<String> tags,
    @Default('ongoing') String status,

    // Tarih alanları için özel dönüştürücülerimizi kullanıyoruz.
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? lastUpdatedAt,

    // Sayaçlar
    @Default(0) int viewCount,
    @Default(0) int voteCount,
    @Default(0) int chapterCount,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}
