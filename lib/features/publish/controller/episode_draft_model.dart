// episode_draft_model.dart (yeni bir dosya olabilir)
import 'dart:typed_data';

class EpisodeDraftModel {
  final String title;
  final Uint8List thumbnail; // Bölüm kapağı
  final List<Uint8List> pages; // Bölüm sayfaları

  EpisodeDraftModel({
    required this.title,
    required this.thumbnail,
    required this.pages,
  });
}
