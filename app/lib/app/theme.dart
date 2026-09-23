import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFFFEFD);
  static const white = Color(0xFFFFFFFF);
  static const primary = Color(0xFFFF4900);
  static const kakao = Color(0xFFFEE500);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF636366);
  static const textMuted = Color(0xFF8E8E93);
  static const placeholder = Color(0xFFADA39E);
  static const chipText = Color(0xFF717A8E);
  static const systemBlack = Color(0xFF121212);
  static const surfaceSubtle = Color(0xFFF9F9FB);
  static const border = Color(0xFFE5E5EA);
  static const searchBorder = Color(0xFFE8D8C7);
  static const disabled = Color(0xFFB0B2B6);
  static const errorSurface = Color(0xFFFFEFE9);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.primary,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodySmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
      ),
      labelMedium: TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
      ),
      labelSmall: TextStyle(
        color: AppColors.chipText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      ),
    ),
  );
}
