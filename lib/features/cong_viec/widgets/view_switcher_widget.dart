import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Bộ chuyển đổi chế độ xem: Segmented control [ Lịch tuần (Active xanh) | Lịch tháng ]
/// Hỗ trợ Dark Mode và Đa ngôn ngữ
class ViewSwitcherWidget extends StatelessWidget {
  final int selectedIndex; // 0: Lịch tuần, 1: Lịch tháng
  final ValueChanged<int> onIndexChanged;
  final bool isDark;
  final String? nhanLichTuan;
  final String? nhanLichThang;

  const ViewSwitcherWidget({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    this.isDark = false,
    this.nhanLichTuan,
    this.nhanLichThang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
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
                title: nhanLichTuan ?? 'Lịch tuần',
                isSelected: selectedIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
            ),

            // Segment 2: Lịch tháng
            Expanded(
              child: _buildSegmentItem(
                title: nhanLichThang ?? 'Lịch tháng',
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
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sageGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}
