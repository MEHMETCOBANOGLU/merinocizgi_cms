import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
// seriesProvider'ı import et

// Admin panelinin ana veri kaynağı: Onay bekleyen görevler
final reviewTasksProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots();
});

// Yazarın e-postasını almak için kullandığın provider'ı da buraya taşıyabiliriz.
// Bu, auth_state_provider.dart dosyasında olabilir, ama burada da durabilir.
final authorProfileProvider =
    FutureProvider.family<DocumentSnapshot?, String>((ref, authorId) async {
  if (authorId.isEmpty || authorId == 'Bilinmiyor') return null;
  return FirebaseFirestore.instance.collection('users').doc(authorId).get();
});

// --- YENİ PROVIDER ---
// Adminin TÜM serileri görmesini sağlar.
// Arama işlevselliği için bir family provider'a dönüştürelim.
final allSeriesForAdminProvider = StreamProvider.autoDispose
    .family<QuerySnapshot, String>((ref, String searchQuery) {
  Query query = FirebaseFirestore.instance
      .collection('series')
      .orderBy('createdAt', descending: true);

  // Eğer arama metni varsa, sorguyu filtrele.
  // Not: Firestore'da 'contains' gibi sorgular için ek yapılandırma (index) gerekebilir.
  // Şimdilik 'isEqualTo' ile tam eşleşme yapalım. Daha gelişmiş arama için Algolia gibi servisler kullanılır.
  if (searchQuery.isNotEmpty) {
    query = query.where('authorName', isEqualTo: searchQuery);
  }

  return query.snapshots();
});

// 3. ADMİN İÇİN (YENİ): Onay bekleyen serileri getirir (Admin Paneli için)
final pendingSeriesProvider = StreamProvider<QuerySnapshot>((ref) {
  // Sadece admin ise bu sorguyu çalıştır, yoksa boş stream döndür.
  final isAdmin = ref.watch(isAdminProvider);
  if (!isAdmin) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('series')
      .where('status',
          isEqualTo: 'pending') // <-- YENİ: Sadece onay bekleyenler
      .orderBy('createdAt', descending: true)
      .snapshots();
});
