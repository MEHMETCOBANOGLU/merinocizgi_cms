// lib/mobileFeatures/shared/widgets/liquid_glass_icon_button.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/index.dart';

class LiquidGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color iconColor;
  final Color backgroundColor;

  const LiquidGlassIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 46.0,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.white10, // Yarı şeffaf beyaz
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ClipOval, içindeki her şeyi dairesel olarak kırpar.
    return ClipOval(
      child: BackdropFilter(
        // Bu, arkasındaki her şeyi blurlayan sihirli kısımdır.
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            // (Opsiyonel) Dairenin kenarına ince bir parlama efekti
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
          ),
          child: IconButton(
            icon: Icon(icon),
            iconSize: size * 0.5, // İkonun boyutu daireye orantılı olsun
            color: iconColor,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
