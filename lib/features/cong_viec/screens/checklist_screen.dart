import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../thong_bao/widgets/hop_thoai_thong_bao.dart';
import '../controllers/checklist_controller.dart';
import '../models/cong_viec_model.dart';
import '../repositories/i_event_repository.dart';
import '../widgets/checklist_item_widget.dart';
import '../widgets/event_detail_dialog.dart';
import '../widgets/timass_logo_widget.dart';

/// Màn hình Danh Sách Check List Công Việc Hôm Nay
/// Thiết kế chuẩn mực, chi tiết và sắc sảo theo đúng `ui sample/ui check list.png`
class ChecklistScreen extends StatelessWidget {
  final DateTime? initialDate;
  final IEventRepository? eventRepository;

  const ChecklistScreen({
    super.key,
    this.initialDate,
    this.eventRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChecklistController>(
      create: (_) => ChecklistController(
        eventRepository: eventRepository,
        ngayChon: initialDate,
      ),
      child: const _ChecklistScreenView(),
    );
  }
}

class _ChecklistScreenView extends StatelessWidget {
  const _ChecklistScreenView();

  void _moDialogThemCongViec(
    BuildContext context,
    ChecklistController controller,
  ) {
    final DateTime targetDate = controller.ngayHienTai;
    final CongViecModel newEvent = CongViecModel(
      id: 0,
      maNguoiDung: 1,
      tenCongViec: '',
      thoiGianBatDau: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        9,
        0,
      ),
      thoiGianKetThuc: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        10,
        30,
      ),
      diaDiem: '',
      laThietYeu: false,
      daHoanThanh: false,
      ngayTao: DateTime.now(),
    );

    EventDetailDialog.show(
      context,
      congViec: newEvent,
      onSave: (created) => controller.themCongViec(created),
      onDelete: (_) {},
    );
  }

  void _moDialogSuaCongViec(
    BuildContext context,
    ChecklistController controller,
    CongViecModel congViec,
  ) {
    EventDetailDialog.show(
      context,
      congViec: congViec,
      onSave: (updated) => controller.themCongViec(updated),
      onDelete: (id) => controller.xoaCongViec(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChecklistController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F5),
      body: Stack(
        children: [
          // 1. Nền uốn lượn Gradient màu đào pastel phía trên
          Positioned.fill(
            child: CustomPaint(
              painter: _ChecklistTopWavePainter(),
            ),
          ),

          // 2. Nội dung giao diện
          SafeArea(
            child: Column(
              children: [
                // A. Header: Nút back, Logo Timass, chuông thông báo, avatar
                _buildHeader(context),

                // B. Danh sách cuộn chứa Tiêu đề, Card tiến độ & Checklist
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.sageGreen,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          children: [
                            // Tiêu đề lớn & Ngày tháng
                            _buildTitleSection(controller),

                            const SizedBox(height: 18),

                            // Thanh tiến độ tổng quan (Progress Card)
                            _buildProgressOverviewCard(controller),

                            const SizedBox(height: 20),

                            // Danh sách các công việc
                            if (controller.danhSachCongViec.isEmpty)
                              _buildEmptyState(context, controller)
                            else
                              for (final cv in controller.danhSachCongViec)
                                ChecklistItemWidget(
                                  congViec: cv,
                                  onToggle: (id) =>
                                      controller.toggleComplete(id),
                                  onTap: () => _moDialogSuaCongViec(
                                    context,
                                    controller,
                                    cv,
                                  ),
                                ),

                            const SizedBox(height: 16),
                          ],
                        ),
                ),

                // C. Footer: Dòng hướng dẫn & Nút to "Thêm công việc"
                _buildFooter(context, controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Header chuẩn mẫu: Nút back `<`, Logo Timass, Icon chuông, Avatar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          // Nút quay lại (Back button)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Logo Timass (Đồng hồ 3D + Chữ Timass)
          const TimassLogoWidget(
            size: 32,
            fontSize: 22,
          ),

          const Spacer(),

          // Icon chuông thông báo
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HopThoaiThongBao.show(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  if (DichVuThongBao.instance.lichSuThongBao.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Avatar người dùng bo tròn
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageGreen.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const ClipOval(
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.darkNavy,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Tiêu đề lớn "Danh sách công việc hôm nay" và dòng phụ ngày tháng
  Widget _buildTitleSection(ChecklistController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách công việc\nhôm nay',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.darkNavy,
            height: 1.22,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.chuoiNgayHienThi,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  /// 3. Thanh tiến độ tổng quan: "5/8 việc đã hoàn thành" - "65%", ProgressBar bo góc
  Widget _buildProgressOverviewCard(ChecklistController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${controller.soViecDaHoanThanh}/${controller.tongSoViec} việc đã hoàn thành',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${controller.phanTramHoanThanh}%',
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkNavy,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 0.0,
                end: controller.tiLeHoanThanh,
              ),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.sageGreen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Footer: Hướng dẫn và Nút to nổi bật "Thêm công việc"
  Widget _buildFooter(BuildContext context, ChecklistController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5).withValues(alpha: 0.95),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Đường gạch ngăn cách mỏng phía trên
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 10),

          // Dòng hướng dẫn
          const Text(
            'Tích vào ô tròn để đánh dấu hoàn thành nhanh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

          // Nút to nổi bật "Thêm công việc" màu Sage green
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _moDialogThemCongViec(context, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Thêm công việc',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state khi ngày đó chưa có việc nào
  Widget _buildEmptyState(
    BuildContext context,
    ChecklistController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 56,
            color: AppColors.sageGreen.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Không có công việc nào trong danh sách',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter vẽ đường sóng Gradient màu đào ở vùng trên của màn hình
class _ChecklistTopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Lớp nền mềm mại
    final Paint bgPaint = Paint()..color = const Color(0xFFFFF7F5);
    canvas.drawRect(rect, bgPaint);

    // Mảng màu đào ấm áp ở phần trên (Header và Tiêu đề)
    final Path wavePath = Path();
    wavePath.moveTo(0, 0);
    wavePath.lineTo(size.width, 0);
    wavePath.lineTo(size.width, size.height * 0.28);
    wavePath.cubicTo(
      size.width * 0.70,
      size.height * 0.32,
      size.width * 0.30,
      size.height * 0.25,
      0,
      size.height * 0.30,
    );
    wavePath.close();

    final Paint wavePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFD4CC),
          Color(0xFFFFE5DE),
          Color(0xFFFFF7F5),
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.32));

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
