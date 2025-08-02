import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';

//quill db e texti json formtında tutuyor. bu yüzden bunu parse etmeliyiz
class QuillContentView extends StatelessWidget {
  final dynamic rawContent;
  const QuillContentView({super.key, required this.rawContent});

  @override
  Widget build(BuildContext context) {
    final doc = parseQuillDoc(rawContent);
    final controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      focusNode: FocusNode(),
      config: const QuillEditorConfig(
        // readOnly: true,                 // <- önemli
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        showCursor: false,
        enableInteractiveSelection: false,
        scrollable: true,
      ),
    );
  }
}

Document parseQuillDoc(dynamic raw) {
  if (raw == null) return Document();
  if (raw is String) {
    // Firestore'da string tutulduysa
    final decoded = jsonDecode(raw);
    return Document.fromJson(List<Map<String, dynamic>>.from(decoded));
  }
  if (raw is List) {
    // Firestore'da direkt List<Map> olarak tutulduysa
    return Document.fromJson(List<Map<String, dynamic>>.from(raw));
  }
  // Beklenmeyen format – yine de bir şey göster
  return Document()..insert(0, raw.toString());
}
