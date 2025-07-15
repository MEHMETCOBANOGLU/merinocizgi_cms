import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const MobileHomeAppBar({super.key, this.actions});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leadingWidth: 100,
      leading: Image.asset(
        'assets/images/merino.png',
        width: 55,
      ),
      actions: actions,
    );
  }
}
