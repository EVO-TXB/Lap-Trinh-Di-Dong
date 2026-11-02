import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../thong_bao/widgets/hop_thoai_thong_bao.dart';
import '../../thong_bao/widgets/popup_nhac_nho_dialog.dart';
import '../../thong_bao/widgets/messenger_notification_banner.dart';
import '../../thong_bao/widgets/chat_head_bubble_widget.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../../cai_dat/screens/cai_dat_screen.dart';
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
import 'checklist_screen.dart';
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
  final List<CongViecModel> _danhSachBongBong = [];

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện phát thông báo từ Scanner Service chạy ngầm
    _streamThongBaoSub = DichVuThongBao.instance.streamThongBao.listen((congViec) {
      if (!mounted) return;
      _xuLyPhatThongBao(congViec);
    });
  }

  @override
  void dispose() {
    _streamThongBaoSub?.cancel();
    super.dispose();
  }

  /// Xử lý phát thông báo phong cách Messenger (Banner trượt & Bong bóng nổi)
  void _xuLyPhatThongBao(CongViecModel congViec) {
    SettingsController? settings;
    try {
      settings = context.read<SettingsController>();
    } catch (_) {
      settings = null;
    }

    final kieu = settings?.kieuThongBao ?? 'Cả hai (Banner + Bong bóng)';
    final controller = context.read<ScheduleController>();

    if (kieu == 'Hộp thoại Popup') {
      _hienThiPopupNhacNho(congViec);
      return;
    }

    // 1. Kiểu 1: Banner trượt từ đỉnh màn hình xuống (Heads-up Notification)
    if (kieu.contains('Banner') || kieu.contains('Cả hai')) {
      MessengerNotificationBanner.show(
        context,
        congViec: congViec,
        onXemChiTiet: () {
          _moDialogChiTiet(context, congViec, controller);
        },
        onHoanBao: () {
          DichVuThongBao.instance.hoanBaoSnooze(congViec.id, soPhut: 5);
          if (mounted) {
            setState(() => _danhSachBongBong.removeWhere((e) => e.id == congViec.id));
            SettingsController? settings;
            try {
              settings = context.read<SettingsController>();
            } catch (_) {
              settings = null;
            }
            final String msg = settings?.tr('snoozed_msg', params: {'name': congViec.tenCongViec}) ??
                'Đã hoãn nhắc nhở "${congViec.tenCongViec}" thêm 5 phút.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.sageGreen,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    }

    // 2. Kiểu 2: Bong bóng nổi kéo thả Messenger (Chat Head)
    if (kieu.contains('Bong bóng') || kieu.contains('Cả hai')) {
      if (mounted) {
        setState(() {
          if (!_danhSachBongBong.any((e) => e.id == congViec.id)) {
            _danhSachBongBong.insert(0, congViec);
          }
        });
      }
    }
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
        SettingsController? settings;
        try {
          settings = context.read<SettingsController>();
        } catch (_) {
          settings = null;
        }
        final String msg = settings?.tr('snoozed_msg', params: {'name': congViec.tenCongViec}) ??
            'Đã hoãn nhắc nhở "${congViec.tenCongViec}" thêm 5 phút.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
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

  void _moDialogChiTiet(BuildContext context, CongViecModel congViec, ScheduleController controller) {
    EventDetailDialog.show(
      context,
      congViec: congViec,
      danhSachHienCo: controller.danhSachCongViec,
      onSave: (updated) => controller.luuCongViec(updated),
      onDelete: (id) => controller.xoaCongViec(id),
      onSaveBatch: (batch) => controller.luuChuoiCongViec(batch),
      onDeleteSeries: (maChuoi) => controller.xoaChuoiCongViec(maChuoi),
      onUpdateSeries: (maChuoi, mau, batch) => controller.capNhatChuoiCongViec(
        maChuoiLap: maChuoi,
        mau: mau,
        danhSachMoiNeuDoiLich: batch,
      ),
    );
  }

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
      nhacNhoTruocPhut: 15,
      ngayTao: DateTime.now(),
    );

    EventDetailDialog.show(
      context,
      congViec: newEvent,
      danhSachHienCo: controller.danhSachCongViec,
      onSave: (created) => controller.luuCongViec(created),
      onDelete: (_) {},
      onSaveBatch: (batch) => controller.luuChuoiCongViec(batch),
      onDeleteSeries: (maChuoi) => controller.xoaChuoiCongViec(maChuoi),
      onUpdateSeries: (maChuoi, mau, batch) => controller.capNhatChuoiCongViec(
        maChuoiLap: maChuoi,
        mau: mau,
        danhSachMoiNeuDoiLich: batch,
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

    return Consumer<ScheduleController>(
      builder: (context, controller, child) {
        // Đồng bộ ngày bắt đầu tuần từ Cài đặt
        if (settings != null) {
          final bool laChuNhat = settings.ngayBatDauTuan == 'Chủ Nhật';
          if (controller.batDauChuNhat != laChuNhat) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.capNhatNgayBatDauTuan(laChuNhat);
            });
          }
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFBF4ED),
          body: Stack(
            children: [
              // 1. Toàn bộ họa tiết nền hữu cơ (Organic Waves) uốn lượn xuyên suốt từ trên xuống dưới
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundWavePainter(isDark: isDark),
                ),
              ),

              // 2. Nội dung chính giao diện xếp chồng lên trên nền trong suốt
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // A. App Header: Logo Timass, "+ Thêm việc", Chuông thông báo, Avatar
                    AppHeaderWidget(
                      isDark: isDark,
                      textThemViec: settings?.tr('add_work'),
                      onThemCongViec: () => _moDialogThemCongViec(context, controller),
                      onThongBao: () {
                        HopThoaiThongBao.show(
                          context,
                          onXemChiTiet: (cv) => _moDialogChiTiet(context, cv, controller),
                        );
                      },
                      onAvatar: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CaiDatScreen()),
                        );
                      },
                      coThongBaoMoi: DichVuThongBao.instance.lichSuThongBao.isNotEmpty,
                    ),

                    // B. Thanh điều hướng thời gian: 1 dòng duy nhất "13/10/2026 (Tuần 42)", < >, "Hôm nay"
                    TimeNavigationWidget(
                      tieuDe: controller.layTieuDeTuan(
                        nhanTuan: settings?.tr('week_label') ?? 'Tuần',
                      ),
                      isDark: isDark,
                      nhanHomNay: settings?.tr('today'),
                      onTuanTruoc: controller.chuyenTuanTruoc,
                      onTuanSau: controller.chuyenTuanSau,
                      onHomNay: controller.chuyenDenHomNay,
                    ),

                    // C. Bộ chuyển đổi View: Segmented control [ Lịch tuần | Lịch tháng ]
                    ViewSwitcherWidget(
                      selectedIndex: controller.cheDoXem,
                      isDark: isDark,
                      nhanLichTuan: settings?.tr('weekly_schedule'),
                      nhanLichThang: settings?.tr('monthly_schedule'),
                      onIndexChanged: (index) {
                        controller.doiCheDoXem(index);
                      },
                    ),

                    // D. Khu vực hiển thị chuyển đổi mượt mà giữa Lịch tuần & Lịch tháng
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
                            ? _buildWeeklyView(context, controller, isDark: isDark, settings: settings)
                            : const MonthCalendarView(
                                key: ValueKey('MonthCalendarView'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bong bóng nổi kéo thả phong cách Messenger (Chat Head)
              if (_danhSachBongBong.isNotEmpty)
                ChatHeadBubbleWidget(
                  danhSachCongViec: _danhSachBongBong,
                  onXemChiTiet: (cv) => _moDialogChiTiet(context, cv, controller),
                  onHoanBao: (cv) {
                    DichVuThongBao.instance.hoanBaoSnooze(cv.id, soPhut: 5);
                    if (mounted) {
                      setState(() => _danhSachBongBong.removeWhere((e) => e.id == cv.id));
                      SettingsController? settings;
                      try {
                        settings = context.read<SettingsController>();
                      } catch (_) {
                        settings = null;
                      }
                      final String msg = settings?.tr('snoozed_msg', params: {'name': cv.tenCongViec}) ??
                          'Đã hoãn nhắc nhở "${cv.tenCongViec}" thêm 5 phút.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: AppColors.sageGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  onDongBongBong: () {
                    if (mounted) {
                      setState(() => _danhSachBongBong.clear());
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyView(
    BuildContext context,
    ScheduleController controller, {
    required bool isDark,
    SettingsController? settings,
  }) {
    return Column(
      key: const ValueKey('WeeklyScheduleView'),
      children: [
        // Card hiển thị tiến độ công việc trong ngày (Tapping opens ChecklistScreen)
        ProgressCardWidget(
          isDark: isDark,
          tongSoViec: controller.tongSoViecHomNay,
          soViecDaXong: controller.soViecDaXongHomNay,
          tiLe: controller.tiLeHoanThanh,
          phanTram: controller.phanTramHoanThanh,
          textHomNayViec: settings?.tr('today_task_count', params: {
            'done': controller.soViecDaXongHomNay.toString(),
            'total': controller.tongSoViecHomNay.toString(),
          }),
          textDaXong: settings?.tr('completed_percent', params: {
            'percent': controller.phanTramHoanThanh.toString(),
          }),
          labelChuDong: settings?.tr('active_task'),
          labelBiDong: settings?.tr('passive_task'),
          labelHoanThanh: settings?.tr('completed_task'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChecklistScreen(
                  initialDate: controller.ngayHienTai,
                ),
              ),
            );
          },
        ),

        // Lưới ma trận thời gian 7 ngày trong tuần
        Expanded(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.sageGreen,
                  ),
                )
              : WeeklyGridWidget(
                  controller: controller,
                  isDark: isDark,
                  ngonNgu: settings?.ngonNgu ?? 'Tiếng Việt',
                ),
        ),
      ],
    );
  }
}
