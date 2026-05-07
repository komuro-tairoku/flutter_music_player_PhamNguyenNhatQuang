import 'package:flutter/material.dart';

class AppColors {
  // Core palette - warm off-white & deep charcoal
  static const Color background = Color(0xFFF7F5F2);
  static const Color backgroundDark = Color(0xFF1A1916);
  static const Color surface = Color(0xFFEFECE8);
  static const Color surfaceDark = Color(0xFF252320);
  static const Color surfaceElevated = Color(0xFFE8E4DE);
  static const Color surfaceElevatedDark = Color(0xFF2F2C29);

  // Accent — warm amber
  static const Color primary = Color(0xFFD4825A);
  static const Color primaryLight = Color(0xFFE8A882);
  static const Color primaryDark = Color(0xFFB8643E);

  // Text
  static const Color textPrimary = Color(0xFF1A1916);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textTertiary = Color(0xFFB0AAA2);
  static const Color textOnDark = Color(0xFFF7F5F2);
  static const Color textOnDarkSecondary = Color(0xFFB0AAA2);

  // Utility
  static const Color divider = Color(0xFFDDD9D3);
  static const Color dividerDark = Color(0xFF353230);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0D0C0B);

  // Legacy aliases (keep compatibility)
  static const Color grey = Color(0xFFB0AAA2);
  static const Color greyDark = Color(0xFF353230);
  static const Color accent = Color(0xFFD4825A);
}

class AppSizes {
  static const double miniPlayerHeight = 72.0;
  static const double albumArtBorderRadius = 12.0;
  static const double mainControlSize = 48.0;
  static const double secondaryControlSize = 36.0;
  static const double screenPadding = 20.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 40.0;
}

class AppStrings {
  static const String appName = 'Tune';
  static const String nowPlaying = 'Now Playing';
  static const String noSongsFound = 'No Music Found';
  static const String addMusicMessage =
      'Add some music files to your device to get started';
  static const String permissionRequired = 'Permission Required';
  static const String permissionMessage =
      'Please allow access to your music library';
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'serif',
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.8,
  );
}
