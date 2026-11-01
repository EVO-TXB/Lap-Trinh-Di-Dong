import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'timass_logo.dart';

class AuthHeaderIllustration extends StatelessWidget {
  final double height;

  const AuthHeaderIllustration({
    super.key,
    this.height = 275.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.peachBackground,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng tròn điểm nhấn màu san hô nền phía sau bên phải
          Positioned(
            right: -30,
            top: 45,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9E94).withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Vòng tròn phụ bên dưới
          Positioned(
            left: -20,
            bottom: 30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDFDC).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Nội dung trung tâm: Logo Timass + Đồng hồ 3D + Lịch + Đồng hồ cát
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo Timass ở trên cùng (Đồng hồ 3D + Chữ Timass chuẩn nhận diện)
                const TimassLogo(height: 52.0),
                const SizedBox(height: 14.0),

                // 2. Cụm Minh họa 3D: Đồng hồ pastel + Lịch + Đồng hồ cát + Bánh răng + Ngôi sao
                SizedBox(
                  width: 230,
                  height: 145,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Bánh răng tím pastel bên trái
                      Positioned(
                        left: 10,
                        top: 25,
                        child: Icon(
                          Icons.settings_suggest_rounded,
                          size: 34,
                          color: const Color(0xFFA5B4FC).withOpacity(0.85),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 25,
                        child: Icon(
                          Icons.settings_rounded,
                          size: 28,
                          color: const Color(0xFFC7D2FE).withOpacity(0.9),
                        ),
                      ),

                      // Ngôi sao lấp lánh (Sparkles)
                      Positioned(
                        left: 38,
                        top: 5,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: const Color(0xFFF59E0B).withOpacity(0.9),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 12,
                        child: Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: const Color(0xFFFBBF24).withOpacity(0.95),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 75,
                        child: Icon(
                          Icons.diamond_rounded,
                          size: 14,
                          color: const Color(0xFFFF8A80).withOpacity(0.9),
                        ),
                      ),

                      // Đồng hồ 3D Pastel trung tâm (Claymorphism Style)
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF9E94),
                              Color(0xFFFF7A70),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7A70).withOpacity(0.4),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Center(
                          // Mặt đồng hồ trắng
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Các vạch chỉ giờ
                                ...List.generate(12, (i) {
                                  final double angle = i * (3.141592653589793 * 2 / 12);
                                  return Transform.rotate(
                                    angle: angle,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 2.5,
                                        height: 5,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: i % 3 == 0 ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Kim giờ (màu tím xanh chỉ hướng 10h)
                                Transform.rotate(
                                  angle: -0.9,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 4,
                                      height: 26,
                                      margin: const EdgeInsets.only(bottom: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F46E5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),

                                // Kim phút (màu san hô chỉ hướng 2h)
                                Transform.rotate(
                                  angle: 0.8,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 3,
                                      height: 34,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),

                                // Tâm đồng hồ
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Tờ Lịch 3D bay bổng phía trên bên phải
                      Positioned(
                        top: 2,
                        right: 28,
                        child: Transform.rotate(
                          angle: 0.12,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Thanh đỏ đầu lịch
                                Container(
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                    ],
                                  ),
                                ),
                                // Các chấm sự kiện màu sắc
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildDot(const Color(0xFF38BDF8)),
                                          _buildDot(const Color(0xFF34D399)),
                                          _buildDot(const Color(0xFFFBBF24)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildDot(const Color(0xFFF472B6)),
                                          _buildDot(const Color(0xFF818CF8)),
                                          _buildDot(const Color(0xFFA78BFA)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Đồng hồ cát 3D phía dưới bên phải
                      Positioned(
                        bottom: 0,
                        right: 32,
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Container(
                            width: 40,
                            height: 52,
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF818CF8),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 3, width: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFDE68A), size: 28),
                                Container(height: 3, width: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
