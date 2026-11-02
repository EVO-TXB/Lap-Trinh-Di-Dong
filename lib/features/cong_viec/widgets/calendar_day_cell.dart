import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/month_calendar_controller.dart';

/// Widget biểu diễn một Ô ngày trong Lưới Lịch Tháng (CalendarDayCell):
/// - Ngày tháng trước/sau: Chữ mờ (opacity 30%)
/// - Ngày bình thường: Chữ số màu Navy đậm
/// - Ngày hôm nay (Today): Vòng viền cam đào/đỏ nhận diện nổi bật
/// - Ngày được chọn (Selected): Nền tròn màu Sage Green (#729B79), chữ trắng
/// - Chấm sự kiện (Event Indicator Dots): Tối đa 3 chấm (Xanh lam, Cam, Xanh lá) hoặc 2 chấm + dấu '+'
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final DayIndicatorDots indicatorDots;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.indicatorDots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Khối hình tròn chứa số ngày
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Ngày được chọn: Nền Sage Green bo tròn
                color: isSelected
                    ? AppColors.sageGreen
                    : Colors.transparent,
                // Ngày hôm nay (khi chưa được chọn): Có vòng viền cam đào nổi bật
                border: (isToday && !isSelected)
                    ? Border.all(color: const Color(0xFFFF8A75), width: 1.8)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.sageGreen.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 3),

            // Chấm chỉ báo sự kiện (Event Indicator Dots)
            SizedBox(
              height: 7,
              child: _buildIndicatorDots(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor() {
    if (isSelected) {
      return Colors.white; // Chữ trắng khi đang chọn
    }
    if (!isCurrentMonth) {
      return AppColors.textDark.withValues(alpha: 0.30); // Làm mờ ngày ngoài tháng
    }
    if (isToday) {
      return const Color(0xFFE54D38); // Màu nhấn cho ngày hôm nay
    }
    return AppColors.darkNavy; // Màu Navy đậm cho ngày bình thường
  }

  Widget _buildIndicatorDots() {
    if (indicatorDots.dotColors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final Color color in indicatorDots.dotColors)
          Container(
            width: 5.0,
            height: 5.0,
            margin: const EdgeInsets.symmetric(horizontal: 1.2),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        if (indicatorDots.hasMore)
          const Padding(
            padding: EdgeInsets.only(left: 1.0, bottom: 2.0),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                height: 0.8,
              ),
            ),
          ),
      ],
    );
  }
}
