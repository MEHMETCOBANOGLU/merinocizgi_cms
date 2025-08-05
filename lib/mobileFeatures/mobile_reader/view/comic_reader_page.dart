import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/controller/myAccount_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_settings/controller/settings_provider.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/custom_glass_appBar.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';

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
            contentType: 'series',
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
      // appBar: CustomGlassAppBar(title: 'Başlık', actions: [
      //   IconButton(
      //     icon: const Icon(Icons.more_vert),
      //     onPressed: () {
      //       _bottomSheet(context, ref);
      //     },
      //   ),
      // ]),
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

          return CustomScrollView(
            slivers: [
              CustomGlassSliverAppBar(
                leading: IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                title: "Başlık",
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _bottomSheet(context, ref);
                    },
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                            child: Icon(Icons.broken_image,
                                color: Colors.redAccent),
                          );
                        },
                      ),
                    );
                  },
                  childCount: pages.length,
                ),
              ),
            ],
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

  _bottomSheet(BuildContext context, WidgetRef ref) {
    final settingsController = ref.read(settingsControllerProvider);
    double _currentBrightness = settingsController.brightness;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withOpacity(0.2), // ← Bu satır aslında çalışmaz!

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.3), // Saydam renk (önemli)
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🟨 Parlaklık başlığı + slider bar aynı satırda
                      Row(
                        children: [
                          // Text(
                          //   'Parlaklık',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(width: 12),
                          Expanded(
                            child: Transform.scale(
                              scale: 0.85,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.dark_mode,
                                        color: Colors.white70),
                                    Expanded(
                                      child: Slider(
                                        value: _currentBrightness,
                                        min: 0.0,
                                        max: 1.0,
                                        divisions: 100,
                                        activeColor: AppColors.accent,
                                        inactiveColor: Colors.white70,
                                        onChanged: (value) {
                                          setState(
                                              () => _currentBrightness = value);
                                          settingsController
                                              .updateBrightness(value)
                                              .catchError((e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Parlaklık hatası: $e')),
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    const Icon(Icons.light_mode,
                                        color: Colors.white70),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(
                              Icons.report_problem_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // bottomSheet kapanır
                              showReportDialog(
                                context,
                                ref,
                                seriesId: widget.seriesId,
                                episodeId: widget.episodeId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

Future<void> showReportDialog(BuildContext context, WidgetRef ref,
    {required String seriesId, required String episodeId}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final reasons = [
    'Uygunsuz çıplaklık veya cinsel içerik',
    'Şiddet veya rahatsız edici görseller',
    'Nefret söylemi veya istismar',
    'Spam veya reklam',
    'Telif hakkı ihlali',
  ];

  final docId = '${seriesId}_${episodeId}_${user.uid}';
  final reportRef = FirebaseFirestore.instance.collection('reports').doc(docId);

  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      backgroundColor: Colors.grey[900],
      title: const Center(
        child: Text('Bildir',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        ...reasons.map((reason) => SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context); // dialogu kapat

                try {
                  final alreadyReported = await reportRef.get();
                  if (alreadyReported.exists) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bu bölümü zaten bildirdiniz.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bildiriminiz alındı: "$reason"'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    await reportRef.set({
                      'userId': user.uid,
                      'seriesId': seriesId,
                      'episodeId': episodeId,
                      'reason': reason,
                      'reportedAt': FieldValue.serverTimestamp(),
                    });
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bir hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(reason, style: const TextStyle(color: Colors.white)),
            )),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Center(
              child: Text('İptal', style: TextStyle(color: Colors.redAccent))),
        )
      ],
    ),
  );
}
