import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../cong_viec/models/cong_viec_model.dart';
import 'dong_ho_bao_thuc_3d_widget.dart';

/// Dialog Popup Nhắc nhở sắp đến giờ chuẩn xác theo mẫu `ui sample/ui thông báo.png`
class PopupNhacNhoDialog extends StatelessWidget {
  final CongViecModel congViec;
  final VoidCallback? onXemChiTiet;
  final VoidCallback? onHoanBaoSnooze;
  final VoidCallback? onDong;
  final bool animate;

  const PopupNhacNhoDialog({
    super.key,
    required this.congViec,
    this.onXemChiTiet,
    this.onHoanBaoSnooze,
    this.onDong,
    this.animate = true,
  });

  /// Hàm tiện ích static mở Dialog Popup từ bất kỳ đâu
  static Future<void> show(
    BuildContext context, {
    required CongViecModel congViec,
    VoidCallback? onXemChiTiet,
    VoidCallback? onHoanBaoSnooze,
    VoidCallback? onDong,
    bool animate = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => PopupNhacNhoDialog(
        congViec: congViec,
        animate: animate,
        onXemChiTiet: () {
          Navigator.of(dialogContext).pop();
          onXemChiTiet?.call();
        },
        onHoanBaoSnooze: () {
          Navigator.of(dialogContext).pop();
          onHoanBaoSnooze?.call();
        },
        onDong: () {
          Navigator.of(dialogContext).pop();
          onDong?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng giờ hiển thị (Ví dụ: 07:30)
    final String gioBatDau = DateFormat('HH:mm').format(congViec.thoiGianBatDau);
    final String diaDiem = (congViec.diaDiem != null && congViec.diaDiem!.isNotEmpty)
        ? ' tại ${congViec.diaDiem}'
        : '';
    final String dongPhu = 'Bắt đầu sau ${congViec.nhacNhoTruocPhut} phút nữa ($gioBatDau$diaDiem)';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =======================================================
              // 1. Header Popup: Icon Chuông đỏ + Text + Nút Đóng 'X'
              // =======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 16.0, 12.0, 0.0),
                child: Row(
                  children: [
                    // Icon chuông đỏ
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFFEF4444),
                        size: 17.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Tiêu đề header
                    const Expanded(
                      child: Text(
                        'Timass • Nhắc nhở sắp đến giờ',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    // Nút đóng X
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0, color: Color(0xFF94A3B8)),
                      splashRadius: 18,
                      onPressed: onDong ?? () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1.0, color: Color(0xFFF1F5F9)),

              // =======================================================
              // 2. Minh họa Đồng hồ báo thức pastel tông cam/vàng cam
              // =======================================================
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                child: Center(
                  child: DongHoBaoThuc3DWidget(
                    size: 115.0,
                    animate: animate,
                  ),
                ),
              ),

              // =======================================================
              // 3. Nội dung sự kiện: Tên in đậm nổi bật + Dòng phụ
              // =======================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Column(
                  children: [
                    Text(
                      congViec.tenCongViec.isNotEmpty
                          ? congViec.tenCongViec
                          : 'Lập trình Web nâng cao',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      dongPhu,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // =======================================================
              // 4. Các nút hành động: Nút phụ "Đóng", "Hoãn 5p", Nút chính "Xem chi tiết"
              // =======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Nút phụ "Đóng"
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 46.0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                foregroundColor: const Color(0xFF475569),
                              ),
                              onPressed: onDong ?? () => Navigator.of(context).pop(),
                              child: const Text(
                                'Đóng',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Nút chính "Xem chi tiết" màu Sage green bo tròn
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 46.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sageGreen,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: onXemChiTiet,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Xem chi tiết',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(Icons.arrow_forward_rounded, size: 16.0, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Tùy chọn tiện ích Snooze: Nhắc lại sau 5 phút
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.snooze_rounded, size: 16.0),
                      label: const Text(
                        'Nhắc lại sau 5 phút (Snooze)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: onHoanBaoSnooze ??
                          () {
                            DichVuThongBao.instance.hoanBaoSnooze(congViec.id, soPhut: 5);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã hoãn nhắc việc "${congViec.tenCongViec}" thêm 5 phút'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
