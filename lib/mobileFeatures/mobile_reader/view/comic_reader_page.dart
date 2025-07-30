import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_settings/controller/settings_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ComicReaderPage extends ConsumerStatefulWidget {
  final String seriesId;
  final String episodeId;

  const ComicReaderPage({
    Key? key,
    required this.seriesId,
    required this.episodeId,
  }) : super(key: key);

  @override
  ConsumerState<ComicReaderPage> createState() => _ComicReaderPageState();
}

class _ComicReaderPageState extends ConsumerState<ComicReaderPage> {
  bool _historyUpdated = false;
  bool _viewEventSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHistory();
      _sendReadEvent();
    });
  }

  Future<void> _updateHistory() async {
    if (_historyUpdated || !mounted) return;
    setState(() => _historyUpdated = true);

    try {
      final seriesDoc = await ref.read(seriesProvider(widget.seriesId).future);
      final episodes =
          await ref.read(allEpisodesForSeriesProvider(widget.seriesId).future);

      if (!seriesDoc.exists || episodes.isEmpty) return;

      final seriesData = seriesDoc.data() as Map<String, dynamic>;
      final episodeDoc = episodes.firstWhere((e) => e.id == widget.episodeId);
      final episodeData = episodeDoc.data() as Map<String, dynamic>;

      await ref
          .read(MyAccountControllerProvider.notifier)
          .updateUserReadingHistory(
            seriesId: widget.seriesId,
            seriesTitle: seriesData['title'] ?? '',
            seriesImageUrl: seriesData['squareImageUrl'] ?? '',
            episodeId: widget.episodeId,
            episodeTitle: episodeData['title'] ?? '',
          );
    } catch (e) {
      debugPrint("Geçmiş güncellenirken hata: $e");
    }
  }

  Future<void> _sendReadEvent() async {
    if (_viewEventSent) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('readEvents').add({
        'userId': user.uid,
        'seriesId': widget.seriesId,
        'episodeId': widget.episodeId,
        'readAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _viewEventSent = true);
      }
    } catch (e) {
      debugPrint("Okuma olayı kaydedilirken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodeAsync =
        ref.watch(allEpisodesForSeriesProvider(widget.seriesId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Okuma Modu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _bottomSheet(context, ref);
            },
          ),
        ],
      ),
      body: episodeAsync.when(
        data: (episodes) {
          final episode = episodes.firstWhere(
              (doc) => doc.id == widget.episodeId,
              orElse: () => throw Exception("Bölüm bulunamadı"));

          final data = episode.data() as Map<String, dynamic>;
          final pages = List<String>.from(data['pages'] ?? []);

          if (pages.isEmpty) {
            return const Center(
              child: Text(
                "Bu bölümde görsel bulunamadı.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return InteractiveViewer(
            panEnabled: false,
            minScale: 1,
            maxScale: 5,
            child: ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final imageUrl = pages[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child:
                            Icon(Icons.broken_image, color: Colors.redAccent),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(
          child: Text(
            "Yüklenemedi: $e",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Future<void> setBrightness(double value) async {
  try {
    await ScreenBrightness()
        .setApplicationScreenBrightness(value); // value: 0.0 - 1.0
  } catch (e) {
    print("Parlaklık ayarlanamadı: $e");
  }
}

_bottomSheet(BuildContext context, WidgetRef ref) {
  final settingsController = ref.read(settingsControllerProvider);
  double _currentBrightness = settingsController.brightness;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟨 Parlaklık başlığı + slider bar aynı satırda
                Row(
                  children: [
                    const Text(
                      'Parlaklık',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.dark_mode, color: Colors.white70),
                            Expanded(
                              child: Slider(
                                value: _currentBrightness,
                                min: 0.0,
                                max: 1.0,
                                divisions: 100,
                                activeColor: AppColors.primary,
                                inactiveColor: Colors.white30,
                                onChanged: (value) {
                                  setState(() => _currentBrightness = value);
                                  settingsController
                                      .updateBrightness(value)
                                      .catchError((e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Parlaklık hatası: $e')),
                                    );
                                  });
                                },
                              ),
                            ),
                            const Icon(Icons.light_mode, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.flag, color: Colors.white),
                        label: const Text('Bölümü bildir',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          // Report işlemi burada yapılabilir
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text('Paylaş',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                          // Share işlemi burada yapılabilir
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
