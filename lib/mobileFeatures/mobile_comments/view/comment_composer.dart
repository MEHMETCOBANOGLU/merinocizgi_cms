// comment_composer.dart
// CommentComposer: Altta sabit inline composer. Yanıt modunda üstünde “Yanıtladığın: @kisi ❌” barı çıkar. Otomatik fokus/temizleme yapar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/controller/reply_state_provider.dart';

class CommentComposer extends ConsumerStatefulWidget {
  final String? hint;
  final Future<void> Function(String text) onSend;
  final FocusNode? externalFocusNode; // Dışarıdan focus yönetimi (opsiyonel)
  const CommentComposer({
    super.key,
    this.hint,
    required this.onSend,
    this.externalFocusNode,
  });

  @override
  ConsumerState<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<CommentComposer> {
  final _ctrl = TextEditingController();
  FocusNode? _ownFocus;
  FocusNode get _focus =>
      widget.externalFocusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ctrl.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replyTarget = ref.watch(replyStateProvider);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyTarget != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
                color: Colors.black54,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                        children: [
                          const TextSpan(text: "Yanıtladığın: "),
                          TextSpan(
                            text: "@${replyTarget.userName}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          if ((replyTarget.preview ?? '').isNotEmpty)
                            TextSpan(text: " — ${replyTarget.preview}"),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.white70),
                    onPressed: () {
                      ref.read(replyStateProvider.notifier).clear();
                      _ctrl.clear();
                      _focus.requestFocus();
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? "Yorum yaz...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _ctrl.text.trim();
                    if (text.isEmpty) return;
                    await widget.onSend(text);
                    _ctrl.clear();
                    ref.read(replyStateProvider.notifier).clear();
                    // Fokus’u bırakmak istemezsen kaldır
                    // FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
