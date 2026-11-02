import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/hero_3d_illustration.dart';

/// Màn hình Thông tin sản phẩm (About App Screen)
/// Tái hiện chuẩn xác 100% theo ảnh mẫu "ui sample/ui thông tin sản phẩm.png"
class ThongTinSanPhamScreen extends StatelessWidget {
  const ThongTinSanPhamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Header Bar: Nút "< Cài đặt" và Tiêu đề "Thông tin sản phẩm"
            _buildHeader(context),

            // 2. Nội dung cuộn chính
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    // A. Hero Section: Hình 3D pastel + Logo Timass + Slogan + Phiên bản
                    _buildHeroSection(),

                    const SizedBox(height: 16),

                    // B. Card Thông tin dự án & Thành viên
                    _buildProjectInfoCard(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          // Nút "< Cài đặt"
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.darkNavy,
                      size: 26,
                    ),
                    Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Tiêu đề "Thông tin sản phẩm"
          const Expanded(
            child: Text(
              'Thông tin sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Section: Hình 3D pastel + Logo + Slogan
  Widget _buildHeroSection() {
    return Column(
      children: [
        // Minh họa 3D đồng hồ pastel, lịch, đồng hồ cát & bánh răng
        const Hero3DIllustration(size: 155),
        const SizedBox(height: 10),

        // Logo thương hiệu Timass
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon đồng hồ tròn màu tím xanh
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF818CF8),
                    Color(0xFF4F46E5),
                  ],
                  center: Alignment(-0.2, -0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Tên "Timass"
            const Text(
              'Timass',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Slogan
        const Text(
          'Ứng dụng quản lý thời gian & tối ưu hiệu suất',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // Phiên bản
        const Text(
          'Phiên bản: 1.0.0 (MVP)',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Card thông tin dự án & thành viên chuẩn theo ảnh mẫu
  Widget _buildProjectInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Lớp & Nhóm
          _buildTextWithEmoji(
            emoji: '🏫',
            boldPrefix: 'Lớp: ',
            content: 'CSE702027-1-1-26(N02)',
          ),
          const SizedBox(height: 10),
          _buildTextWithEmoji(
            emoji: '👥',
            boldPrefix: 'Nhóm: ',
            content: 'Nhóm 1',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),

          // 2. Thành viên 1: Trịnh Xuân Bắc
          _buildMemberRow(
            name: 'Trịnh Xuân Bắc',
            role: 'Nhà phát triển',
            studentId: '24105823',
          ),

          const SizedBox(height: 14),

          // 3. Thành viên 2: Nguyễn Tiến Vinh
          _buildMemberRow(
            name: 'Nguyễn Tiến Vinh',
            role: 'Nhà phát triển',
            studentId: '24100226',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),

          // 4. Giảng viên hướng dẫn: ThS. Nguyễn Xuân Quế
          _buildTeacherRow(
            name: 'ThS. Nguyễn Xuân Quế',
            role: 'Giảng viên hướng dẫn',
          ),

          const SizedBox(height: 20),

          // 5. Nút "Quay lại Cài đặt" (Sage green)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF769F86), // Chuẩn mã màu Sage green trong ảnh
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Quay lại Cài đặt',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị dòng với Emoji
  Widget _buildTextWithEmoji({
    required String emoji,
    required String boldPrefix,
    required String content,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.darkNavy,
            ),
            children: [
              TextSpan(
                text: boldPrefix,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: content,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dòng thành viên phát triển
  Widget _buildMemberRow({
    required String name,
    required String role,
    required String studentId,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.people_alt_rounded, color: Color(0xFF64748B), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text(
                    'Vai trò: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF769F86),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF769F86),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'MSSV: $studentId',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dòng giảng viên hướng dẫn
  Widget _buildTeacherRow({
    required String name,
    required String role,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🎓', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text(
                    'Vai trò: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
