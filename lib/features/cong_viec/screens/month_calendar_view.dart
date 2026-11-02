import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/month_calendar_controller.dart';
import '../repositories/mock_event_repository.dart';
import '../widgets/monthly_calendar_grid.dart';

/// Giao diện Lịch Tháng (Monthly Calendar View) thuần túy
/// Đã lược bỏ phần checklist kéo theo yêu cầu, chỉ hiển thị ma trận lịch tháng
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
