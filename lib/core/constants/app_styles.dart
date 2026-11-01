import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Tieu de Auth lon
  static const TextStyle authTitle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  // Mo ta duoi tieu de
  static const TextStyle authSubtitle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.35,
  );

  // Nhan o nhap lieu
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Van ban trong o nhap lieu
  static const TextStyle inputText = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  // Goi y nhap lieu (Hint)
  static const TextStyle inputHint = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  // Chu nut bam Sage Green
  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Chu lien ket duoi cung
  static const TextStyle footerText = TextStyle(
    fontSize: 13.5,
    color: AppColors.textDark,
  );

  static const TextStyle footerLink = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Bo goc the Card Form (Bo tron 4 goc chu yeu giong anh mau)
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(24.0));

  // Bo goc khung nhap lieu
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(10.0));

  // Bo goc nut bam
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
}
