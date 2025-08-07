import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_social/view/post_composer_sheet.dart';

class addPostSheet extends ConsumerWidget {
  const addPostSheet(
    BuildContext context, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () {
          if (user?.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Giriş yapmanız gerekiyor.")));
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // klavye için önemli
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const PostComposerSheet(),
            );
          }
        },
        child: const Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,

          children: [
            Positioned(
                bottom: 6,
                right: 4,
                child: Icon(MingCute.quill_pen_line, color: Colors.white)),
            Positioned(
                left: 7,
                top: 5,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                )),
          ], // Row(
        ),
      ),
    );
  }
}

void addPostSheetfunc(BuildContext context, WidgetRef ref) {
  final user = ref.read(authStateProvider).asData?.value;

  if (user?.user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Giriş yapmanız gerekiyor.")),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const PostComposerSheet(),
    );
  }
}
