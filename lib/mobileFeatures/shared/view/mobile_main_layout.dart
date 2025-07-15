import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/bottom_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/home_app_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/view/myAccountPage.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

class MobileMainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MobileMainLayout({super.key, required this.child});

  @override
  ConsumerState<MobileMainLayout> createState() => _MobileMainLayoutState();
}

class _MobileMainLayoutState extends ConsumerState<MobileMainLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);
    return Scaffold(
        key: _scaffoldKey,
        appBar: const MobileHomeAppBar(),
        body: Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            BottomBarWidget(
              items: [
                BottomBarItem(
                  icon: Icons.home_outlined,
                  color: selectedBottomBarIndex == 0
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 0;
                    context.go('/');
                  },
                ),
                BottomBarItem(
                  icon: Icons.favorite_border,
                  color: selectedBottomBarIndex == 1
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 1;
                  },
                ),
                BottomBarItem(
                  icon: Icons.search_outlined,
                  color: selectedBottomBarIndex == 2
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 2;
                  },
                ),
                BottomBarItem(
                  icon: Icons.person_outlined,
                  color: selectedBottomBarIndex == 3
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 3;
                    context.push('/myAccount');
                  },
                ),
              ],
            )
          ],
        ));
  }
}
