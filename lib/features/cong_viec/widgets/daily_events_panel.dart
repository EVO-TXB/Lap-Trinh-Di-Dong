import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';

/// Panel Chi tiết Sự kiện của Ngày được chọn (Selected Day Agenda Panel):
/// - Hỗ trợ kéo hẳn lên trên (DraggableScrollableSheet) để xem trọn vẹn danh sách công việc
/// - Tiêu đề ngày kèm số lượng công việc được pinned cố định ở đỉnh panel
/// - Danh sách các công việc với Khung giờ, Tên, Badge loại việc, Địa điểm
/// - Checkbox tròn cho phép đánh dấu nhanh hoàn thành
/// - Trạng thái trống (Empty State) với minh họa và nút "+ Thêm việc"
class DailyEventsPanel extends StatelessWidget {
  final DateTime ngayDangChon;
  final List<CongViecModel> danhSachCongViec;
  final ValueChanged<CongViecModel> onToggleHoanThanh;
  final ValueChanged<CongViecModel> onTapCongViec;
  final VoidCallback onThemCongViec;
  final ScrollController? scrollController;
  final VoidCallback? onToggleExpand;
  final bool isExpanded;

  const DailyEventsPanel({
    super.key,
    required this.ngayDangChon,
    required this.danhSachCongViec,
    required this.onToggleHoanThanh,
    required this.onTapCongViec,
    required this.onThemCongViec,
    this.scrollController,
    this.onToggleExpand,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String tieuDeNgay = 'Lịch trình ngày ${formatter.format(ngayDangChon)}';
    final int soLuong = danhSachCongViec.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Header được Pinned cố định ở đỉnh Panel (Handle bar + Tiêu đề ngày + Nút "+ Thêm việc")
            SliverPersistentHeader(
              pinned: true,
              delegate: _AgendaHeaderDelegate(
                height: 74.0,
                child: _buildPinnedHeader(context, tieuDeNgay, soLuong),
              ),
            ),

            // 2. Nội dung chính: Danh sách sự kiện hoặc Empty State
            if (soLuong == 0)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                sliver: SliverList.separated(
                  itemCount: soLuong,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final CongViecModel item = danhSachCongViec[index];
                    return _buildEventItem(item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Pinned Header: Thanh kéo thẩm mỹ, Tiêu đề ngày, Số lượng việc, Nút "+ Thêm việc"
  Widget _buildPinnedHeader(BuildContext context, String tieuDeNgay, int soLuong) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A. Thanh kéo thẩm mỹ hỗ trợ Tap để mở rộng/thu gọn nhanh
          GestureDetector(
            onTap: onToggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AppColors.sageGreen
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

          // B. Hàng Tiêu đề ngày + Số lượng việc + Nút "+ Thêm việc"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: tieuDeNgay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextSpan(
                          text: ' ($soLuong việc)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: soLuong > 0
                                ? AppColors.sageGreen
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Nút thu gọn / mở rộng nhanh (nếu có handler)
                if (onToggleExpand != null) ...[
                  InkWell(
                    onTap: onToggleExpand,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                        size: 24,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],

                // Nút "+ Thêm việc"
                InkWell(
                  onTap: onThemCongViec,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 15, color: AppColors.sageGreen),
                        SizedBox(width: 3),
                        Text(
                          'Thêm việc',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sageGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  /// Thẻ công việc chi tiết
  Widget _buildEventItem(CongViecModel item) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    final bool isCompleted = item.trangThaiHoanThanhHienThi;
    final String thoiGianStr =
        '${timeFormat.format(item.thoiGianBatDau)} - ${timeFormat.format(item.thoiGianKetThuc)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTapCongViec(item),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFF8FAFC)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFCBD5E1).withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Checkbox tròn hoàn thành
              GestureDetector(
                onTap: () => onToggleHoanThanh(item),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.completedGreenLegend
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.completedGreenLegend
                          : const Color(0xFF94A3B8),
                      width: 1.8,
                    ),
                  ),
                  child: isCompleted
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),

              // 2. Nội dung thông tin công việc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng: Khung giờ + Badge loại việc
                    Row(
                      children: [
                        Text(
                          thoiGianStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? AppColors.textMuted
                                : AppColors.darkNavy,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Badge loại việc: Chủ động (xanh) hoặc Bị động/Thiết yếu (cam)
                        _buildCategoryBadge(item.laThietYeu),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Tên công việc
                    Text(
                      item.tenCongViec,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.textMuted
                            : AppColors.textDark,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Địa điểm (nếu có)
                    if (item.diaDiem != null && item.diaDiem!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isCompleted
                                ? AppColors.textMuted
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.diaDiem!,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isCompleted
                                    ? AppColors.textMuted
                                    : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 3. Mũi tên nhỏ gợi ý xem chi tiết
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge phân loại việc: Chủ động (Xanh lam pastel) / Bị động (Cam pastel)
  Widget _buildCategoryBadge(bool laThietYeu) {
    if (laThietYeu) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBD8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Bị động / Thiết yếu',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC2410C),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE0EDFD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Chủ động',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E40AF),
        ),
      ),
    );
  }

  /// Trạng thái trống (Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 34,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Không có công việc nào trong ngày này',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onThemCongViec,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                elevation: 1,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Thêm việc cho ngày này',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delegate giúp ghim Pinned Header tại đỉnh Panel của DraggableScrollableSheet
class _AgendaHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _AgendaHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _AgendaHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
