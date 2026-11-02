import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/month_calendar_controller.dart';
import '../models/cong_viec_model.dart';
import '../repositories/mock_event_repository.dart';
import '../widgets/daily_events_panel.dart';
import '../widgets/event_detail_dialog.dart';
import '../widgets/monthly_calendar_grid.dart';

/// Giao diện Lịch Tháng (Monthly Calendar View):
/// - Lưới ma trận ngày trong tháng (7 cột x 5-6 hàng) kèm chấm chỉ báo sự kiện
/// - Panel chi tiết sự kiện của ngày được chọn dạng DraggableScrollableSheet có thể kéo hẳn lên trên
class MonthCalendarView extends StatelessWidget {
  const MonthCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MonthCalendarController>(
      create: (_) => MonthCalendarController(eventRepository: MockEventRepository()),
      child: const _MonthCalendarContent(),
    );
  }
}

class _MonthCalendarContent extends StatefulWidget {
  const _MonthCalendarContent();

  @override
  State<_MonthCalendarContent> createState() => _MonthCalendarContentState();
}

class _MonthCalendarContentState extends State<_MonthCalendarContent> {
  late final DraggableScrollableController _sheetController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_onSheetScrolled);
  }

  void _onSheetScrolled() {
    if (!_sheetController.isAttached) return;
    final bool expanded = _sheetController.size > 0.72;
    if (expanded != _isExpanded) {
      setState(() {
        _isExpanded = expanded;
      });
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetScrolled);
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheetExpand(double initialSize) {
    if (_sheetController.isAttached) {
      if (_sheetController.size < 0.72) {
        _sheetController.animateTo(
          0.96,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      } else {
        _sheetController.animateTo(
          initialSize,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _moDialogThemCongViec(BuildContext context, MonthCalendarController controller) {
    final DateTime targetDate = controller.ngayDangChon;
    final CongViecModel newEvent = CongViecModel(
      id: 0,
      maNguoiDung: 1,
      tenCongViec: '',
      thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 9, 0),
      thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 30),
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

  void _moDialogSuaCongViec(BuildContext context, MonthCalendarController controller, CongViecModel congViec) {
    EventDetailDialog.show(
      context,
      congViec: congViec,
      onSave: (updated) => controller.luuCongViec(updated),
      onDelete: (id) => controller.xoaCongViec(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthCalendarController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.sageGreen,
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Tính toán kích thước ban đầu (initialChildSize) để Panel nằm ngay dưới Lưới tháng
            final double availableHeight = constraints.maxHeight;
            const double gridHeightEstimate = 300.0;
            final double rawInitial = (availableHeight - gridHeightEstimate) / availableHeight;
            final double initialSize = rawInitial.clamp(0.40, 0.60);
            const double minSize = 0.25;
            const double maxSize = 0.96;

            return Stack(
              children: [
                // 1. Lưới ma trận Lịch Tháng (nằm ở lớp nền trên)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MonthlyCalendarGrid(
                    controller: controller,
                  ),
                ),

                // 2. Panel Chi tiết Sự kiện của Ngày được chọn có thể kéo hẳn lên trên (DraggableScrollableSheet)
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: initialSize,
                  minChildSize: minSize,
                  maxChildSize: maxSize,
                  snap: true,
                  snapSizes: [minSize, initialSize, maxSize],
                  builder: (context, scrollController) {
                    return DailyEventsPanel(
                      scrollController: scrollController,
                      onToggleExpand: () => _toggleSheetExpand(initialSize),
                      isExpanded: _isExpanded,
                      ngayDangChon: controller.ngayDangChon,
                      danhSachCongViec: controller.danhSachCongViecNgayDuocChon,
                      onToggleHoanThanh: (item) => controller.toggleTrangThaiHoanThanh(item),
                      onTapCongViec: (item) => _moDialogSuaCongViec(context, controller, item),
                      onThemCongViec: () => _moDialogThemCongViec(context, controller),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
