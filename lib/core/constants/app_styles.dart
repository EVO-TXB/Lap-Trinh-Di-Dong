import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Kiểu chữ & trang trí chuẩn theo thiết kế Timass
class AppStyles {
  static const TextStyle logoText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.darkNavy,
    letterSpacing: -0.5,
  );

  static const TextStyle headerTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.darkNavy,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle legendText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle timeColumnText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.timeText,
  );

  static const TextStyle dayColumnHeader = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static BoxDecoration cardShadow = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
