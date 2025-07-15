import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/features/publish/controller/series_draft_provider.dart';
import 'package:merinocizgi/features/publish/widgets/comicDetailsForm.dart';
import 'package:merinocizgi/features/publish/widgets/episodes_form.dart';
import 'package:merinocizgi/features/publish/widgets/review_and_publish.dart';

class CreateComicFlowPage extends ConsumerStatefulWidget {
  const CreateComicFlowPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateComicFlowPage> createState() =>
      _CreateComicFlowPageState();
}

class _CreateComicFlowPageState extends ConsumerState<CreateComicFlowPage> {
  final PageController _pageController = PageController();

  final merinoKey = GlobalKey();
  final comicsKey = GlobalKey();
  final artistsKey = GlobalKey();

  int _currentStep = 0;

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final seriesDraft = ref.watch(seriesDraftProvider);
    final seriesTitle = seriesDraft.title;

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // ── AŞAMA 1: Seri Detay Formu ──
              ComisDetailForm(
                // onSubmit: _handleSeriesSubmit, // Sadece fonksiyonu geçin
                // onNext: () => _goToStep(1),
                onStepTapped: (int step) {
                  _goToStep(step);
                },
              ),

              // ── AŞAMA 2: Bölüm Ekleme Ekranı ──

              EpisodesForm(
                // seriesId: seriesTitle!,
                // onNext: () => _goToStep(2),
                onStepTapped: (int step) {
                  _goToStep(step);
                },
              ),

              // ── AŞAMA 3: İnceleme ──
              seriesTitle == null
                  ? const Center(child: Text("Seri oluşturulmamış"))
                  : ReviewAndPublishView(
                      // seriesId: seriesTitle!,
                      onPublishComplete: () => context.go("/"),
                      onStepTapped: (int step) {
                        _goToStep(step);
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}


// draft id oluştur