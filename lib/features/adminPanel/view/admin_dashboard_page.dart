// lib/features/admin/view/admin_dashboard_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/core/utils/seo_utils.dart';
import 'package:merinocizgi/features/adminPanel/provider/admin_providers.dart';
import 'package:merinocizgi/features/adminPanel/widget/dynamic_island_bar.dart';
import 'package:merinocizgi/features/adminPanel/widget/series_review_card.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0; // 0: Onay Bekleyenler, 1: Tüm Seriler
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // --- SEO GÜNCELLEMESİ ---
    // Bu widget her çizildiğinde başlık ve açıklama güncellenir.
    updateSeoTags(
      title: "MerinoÇizgi - Admin Panel",
      description:
          'MerinoÇizgi Admin Sayfası', // Açıklamayı ilk 155 karakterle sınırla
    );
    return NestedScrollView(
      // 1. HEADER (BAŞLIK BÖLÜMÜ)
      // Bu bölüm, kaydırıldığında AppBar'ın altında kalır ve onunla birlikte kaybolur.
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          // SliverToBoxAdapter, normal bir widget'ı (Column, Container gibi)
          // bir sliver'a dönüştürmemizi sağlar. Çok pratiktir.
          SliverToBoxAdapter(
            child: DynamicIslandBar(
              selectedIndex: _selectedIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
        ];
      },
      // 2. BODY (ANA İÇERİK)
      // Burası, header kaybolduktan sonra kalan ve kendi içinde kaydırılabilen alandır.
      body: _buildSelectedList(),
    );
  }

  // Hangi sekme seçiliyse ona göre doğru widget'ı oluşturan metot
  Widget _buildSelectedList() {
    if (_selectedIndex == 0) {
      // --- SEÇENEK 1: Onay Bekleyenler ---
      return _buildReviewTasksList();
    } else {
      // --- SEÇENEK 2: Tüm Seriler (Arama özelliği ile) ---
      return _buildAllSeriesList();
    }
  }

  // Onay bekleyen görevleri listeleyen widget
  Widget _buildReviewTasksList() {
    final reviewTasksAsync = ref.watch(reviewTasksProvider);
    return reviewTasksAsync.when(
      data: (tasks) {
        if (tasks.docs.isEmpty) {
          return const Center(child: Text('Onay bekleyen içerik bulunmuyor.'));
        }

        final Map<String, List<DocumentSnapshot>> tasksBySeries = {};
        for (var doc in tasks.docs) {
          final seriesId = doc['seriesId'] as String;
          if (!tasksBySeries.containsKey(seriesId)) {
            tasksBySeries[seriesId] = [];
          }
          tasksBySeries[seriesId]!.add(doc);
        }
        final seriesIds = tasksBySeries.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: seriesIds.length,
          itemBuilder: (context, index) {
            return SeriesReviewCard(seriesId: seriesIds[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Hata: $e")),
    );
  }

  // Tüm serileri listeleyen widget
  Widget _buildAllSeriesList() {
    // Arama metnini provider'a parametre olarak geçiyoruz.
    final allSeriesAsync = ref.watch(allSeriesForAdminProvider(_searchQuery));
    return allSeriesAsync.when(
      data: (series) {
        if (series.docs.isEmpty) {
          return const Center(child: Text('Hiç seri bulunamadı.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: series.docs.length,
          itemBuilder: (context, index) {
            // SeriesReviewCard her iki liste için de kullanılabilir, çünkü sadece seriesId alıyor.
            return SeriesReviewCard(seriesId: series.docs[index].id);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Hata: $e")),
    );
  }
}
