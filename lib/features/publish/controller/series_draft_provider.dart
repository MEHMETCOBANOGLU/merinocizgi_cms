// series_draft_provider.dart (güncellenmiş hali)

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/features/publish/controller/episode_draft_model.dart';
// EpisodeDraftModel'ı import etmeyi unutmayın

class SeriesDraft {
  final String? seriesId;
  final String userId;
  final String title;
  final String summary;
  final String? category1;
  final String? category2;
  final Uint8List? squareImage;
  final Uint8List? verticalImage;
  final bool isPublished;
  final List<EpisodeDraftModel> episodes; // <-- YENİ

  SeriesDraft({
    this.seriesId,
    this.userId = '',
    this.title = '',
    this.summary = '',
    this.category1,
    this.category2,
    this.squareImage,
    this.verticalImage,
    this.isPublished = false,
    this.episodes = const [], // <-- YENİ
  });

  SeriesDraft copyWith({
    String? seriesId,
    String? userId,
    String? title,
    String? summary,
    String? category1,
    String? category2,
    Uint8List? squareImage,
    Uint8List? verticalImage,
    bool? isPublished,
    List<EpisodeDraftModel>? episodes, // <-- YENİ
  }) {
    return SeriesDraft(
      seriesId: seriesId ?? this.seriesId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category1: category1 ?? this.category1,
      category2: category2 ?? this.category2,
      squareImage: squareImage ?? this.squareImage,
      verticalImage: verticalImage ?? this.verticalImage,
      isPublished: isPublished ?? this.isPublished,
      episodes: episodes ?? this.episodes, // <-- YENİ
    );
  }
}

class SeriesDraftNotifier extends StateNotifier<SeriesDraft> {
  SeriesDraftNotifier() : super(SeriesDraft());

  void updateSeriesDetails({
    String? userId,
    String? title,
    String? summary,
    String? category1,
    String? category2,
    Uint8List? squareImage,
    Uint8List? verticalImage,
  }) {
    state = state.copyWith(
      userId: userId,
      title: title,
      summary: summary,
      category1: category1,
      category2: category2,
      squareImage: squareImage,
      verticalImage: verticalImage,
    );
  }

  // YENİ METOD: Taslağa bölüm eklemek için
  void addEpisode(EpisodeDraftModel episode) {
    state = state.copyWith(
      episodes: [...state.episodes, episode],
    );
  }

  void reset() {
    state = SeriesDraft();
  }

  void setSelectedSeriesId(String seriesId) {
    state = state.copyWith(seriesId: seriesId);
  }
}

final seriesDraftProvider =
    StateNotifierProvider<SeriesDraftNotifier, SeriesDraft>(
        (ref) => SeriesDraftNotifier());
