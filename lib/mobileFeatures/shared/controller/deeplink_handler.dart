import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeeplinkHandler {
  static StreamSubscription? _sub;
  static String? _pendingRoute;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final appLinks = AppLinks();

    // Handle initial link when app is launched from a deep link
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      _handleUri(uri);
    }

    // Listen for incoming links while app is running
    _sub = appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });
  }

  static void _handleUri(Uri uri) {
    print('Gelen URI: $uri');
    if (uri.host == 'series' && uri.pathSegments.length == 3) {
      final seriesId = uri.pathSegments[0];
      final keyword = uri.pathSegments[1];
      final episodeId = uri.pathSegments[2];

      if (keyword == 'episodes') {
        final route = '/comic-reader/$seriesId/$episodeId';
        print('✅ Yönlendiriliyor (pending): $route');
        _pendingRoute = route;
      }
    }
  }

  static void checkAndNavigate(BuildContext context) {
    if (_pendingRoute != null) {
      final route = _pendingRoute!;
      _pendingRoute = null;

      // Use addPostFrameCallback to ensure the widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          print('🔁 Yönlendirme başlıyor: $route');
          if (context.mounted) {
            GoRouter.of(context).push(route);
          }
        } catch (e) {
          print('❌ GoRouter yönlendirme hatası: $e');
        }
      });
    }
  }

  static bool get hasPendingRoute => _pendingRoute != null;

  static void dispose() {
    _sub?.cancel();
    _isInitialized = false;
  }
}