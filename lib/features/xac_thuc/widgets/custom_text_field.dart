import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool laMatKhau;
  final bool hienMatKhau;
  final VoidCallback? onToggleHienMatKhau;
  final TextInputType kieuBanPhim;
  final String? thongBaoLoi;
  final ValueChanged<String>? onChanged;
  final bool tuDongFocus;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.laMatKhau = false,
    this.hienMatKhau = false,
    this.onToggleHienMatKhau,
    this.kieuBanPhim = TextInputType.text,
    this.thongBaoLoi,
    this.onChanged,
    this.tuDongFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label mau den dam, ro net
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 7.0),
        TextField(
          controller: controller,
          obscureText: laMatKhau && !hienMatKhau,
          keyboardType: kieuBanPhim,
          autofocus: tuDongFocus,
          onChanged: onChanged,
          // Text mau den
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade400,
            ),
            // Nen trang
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 13.0,
            ),
            // Vien den ro rang theo yeu cau
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: thongBaoLoi != null ? AppColors.matKhauYeu : Colors.black,
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: thongBaoLoi != null ? AppColors.matKhauYeu : Colors.black,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.matKhauYeu, width: 1.3),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.matKhauYeu, width: 1.8),
            ),
            // Nut bat/tat mat khau thiet ke moi thanh lich & hien dai
            suffixIcon: laMatKhau
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Center(
                      widthFactor: 1.0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: onToggleHienMatKhau,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: hienMatKhau
                                  ? AppColors.sageGreen.withOpacity(0.15)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: hienMatKhau
                                    ? AppColors.sageGreen.withOpacity(0.4)
                                    : Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              hienMatKhau
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 18.0,
                              color: hienMatKhau
                                  ? AppColors.sageGreenDark
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        if (thongBaoLoi != null) ...[
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              thongBaoLoi!,
              style: const TextStyle(
                color: AppColors.matKhauYeu,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
