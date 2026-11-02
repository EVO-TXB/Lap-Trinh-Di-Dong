import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Quản lý Theme toàn ứng dụng (Chế độ Sáng & Tối)
class AppThemes {
  /// Theme Sáng (Light Theme)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.sageGreen,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sageGreen,
      brightness: Brightness.light,
      primary: AppColors.sageGreen,
      surface: Colors.white,
      onSurface: AppColors.darkNavy,
      outline: const Color(0xFFD1D5DB),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFF1F5F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.darkNavy,
      elevation: 0,
    ),
  );

  /// Theme Tối (Dark Theme)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.sageGreen,
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sageGreen,
      brightness: Brightness.dark,
      primary: AppColors.sageGreen,
      surface: const Color(0xFF1E293B), // Slate 800
      onSurface: const Color(0xFFF8FAFC), // Slate 50
      outline: const Color(0xFF334155), // Slate 700
    ),
    cardColor: const Color(0xFF1E293B), // Slate 800
    dividerColor: const Color(0xFF334155), // Slate 700
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Color(0xFFF8FAFC),
      elevation: 0,
    ),
  );
}

