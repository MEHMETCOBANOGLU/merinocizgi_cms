// lib/features/home/controller/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- YENİ PROVIDER: ScrollController ---
// Bu provider, ScrollController'ın tek bir örneğini oluşturur ve yönetir.
// .autoDispose ekleyerek, onu dinleyen kimse kalmadığında controller'ın
// otomatik olarak temizlenmesini sağlarız, bu da bellek sızıntılarını önler.
final homeScrollControllerProvider =
    Provider.autoDispose<ScrollController>((ref) {
  final controller = ScrollController();
  // Provider dispose edildiğinde, controller'ı da temizle.
  ref.onDispose(() => controller.dispose());
  return controller;
});

final merinoKeyProvider = Provider((_) => GlobalKey());
final comicsKeyProvider = Provider((_) => GlobalKey());
final artistsKeyProvider = Provider((_) => GlobalKey());

// --- GÜNCELLENMİŞ HomeController ve Provider'ı ---
// Artık HomeController'ın kendisi ScrollController'ı TUTMAYACAK.
// Sadece ona İHTİYAÇ DUYDUĞUNDA provider'dan okuyacak.
class HomeController {
  final Ref _ref;

  HomeController(this._ref);

  void scrollTo(GlobalKey key) {
    // ScrollController'ı provider'dan OKU (read).
    final scrollController = _ref.read(homeScrollControllerProvider);

    // Geri kalan mantık aynı.
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }
}

// HomeController'ı sağlayan provider.
// Artık StateNotifier değil, çünkü kendi state'i yok.
final homeControllerProvider = Provider.autoDispose((ref) {
  return HomeController(ref);
});
