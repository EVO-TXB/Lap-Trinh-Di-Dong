import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
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

/// Màn hình chính Lịch Trình (Schedule Screen) hỗ trợ chuyển đổi Lịch Tuần & Lịch Tháng
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

class _LichTuanView extends StatelessWidget {
  const _LichTuanView();

  void _moDialogThemCongViec(BuildContext context, ScheduleController controller) {
    final DateTime now = controller.ngayHienTai;
    final CongViecModel newEvent = CongViecModel(
      id: 0,
      maNguoiDung: 1,
      tenCongViec: '',
      thoiGianBatDau: DateTime(now.year, now.month, now.day, 9, 0),
      thoiGianKetThuc: DateTime(now.year, now.month, now.day, 10, 30),
      diaDiem: '',
      laThietYeu: false,
      daHoanThanh: false,
      ngayTao: DateTime.now(),
    );

    EventDetailDialog.show(
      context,
      congViec: newEvent,
      onSave: (created) => controller.luuCongViec(created),
      onDelete: (_) {},
    );
  }

  Widget _buildWeeklyView(BuildContext context, ScheduleController controller) {
    return Column(
      key: const ValueKey('WeeklyScheduleView'),
      children: [
        // B1. Thanh điều hướng thời gian tuần: "Tháng 10, 2026 (Tuần 42)", < >, "Hôm nay"
        TimeNavigationWidget(
          tieuDe: controller.tieuDeTuan,
          onTuanTruoc: controller.chuyenTuanTruoc,
          onTuanSau: controller.chuyenTuanSau,
          onHomNay: controller.chuyenDenHomNay,
        ),

        // B2. Widget tiến độ ngày (Progress Card: 5/8 việc đã xong (62%))
        ProgressCardWidget(
          tongSoViec: controller.tongSoViecHomNay,
          soViecDaXong: controller.soViecDaXongHomNay,
          tiLe: controller.tiLeHoanThanh,
          phanTram: controller.phanTramHoanThanh,
        ),

        // B3. Lưới thời gian (Weekly Time Grid - Nền bán trong suốt để họa tiết xuyên qua)
        Expanded(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.sageGreen,
                  ),
                )
              : WeeklyGridWidget(
                  controller: controller,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleController>(
      builder: (context, controller, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Toàn bộ họa tiết nền hữu cơ (Organic Waves) uốn lượn xuyên suốt từ trên xuống dưới
              // và xuyên qua bên dưới Lưới lịch trình (Weekly Grid / Monthly Grid)
              const Positioned.fill(
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
                      onThemCongViec: () => _moDialogThemCongViec(context, controller),
                      onThongBao: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không có thông báo mới!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      onAvatar: () {},
                    ),

                    // B. Bộ chuyển đổi View: Segmented control [ Lịch tuần | Lịch tháng ]
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
                            : const MonthCalendarView(key: ValueKey('MonthCalendarView')),
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
}
