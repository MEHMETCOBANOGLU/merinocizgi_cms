import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class AppTextStyles {
  //app bardaki title
  static final title = GoogleFonts.bangers(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  static final subtitle = GoogleFonts.fredoka(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  // body deki büyük title
  static final heading = GoogleFonts.permanentMarker(
    textStyle: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
    ),
  );

  // body deki alt title
  static final subheading = GoogleFonts.permanentMarker(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
    ),
  );
  static final text = GoogleFonts.comicNeue(
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.4,
      letterSpacing: 1.2,
      color: Colors.white,
    ),
  );

  static final oswaldTitle = GoogleFonts.oswald(
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 30,
      color: AppColors.textPrimary,
    ),
  );
  static final oswaldSubtitle = GoogleFonts.oswald(
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: AppColors.textPrimary,
    ),
  );
  static final oswaldText = GoogleFonts.oswald(
    textStyle: const TextStyle(
      color: AppColors.textPrimary,
    ),
  );
}
