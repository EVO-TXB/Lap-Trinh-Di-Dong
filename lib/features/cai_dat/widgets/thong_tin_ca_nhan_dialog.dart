import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../xac_thuc/models/nguoi_dung_model.dart';

/// Hộp thoại Chi tiết thông tin cá nhân
class ThongTinCaNhanDialog extends StatelessWidget {
  final NguoiDungModel? nguoiDung;

  const ThongTinCaNhanDialog({super.key, this.nguoiDung});

  static Future<void> show(BuildContext context, {NguoiDungModel? nguoiDung}) {
    return showDialog(
      context: context,
      builder: (_) => ThongTinCaNhanDialog(nguoiDung: nguoiDung),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hoTen = nguoiDung?.hoTen ?? 'Nguyễn Văn A';
    final String soDienThoai = nguoiDung?.soDienThoai ?? '09xx xxx xxx';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: const Row(
        children: [
          Icon(Icons.badge_rounded, color: AppColors.sageGreen, size: 26),
          SizedBox(width: 10),
          Text(
            'Thông tin cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar lớn
          Center(
            child: Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE2E8F0),
                    border: Border.all(color: AppColors.sageGreen, width: 2.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/auth_illustration.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.sageGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thông tin chi tiết
          _buildInfoRow(Icons.person_outline, 'Họ và tên', hoTen),
          const Divider(height: 16),
          _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', soDienThoai),
          const Divider(height: 16),
          _buildInfoRow(Icons.verified_user_outlined, 'Trạng thái', 'Đang hoạt động (Đã xác thực)'),
          const Divider(height: 16),
          _buildInfoRow(Icons.security_outlined, 'Quyền hạn', 'Thành viên tiêu chuẩn'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sageGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.sageGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

