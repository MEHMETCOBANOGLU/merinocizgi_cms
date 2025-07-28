import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';

class EditChapterPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const EditChapterPage({
    Key? key,
    required this.bookId,
    this.chapterId,
  }) : super(key: key);

  @override
  ConsumerState<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends ConsumerState<EditChapterPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _editorInitialized = false;

  bool get _isEditing => widget.chapterId != null;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  Future<void> _saveChapter(String status) async {
    setState(() => _isLoading = true);
    final contentJson = jsonEncode(_controller.document.toDelta().toJson());
    final bookController = ref.read(bookControllerProvider.notifier);

    try {
      if (_isEditing) {
        await bookController.updateChapter(
          bookId: widget.bookId,
          chapterId: widget.chapterId!,
          content: contentJson,
          status: status,
        );
      } else {
        await bookController.createChapter(
          bookId: widget.bookId,
          content: contentJson,
          status: status,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Bölüm kaydedildi"), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !_editorInitialized) {
      final chapterAsync = ref.watch(singleChapterProvider(
        (bookId: widget.bookId, chapterId: widget.chapterId!),
      ));

      return chapterAsync.when(
        data: (doc) {
          if (doc != null && doc.exists) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              final rawContent = data['content'];

              late Document document;

              if (rawContent != null &&
                  (rawContent.trim().startsWith('{') ||
                      rawContent.trim().startsWith('['))) {
                document = Document.fromJson(jsonDecode(rawContent));
              } else {
                document = Document()..insert(0, rawContent ?? '');
              }

              _controller = QuillController(
                document: document,
                selection: const TextSelection.collapsed(offset: 0),
              );
              _editorInitialized = true;
            } catch (e) {
              debugPrint('Quill JSON Hatası: $e');
              _controller = QuillController.basic();
            }
          }
          return _buildUI();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text("Hata: $e"))),
      );
    }

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Bölümü Düzenle" : "Yeni Bölüm"),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(bookControllerProvider.notifier).deleteChapter(
                      bookId: widget.bookId,
                      chapterId: widget.chapterId!,
                    );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: true,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: true,
              showListBullets: true,
              showListNumbers: true,
              showQuote: true,
              showCodeBlock: true,
              showClearFormat: true,
              showHeaderStyle: true,
              showAlignmentButtons: true,
              showUndo: true,
              showRedo: true,
              showLink: true,
              showDirection: true,
              showIndent: true,
              showInlineCode: true,
              multiRowsDisplay: false,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(
                      8), // köşeleri hafif yuvarlamak için
                ),
                padding: const EdgeInsets.all(
                    8), // içeriden padding verirseniz daha güzel görünür
                child: QuillEditor(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: const QuillEditorConfig(
                    scrollable: true,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                  ),
                  scrollController: ScrollController(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: _isLoading ? null : () => _saveChapter('draft'),
                child: const Text("Taslak"),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _saveChapter('published'),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Kaydet"),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
