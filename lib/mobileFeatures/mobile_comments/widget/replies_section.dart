import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/time.dart';

/// repliesProvider(parentId) => Stream<List<Comment>>
class RepliesSection extends ConsumerStatefulWidget {
  final String parentId;
  const RepliesSection({super.key, required this.parentId});

  @override
  ConsumerState<RepliesSection> createState() => _RepliesSectionState();
}

class _RepliesSectionState extends ConsumerState<RepliesSection>
    with TickerProviderStateMixin {
  bool _expanded = false;
  static const int _previewCount = 0;

  @override
  Widget build(BuildContext context) {
    final replies = ref.watch(repliesProvider(widget.parentId));

    return replies.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        final total = list.length;
        final shown = _expanded ? list : list.take(_previewCount).toList();
        final remaining = (total - _previewCount).clamp(0, total);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yanıtlar (soldan içe girinti)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                children: shown.map((r) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 40.0, top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                (r.userPhoto != null && r.userPhoto!.isNotEmpty)
                                    ? NetworkImage(r.userPhoto!)
                                    : null),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${r.userName}',
                                    style: AppTextStyles.oswaldText.copyWith(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${timeAgoTr(r.createdAt)}',
                                    style: AppTextStyles.oswaldText.copyWith(
                                        color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                r.text,
                                style: AppTextStyles.oswaldText.copyWith(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 4),

            // Buton: göster/gizle
            TextButton(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.white10,
                  ),
                  Text(
                    _expanded
                        ? 'Yanıtları gizle'
                        : (remaining > 0
                            ? '$remaining diğer yanıtı gör'
                            : 'Yanıtları gör ($total)'),
                    style: AppTextStyles.oswaldText.copyWith(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(left: 40.0),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Text('Cevaplar yüklenemedi: $e'),
      ),
    );
  }
}
