import 'package:flutter/material.dart';

class CommentComposer extends StatefulWidget {
  final void Function(String text) onSend;
  final String? hint;

  const CommentComposer({super.key, required this.onSend, this.hint});

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final _c = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Yorum yaz…',
              filled: true,
              fillColor: Colors.white10,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _sending
              ? null
              : () async {
                  final text = _c.text.trim();
                  if (text.isEmpty) return;
                  setState(() => _sending = true);
                  try {
                    widget.onSend(text);
                    _c.clear();
                  } finally {
                    if (mounted) setState(() => _sending = false);
                  }
                },
          icon: _sending
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        )
      ],
    );
  }
}
