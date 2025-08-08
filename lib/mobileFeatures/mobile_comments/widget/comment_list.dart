// comment_list.dart (IG tarzı)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/controller/reply_state_provider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/replies_section.dart';
import 'comment_tile.dart';
import 'package:merinocizgi/domain/entities/comment.dart';
import 'package:merinocizgi/domain/repositories/comment_repository.dart';

class CommentList extends ConsumerStatefulWidget {
  final String contentType;
  final String contentId;
  const CommentList({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  @override
  ConsumerState<CommentList> createState() => _CommentListState();
}

class _CommentListState extends ConsumerState<CommentList> {
  final _scrollCtrl = ScrollController();

  Future<void> _focusComposer() async {
    // küçük delay fokus için iyi olur
    await Future.delayed(const Duration(milliseconds: 80));
    // sayfanın composer’ına fokus vermek için dışarıdan focusNode geçebilirsin
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(commentRepositoryProvider);

    return StreamBuilder<List<Comment>>(
      stream: repo.watchTopLevel(
        contentType: widget.contentType,
        contentId: widget.contentId,
      ),
      builder: (context, topSnap) {
        if (!topSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final parents = topSnap.data!;
        if (parents.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView(
          controller: _scrollCtrl,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            for (final p in parents) ...[
              CommentTile(
                comment: p,
                isReply: false,
                depth: 0,
                onReplyTap: () async {
                  ref.read(replyStateProvider.notifier).set(
                        ReplyTarget(
                          commentId: p.id,
                          userName: p.userName,
                          preview: p.text.length > 40
                              ? '${p.text.substring(0, 40)}…'
                              : p.text,
                        ),
                      );
                  await _focusComposer();
                },
              ),
              // 🔻 RepliesSection entegrasyonu (göster/gizle + aksiyonlar)
              RepliesSection(
                parentId: p.id,
                onReplyTap: (r) async {
                  // IG gibi: reply’e yanıt verirken de parent’a bağla
                  ref.read(replyStateProvider.notifier).set(
                        ReplyTarget(
                          commentId: p.id, // kritik: parent’a bağla
                          userName: r.userName,
                          preview: r.text.length > 40
                              ? '${r.text.substring(0, 40)}…'
                              : r.text,
                        ),
                      );
                  await _focusComposer();
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
