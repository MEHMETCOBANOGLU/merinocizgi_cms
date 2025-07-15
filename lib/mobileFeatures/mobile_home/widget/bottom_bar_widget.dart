import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/view/myAccountPage.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

class BottomBarWidget extends ConsumerWidget {
  final List<BottomBarItem> items;

  const BottomBarWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);

    return Positioned(
      bottom: 16,
      child: Container(
        height: 56,
        width: size.width * .8,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .map((e) => Material(
                    color: selectedBottomBarIndex == items.indexOf(e)
                        ? AppColors.bg
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                    child: IconButton(
                      icon: Icon(e.icon),
                      onPressed: e.onTap,
                      color: e.color,
                      splashRadius: 24.0,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class BottomBarItem {
  final IconData icon;
  final Color color;

  final VoidCallback onTap;

  BottomBarItem({
    required this.icon,
    required this.onTap,
    required this.color,
  });
}
