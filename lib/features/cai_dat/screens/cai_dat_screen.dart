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
/// Hỗ trợ đầy đủ:
/// 1. Chuyển đổi ngôn ngữ Tiếng Việt & English
/// 2. Chế độ giao diện Sáng & Tối (Dark Mode)
/// 3. Cấu hình lịch trình, thông báo, xóa bộ nhớ đệm, đồng bộ dữ liệu
class CaiDatScreen extends StatelessWidget {
  const CaiDatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, child) {
        final authController = context.watch<AuthController>();
        final nguoiDung = authController.nguoiDungHienTai;
        final bool isDark = controller.isDarkMode;

        // Bảng màu thích ứng động theo Light/Dark Mode
        final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
        final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final Color textColor = isDark ? const Color(0xFFF8FAFC) : AppColors.darkNavy;
        final Color subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                // 1. Header Bar: Nút "<" và Tiêu đề "Cài đặt" / "Settings"
                _buildHeader(context, controller, isDark),

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
                          title: controller.tr('account_security'),
                          textColor: textColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          children: [
                            // Dòng subheader "Thẻ Thông tin cá nhân"
                            Row(
                              children: [
                                const Icon(Icons.person, color: Color(0xFFF97316), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  controller.tr('personal_info_card'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: subtextColor,
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
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            nguoiDung?.soDienThoai ?? '09xx xxx xxx',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: subtextColor,
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

                            Divider(height: 18, color: dividerColor),

                            // Dòng "Đổi mật khẩu"
                            InkWell(
                              onTap: () async {
                                final res = await DoiMatKhauDialog.show(context);
                                if (res == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(controller.tr('change_password_success')),
                                      backgroundColor: AppColors.sageGreen,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_outline_rounded, color: Color(0xFF10B981), size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        controller.tr('change_password'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
                                  ],
                                ),
                              ),
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Dòng "Đăng xuất" (Chữ đỏ)
                            InkWell(
                              onTap: () => _xacNhanDangXuat(context, authController, controller),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                                    const SizedBox(width: 12),
                                    Text(
                                      controller.tr('logout'),
                                      style: const TextStyle(
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
                          title: controller.tr('schedule_automation'),
                          textColor: textColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          children: [
                            // Switch "Tự động tích việc thiết yếu"
                            Row(
                              children: [
                                const Icon(Icons.event_available_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.tr('auto_complete_essential'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.tr('auto_complete_desc'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subtextColor,
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

                            Divider(height: 18, color: dividerColor),

                            // Dropdown "Ngày bắt đầu tuần"
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, color: Color(0xFF0D9488), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('week_start_day'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.ngayBatDauTuan,
                                  items: const ['Thứ Hai', 'Chủ Nhật'],
                                  isDark: isDark,
                                  labelBuilder: (val) => val == 'Thứ Hai'
                                      ? controller.tr('monday')
                                      : controller.tr('sunday'),
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
                          title: controller.tr('notifications_reminders'),
                          textColor: textColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          children: [
                            // Switch "Bật/Tắt thông báo đẩy"
                            Row(
                              children: [
                                const Icon(Icons.notifications_rounded, color: Color(0xFFFB923C), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('push_notifications'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildCustomSwitch(
                                  value: controller.batThongBaoDay,
                                  onChanged: controller.capNhatBatThongBaoDay,
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Dropdown "Thời gian nhắc trước"
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('reminder_time'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<int>(
                                  value: controller.thoiGianNhacTruoc,
                                  items: const [5, 10, 15, 30, 60],
                                  isDark: isDark,
                                  labelBuilder: (val) => val >= 60
                                      ? controller.tr('remind_hour_before')
                                      : controller.tr('remind_minutes_before', params: {'n': val.toString()}),
                                  onChanged: (val) {
                                    if (val != null) controller.capNhatThoiGianNhacTruoc(val);
                                  },
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Switch "Âm thanh & Rung"
                            Row(
                              children: [
                                const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('sound_vibration'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildCustomSwitch(
                                  value: controller.amThanhRung,
                                  onChanged: controller.capNhatAmThanhRung,
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Kiểu thông báo (Messenger banner / Chat head)
                            Row(
                              children: [
                                const Icon(Icons.style_rounded, color: Color(0xFF6366F1), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('notification_style'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.kieuThongBao,
                                  isDark: isDark,
                                  items: const [
                                    'Cả hai (Banner + Bong bóng)',
                                    'Banner trượt Messenger',
                                    'Bong bóng nổi (Chat Head)',
                                    'Hộp thoại Popup',
                                  ],
                                  labelBuilder: (val) {
                                    if (val == 'Cả hai (Banner + Bong bóng)') return controller.tr('notification_style_both');
                                    if (val == 'Banner trượt Messenger') return controller.tr('notification_style_banner');
                                    if (val == 'Bong bóng nổi (Chat Head)') return controller.tr('notification_style_bubble');
                                    return controller.tr('notification_style_popup');
                                  },
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
                          title: controller.tr('ui_language'),
                          textColor: textColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          children: [
                            // Chọn Ngôn ngữ (Pill Toggle Tiếng Việt / English)
                            Row(
                              children: [
                                const Icon(Icons.language_rounded, color: Color(0xFF6366F1), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('language'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildLanguagePillSelector(
                                  currentLanguage: controller.ngonNgu,
                                  isDark: isDark,
                                  onSelected: controller.capNhatNgonNgu,
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Chế độ giao diện (Sáng / Tối)
                            Row(
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('theme_mode'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                _buildDropdownSelector<String>(
                                  value: controller.cheDoGiaoDien,
                                  isDark: isDark,
                                  items: const ['Sáng', 'Tối'],
                                  labelBuilder: (val) => val == 'Sáng'
                                      ? controller.tr('light_mode')
                                      : controller.tr('dark_mode'),
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
                          title: controller.tr('data_offline'),
                          textColor: textColor,
                        ),
                        _buildCardContainer(
                          cardBg: cardBg,
                          cardBorder: cardBorder,
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
                                      Text(
                                        controller.tr('sync_status'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.caiDat.moTaDongBoLanCuoi,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subtextColor,
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
                                        SnackBar(
                                          content: Text(controller.tr('sync_success')),
                                          backgroundColor: AppColors.sageGreen,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Xóa bộ nhớ đệm (Clear Cache)
                            Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Color(0xFF10B981), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.tr('clear_cache'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final daXoa = await controller.xoaBoNhoDem();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(controller.tr('clear_cache_success', params: {
                                            'n': daXoa.toStringAsFixed(1),
                                          })),
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
                                  child: Text(
                                    controller.tr('clear_cache_btn'),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            Divider(height: 18, color: dividerColor),

                            // Thông tin về sản phẩm
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ThongTinSanPhamScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.layers_rounded, color: Color(0xFF64748B), size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        controller.tr('about_product'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
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

  /// Header Top Bar
  Widget _buildHeader(BuildContext context, SettingsController controller, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 14,
        left: 12,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
              : const [Color(0xFFFFB3A7), Color(0xFFFFA599)],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x1AFF8A80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút "<"
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.chevron_left_rounded,
              color: isDark ? Colors.white : AppColors.darkNavy,
              size: 28,
            ),
          ),

          // Tiêu đề "Cài đặt" / "Settings" nằm giữa
          Expanded(
            child: Text(
              controller.tr('settings'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.darkNavy,
                letterSpacing: -0.3,
              ),
            ),
          ),

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
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Khung Card bao quanh các mục
  Widget _buildCardContainer({
    required Color cardBg,
    required Color cardBorder,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
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
    required bool isDark,
    String Function(T item)? labelBuilder,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF8FAFC) : AppColors.darkNavy,
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
    required bool isDark,
    required ValueChanged<String> onSelected,
  }) {
    final isVietnamese = currentLanguage == 'Tiếng Việt';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
  void _xacNhanDangXuat(BuildContext context, AuthController authController, SettingsController settings) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(settings.tr('logout_confirm_title')),
          ],
        ),
        content: Text(settings.tr('logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(settings.tr('cancel'), style: const TextStyle(color: Colors.grey)),
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
            child: Text(settings.tr('logout')),
          ),
        ],
      ),
    );
  }
}
