import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';

/// Card sự kiện đặt chính xác theo khung giờ, bo góc, phân loại màu sắc và thích ứng linh hoạt theo chiều cao
class EventCardWidget extends StatelessWidget {
  final CongViecModel congViec;
  final VoidCallback onTap;

  const EventCardWidget({
    super.key,
    required this.congViec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = congViec.trangThaiHoanThanhHienThi;

    // Phân loại màu sắc theo loại công việc
    final Color bgColor = _getBackgroundColor();
    final Color borderColor = _getBorderColor();
    final Color textColor = _getTextColor();

    final String thoiGianText =
        '${DateFormat('HH:mm').format(congViec.thoiGianBatDau)} - ${DateFormat('HH:mm').format(congViec.thoiGianKetThuc)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxHeight = constraints.maxHeight;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Khung giờ
                        Text(
                          thoiGianText,
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                            color: textColor.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // 2. Tên công việc
                        if (maxHeight >= 32) ...[
                          const SizedBox(height: 1),
                          Text(
                            congViec.tenCongViec,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.15,
                            ),
                            maxLines: maxHeight >= 55 ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // 3. Địa điểm (hiển thị khi đủ chiều cao >= 64px)
                        if (maxHeight >= 64 &&
                            congViec.diaDiem != null &&
                            congViec.diaDiem!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            congViec.diaDiem!,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Huy hiệu tích tròn xanh góc phải báo đã hoàn thành (như ảnh mẫu)
                  if (isCompleted)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C987A), // Xanh lá cây Sage
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (congViec.laThietYeu) {
      return AppColors.orangeCardBg; // Thẻ cam pastel (Nghỉ trưa & Ăn cơm)
    }
    if (congViec.tenCongViec.toLowerCase().contains('toeic') ||
        congViec.tenCongViec.toLowerCase().contains('tiếng anh')) {
      return AppColors.purpleCardBg; // Thẻ tím lavender (Học TOEIC)
    }
    return AppColors.blueCardBg; // Thẻ xanh pastel (Học Web)
  }

  Color _getBorderColor() {
    if (congViec.laThietYeu) {
      return AppColors.orangeCardBorder;
    }
    if (congViec.tenCongViec.toLowerCase().contains('toeic') ||
        congViec.tenCongViec.toLowerCase().contains('tiếng anh')) {
      return AppColors.purpleCardBorder;
    }
    return AppColors.blueCardBorder;
  }

  Color _getTextColor() {
    if (congViec.laThietYeu) {
      return AppColors.orangeCardText;
    }
    if (congViec.tenCongViec.toLowerCase().contains('toeic') ||
        congViec.tenCongViec.toLowerCase().contains('tiếng anh')) {
      return AppColors.purpleCardText;
    }
    return AppColors.blueCardText;
  }
}
