import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../thong_bao/widgets/hop_thoai_thong_bao.dart';
import '../../thong_bao/widgets/popup_nhac_nho_dialog.dart';
import '../../xac_thuc/providers/auth_controller.dart';
import '../controllers/schedule_controller.dart';
import '../models/cong_viec_model.dart';
import '../repositories/mock_event_repository.dart';
import '../widgets/app_header_widget.dart';
import '../widgets/background_wave_painter.dart';
import '../widgets/event_detail_dialog.dart';
import '../widgets/progress_card_widget.dart';
import '../widgets/time_navigation_widget.dart';
import '../widgets/view_switcher_widget.dart';
import '../widgets/weekly_grid_widget.dart';
import 'month_calendar_view.dart';

/// Màn hình chính Lịch Trình Tuần (Weekly Schedule Screen)
/// Tích hợp đầy đủ Module Thông báo nhắc nhở & Tác vụ nền (Prompt 2)
class LichTuanScreen extends StatelessWidget {
  const LichTuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScheduleController>(
      create: (_) => ScheduleController(eventRepository: MockEventRepository()),
      child: const _LichTuanView(),
    );
  }
}

class _LichTuanView extends StatefulWidget {
  const _LichTuanView();

  @override
  State<_LichTuanView> createState() => _LichTuanViewState();
}

class _LichTuanViewState extends State<_LichTuanView> {
  StreamSubscription<CongViecModel>? _streamThongBaoSub;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện phát thông báo từ Scanner Service chạy ngầm
    _streamThongBaoSub = DichVuThongBao.instance.streamThongBao.listen((
      congViec,
    ) {
      if (!mounted) return;
      _hienThiPopupNhacNho(congViec);
    });
  }

  @override
  void dispose() {
    _streamThongBaoSub?.cancel();
    super.dispose();
  }

  /// Hiển thị Dialog Popup Nhắc nhở theo ảnh mẫu `ui sample/ui thông báo.png`
  void _hienThiPopupNhacNho(CongViecModel congViec) {
    final controller = context.read<ScheduleController>();

    PopupNhacNhoDialog.show(
      context,
      congViec: congViec,
      onXemChiTiet: () {
        _moDialogChiTiet(context, congViec, controller);
      },
      onHoanBaoSnooze: () {
        DichVuThongBao.instance.hoanBaoSnooze(congViec.id, soPhut: 5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã hoãn nhắc nhở "${congViec.tenCongViec}" thêm 5 phút.',
            ),
            backgroundColor: AppColors.sageGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onDong: () {
        DichVuThongBao.instance.boQuaThongBao(congViec.id);
      },
    );
  }

  void _moDialogChiTiet(
    BuildContext context,
    CongViecModel congViec,
    ScheduleController controller,
  ) {
    EventDetailDialog.show(
      context,
      congViec: congViec,
      onSave: (updated) => controller.luuCongViec(updated),
      onDelete: (id) => controller.xoaCongViec(id),
    );
  }

  void _moDialogThemCongViec(
    BuildContext context,
    ScheduleController controller,
  ) {
    final DateTime now = controller.ngayHienTai;
    final CongViecModel newEvent = CongViecModel(
      id: 0,
      maNguoiDung: 1,
      tenCongViec: '',
      thoiGianBatDau: DateTime(now.year, now.month, now.day, 9, 0),
      thoiGianKetThuc: DateTime(now.year, now.month, now.day, 10, 30),
      diaDiem: '',
      mauSac: AppColors.softSkyBlue,
      daHoanThanh: false,
    );

    EventDetailDialog.show(
      context,
      congViec: newEvent,
      onSave: (created) => controller.luuCongViec(created),
    );
  }

  void _hienThiDialogTaiKhoan(BuildContext context) {
    final authController = context.read<AuthController>();
    final tenNguoiDung = authController.nguoiDung?.hoTen ?? 'Người dùng';
    final email = authController.nguoiDung?.email ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.sageGreen.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: AppColors.primaryCharcoal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenNguoiDung,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryCharcoal,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng', style: TextStyle(color: AppColors.secondarySlate)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              authController.dangXuat();
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.white),
            label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          body: Stack(
            children: [
              // 1. Lớp sóng trang trí hữu cơ (Organic Fluid Waves) theo style Timass
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundWavePainter(),
                ),
              ),

              // 2. Nội dung chính giao diện xếp chồng lên trên nền trong suốt
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // A. App Header: Logo Timass, "+ Thêm việc", Chuông thông báo, Avatar
                    AppHeaderWidget(
                      onThemCongViec: () =>
                          _moDialogThemCongViec(context, controller),
                      onThongBao: () {
                        HopThoaiThongBao.show(
                          context,
                          onXemChiTiet: (cv) =>
                              _moDialogChiTiet(context, cv, controller),
                        );
                      },
                      onAvatar: () => _hienThiDialogTaiKhoan(context),
                      coThongBaoMoi:
                          DichVuThongBao.instance.lichSuThongBao.isNotEmpty,
                    ),

                    // B. Thanh điều hướng thời gian: "Tháng 10, 2026 (Tuần 42)", < >, "Hôm nay"
                    TimeNavigationWidget(
                      tieuDe: controller.tieuDeTuan,
                      onTuanTruoc: controller.chuyenTuanTruoc,
                      onTuanSau: controller.chuyenTuanSau,
                      onHomNay: controller.chuyenDenHomNay,
                    ),

                    // C. Bộ chuyển đổi View: Segmented control [ Lịch tuần | Lịch tháng ]
                    ViewSwitcherWidget(
                      selectedIndex: controller.cheDoXem,
                      onIndexChanged: (index) {
                        controller.doiCheDoXem(index);
                      },
                    ),

                    // C. Khu vực hiển thị chuyển đổi mượt mà (Fade & Slide transition)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.02),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: controller.cheDoXem == 0
                            ? _buildWeeklyView(context, controller)
                            : const MonthCalendarView(
                                key: ValueKey('MonthCalendarView'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyView(BuildContext context, ScheduleController controller) {
    return Column(
      key: const ValueKey('WeeklyScheduleView'),
      children: [
        // Card hiển thị tiến độ công việc trong tuần (Circular indicator & stats)
        ProgressCardWidget(
          tiLeHoanThanh: controller.tiLeHoanThanh,
          soCongViecHoanThanh: controller.soCongViecHoanThanh,
          tongSoCongViec: controller.tongSoCongViec,
        ),

        // Lưới ma trận thời gian 7 ngày trong tuần
        Expanded(
          child: WeeklyGridWidget(
            danhSachNgayTrongTuan: controller.danhSachNgayTrongTuan,
            danhSachCongViec: controller.danhSachCongViec,
            ngayHienTai: controller.ngayHienTai,
            onEventTap: (congViec) =>
                _moDialogChiTiet(context, congViec, controller),
            onToggleStatus: (congViec) =>
                controller.thayDoiTrangThai(congViec.id),
          ),
        ),
      ],
    );
  }
}
