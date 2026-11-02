import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../xac_thuc/providers/auth_controller.dart';
import '../../xac_thuc/screens/dang_nhap_screen.dart';
import '../controllers/settings_controller.dart';
import '../widgets/doi_mat_khau_dialog.dart';
import '../widgets/thong_tin_ca_nhan_dialog.dart';
import 'thong_tin_san_pham_screen.dart';

/// Màn hình Cài đặt hệ thống (Settings Screen)
/// Tái hiện chuẩn xác 100% theo giao diện "ui sample/ui cài đặt.png"
class CaiDatScreen extends StatelessWidget {
  const CaiDatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, child) {
        final authController = context.watch<AuthController>();
        final nguoiDung = authController.nguoiDungHienTai;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                // 1. Header Bar: Nút "<" và Tiêu đề "Cài đặt"
                _buildHeader(context),

                // 2. Danh sách các Section cài đặt
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION 1: Tài khoản & Bảo mật
                        _buildSectionHeader(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF4F46E5),
                          title: 'Tài khoản & Bảo mật',
                        ),
                        _buildCardContainer(
                          children: [
                            // Dòng subheader "Thẻ Thông tin cá nhân"
                            Row(
                              children: [
                                const Icon(Icons.person, color: Color(0xFFF97316), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Thẻ Thông tin cá nhân',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Dòng Profile User
                            InkWell(
                              onTap: () => ThongTinCaNhanDialog.show(context, nguoiDung: nguoiDung),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    // Avatar tròn
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFE2E8F0),
                                        border: Border.all(color: AppColors.sageGreen, width: 1.5),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/images/auth_illustration.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Tên & SĐT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nguoiDung?.hoTen ?? 'Nguyễn Văn A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            nguoiDung?.soDienThoai ?? '09xx xxx xxx',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Icon Mũi tên phải
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Dòng "Đổi mật khẩu"
                            InkWell(
                              onTap: () async {
                                final res = await DoiMatKhauDialog.show(context);
                                if (res == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đổi mật khẩu thành công!'),
                                      backgroundColor: AppColors.sageGreen,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.lock_outline_rounded, color: Color(0xFF10B981), size: 22),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Đổi mật khẩu',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Dòng "Đăng xuất" (Chữ đỏ)
                            InkWell(
                              onTap: () => _xacNhanDangXuat(context, authController),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // SECTION 2: Cấu hình Lịch trình & Tự động hóa
                        _buildSectionHeader(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Cấu hình Lịch trình & Tự động hóa',
                        ),
                        _buildCardContainer(
                          children: [
                            // Switch "Tự động tích việc thiết yếu"
                            Row(
                              children: [
                                const Icon(Icons.event_available_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tự động tích việc thiết yếu',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Tự động hoàn thành khi qua khung giờ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildCustomSwitch(
                                  value: controller.tuDongTichViecThietYeu,
                                  onChanged: controller.capNhatTuDongTichViecThietYeu,
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Dropdown "Ngày bắt đầu tuần"
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, color: Color(0xFF0D9488), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Ngày bắt đầu tuần',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.ngayBatDauTuan,
                                  items: const ['Thứ Hai', 'Chủ Nhật'],
                                  onChanged: (val) {
                                    if (val != null) controller.capNhatNgayBatDauTuan(val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // SECTION 3: Thông báo & Nhắc nhở
                        _buildSectionHeader(
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFFF97316),
                          title: 'Thông báo & Nhắc nhở',
                        ),
                        _buildCardContainer(
                          children: [
                            // Switch "Bật/Tắt thông báo đẩy"
                            Row(
                              children: [
                                const Icon(Icons.notifications_rounded, color: Color(0xFFFB923C), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Bật/Tắt thông báo đẩy',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildCustomSwitch(
                                  value: controller.batThongBaoDay,
                                  onChanged: controller.capNhatBatThongBaoDay,
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Dropdown "Thời gian nhắc trước"
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Thời gian nhắc trước',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<int>(
                                  value: controller.thoiGianNhacTruoc,
                                  items: const [5, 10, 15, 30, 60],
                                  labelBuilder: (val) => val >= 60 ? 'Trước 1 tiếng' : 'Trước $val phút',
                                  onChanged: (val) {
                                    if (val != null) controller.capNhatThoiGianNhacTruoc(val);
                                  },
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Switch "Âm thanh & Rung"
                            Row(
                              children: [
                                const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Âm thanh & Rung',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildCustomSwitch(
                                  value: controller.amThanhRung,
                                  onChanged: controller.capNhatAmThanhRung,
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Kiểu thông báo (Messenger banner / Chat head)
                            Row(
                              children: [
                                const Icon(Icons.style_rounded, color: Color(0xFF6366F1), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Kiểu thông báo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.kieuThongBao,
                                  items: const [
                                    'Cả hai (Banner + Bong bóng)',
                                    'Banner trượt Messenger',
                                    'Bong bóng nổi (Chat Head)',
                                    'Hộp thoại Popup',
                                  ],
                                  onChanged: (val) {
                                    if (val != null) controller.capNhatKieuThongBao(val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // SECTION 4: Giao diện & Ngôn ngữ
                        _buildSectionHeader(
                          icon: Icons.public_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Giao diện & Ngôn ngữ',
                        ),
                        _buildCardContainer(
                          children: [
                            // Chọn Ngôn ngữ (Pill Toggle Tiếng Việt / English)
                            Row(
                              children: [
                                const Icon(Icons.language_rounded, color: Color(0xFF6366F1), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Ngôn ngữ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildLanguagePillSelector(
                                  currentLanguage: controller.ngonNgu,
                                  onSelected: controller.capNhatNgonNgu,
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Chế độ giao diện (Sáng / Tối)
                            Row(
                              children: [
                                const Icon(Icons.light_mode_rounded, color: Color(0xFF64748B), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Chế độ giao diện',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.cheDoGiaoDien,
                                  items: const ['Sáng', 'Tối'],
                                  labelBuilder: (val) => val == 'Sáng' ? '☀️ Sáng' : '🌙 Tối',
                                  onChanged: (val) {
                                    if (val != null) controller.capNhatCheDoGiaoDien(val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // SECTION 5: Dữ liệu & Ngoại tuyến
                        _buildSectionHeader(
                          icon: Icons.cloud_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Dữ liệu & Ngoại tuyến',
                        ),
                        _buildCardContainer(
                          children: [
                            // Trạng thái đồng bộ
                            Row(
                              children: [
                                const Icon(Icons.cloud_sync_rounded, color: Color(0xFF64748B), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Trạng thái đồng bộ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.caiDat.moTaDongBoLanCuoi,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh_rounded, color: AppColors.sageGreen, size: 20),
                                  onPressed: () async {
                                    await controller.dongBoDuLieu();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã cập nhật đồng bộ dữ liệu mới nhất!'),
                                          backgroundColor: AppColors.sageGreen,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Xóa bộ nhớ đệm (Clear Cache)
                            Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Xóa bộ nhớ đệm (Clear Cache)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final daXoa = await controller.xoaBoNhoDem();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã dọn dẹp ${daXoa.toStringAsFixed(1)} MB bộ nhớ đệm thành công!'),
                                          backgroundColor: AppColors.sageGreen,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF769F86),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Xóa đệm',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 18, color: Color(0xFFF1F5F9)),

                            // Thông tin về sản phẩm
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ThongTinSanPhamScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.layers_rounded, color: Color(0xFF64748B), size: 22),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Thông tin về sản phẩm',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header Top Bar chuẩn màu peach coral theo ảnh mẫu
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 14,
        left: 12,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFB3A7),
            Color(0xFFFFA599),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1AFF8A80),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút "<"
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.darkNavy,
              size: 28,
            ),
          ),

          // Tiêu đề "Cài đặt" nằm giữa
          const Expanded(
            child: Text(
              'Cài đặt',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Đối trọng để căn giữa tiêu đề
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Header của từng Section
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  /// Khung Card màu trắng bao quanh các mục
  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Switch chuẩn màu xanh Sage green theo ảnh mẫu
  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF769F86),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFCBD5E1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Dropdown Selector tùy biến gọn gàng
  Widget _buildDropdownSelector<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T item)? labelBuilder,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkNavy,
        ),
        borderRadius: BorderRadius.circular(12),
        items: items.map((item) {
          final text = labelBuilder != null ? labelBuilder(item) : item.toString();
          return DropdownMenuItem<T>(
            value: item,
            child: Text(text),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// Pill Selector chọn Ngôn ngữ "Tiếng Việt / English"
  Widget _buildLanguagePillSelector({
    required String currentLanguage,
    required ValueChanged<String> onSelected,
  }) {
    final isVietnamese = currentLanguage == 'Tiếng Việt';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiếng Việt
          GestureDetector(
            onTap: () => onSelected('Tiếng Việt'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isVietnamese ? const Color(0xFF769F86) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Tiếng Việt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isVietnamese ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const Text(' / ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          // English
          GestureDetector(
            onTap: () => onSelected('English'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isVietnamese ? const Color(0xFF769F86) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'English',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: !isVietnamese ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xác nhận đăng xuất
  void _xacNhanDangXuat(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng Timass?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await authController.handleDangXuat();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DangNhapScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
