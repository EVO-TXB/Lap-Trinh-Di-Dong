import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Bộ chuyển đổi chế độ xem: Segmented control [ Lịch tuần (Active xanh) | Lịch tháng ]
class ViewSwitcherWidget extends StatelessWidget {
  final int selectedIndex; // 0: Lịch tuần, 1: Lịch tháng
  final ValueChanged<int> onIndexChanged;

  const ViewSwitcherWidget({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Segment 1: Lịch tuần
            Expanded(
              child: _buildSegmentItem(
                title: 'Lịch tuần',
                isSelected: selectedIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
            ),

            // Segment 2: Lịch tháng
            Expanded(
              child: _buildSegmentItem(
                title: 'Lịch tháng',
                isSelected: selectedIndex == 1,
                onTap: () => onIndexChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sageGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
