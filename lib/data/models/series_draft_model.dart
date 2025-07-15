// lib/models/series_draft_model.dart
import 'dart:typed_data';

class SeriesDraftModel {
  final String title;
  final String summary;
  final String? category1;
  final String? category2;
  final Uint8List? squareImage;
  final Uint8List? verticalImage;
  final bool isPublished;

  SeriesDraftModel({
    this.title = '',
    this.summary = '',
    this.category1,
    this.category2,
    this.squareImage,
    this.verticalImage,
    this.isPublished = false,
  });

  SeriesDraftModel copyWith({
    String? title,
    String? summary,
    String? category1,
    String? category2,
    Uint8List? squareImage,
    Uint8List? verticalImage,
    bool? isPublished,
  }) {
    return SeriesDraftModel(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category1: category1 ?? this.category1,
      category2: category2 ?? this.category2,
      squareImage: squareImage ?? this.squareImage,
      verticalImage: verticalImage ?? this.verticalImage,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  bool get isComplete =>
      title.isNotEmpty &&
      summary.isNotEmpty &&
      category1 != null &&
      squareImage != null &&
      verticalImage != null;
}
