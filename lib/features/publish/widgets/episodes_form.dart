import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/publish/controller/episode_draft_model.dart';
import 'package:merinocizgi/features/publish/controller/series_draft_provider.dart';
import 'package:merinocizgi/features/publish/widgets/DropzoneView.dart';
import 'package:merinocizgi/features/publish/widgets/step_%C4%B0ndicator.dart';

// Bu form da artık Firebase'e yazmayacak.
//_submit metodu, bir EpisodeDraftModel oluşturup bunu SeriesDraftProvider'a ekleyecek.

// 1. Change StatefulWidget to ConsumerStatefulWidget
class EpisodesForm extends ConsumerStatefulWidget {
  // final String seriesId;
  // final VoidCallback onNext;
  final void Function(int step) onStepTapped;

  const EpisodesForm({
    Key? key,
    // required this.seriesId,
    // required this.onNext,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  // 2. The createState method remains the same
  ConsumerState<EpisodesForm> createState() => _EpisodesFormState();
}

// 3. Change State<EpisodesForm> to ConsumerState<EpisodesForm>
class _EpisodesFormState extends ConsumerState<EpisodesForm> {
  final _titleCtrl = TextEditingController();
  Uint8List? _episodeImage;
  bool _loading = false;
  List<Uint8List> _pages = [];

  // --- RESİM SEÇİMİ ---
  // Note: Your original code had two variables for images but only used one in the picker logic.
  // I've simplified it to use just _episodeImage as per the picker logic.
  // If _verticalThumb is needed, you'll need to adjust _pickImage and _buildImagePicker.
  // Uint8List? _verticalThumb;

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        _episodeImage = res.files.single.bytes!;
      });
    }
  }

  Widget _buildFormFields(bool isWideScreen, dynamic seriesTitleWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: StepIndicator(
            steps: const [
              'Seri Detayları',
              'Bölümleri Ekle',
              'İncele ve Yayınla'
            ],
            currentStep: 1,
            activeColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
            circleSize: 36,
            borderWidth: 4,
            lineThickness: 5,
            // onStepTapped'i de buraya eklemek isteyebilirsiniz.
            // onStepTapped: widget.onStepTapped,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: seriesTitleWidget,
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.41,
            child: TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Bölüm Başlığı',
                  hintText: '60 karakterden az olmalıdır',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  )),
              maxLength: 60,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Boş bırakılamaz' : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.topCenter,
          child: DropzoneW(
            onFilesChanged: (files) {
              setState(() {
                _pages = files;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        if (isWideScreen)
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: _submit,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text("Bölümü Kaydet", style: AppTextStyles.subtitle),
                  ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String note,
    Uint8List? imageData,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        // const SizedBox(height: 70),
        Text(label, style: AppTextStyles.title.copyWith(color: Colors.black)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: imageData != null
                  ? DecorationImage(
                      image: MemoryImage(imageData), fit: BoxFit.cover)
                  : null,
            ),
            child: imageData == null
                ? const Center(
                    child: Icon(Icons.cloud_upload_outlined,
                        size: 40, color: Colors.grey),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          note,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        // const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty ||
        _episodeImage == null ||
        _pages.isEmpty ||
        _pages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Başlık, kapak ve en az beş sayfa ekleyin.")),
      );
      return;
    }

    // Yeni bir EpisodeDraftModel oluştur.
    final newEpisodeDraft = EpisodeDraftModel(
      title: _titleCtrl.text.trim(),
      thumbnail: _episodeImage!,
      pages: _pages,
    );

    // This now works because `ref` is a property of ConsumerState.
    ref.read(seriesDraftProvider.notifier).addEpisode(newEpisodeDraft);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bölüm taslağı eklendi!")),
    );

    // Formu temizle ve bir sonraki bölüme hazırla.
    _titleCtrl.clear();
    setState(() {
      _episodeImage = null;
      _pages = [];
      // You may need to clear the DropzoneW widget as well if it holds its own state.
    });

    widget.onStepTapped(2);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final seriesDraft = ref.watch(seriesDraftProvider);
    final selectedSeriesId = seriesDraft.seriesId;

    // Başlığı gösterecek widget'ı dinamik olarak belirliyoruz.
    Widget seriesTitleWidget;

    if (selectedSeriesId != null && selectedSeriesId.isNotEmpty) {
      // --- SENARYO 1: VAR OLAN BİR SERİ İLE DEVAM EDİLİYOR ---
      // Firestore'dan bu serinin başlığını çekiyoruz.
      final seriesAsync = ref.watch(seriesProvider(selectedSeriesId));
      seriesTitleWidget = seriesAsync.when(
        data: (seriesDoc) {
          // Gelen dökümandan başlığı güvenli bir şekilde al.
          final title = (seriesDoc.data() as Map<String, dynamic>?)?['title'] ??
              'Seri Başlığı Yok';
          return Text(
            title,
            style: AppTextStyles.title.copyWith(color: Colors.black),
          );
        },
        loading: () => const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, st) => const Text('Seri başlığı yüklenemedi',
            style: TextStyle(color: Colors.red)),
      );
    } else {
      // --- SENARYO 2: YENİ BİR SERİ OLUŞTURULUYOR ---
      // Başlığı direkt olarak taslaktan alıyoruz.
      seriesTitleWidget = Text(
        seriesDraft.title, // Taslaktaki başlık
        style: AppTextStyles.title.copyWith(color: Colors.black),
      );
    }

    // 4. Removed the Consumer widget wrapper.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWideScreen =
                constraints.maxWidth >= AppBreakpoints.tablet;
            return Flex(
              direction: isWideScreen ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWideScreen)
                  Container(
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildImagePicker(
                          label: 'Kare Küçük Resimö',
                          note:
                              'Tavsiye edilen resim boyutu 160px*151px olmalıdır.\nGörüntü 500 KB\'tan küçük olmalıdır.\nYalnızca JPG, JPEG ve PNG formatlarına izin verilir.\nDosya ismi harfler ve numaralardan oluşturulmuş olmalıdır.',
                          imageData: _episodeImage,
                          onTap: _pickImage,
                        ),
                      ],
                    ),
                  ),
                isWideScreen
                    ? const SizedBox(width: 32)
                    : const SizedBox(height: 32),
                isWideScreen
                    ? Expanded(
                        child:
                            _buildFormFields(isWideScreen, seriesTitleWidget),
                      )
                    : _buildFormFields(isWideScreen, seriesTitleWidget),
                if (!isWideScreen)
                  Center(
                    child: _buildImagePicker(
                      label: 'Kare Küçük Resim',
                      note:
                          'Tavsiye edilen resim boyutu 160px*151px olmalıdır.\nGörüntü 500 KB\'tan küçük olmalıdır.\nYalnızca JPG, JPEG ve PNG formatlarına izin verilir.\nDosya ismi harfler ve numaralardan oluşturulmuş olmalıdır.',
                      imageData: _episodeImage,
                      onTap: _pickImage, // Simplified the call
                    ),
                  ),
                SizedBox(
                  height: 18,
                ),
                if (!isWideScreen)
                  Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : OutlinedButton(
                            onPressed: _submit,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text("Bölümü Kaydet",
                                style: AppTextStyles.subtitle),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
