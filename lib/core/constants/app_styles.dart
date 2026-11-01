import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Kiểu chữ & trang trí chuẩn theo thiết kế Timass
class AppStyles {
  // === STYLES CHO AUTHENTICATION ===
  // Tiêu đề Auth lớn
  static const TextStyle authTitle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  // Mô tả dưới tiêu đề
  static const TextStyle authSubtitle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.35,
  );

  // Nhãn ô nhập liệu
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Văn bản trong ô nhập liệu
  static const TextStyle inputText = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  // Gợi ý nhập liệu (Hint)
  static const TextStyle inputHint = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  // Chữ nút bấm Sage Green
  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Chữ liên kết dưới cùng
  static const TextStyle footerText = TextStyle(
    fontSize: 13.5,
    color: AppColors.textDark,
  );

  static const TextStyle footerLink = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.bold,
    color: AppColors.sageGreenDark,
  );

  // Bo góc thẻ Card Form (Bo tròn 4 góc chủ yếu giống ảnh mẫu)
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(24.0));

  // Bo góc khung nhập liệu
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(10.0));

  // Bo góc nút bấm
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));

  // === STYLES CHO LỊCH TRÌNH & CÔNG VIỆC ===
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
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
