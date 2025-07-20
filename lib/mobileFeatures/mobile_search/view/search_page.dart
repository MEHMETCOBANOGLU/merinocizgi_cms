// lib/mobileFeatures/search/view/mobile_search_page.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_search/controller/search_providers.dart';

class MobileSearchPage extends ConsumerStatefulWidget {
  const MobileSearchPage({super.key});

  @override
  ConsumerState<MobileSearchPage> createState() => _MobileSearchPageState();
}

class _MobileSearchPageState extends ConsumerState<MobileSearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Arama kutusundaki her değişikliği dinle.
    _searchController.addListener(_onSearchChanged);
  }

  // Kullanıcı yazmayı bıraktıktan 500ms sonra arama yaparak gereksiz sorguları engeller.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultAsync = ref.watch(searchResultProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Eser veya yazar arayın...',
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: searchQuery.isEmpty
                  ? const Center(child: Text("Aramak için yazmaya başlayın..."))
                  : searchResultAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, st) =>
                          Center(child: Text('Bir hata oluştu: $err')),
                      data: (data) => _buildResultsList(data),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(Map<String, List<DocumentSnapshot>> data) {
    final series = data['series']!;
    final authors = data['authors']!;

    if (series.isEmpty && authors.isEmpty) {
      return const Center(child: Text("Sonuç bulunamadı."));
    }

    return ListView(
      children: [
        if (series.isNotEmpty) ...[
          const Text("Seriler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...series.map((doc) => _SeriesResultTile(seriesDoc: doc)),
          const Divider(height: 30),
        ],
        if (authors.isNotEmpty) ...[
          const Text("Yazarlar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...authors.map((doc) => _AuthorResultTile(authorDoc: doc)),
        ],
      ],
    );
  }
}

// --- Arayüz için yardımcı alt-widget'lar ---

class _SeriesResultTile extends StatelessWidget {
  final DocumentSnapshot seriesDoc;
  const _SeriesResultTile({required this.seriesDoc});

  @override
  Widget build(BuildContext context) {
    final data = seriesDoc.data() as Map<String, dynamic>;
    return ListTile(
      leading: data['squareImageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(data['squareImageUrl'],
                  width: 50, height: 50, fit: BoxFit.cover),
            )
          : const Icon(Icons.book),
      title: Text(data['title'] ?? ''),
      subtitle: Text(data['authorName'] ?? ''),
      onTap: () => context.push('/series/${seriesDoc.id}'),
    );
  }
}

class _AuthorResultTile extends StatelessWidget {
  final DocumentSnapshot authorDoc;
  const _AuthorResultTile({required this.authorDoc});

  @override
  Widget build(BuildContext context) {
    final data = authorDoc.data() as Map<String, dynamic>;
    return ListTile(
      leading: data['profileImageUrl'] != null
          ? CircleAvatar(backgroundImage: NetworkImage(data['profileImageUrl']))
          : const Icon(Icons.person),
      title: Text(data['mahlas'] ?? ''),
      onTap: () => context.push('/UserProfile/${authorDoc.id}'),
    );
  }
}
