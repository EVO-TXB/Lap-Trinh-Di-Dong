import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';

/// Widget phần tử công việc dạng Checklist
/// Tái hiện chuẩn xác 100% theo mẫu thiết kế `ui sample/ui check list.png`:
/// - Checkbox tròn to viền xám, khi tích chuyển sang màu xanh Sage với dấu tích trắng
/// - Tên công việc: Chữ gạch ngang & mờ đi khi đã hoàn thành
/// - Dòng phụ: Khung giờ (HH:mm - HH:mm) và Địa điểm ( | Phòng học/Online)
/// - Badge phân loại bên phải: Tag "Chủ động" (nền xanh chữ xanh đậm) hoặc "Bị động" (nền cam chữ cam đậm)
/// - Hỗ trợ Dark Mode và Đa ngôn ngữ (Tiếng Việt / English)
class ChecklistItemWidget extends StatelessWidget {
  final CongViecModel congViec;
  final ValueChanged<int> onToggle;
  final VoidCallback? onTap;
  final bool isDark;
  final String ngonNgu;

  const ChecklistItemWidget({
    super.key,
    required this.congViec,
    required this.onToggle,
    this.onTap,
    this.isDark = false,
    this.ngonNgu = 'Tiếng Việt',
  });

  @override
  Widget build(BuildContext context) {
    final bool daHoanThanh = congViec.daHoanThanh;
    final String thoiGianText = _dinhDangThoiGianVaDiaDiem(congViec);
    final String? nhanPhanLoai = _layNhanPhanLoai(congViec);

    return InkWell(
      onTap: () => onToggle(congViec.id),
      onLongPress: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.sageGreen.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Checkbox tròn to (28x28px)
            _buildRoundCheckbox(daHoanThanh),

            const SizedBox(width: 14),

            // 2. Nội dung công việc (Tiêu đề + Giờ giấc & Địa điểm)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tên công việc
                  Text(
                    congViec.tenCongViec,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: daHoanThanh
                          ? (isDark ? const Color(0xFF64748B) : const Color(0xFF6B7280))
                          : (isDark ? const Color(0xFFF1F5F9) : AppColors.darkNavy),
                      decoration: daHoanThanh
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: isDark ? const Color(0xFF64748B) : const Color(0xFF6B7280),
                      decorationThickness: 1.8,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Dòng phụ: Giờ thực hiện & Địa điểm
                  Text(
                    thoiGianText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Badge phân loại bên phải (Chủ động / Bị động)
            if (nhanPhanLoai != null) ...[
              const SizedBox(width: 8),
              _buildBadgeTag(nhanPhanLoai),
            ],
          ],
        ),
      ),
    );
  }

  /// Checkbox tròn to viền xám, tích đổi thành nền Sage Green có icon V trắng
  Widget _buildRoundCheckbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? AppColors.sageGreen : Colors.transparent,
        border: Border.all(
          color: isChecked
              ? AppColors.sageGreen
              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          width: 2.0,
        ),
      ),
      child: isChecked
          ? const Center(
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
                weight: 800,
              ),
            )
          : null,
    );
  }

  /// Định dạng giờ thực hiện và địa điểm (ví dụ: "07:30 - 09:30 | A3-402")
  String _dinhDangThoiGianVaDiaDiem(CongViecModel cv) {
    final timeFormat = DateFormat('HH:mm');
    final String gioBatDau = timeFormat.format(cv.thoiGianBatDau);
    final String gioKetThuc = timeFormat.format(cv.thoiGianKetThuc);
    final String timeStr = '$gioBatDau - $gioKetThuc';

    if (cv.diaDiem != null && cv.diaDiem!.trim().isNotEmpty) {
      return '$timeStr | ${cv.diaDiem!.trim()}';
    }
    return timeStr;
  }

  /// Xác định nhãn phân loại (Chủ động / Bị động)
  String? _layNhanPhanLoai(CongViecModel cv) {
    final bool isEnglish = ngonNgu == 'English';
    final String activeLabel = isEnglish ? 'Active' : 'Chủ động';
    final String passiveLabel = isEnglish ? 'Passive' : 'Bị động';

    if (cv.ghiChu != null && (cv.ghiChu!.trim() == 'Chủ động' || cv.ghiChu!.trim() == 'Active')) {
      return activeLabel;
    }
    if (cv.ghiChu != null && (cv.ghiChu!.trim() == 'Bị động' || cv.ghiChu!.trim() == 'Passive')) {
      return passiveLabel;
    }

    if (cv.laThietYeu || cv.loaiSuKien == 'BI_DONG') {
      return passiveLabel;
    }

    return null;
  }

  /// Badge phân loại theo phong cách pill pastel
  Widget _buildBadgeTag(String tag) {
    final bool isChuDong = tag == 'Chủ động' || tag == 'Active';

    final Color bgColor = isDark
        ? (isChuDong ? const Color(0xFF1E3A8A) : const Color(0xFF7C2D12))
        : (isChuDong ? const Color(0xFFD8EAFF) : const Color(0xFFFFE2CC));

    final Color textColor = isDark
        ? (isChuDong ? const Color(0xFF93C5FD) : const Color(0xFFFDBA74))
        : (isChuDong ? const Color(0xFF1E40AF) : const Color(0xFFC2410C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
