import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeeplinkHandler {
  static StreamSubscription? _sub;
  static String? _pendingRoute;
  static BuildContext? _context;

  static Future<void> init(BuildContext context) async {
    _context = context;
    final appLinks = AppLinks();

    // Handle initial link when app is launched
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      _handleUri(uri);
      _redirectIfNeeded();
    }

    // Listen for incoming links when app is already running
    _sub = appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        _handleUri(uri);
        _redirectIfNeeded();
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

  static void _redirectIfNeeded() {
    if (_pendingRoute != null && _context != null) {
      final route = _pendingRoute!;
      _pendingRoute = null;

      // Use addPostFrameCallback to ensure the context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          print('🔁 Yönlendirme başlıyor: $route');
          if (_context!.mounted) {
            GoRouter.of(_context!).push(route);
            print('✅ Yönlendirme başarılı: $route');
          }
        } catch (e) {
          print('❌ GoRouter yönlendirme hatası: $e');
        }
      });
    }
  }

  static void dispose() {
    _sub?.cancel();
    _context = null;
    _pendingRoute = null;
  }
}