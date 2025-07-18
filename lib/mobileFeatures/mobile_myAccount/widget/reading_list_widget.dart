import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/controller/library_controller.dart'; // Provider'ların olduğu dosyayı import edin

/// Okuma listelerinin gösterildiği ana sayfa widget'ı
class MyReadingListPage extends ConsumerWidget {
  const MyReadingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcının tüm kütüphanelerini (okuma listelerini) izle
    final librariesAsync = ref.watch(userLibrariesProvider);

    return librariesAsync.when(
      data: (libraries) {
        if (libraries.isEmpty) {
          return const Center(
            child: Text(
              "Henüz hiç okuma listeniz yok.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: libraries.length,
          itemBuilder: (context, index) {
            final libraryDoc = libraries[index];
            return _LibraryExpansionTile(libraryDoc: libraryDoc);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text("Listeler yüklenirken bir hata oluştu: $error"),
      ),
    );
  }
}

/// Her bir okuma listesi için genişleyebilir bir "tile" oluşturan widget.
final expansionStateProvider = StateProvider<bool>((ref) => false);

class _LibraryExpansionTile extends ConsumerWidget {
  final DocumentSnapshot libraryDoc;

  const _LibraryExpansionTile({required this.libraryDoc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryData = libraryDoc.data() as Map<String, dynamic>;
    final libraryName = libraryData['name'] ?? 'İsimsiz Liste';
    final seriesCount = libraryData['seriesCount'] ?? 0;

    final isExpanded = ref.watch(expansionStateProvider);
    final isExpandedNotifier = ref.read(expansionStateProvider.notifier);

    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(
              libraryName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              "$seriesCount seri",
              style: const TextStyle(color: Colors.grey),
            ),
            // Genişleme okunun rengini değiştirme
            collapsedIconColor: Colors.white70,
            iconColor: Colors.white60,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded)
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: Colors.white70),
                    onPressed: () {
                      ref
                          .read(libraryControllerProvider.notifier)
                          .deleteLibrary(libraryDoc.id);
                    },
                  ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onExpansionChanged: (expanded) {
              isExpandedNotifier.state = expanded;
            },

            children: [
              // Bu kısım, tile genişlediğinde gösterilir.
              // Belirli bir listenin içindeki serileri izlemek için yeni provider'ı kullanırız.
              ref.watch(seriesInLibraryProvider(libraryDoc.id)).when(
                    data: (seriesList) {
                      if (seriesList.isEmpty) {
                        return const ListTile(
                          title: Text(
                            "Bu listede henüz seri yok.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      // Her bir seri için bir kart oluşturur.
                      return Column(
                        children: seriesList
                            .map((seriesDoc) =>
                                _SeriesCard(seriesDoc: seriesDoc))
                            .toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: Text("Seriler yüklenemedi2: $error"),
                    ),
                  ),
            ],
          ),
        ));
  }
}

/// Genişletilmiş liste içinde her bir seriyi gösteren kart widget'ı
class _SeriesCard extends ConsumerWidget {
  final DocumentSnapshot seriesDoc;

  const _SeriesCard({required this.seriesDoc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesData = seriesDoc.data() as Map<String, dynamic>;
    final title = seriesData['seriesTitle'] ?? 'İsimsiz Seri';
    final imageUrl = seriesData['seriesImageUrl'];
    final path =
        seriesDoc.reference.path; // örnek: library/abc123/series/Y1fwG...
    final libraryId = path.split('/')[3]; // 'abc123'

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        color: AppColors.card,
        child: ListTile(
          leading: (imageUrl != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.image_not_supported, size: 50),
          title: Text(title),
          trailing: IconButton(
              onPressed: () {
                print("Silme tıklandı: $libraryId (ID: ${seriesDoc.id})");
                ref
                    .read(libraryControllerProvider.notifier)
                    .removeSeriesFromLibrary(libraryId, seriesDoc.id);
              },
              icon: const Icon(Icons.delete, color: Colors.white70)),
          onTap: () {
            // Buraya tıklandığında serinin detay sayfasına gitme kodu eklenebilir.
            // Örneğin: context.push('/series/${seriesDoc.id}');
            print("Tıklandı: $title (ID: ${seriesDoc.id})");
          },
        ),
      ),
    );
  }
}
