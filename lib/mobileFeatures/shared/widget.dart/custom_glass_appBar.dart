import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class CustomGlassSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const CustomGlassSliverAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 10,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(), // boş ama blur efekti için gerekli
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
