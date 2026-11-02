import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
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
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }
    final bool isDark = settings?.isDarkMode ?? false;
    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : AppColors.darkNavy;
    final Color textColor = isDark ? const Color(0xFFCBD5E1) : AppColors.textMedium;

    final String fallbackOther = settings?.ngonNgu == 'English' ? 'another event' : 'công việc khác';
    final String tenViec = congViecBiTrung?.tenCongViec ?? fallbackOther;
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
      backgroundColor: dialogBg,
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
                    color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: onSuaLai,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                  tooltip: settings?.tr('close_btn') ?? 'Đóng',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              settings?.tr('conflict_warning_title') ?? 'Cảnh báo trùng lịch!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),

            // Nội dung chi tiết
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.5,
                  color: textColor,
                  height: 1.45,
                ),
                children: [
                  TextSpan(text: settings?.tr('conflict_with_event') ?? 'Khung giờ này đã bị trùng với sự kiện '),
                  TextSpan(
                    text: '"$tenViec"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  if (thoiGian.isNotEmpty) ...[
                    const TextSpan(text: ' ('),
                    TextSpan(
                      text: thoiGian,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const TextSpan(text: ')'),
                  ],
                  TextSpan(
                    text: settings?.tr('conflict_adjust_msg') ?? '!\nVui lòng sửa lại khung giờ để tránh chồng chéo công việc.',
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
                      side: BorderSide(color: isDark ? const Color(0xFF475569) : AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      settings?.tr('adjust_time_btn') ?? 'Sửa lại khung giờ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
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
                      child: Text(
                        settings?.tr('save_anyway_btn') ?? 'Vẫn tiếp tục lưu',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

