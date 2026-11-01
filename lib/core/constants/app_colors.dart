import 'package:flutter/material.dart';

/// Bảng màu chuẩn giao diện Timass
class AppColors {
  // === MÀU CHỦ ĐẠO & AUTHENTICATION ===
  // Màu chủ đạo Sage Green (chuẩn triệt để theo ảnh mẫu R=130, G=164, B=140)
  static const Color sageGreen = Color(0xFF82A48C);
  static const Color sageGreenDark = Color(0xFF6C8F76);
  static const Color sageGreenLight = Color(0xFFE8EFEA);
  static const Color sageGreenHover = Color(0xFF5A8567);

  // Màu nền Header & Accent
  static const Color headerBackgroundStart = Color(0xFFFFF1EE);
  static const Color headerBackgroundEnd = Color(0xFFFDE4DE);
  static const Color peachBackground = Color(0xFFFDE8E6);
  static const Color coralAccent = Color(0xFFFF8A80);
  static const Color screenMockupBackground = Color(0xFFE2E4E8);
  static const Color backgroundWhite = Colors.white;

  // Màu thương hiệu & chữ
  static const Color darkNavy = Color(0xFF181848);
  static const Color textDark = Color(0xFF111827);
  static const Color textMedium = Color(0xFF374151);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF64748B);

  // Màu thẻ card & khung nhập liệu
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color borderGrey = Color(0xFFD1D5DB);
  static const Color borderFocused = Color(0xFF82A48C);
  static const Color fillGrey = Color(0xFFF9FAFB);

  // Màu đo độ mạnh mật khẩu chuẩn theo ui đăng kí
  static const Color matKhauYeu = Color(0xFFEF4444); // Đỏ
  static const Color matKhauTrungBinh = Color(0xFFF59E0B); // Cam
  static const Color matKhauKha = Color(0xFF10B981); // Xanh lá nhạt
  static const Color matKhauManh = Color(0xFF059669); // Xanh lá đậm
  static const Color matKhauTrong = Color(0xFFE5E7EB); // Xám nhạt

  // === MÀU PHỤC VỤ LỊCH TRÌNH & CÔNG VIỆC (FEATURE 2) ===
  // 1. Thẻ xanh lam (Công việc chủ động / Học Web)
  static const Color blueCardBg = Color(0xFFD1E4FA);
  static const Color blueCardBorder = Color(0xFFB9D7FB);
  static const Color blueCardText = Color(0xFF1E3A8A);

  // 2. Thẻ cam (Thiết yếu / Nghỉ trưa & Ăn cơm)
  static const Color orangeCardBg = Color(0xFFFFE2C6);
  static const Color orangeCardBorder = Color(0xFFFED7AA);
  static const Color orangeCardText = Color(0xFF9A3412);

  // 3. Thẻ tím lavender (Học TOEIC)
  static const Color purpleCardBg = Color(0xFFE8DEFC);
  static const Color purpleCardBorder = Color(0xFFDDD0FB);
  static const Color purpleCardText = Color(0xFF581C87);

  // Chỉ báo thời gian thực (Vạch đỏ & Badge)
  static const Color redIndicator = Color(0xFFEF4444);
  static const Color redIndicatorBg = Color(0xFFEF4444);

  // Màu thanh tiến độ & Chú thích
  static const Color progressCircle = Color(0xFF5C6BC0);
  static const Color progressTrack = Color(0xFFEEF2F6);
  static const Color activeBlueLegend = Color(0xFF4A72F5);
  static const Color passiveOrangeLegend = Color(0xFFFB923C);
  static const Color completedGreenLegend = Color(0xFF6C987A);

  // Đường kẻ lưới lịch trình
  static const Color gridLine = Color(0xFFF1F5F9);
  static const Color gridBorder = Color(0xFFE2E8F0);
  static const Color timeText = Color(0xFF475569);
}
