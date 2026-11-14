import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../xac_thuc/providers/auth_controller.dart';
import '../controllers/month_calendar_controller.dart';
import '../repositories/mock_event_repository.dart';
import '../widgets/monthly_calendar_grid.dart';

/// Giao diện Lịch Tháng (Monthly Calendar View) thuần túy
/// Đã lược bỏ phần checklist kéo theo yêu cầu, chỉ hiển thị ma trận lịch tháng
class MonthCalendarView extends StatelessWidget {
  final DateTime? ngayKhoiTao;

  const MonthCalendarView({
    super.key,
    this.ngayKhoiTao,
  });

  @override
  Widget build(BuildContext context) {
    int currentUserId = 1;
    try {
      final authController = context.watch<AuthController>();
      currentUserId = authController.nguoiDungHienTai?.id ?? 1;
    } catch (_) {}

    return ChangeNotifierProvider<MonthCalendarController>(
      key: ValueKey('MonthCalendarController_user_$currentUserId'),
      create: (_) => MonthCalendarController(
        eventRepository: MockEventRepository(userId: currentUserId),
        ngayKhoiTao: ngayKhoiTao,
      ),
      child: const _MonthCalendarContent(),
    );
  }
}

class _MonthCalendarContent extends StatelessWidget {
  const _MonthCalendarContent();

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

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: MonthlyCalendarGrid(
            controller: controller,
          ),
        );
      },
    );
  }
}
