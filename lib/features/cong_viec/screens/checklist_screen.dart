import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../../xac_thuc/providers/auth_controller.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../thong_bao/widgets/hop_thoai_thong_bao.dart';
import '../controllers/checklist_controller.dart';
import '../models/cong_viec_model.dart';
import '../repositories/i_event_repository.dart';
import '../repositories/mock_event_repository.dart';
import '../widgets/checklist_item_widget.dart';
import '../widgets/event_detail_dialog.dart';
import '../widgets/timass_logo_widget.dart';

/// Màn hình Danh Sách Check List Công Việc Hôm Nay
/// Thiết kế chuẩn mực, chi tiết và sắc sảo theo đúng `ui sample/ui check list.png`
class ChecklistScreen extends StatelessWidget {
  final DateTime? initialDate;
  final IEventRepository? eventRepository;
  final int? userId;

  const ChecklistScreen({
    super.key,
    this.initialDate,
    this.eventRepository,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    int currentUserId = userId ?? 1;
    try {
      final auth = context.watch<AuthController>();
      if (auth.nguoiDungHienTai?.id != null) {
        currentUserId = auth.nguoiDungHienTai!.id!;
      }
    } catch (_) {}

    return ChangeNotifierProvider<ChecklistController>(
      key: ValueKey('ChecklistController_user_$currentUserId'),
      create: (_) => ChecklistController(
        eventRepository: eventRepository ?? MockEventRepository(userId: currentUserId),
        ngayChon: initialDate,
        userId: currentUserId,
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
      maNguoiDung: controller.userId,
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
      danhSachHienCo: controller.danhSachCongViec,
      onSave: (created) => controller.themCongViec(created),
      onDelete: (_) {},
      onSaveBatch: (batch) => controller.luuChuoiCongViec(batch),
      onDeleteSeries: (maChuoi) => controller.xoaChuoiCongViec(maChuoi),
      onUpdateSeries: (maChuoi, mau, batch) => controller.capNhatChuoiCongViec(
        maChuoiLap: maChuoi,
        mau: mau,
        danhSachMoiNeuDoiLich: batch,
      ),
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
      danhSachHienCo: controller.danhSachCongViec,
      onSave: (updated) => controller.capNhatCongViec(updated),
      onDelete: (id) => controller.xoaCongViec(id),
      onSaveBatch: (batch) => controller.luuChuoiCongViec(batch),
      onDeleteSeries: (maChuoi) => controller.xoaChuoiCongViec(maChuoi),
      onUpdateSeries: (maChuoi, mau, batch) => controller.capNhatChuoiCongViec(
        maChuoiLap: maChuoi,
        mau: mau,
        danhSachMoiNeuDoiLich: batch,
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
    final String ngonNgu = settings?.ngonNgu ?? 'Tiếng Việt';
    final controller = context.watch<ChecklistController>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFF7F5),
      body: Stack(
        children: [
          // 1. Nền trang trí màu đào / Dark Slate ở phía trên
          Positioned.fill(
            child: CustomPaint(
              painter: _ChecklistTopWavePainter(isDark: isDark),
            ),
          ),

          // 2. Nội dung giao diện
          SafeArea(
            child: Column(
              children: [
                // A. Header: Nút back, Logo Timass, chuông thông báo, avatar
                _buildHeader(context, isDark: isDark),

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
                            _buildTitleSection(controller, isDark: isDark, settings: settings),

                            const SizedBox(height: 18),

                            // Thanh tiến độ tổng quan (Progress Card)
                            _buildProgressOverviewCard(controller, isDark: isDark, settings: settings),

                            const SizedBox(height: 20),

                            // Danh sách các công việc
                            if (controller.danhSachCongViec.isEmpty)
                              _buildEmptyState(context, controller, isDark: isDark, settings: settings)
                            else
                              for (final cv in controller.danhSachCongViec)
                                ChecklistItemWidget(
                                  congViec: cv,
                                  isDark: isDark,
                                  ngonNgu: ngonNgu,
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
                _buildFooter(context, controller, isDark: isDark, settings: settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Header chuẩn mẫu: Nút back `<`, Logo Timass, Icon chuông, Avatar
  Widget _buildHeader(BuildContext context, {required bool isDark}) {
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : AppColors.darkNavy,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: isDark ? Colors.white : AppColors.darkNavy,
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
                color: isDark ? const Color(0xFF334155) : Colors.white,
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
            child: ClipOval(
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? Colors.white : AppColors.darkNavy,
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
  Widget _buildTitleSection(
    ChecklistController controller, {
    required bool isDark,
    SettingsController? settings,
  }) {
    final title = settings?.tr('today_task_checklist') ?? 'Danh sách công việc\nhôm nay';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.darkNavy,
            height: 1.22,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.chuoiNgayHienThi,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  /// 3. Thanh tiến độ tổng quan: "5/8 việc đã hoàn thành" - "65%", ProgressBar bo góc
  Widget _buildProgressOverviewCard(
    ChecklistController controller, {
    required bool isDark,
    SettingsController? settings,
  }) {
    final progressText = settings?.tr('tasks_completed_count', params: {
      'done': controller.soViecDaHoanThanh.toString(),
      'total': controller.tongSoViec.toString(),
    }) ?? '${controller.soViecDaHoanThanh}/${controller.tongSoViec} việc đã hoàn thành';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                progressText,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${controller.phanTramHoanThanh}%',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.darkNavy,
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
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
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
  Widget _buildFooter(
    BuildContext context,
    ChecklistController controller, {
    required bool isDark,
    SettingsController? settings,
  }) {
    final instruction = settings?.tr('checklist_instruction') ??
        'Tích vào ô tròn để đánh dấu hoàn thành nhanh';
    final addLabel = settings?.tr('add_task') ?? 'Thêm công việc';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.95)
            : const Color(0xFFFFF7F5).withValues(alpha: 0.95),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 10),

          Text(
            instruction,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

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
              child: Text(
                addLabel,
                style: const TextStyle(
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
    ChecklistController controller, {
    required bool isDark,
    SettingsController? settings,
  }) {
    final emptyMsg = settings?.tr('empty_checklist') ?? 'Không có công việc nào trong danh sách';

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
          Text(
            emptyMsg,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter vẽ đường sóng Gradient màu đào ở vùng trên của màn hình
class _ChecklistTopWavePainter extends CustomPainter {
  final bool isDark;

  const _ChecklistTopWavePainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Lớp nền mềm mại
    final Paint bgPaint = Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFF7F5);
    canvas.drawRect(rect, bgPaint);

    // Mảng màu đào ấm áp / Dark Slate ở phần trên
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
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF1E293B),
                Color(0xFF152033),
                Color(0xFF0F172A),
              ]
            : const [
                Color(0xFFFFD4CC),
                Color(0xFFFFE5DE),
                Color(0xFFFFF7F5),
              ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.32));

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _ChecklistTopWavePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
