// lib/features/books/view/edit_chapter_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class EditChapterPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId; // Yeni bölüm için bu null olacak

  const EditChapterPage({
    Key? key,
    required this.bookId,
    this.chapterId,
  }) : super(key: key);

  @override
  ConsumerState<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends ConsumerState<EditChapterPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final String status = "draft";
  bool _isLoading = false;

  // Modu belirle: "Yeni" mi, "Düzenleme" mi?
  bool get _isEditing => widget.chapterId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveChapter(String status) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final bookController = ref.read(bookControllerProvider.notifier);

    try {
      if (_isEditing) {
        // Düzenleme modundaysak, güncelle
        await bookController.updateChapter(
          bookId: widget.bookId,
          chapterId: widget.chapterId!,
          title: _titleController.text.trim(),
          content: _contentController.text,
          status: status,
        );
      } else {
        // Yeni bölüm modundaysak, oluştur
        await bookController.createChapter(
          bookId: widget.bookId,
          title: _titleController.text.trim(),
          content: _contentController.text,
          status: status,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Bölüm başarıyla kaydedildi!"),
            backgroundColor: Colors.green));
        Navigator.of(context)
            .pop(); // Bir önceki sayfaya (Bölüm Listesi) geri dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Bir hata oluştu: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer düzenleme modundaysak, mevcut bölüm verisini çek ve form alanlarını doldur.
    if (_isEditing) {
      final chapterAsync = ref.watch(singleChapterProvider(
          (bookId: widget.bookId, chapterId: widget.chapterId!)));

      return chapterAsync.when(
        data: (doc) {
          if (doc != null && doc.exists) {
            // Veri geldiğinde controller'ları sadece bir kez doldur.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_titleController.text.isEmpty) {
                // Sadece boşsa doldur
                final data = doc.data() as Map<String, dynamic>;
                _titleController.text = data['title'] ?? '';
                _contentController.text = data['content'] ?? '';
              }
            });
          }
          return _buildEditorUI(); // Veri yüklendikten sonra UI'ı çiz
        },
        loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Bölüm yüklenemedi: $e"))),
      );
    }

    // Yeni bölüm modundaysak, doğrudan UI'ı çiz.
    return _buildEditorUI();
  }

  // Asıl UI'ı oluşturan metot
  Widget _buildEditorUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Bölümü Düzenle" : "Yeni Bölüm Ekle"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(MingCute.delete_3_line),
              onPressed: () {
                if (_isEditing) {
                  // Düzenleme modundaysak, bölümü sil
                  ref.read(bookControllerProvider.notifier).deleteChapter(
                      bookId: widget.bookId, chapterId: widget.chapterId!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Bölüm Başlığı",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Başlık boş olamaz"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Bölüm İçeriği",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 25, // Geniş bir alan
                validator: (value) => (value == null || value.isEmpty)
                    ? "İçerik boş olamaz"
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => _saveChapter('draft'),
                      child: const Text("Taslak")),
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _saveChapter('published'),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Kaydet"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
