// lib/features/publish/widgets/comicDetailsForm.dart

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/features/publish/controller/series_draft_provider.dart';
import 'package:merinocizgi/features/publish/widgets/step_%C4%B0ndicator.dart';

class ComisDetailForm extends ConsumerStatefulWidget {
  final void Function(int step) onStepTapped;

  const ComisDetailForm({
    Key? key,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  ConsumerState<ComisDetailForm> createState() => _ComisDetailFormState();
}

class _ComisDetailFormState extends ConsumerState<ComisDetailForm> {
  // --- STATE DEĞİŞKENLERİ ---
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  String? _category1;
  String? _category2;
  Uint8List? _squareThumb;
  Uint8List? _verticalThumb;

  final List<String> _categories = [
    'FANTEZİ',
    'KOMEDİ',
    'AKSİYON',
    'DRAM',
    'ROMANTİZM',
    'BİLİMKURGU',
    'SÜPER KAHRAMAN',
    'GERİLİM',
    'KORKU',
    'ZOMBİ',
    'OKUL',
    'DOĞAÜSTÜ',
    'HAYVAN',
    'SUÇ/GİZEM',
    'TARİHSEL',
    'BİLGİLENDİRİCİ',
    'SPOR',
    'HER YAŞTAN',
    'KIYAMET SONRASI',
  ];

  @override
  void initState() {
    super.initState();
    // Sayfa ilk yüklendiğinde, taslaktaki verileri form alanlarına doldur.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(seriesDraftProvider);
      if (mounted) {
        setState(() {
          _titleCtrl.text = draft.title;
          _summaryCtrl.text = draft.summary;
          _category1 = draft.category1;
          _category2 = draft.category2;
          _squareThumb = draft.squareImage;
          _verticalThumb = draft.verticalImage;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  // --- ANA BUILD METODU ---
  @override
  Widget build(BuildContext context) {
    // Güvenli kullanıcı kontrolü
    final authState = ref.watch(authStateProvider).value;
    if (authState?.user == null) {
      return const Center(
          child: Text("İçerik yayınlamak için lütfen giriş yapın."));
    }

    return WillPopScope(
      onWillPop: () => _showExitDialog(context).then((value) => value ?? false),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWideScreen =
                  constraints.maxWidth >= AppBreakpoints.tablet;
              return Flex(
                direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                // ...
                children: [
                  if (isWideScreen) _buildImagePickers(),
                  isWideScreen
                      ? const SizedBox(width: 32)
                      : const SizedBox(height: 32),

                  // --- DÜZELTME BURADA ---
                  // Eğer geniş ekran ise (Row içinde), Expanded kullan.
                  // Eğer dar ekran ise (Column içinde), Expanded KULLANMA.
                  isWideScreen
                      ? Expanded(
                          child: _buildFormFields(isWideScreen),
                        )
                      : _buildFormFields(isWideScreen),

                  if (!isWideScreen) _buildImagePickers(),
                  SizedBox(
                    height: 18,
                  ),
                  if (!isWideScreen)
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          'Seriyi Oluştur',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI METOTLAR VE WIDGET'LAR ---

  /// Sadece resim yükleme widget'larını oluşturan, temiz bir metot.
  Widget _buildImagePickers() {
    return Center(
      child: Column(
        children: [
          _ImagePicker(
            label: 'Kare Küçük Resim',
            note:
                'Resim boyutu 1080x1080,\nGörüntü 500 KB\'tan küçük olmalıdır.\nYalnızca JPG, JPEG ve PNG formatlarına izin verilir.',
            imageData: _squareThumb,
            onTap: () => _pickImage(true),
          ),
          // const SizedBox(height: 36),
          _ImagePicker(
            label: 'Dikey Küçük Resim',
            note:
                'Resim boyutu 1080x1920,\n Görüntü 700 KB\'tan küçük olmalıdır.\n Yalnızca JPG, JPEG ve PNG formatlarına izin verilir.',
            imageData: _verticalThumb,
            onTap: () => _pickImage(false),
          ),
        ],
      ),
    );
  }

  /// Sadece form alanlarını (StepIndicator, Dropdown, TextFields) oluşturan bir metot.
  Widget _buildFormFields(bool isWideScreen) {
    final authorSeriesAsync = ref.watch(authorSeriesProvider);
    var varOlanSeriler = Align(
      alignment: isWideScreen ? Alignment.centerRight : Alignment.topCenter,
      child: authorSeriesAsync.when(
        data: (seriesSnapshot) {
          if (seriesSnapshot.docs.isEmpty) return const SizedBox.shrink();
          final seriesEntries = seriesSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DropdownMenuEntry<Map<String, String>>(
              value: {'id': doc.id, 'title': data['title'] ?? ''},
              label: data['title'] ?? 'Başlıksız Seri',
            );
          }).toList();

          return SizedBox(
            // width: 300,
            child: DropdownMenu<Map<String, String>>(
              width: 280,
              hintText: 'Var Olan Serilerimden İlerle',
              dropdownMenuEntries: seriesEntries,
              // helperText: 'Daha önceden oluşturulan seriyle ilerleyebilirsin.',
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onSelected: (selected) {
                // if (selected != null) _showContinueSeriesDialog(selected['id'], selected['title']!);
                if (selected != null)
                  _showContinueSeriesDialog(
                      context, selected['id']!, selected['title']!);
              },
            ),
          );
        },
        loading: () => const SizedBox(
            width: 220,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, st) => const Tooltip(
            message: "Seriler yüklenemedi",
            child: Icon(Icons.error, color: Colors.red)),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: StepIndicator(
            steps: const [
              'Seri Detayları',
              'Bölümleri Ekle',
              'İncele ve Yayınla'
            ],
            currentStep: 0,
            activeColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
            circleSize: 36,
            borderWidth: 4,
            lineThickness: 5,
          ),
        ),
        const SizedBox(height: 24),
        _buildHeaderAndExistingSeriesDropdown(varOlanSeriler),
        if (!isWideScreen) const SizedBox(height: 20),
        if (!isWideScreen) varOlanSeriler,
        const SizedBox(height: 24),
        _buildCategorySelectors(),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 300,
            child: TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Seri Başlığı',
                    hintText: '50 karakterden az olmalıdır',
                    hintStyle: TextStyle(color: Colors.grey)),
                maxLength: 50,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Bu alan zorunludur.'
                    : null),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
            controller: _summaryCtrl,
            decoration: const InputDecoration(
                labelText: 'Özet', hintText: '600 karakterden az'),
            maxLines: 9,
            maxLength: 600,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Boş bırakılamaz' : null),
        const SizedBox(height: 10),
        if (isWideScreen)
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                'Seriyi Oluştur',
                style: AppTextStyles.subtitle,
              ),
            ),
          ),
      ],
    );
  }

  /// "Çizgi Romanını Yayınla" başlığını ve "Var Olan Serilerim" dropdown'ını içeren Stack.
  Widget _buildHeaderAndExistingSeriesDropdown(varOlanSeriler) {
    final widthH = MediaQuery.of(context).size.width;
    final bool isWideScreen = widthH >= AppBreakpoints.tablet;

    return Stack(
      alignment: Alignment.center,
      children: [
        Semantics(
          header: true,
          headingLevel: 1,
          child: Text('ÇİZGİ ROMANINI YAYINLA',
              style: AppTextStyles.subheading.copyWith(color: Colors.black)),
        ),
        if (isWideScreen) varOlanSeriler,
      ],
    );
  }

  /// Kategori seçimi için Dropdown'ları içeren Row.
  Widget _buildCategorySelectors() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _category1,
            decoration: const InputDecoration(labelText: 'Kategori 1'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category1 = v),
            validator: (v) => v == null ? 'Bir kategori seçmelisiniz' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _category2,
            decoration:
                const InputDecoration(labelText: 'Kategori 2 (isteğe bağlı)'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category2 = v),
          ),
        ),
      ],
    );
  }

  // --- MANTIK FONKSİYONLARI ---

  /// Form gönderme mantığını içeren fonksiyon.
  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_squareThumb == null || _verticalThumb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen kapak resimlerini seçin.')));
      return;
    }

    final userId = ref.read(authStateProvider).value!.user!.uid;
    ref.read(seriesDraftProvider.notifier).updateSeriesDetails(
          userId: userId,
          title: _titleCtrl.text.trim(),
          summary: _summaryCtrl.text.trim(),
          category1: _category1,
          category2: _category2,
          squareImage: _squareThumb,
          verticalImage: _verticalThumb,
        );
    widget.onStepTapped(1);
  }

  Future<void> _pickImage(bool isSquare) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        if (isSquare) {
          _squareThumb = res.files.single.bytes!;
        } else {
          _verticalThumb = res.files.single.bytes!;
        }
      });
    }
  }

  void _showContinueSeriesDialog(
      BuildContext context, String seriesId, String seriesTitle) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(seriesTitle,
              style: AppTextStyles.title.copyWith(color: Colors.black),
              textAlign: TextAlign.center),
          content: Text(
            'Var olan seriniz "$seriesTitle" ile devam edip yeni bir bölüm eklemek istiyor musunuz?',
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  // Önce diyaloğu kapat
                  Navigator.of(dialogContext).pop();

                  // Sonraki adıma geçiş için ana widget'taki metodu çağır
                  // ve hangi seri ile devam edileceğini de bir şekilde bildirmemiz gerekiyor.
                  // Bunun en iyi yolu, seçilen serinin ID'sini bir state'e yazmaktır.
                  ref
                      .read(seriesDraftProvider.notifier)
                      .setSelectedSeriesId(seriesId);

                  // Artık bir sonraki adıma geçebiliriz.
                  widget.onStepTapped(1);
                },
                child: const Text('Evet'))
          ],
        );
      },
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Formdan çıkmak istediğinize emin misiniz?"),
        content: const Text("Girdiğiniz bilgiler kaybolabilir."),
        actions: [
          TextButton(
            child: const Text("Vazgeç"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Çık"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

// --- AYRI BİR WIDGET: _ImagePicker ---
// Resim seçici UI'ını kendi widget'ına taşımak kodu daha da temizler.
class _ImagePicker extends StatelessWidget {
  final String label;
  final String note;
  final Uint8List? imageData;
  final VoidCallback onTap;

  const _ImagePicker({
    required this.label,
    required this.note,
    this.imageData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.title.copyWith(color: Colors.black)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                image: imageData != null
                    ? DecorationImage(
                        image: MemoryImage(imageData!), fit: BoxFit.cover)
                    : null,
              ),
              child: imageData == null
                  ? const Center(
                      child: Icon(Icons.cloud_upload_outlined,
                          size: 40, color: Colors.grey))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 180,
            child: Text(note,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
