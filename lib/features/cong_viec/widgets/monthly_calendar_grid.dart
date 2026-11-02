import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/month_calendar_controller.dart';
import 'calendar_day_cell.dart';

/// Lưới Lịch Tháng (Monthly Calendar Grid):
/// - Thanh điều hướng: Tháng MM, YYYY, < >, Hôm nay
/// - 7 cột thứ: T2, T3, T4, T5, T6, T7, CN
/// - Ma trận các ngày (7 cột x 5-6 hàng) với chấm chỉ báo màu sắc
class MonthlyCalendarGrid extends StatelessWidget {
  final MonthCalendarController controller;

  const MonthlyCalendarGrid({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final List<DateTime> maTranNgay = controller.taoMaTranLichThang(
      controller.thangHienTai.year,
      controller.thangHienTai.month,
    );

    const List<String> tenCacThu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Thanh tiêu đề tháng & Điều hướng (< > và Hôm nay)
          _buildMonthNavigationHeader(context),

          const SizedBox(height: 10),

          // 2. Hàng tiêu đề 7 thứ trong tuần (T2 -> CN)
          Row(
            children: [
              for (final String thu in tenCacThu)
                Expanded(
                  child: Center(
                    child: Text(
                      thu,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B), // Slate grey thanh lịch
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),

          // 3. Ma trận các ngày (GridView không cuộn)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maTranNgay.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final DateTime date = maTranNgay[index];
              final bool isCurrentMonth = date.month == controller.thangHienTai.month;
              final bool isToday = date.year == controller.ngayHomNay.year &&
                                   date.month == controller.ngayHomNay.month &&
                                   date.day == controller.ngayHomNay.day;
              final bool isSelected = date.year == controller.ngayDangChon.year &&
                                      date.month == controller.ngayDangChon.month &&
                                      date.day == controller.ngayDangChon.day;
              final DayIndicatorDots dots = controller.getChiBaoChamNgay(date);

              return CalendarDayCell(
                date: date,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isSelected: isSelected,
                indicatorDots: dots,
                onTap: () => controller.selectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Thanh điều hướng tháng: "Tháng MM, YYYY", nút < >, nút "Hôm nay"
  Widget _buildMonthNavigationHeader(BuildContext context) {
    return Row(
      children: [
        // Tiêu đề tháng hiện tại
        Expanded(
          child: Text(
            controller.tieuDeThangHienTai,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
              letterSpacing: -0.3,
            ),
          ),
        ),

        // Nút chuyển tháng trước <
        _buildNavButton(
          icon: Icons.chevron_left_rounded,
          onPressed: controller.chuyenThangTruoc,
        ),

        const SizedBox(width: 4),

        // Nút chuyển tháng sau >
        _buildNavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: controller.chuyenThangSau,
        ),

        const SizedBox(width: 8),

        // Nút "Hôm nay"
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.chuyenDenHomNay,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'Hôm nay',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.darkNavy,
          ),
        ),
      ),
    );
  }
}
