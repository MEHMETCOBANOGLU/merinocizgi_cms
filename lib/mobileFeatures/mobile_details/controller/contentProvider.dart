// seriesProvider / bookProvider zaten family ise bunların üstüne kuruyoruz.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

final contentProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) async {
  final seriesDoc = await ref.watch(seriesProvider(id).future);
  if (seriesDoc.exists) return seriesDoc.data();

  final bookDoc = await ref.watch(bookProvider(id).future);
  if (bookDoc.exists) return bookDoc.data();

  return null; // bulunamadı
});
