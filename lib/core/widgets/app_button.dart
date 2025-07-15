import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

/// Uygulama genelinde kullanılan özelleştirilmiş buton.
class AppButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? asset;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.icon,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(10, 48),
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 42,
              ),
            )
          else if (asset != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset('assets/images/$asset', width: 32, height: 32),
            ),
          const SizedBox(height: 4),
          Center(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      // fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
