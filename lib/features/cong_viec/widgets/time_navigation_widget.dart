import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Thanh điều hướng thời gian: bổ sung hiển thị ngày hôm nay bên cạnh Tháng Năm (Tuần 42), nút < >, nút "Hôm nay"
/// Hỗ trợ Dark Mode và Đa ngôn ngữ
class TimeNavigationWidget extends StatelessWidget {
  final String tieuDe;
  final String? chuoiNgay;
  final VoidCallback onTuanTruoc;
  final VoidCallback onTuanSau;
  final VoidCallback onHomNay;
  final bool isDark;
  final String? nhanHomNay;

  const TimeNavigationWidget({
    super.key,
    required this.tieuDe,
    this.chuoiNgay,
    required this.onTuanTruoc,
    required this.onTuanSau,
    required this.onHomNay,
    this.isDark = false,
    this.nhanHomNay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Tiêu đề ngày & tuần gọn gàng trên 1 dòng duy nhất: "13/10/2026 (Tuần 42)"
          Expanded(
            child: Text(
              tieuDe,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.darkNavy,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Nút chuyển tuần trước <
          _buildNavigationIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onTuanTruoc,
          ),

          const SizedBox(width: 4),

          // Nút chuyển tuần sau >
          _buildNavigationIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onTuanSau,
          ),

          const SizedBox(width: 8),

          // Nút "Hôm nay"
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onHomNay,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  nhanHomNay ?? 'Hôm nay',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFF1F5F9) : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
