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
class ChecklistItemWidget extends StatelessWidget {
  final CongViecModel congViec;
  final ValueChanged<int> onToggle;
  final VoidCallback? onTap;

  const ChecklistItemWidget({
    super.key,
    required this.congViec,
    required this.onToggle,
    this.onTap,
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
                          ? const Color(0xFF6B7280) // Mờ đi khi đã hoàn thành
                          : AppColors.darkNavy,
                      decoration: daHoanThanh
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF6B7280),
                      decorationThickness: 1.8,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Dòng phụ: Giờ thực hiện & Địa điểm
                  Text(
                    thoiGianText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
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
          color: isChecked ? AppColors.sageGreen : const Color(0xFFCBD5E1),
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
    // 1. Kiểm tra ghi chú tường minh được gán từ mock hoặc người dùng
    if (cv.ghiChu != null && cv.ghiChu!.trim() == 'Chủ động') {
      return 'Chủ động';
    }
    if (cv.ghiChu != null && cv.ghiChu!.trim() == 'Bị động') {
      return 'Bị động';
    }

    // 2. Kiểm tra cờ laThietYeu hoặc loaiSuKien
    if (cv.laThietYeu || cv.loaiSuKien == 'BI_DONG') {
      return 'Bị động';
    }

    return null;
  }

  /// Badge phân loại theo phong cách pill pastel
  Widget _buildBadgeTag(String tag) {
    final bool isChuDong = tag == 'Chủ động';

    final Color bgColor = isChuDong
        ? const Color(0xFFD8EAFF) // Xanh pastel
        : const Color(0xFFFFE2CC); // Cam đào pastel

    final Color textColor = isChuDong
        ? const Color(0xFF1E40AF) // Xanh dương đậm
        : const Color(0xFFC2410C); // Cam gạch đậm

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

