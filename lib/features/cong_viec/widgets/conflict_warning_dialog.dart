import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';

/// Dialog cảnh báo khi phát hiện trùng lịch trình (Conflict Warning Dialog)
class ConflictWarningDialog extends StatelessWidget {
  final CongViecModel? congViecBiTrung;
  final String? thongBaoTuyChon;
  final VoidCallback onSuaLai;
  final VoidCallback? onVanTiepTucLuu;

  const ConflictWarningDialog({
    super.key,
    this.congViecBiTrung,
    this.thongBaoTuyChon,
    required this.onSuaLai,
    this.onVanTiepTucLuu,
  });

  static Future<bool?> show(
    BuildContext context, {
    CongViecModel? congViecBiTrung,
    String? thongBaoTuyChon,
    bool choPhepVanLuu = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConflictWarningDialog(
        congViecBiTrung: congViecBiTrung,
        thongBaoTuyChon: thongBaoTuyChon,
        onSuaLai: () => Navigator.of(ctx).pop(false),
        onVanTiepTucLuu: choPhepVanLuu ? () => Navigator.of(ctx).pop(true) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tenViec = congViecBiTrung?.tenCongViec ?? 'công việc khác';
    String thoiGian = '';
    if (congViecBiTrung != null) {
      final String start =
          '${congViecBiTrung!.thoiGianBatDau.hour.toString().padLeft(2, '0')}:${congViecBiTrung!.thoiGianBatDau.minute.toString().padLeft(2, '0')}';
      final String end =
          '${congViecBiTrung!.thoiGianKetThuc.hour.toString().padLeft(2, '0')}:${congViecBiTrung!.thoiGianKetThuc.minute.toString().padLeft(2, '0')}';
      thoiGian = '$start - $end';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon cảnh báo + Nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: onSuaLai,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                  tooltip: 'Đóng',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            const Text(
              'Cảnh báo trùng lịch!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 10),

            // Nội dung chi tiết
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textMedium,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(text: 'Khung giờ này đã bị trùng với sự kiện '),
                  TextSpan(
                    text: '"$tenViec"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  if (thoiGian.isNotEmpty) ...[
                    const TextSpan(text: ' ('),
                    TextSpan(
                      text: thoiGian,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const TextSpan(text: ')'),
                  ],
                  const TextSpan(
                    text: '!\nVui lòng sửa lại khung giờ để tránh chồng chéo công việc.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSuaLai,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sửa lại khung giờ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ),
                if (onVanTiepTucLuu != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onVanTiepTucLuu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Vẫn tiếp tục lưu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

