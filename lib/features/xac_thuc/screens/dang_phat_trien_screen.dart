import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../providers/auth_controller.dart';
import '../widgets/timass_logo.dart';

/// Màn hình thông báo tính năng đang phát triển sau khi đăng nhập thành công
class DangPhatTrienScreen extends StatelessWidget {
  const DangPhatTrienScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final nguoiDung = authController.nguoiDungHienTai;
    final double chieuRongManHinh = MediaQuery.of(context).size.width;
    final bool laManHinhRong = chieuRongManHinh > 500;

    Widget noiDungChinh = Scaffold(
      backgroundColor: AppColors.peachBackground,
      appBar: AppBar(
        title: const TimassLogo(height: 36.0),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textDark),
            onPressed: () {
              context.read<AuthController>().handleDangXuat();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppStyles.cardRadius,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Biểu tượng Đang phát triển
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreenLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sageGreen.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: AppColors.sageGreenDark,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Nội dung đang phát triển',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Lời chào người dùng
                Text(
                  'Xin chào, ${nguoiDung?.hoTen ?? 'Người dùng'}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sageGreenDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Số điện thoại: ${nguoiDung?.soDienThoai ?? ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Nội dung giải thích
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.matKhauManh, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đăng nhập tài khoản thành công',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, color: AppColors.matKhauTrungBinh, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Giao diện và tính năng quản lý lịch trình đang được xây dựng',
                              style: TextStyle(fontSize: 13.5, color: AppColors.textMedium),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Nút Đăng xuất
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      context.read<AuthController>().handleDangXuat();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (laManHinhRong) {
      return Scaffold(
        backgroundColor: AppColors.screenMockupBackground,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: noiDungChinh,
          ),
        ),
      );
    }

    return noiDungChinh;
  }
}
