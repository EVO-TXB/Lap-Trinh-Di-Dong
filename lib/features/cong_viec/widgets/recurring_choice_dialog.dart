import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Phạm vi áp dụng cho công việc lặp lại
enum RecurringScope {
  single, // Chỉ áp dụng / chỉ xóa sự kiện này
  allSeries, // Áp dụng / xóa toàn bộ chuỗi lặp
}

/// Loại thao tác trên sự kiện lặp (Sửa hoặc Xóa)
enum RecurringActionType {
  sua,
  xoa,
}

/// Dialog xác nhận phạm vi thay đổi cho công việc lặp lại
class RecurringChoiceDialog extends StatelessWidget {
  final RecurringActionType actionType;
  final ValueChanged<RecurringScope> onScopeSelected;

  const RecurringChoiceDialog({
    super.key,
    required this.actionType,
    required this.onScopeSelected,
  });

  static Future<RecurringScope?> show(
    BuildContext context, {
    required RecurringActionType actionType,
  }) {
    return showDialog<RecurringScope>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RecurringChoiceDialog(
        actionType: actionType,
        onScopeSelected: (scope) => Navigator.of(ctx).pop(scope),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isXoa = actionType == RecurringActionType.xoa;

    final String tieuDe = isXoa
        ? 'Xóa công việc lặp lại'
        : 'Chỉnh sửa công việc lặp lại';

    final String moTa = isXoa
        ? 'Công việc này nằm trong một chuỗi lịch trình lặp lại hàng tuần. Bạn muốn thực hiện xóa như thế nào?'
        : 'Công việc này nằm trong một chuỗi lịch trình lặp lại hàng tuần. Bạn muốn áp dụng thay đổi này như thế nào?';

    final String nut1Text = isXoa ? 'Chỉ xóa sự kiện này' : 'Áp dụng chỉ 1 sự kiện này';
    final String nut2Text =
        isXoa ? 'Xóa toàn bộ chuỗi sự kiện lặp' : 'Áp dụng cho toàn bộ chuỗi sự kiện lặp';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon + Nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isXoa
                        ? const Color(0xFFFEE2E2)
                        : AppColors.sageGreenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isXoa ? Icons.delete_outline_rounded : Icons.sync_rounded,
                    color: isXoa ? const Color(0xFFDC2626) : AppColors.sageGreenDark,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                  tooltip: 'Đóng',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              tieuDe,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 8),

            // Mô tả
            Text(
              moTa,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),

            // 2 Lựa chọn
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nút 1: Chỉ sự kiện này
                OutlinedButton(
                  onPressed: () => onScopeSelected(RecurringScope.single),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    nut1Text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nút 2: Toàn bộ chuỗi
                ElevatedButton(
                  onPressed: () => onScopeSelected(RecurringScope.allSeries),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isXoa ? const Color(0xFFDC2626) : AppColors.sageGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    nut2Text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

