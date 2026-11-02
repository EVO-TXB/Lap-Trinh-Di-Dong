import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Hiệu ứng chuyển trang mượt mà (Silky Smooth Slide & Subtle Fade)
/// Loại bỏ hiện tượng nhấp nháy, giật cục khi chuyển qua lại giữa các màn hình
class SmoothSlideTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Đường cong gia tốc mượt mà chuẩn Material 3
    final primaryCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.easeInCubic,
    );
    final secondaryCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.06, 0.0),
        end: Offset.zero,
      ).animate(primaryCurve),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(primaryCurve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.03, 0.0),
          ).animate(secondaryCurve),
          child: child,
        ),
      ),
    );
  }
}

/// Quản lý Theme toàn ứng dụng (Chế độ Sáng & Tối)
class AppThemes {
  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SmoothSlideTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: SmoothSlideTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: SmoothSlideTransitionsBuilder(),
    },
  );

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
    pageTransitionsTheme: _pageTransitionsTheme,
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
    pageTransitionsTheme: _pageTransitionsTheme,
  );
}
