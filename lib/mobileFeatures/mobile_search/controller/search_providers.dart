// lib/core/providers/search_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Kullanıcının arama çubuğuna girdiği metni tutan basit state.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// 2. Arama metnini kullanarak Firestore'dan sonuçları getiren provider.
final searchResultProvider =
    FutureProvider.autoDispose<Map<String, List<DocumentSnapshot>>>(
        (ref) async {
  final query = ref.watch(searchQueryProvider);

  // Eğer arama metni boşsa, boş bir sonuç döndürerek gereksiz okumaları engelle.
  if (query.isEmpty) {
    return {'series': [], 'authors': []};
  }

  // Firestore'da küçük harfe duyarsız "içerir" sorgusu yapmak zordur.
  // En yaygın ve etkili yöntem, arama yapılacak metinlerin küçük harfli bir
  // kopyasını belgede saklamak ve "ile başlar" sorgusu yapmaktır.
  // Burada bu yöntemi kullanacağız.
  // Not: `\uf8ff` karakteri, Firestore'da "bu metinle başlayan her şey"
  // anlamına gelen bir aralık sorgusu oluşturmak için kullanılır.

  // Seriler içinde arama yap
  final seriesQuery = FirebaseFirestore.instance
      .collection('series')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThan: query + '\uf8ff')
      .limit(10) // Çok fazla sonuç getirmemek için limiti belirle
      .get();

  // Yazarlar (kullanıcılar) içinde arama yap
  final authorsQuery = FirebaseFirestore.instance
      .collection('users')
      .where('mahlas', isGreaterThanOrEqualTo: query) // veya 'displayName'
      .where('mahlas', isLessThan: query + '\uf8ff')
      .limit(10)
      .get();

  // Her iki sorguyu aynı anda çalıştır.
  final results = await Future.wait([seriesQuery, authorsQuery]);

  final seriesResults = results[0].docs;
  final authorResults = results[1].docs;

  // Sonuçları bir Map içinde yapılandırarak döndür.
  return {'series': seriesResults, 'authors': authorResults};
});
