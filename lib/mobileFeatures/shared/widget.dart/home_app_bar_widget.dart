import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  const MobileHomeAppBar({super.key, this.actions, this.bottom});

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leadingWidth: 100,
      leading: Image.asset(
        'assets/images/merino.png',
        width: 55,
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
