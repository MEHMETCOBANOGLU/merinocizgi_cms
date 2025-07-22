import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

// Bu, formun state'ini yönetecek olan basit bir provider.
// Her bir alan için ayrı state'ler tutar.
final bookFormProvider =
    StateNotifierProvider.autoDispose<BookFormNotifier, BookFormState>((ref) {
  return BookFormNotifier();
});

// Formun state'ini tutan sınıf
class BookFormState {
  final Uint8List? coverImage;
  final String title;
  final String description;
  final String? category;
  final String? copyright;
  final List<String> tags;

  BookFormState({
    this.coverImage,
    this.title = '',
    this.description = '',
    this.category,
    this.copyright,
    this.tags = const [],
  });

  BookFormState copyWith({
    Uint8List? coverImage,
    String? title,
    String? description,
    String? category,
    String? copyright,
    List<String>? tags,
  }) {
    return BookFormState(
      coverImage: coverImage ?? this.coverImage,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      copyright: copyright ?? this.copyright,
      tags: tags ?? this.tags,
    );
  }
}

class BookFormNotifier extends StateNotifier<BookFormState> {
  BookFormNotifier() : super(BookFormState());

  void updateField({
    Uint8List? coverImage,
    String? title,
    String? description,
    String? category,
    String? copyright,
  }) {
    state = state.copyWith(
      coverImage: coverImage,
      title: title,
      description: description,
      category: category,
      copyright: copyright,
    );
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
  }
}
// The argument type 'List<DropdownMenuItem<Map<String, String>>>'
// can't be assigned to the parameter type 'List<DropdownMenuItem<String>>?'

final List<Map<String, String>> copyrights = [
  {
    'label': 'Tüm Hakları Saklıdır',
    'description': 'Bu içerik sadece yazarın izniyle kullanılabilir.'
  },
  {
    'label': 'Creative Commons BY',
    'description': 'Kaynak gösterilerek kullanılabilir.'
  },
  {
    'label': 'Creative Commons BY-NC',
    'description': 'Kaynak gösterilmeli, ticari amaçla kullanılamaz.'
  },
  {
    'label': 'Creative Commons BY-NC-ND',
    'description':
        'Kaynak gösterilmeli, ticari olmayan amaçla ve değişiklik yapılmadan kullanılabilir.'
  },
  {
    'label': 'Public Domain',
    'description': 'Bu içerik herkes tarafından serbestçe kullanılabilir.'
  },
  {
    'label': 'Creative Commons BY-SA',
    'description': 'Kaynak gösterilmeli, aynı lisansla paylaşılmalıdır.'
  },
  {
    'label': 'Creative Commons BY-ND',
    'description': 'Kaynak gösterilmeli, ancak değiştirilemez.'
  },
  {
    'label': 'Creative Commons Zero (CC0)',
    'description': 'Yazar tüm haklarından feragat eder. Tamamen serbesttir.'
  }
];

class CreateBookPage extends ConsumerWidget {
  const CreateBookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller'ın durumunu (loading, error) izle
    final bookControllerState = ref.watch(bookControllerProvider);
    final isLoading = bookControllerState is AsyncLoading;

    // Formun state'ini ve notifier'ını izle/oku
    final formState = ref.watch(bookFormProvider);
    final formNotifier = ref.read(bookFormProvider.notifier);
    final tagController = TextEditingController();

    // Hataları dinleyip SnackBar göstermek için bir listener
    ref.listen<AsyncValue<String?>>(bookControllerProvider, (_, state) {
      if (state is AsyncError) {
        print(" Hata: ${state.error}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${state.error}")),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kitap Oluştur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kapak Fotoğrafı
                Center(
                  child: InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform
                          .pickFiles(type: FileType.image, withData: true);
                      if (result?.files.single.bytes != null) {
                        formNotifier.updateField(
                            coverImage: result!.files.single.bytes!);
                      }
                    },
                    child: Container(
                      //4:3
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: formState.coverImage != null
                          ? Image.memory(formState.coverImage!,
                              fit: BoxFit.cover)
                          : const Center(
                              child:
                                  Icon(Icons.add_a_photo_outlined, size: 50)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Kitap Adı
                TextFormField(
                  initialValue: formState.title,
                  onChanged: (value) => formNotifier.updateField(title: value),
                  decoration: const InputDecoration(labelText: "Kitap Adı"),
                ),
                const SizedBox(height: 16),

                // 3. Açıklama
                TextFormField(
                  initialValue: formState.description,
                  onChanged: (value) =>
                      formNotifier.updateField(description: value),
                  decoration:
                      const InputDecoration(labelText: "Açıklama (Sinopsis)"),
                  maxLength: 600,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // 4. Kategori ve Telif Hakkı
                DropdownButtonFormField<String>(
                  value: formState.category,
                  hint: const Text("Kategori Seçin"),
                  items: [
                    'Aksiyon',
                    'Askeri',
                    'Bilim Kurgu',
                    'Deneme',
                    'Dini',
                    'Drama',
                    'Fantastik',
                    'Genel Kurgu',
                    'Genç Kurgu',
                    'Gerilim',
                    'Gizem',
                    'Kısa Hikaye',
                    'Klasikler',
                    'Korku',
                    'Macera',
                    'Polisiye',
                    'Roman',
                    'Romantik Gerilim',
                    'Senaryo',
                    'Siyasi',
                    'Spiritüel',
                    'Şiir',
                    'Tarih',
                    'Türk Klasikleri',
                    'Vampir',
                    'Diğer',
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      formNotifier.updateField(category: value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: formState.copyright,
                  hint: const Text("Telif Hakkı"),
                  // Sadece label'ı göstermek için selectedItemBuilder kullanıyoruz:
                  selectedItemBuilder: (context) {
                    return copyrights.map((item) {
                      return Text(
                          item['label']!); // Seçildiğinde sadece label görünsün
                    }).toList();
                  },
                  items: copyrights.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['label'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['label']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            item['description']!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      formNotifier.updateField(copyright: value),
                ),

                const SizedBox(height: 24),

                // 5. Etiketler
                Text("Etiketler",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagController,
                        decoration:
                            const InputDecoration(hintText: "Etiket ekle..."),
                        onSubmitted: (value) {
                          formNotifier.addTag(value);
                          tagController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        formNotifier.addTag(tagController.text);
                        tagController.clear();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Eklenen etiketleri gösteren Chip'ler
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: formState.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => formNotifier.removeTag(tag),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // 6. Kitabı Oluştur Butonu
                Center(
                  child: ElevatedButton(
                    // Eğer işlem sürüyorsa butonu pasif yap
                    onPressed: isLoading
                        ? null
                        : () async {
                            // Controller'daki metodu çağır
                            final newBookId = await ref
                                .read(bookControllerProvider.notifier)
                                .createBook(formState);

                            // Eğer kitap başarıyla oluşturulduysa (ID döndüyse)
                            if (newBookId != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Kitap başarıyla oluşturuldu! Şimdi bölümleri ekleyebilirsiniz."),
                                    backgroundColor: Colors.green),
                              );
                              // Kullanıcıyı "Bölümleri Yönet" sayfasına yönlendir.
                              context.push(
                                  '/myAccount/books/$newBookId/chapters'); // Örnek bir rota
                            }
                          },
                    // İşlem sürüyorsa loading indicator göster
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Kitabımı Oluştur"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
