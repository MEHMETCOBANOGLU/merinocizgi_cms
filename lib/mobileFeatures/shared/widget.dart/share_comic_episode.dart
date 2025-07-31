import 'package:share_plus/share_plus.dart';

void shareEpisode(String seriesId, String episodeId) {
  final uri = 'merinocizgi://series/$seriesId/episodes/$episodeId';

  final message = '''
📖 Yeni bölüm yayında!

Açmak için tıkla:  
$uri
''';

  Share.share(message);
}
