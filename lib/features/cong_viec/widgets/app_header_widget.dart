import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'timass_logo_widget.dart';

/// App Header: Logo Timass, nút "+ Thêm việc", icon Chuông có chấm đỏ, Avatar người dùng
class AppHeaderWidget extends StatelessWidget {
  final VoidCallback? onThemCongViec;
  final VoidCallback? onThongBao;
  final VoidCallback? onAvatar;
  final bool coThongBaoMoi;

  const AppHeaderWidget({
    super.key,
    this.onThemCongViec,
    this.onThongBao,
    this.onAvatar,
    this.coThongBaoMoi = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 1. Logo Timass chuẩn 100% theo ảnh chi tiết (Đồng hồ 3D + Sector cam + Chữ Timass)
          const TimassLogoWidget(
            size: 34,
            fontSize: 23,
          ),

          const Spacer(),

          // 2. Nút "+ Thêm việc" màu Sage green bo tròn
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onThemCongViec,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.sageGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sageGreen.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Thêm việc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 3. Icon Chuông thông báo (có chấm đỏ khi có thông báo mới)
          GestureDetector(
            onTap: onThongBao,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkNavy,
                    size: 24,
                  ),
                ),
                if (coThongBaoMoi)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 4. Avatar người dùng
          GestureDetector(
            onTap: onAvatar,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFF64748B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const ClipOval(
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
