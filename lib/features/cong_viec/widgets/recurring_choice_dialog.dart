import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';

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
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }
    final bool isDark = settings?.isDarkMode ?? false;
    final bool isXoa = actionType == RecurringActionType.xoa;

    final String tieuDe = isXoa
        ? (settings?.tr('recurring_delete_title') ?? 'Xóa công việc lặp lại')
        : (settings?.tr('recurring_edit_title') ?? 'Chỉnh sửa công việc lặp lại');

    final String moTa = isXoa
        ? (settings?.tr('recurring_delete_desc') ??
            'Công việc này nằm trong một chuỗi lịch trình lặp lại hàng tuần. Bạn muốn thực hiện xóa như thế nào?')
        : (settings?.tr('recurring_edit_desc') ??
            'Công việc này nằm trong một chuỗi lịch trình lặp lại hàng tuần. Bạn muốn áp dụng thay đổi này như thế nào?');

    final String nut1Text = isXoa
        ? (settings?.tr('delete_single_event') ?? 'Chỉ xóa sự kiện này')
        : (settings?.tr('apply_single_event') ?? 'Áp dụng chỉ 1 sự kiện này');
    final String nut2Text = isXoa
        ? (settings?.tr('delete_all_series') ?? 'Xóa toàn bộ chuỗi sự kiện lặp')
        : (settings?.tr('apply_all_series') ?? 'Áp dụng cho toàn bộ chuỗi sự kiện lặp');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  tooltip: settings?.tr('close_tooltip') ?? 'Đóng',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              tieuDe,
              style: TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 8),

            // Mô tả
            Text(
              moTa,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMedium,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.darkNavy,
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

