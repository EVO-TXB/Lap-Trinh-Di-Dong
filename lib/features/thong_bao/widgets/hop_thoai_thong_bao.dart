import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../../cong_viec/models/cong_viec_model.dart';
import '../controllers/thong_bao_controller.dart';

/// Hộp thoại Danh sách Thông báo & Trung tâm nhắc nhở khi nhấn vào Icon Chuông
class HopThoaiThongBao extends StatelessWidget {
  final Function(CongViecModel)? onXemChiTiet;

  const HopThoaiThongBao({
    super.key,
    this.onXemChiTiet,
  });

  static void show(BuildContext context, {Function(CongViecModel)? onXemChiTiet}) {
    context.read<ThongBaoController>().danhDauDaDoc();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => HopThoaiThongBao(onXemChiTiet: onXemChiTiet),
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
    final Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color itemBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color itemBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final thongBaoController = context.watch<ThongBaoController>();
    final List<CongViecModel> danhSach = thongBaoController.lichSuThongBao;
    final bool batThongBao = thongBaoController.caiDat.batThongBao;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tay kéo modal
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 6.0, 16.0, 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFEF4444),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings?.tr('notifications_center_title') ?? 'Thông báo & Nhắc nhở',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        settings?.tr('notifications_auto_scan') ?? 'Quét tự động trước 15 phút & việc thiết yếu',
                        style: const TextStyle(fontSize: 12.0, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                // Nút gạt bật/tắt thông báo
                Switch(
                  value: batThongBao,
                  activeThumbColor: AppColors.sageGreen,
                  onChanged: (val) {
                    thongBaoController.toggleBatThongBao(val);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1.0),

          // Danh sách các thông báo
          Flexible(
            child: danhSach.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          settings?.tr('no_notifications') ?? 'Chưa có thông báo nào',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: danhSach.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final item = danhSach[index];
                      final gioBatDau = DateFormat('HH:mm').format(item.thoiGianBatDau);
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: itemBg,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: itemBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEDD5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.alarm, color: Color(0xFFEA580C), size: 18),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.tenCongViec,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    settings?.ngonNgu == 'English'
                                        ? 'Starts at $gioBatDau${item.diaDiem != null && item.diaDiem!.isNotEmpty ? ' at ${item.diaDiem}' : ''}'
                                        : 'Bắt đầu lúc $gioBatDau${item.diaDiem != null && item.diaDiem!.isNotEmpty ? ' tại ${item.diaDiem}' : ''}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.sageGreen,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                thongBaoController.moPopupNhacNho(
                                  context,
                                  item,
                                  onXemChiTiet: () => onXemChiTiet?.call(item),
                                );
                              },
                              child: Text(settings?.tr('view_popup_btn') ?? 'Xem popup', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
