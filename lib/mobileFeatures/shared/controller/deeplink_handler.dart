import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:merinocizgi/app_router.dart'; // Buradan initialAppRoute gelir

class DeeplinkHandler {
  static StreamSubscription? _sub;

  static Future<void> init() async {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) _handleUri(uri);

    _sub = appLinks.uriLinkStream.listen((uri) {
      if (uri != null) _handleUri(uri);
    });
  }

  static void _handleUri(Uri uri) {
    print('📥 Gelen URI: $uri');
    if (uri.host == 'series' && uri.pathSegments.length == 3) {
      final seriesId = uri.pathSegments[0];
      final keyword = uri.pathSegments[1];
      final episodeId = uri.pathSegments[2];

      if (keyword == 'episodes') {
        initialAppRoute = '/comic-reader/$seriesId/$episodeId';
        print('✅ initialAppRoute ayarlandı: $initialAppRoute');
      }
    } else {
      print('❌ Geçersiz URI formatı: $uri');
    }
  }

  static void dispose() => _sub?.cancel();
}
