import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget vẽ minh họa 3D Pastel: Đồng hồ tròn, lịch pastel, đồng hồ cát & bánh răng
/// Tái hiện chuẩn xác hình minh họa Hero trong "ui thông tin sản phẩm.png"
class Hero3DIllustration extends StatelessWidget {
  final double size;

  const Hero3DIllustration({super.key, this.size = 170});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Tia sáng & Ngôi sao lấp lánh (Sparkles)
          Positioned(
            left: size * 0.12,
            top: size * 0.35,
            child: _buildSparkle(const Color(0xFFFF6584), 16),
          ),
          Positioned(
            right: size * 0.08,
            top: size * 0.40,
            child: _buildSparkle(const Color(0xFFC084FC), 14),
          ),
          Positioned(
            left: size * 0.32,
            top: size * 0.12,
            child: _buildSparkle(const Color(0xFFFDE047), 12),
          ),
          Positioned(
            right: size * 0.28,
            top: size * 0.10,
            child: _buildSparkle(const Color(0xFF67E8F9), 10),
          ),

          // 2. Bánh răng màu tím pastel phía sau bên trái
          Positioned(
            left: size * 0.06,
            top: size * 0.26,
            child: _buildGear(const Color(0xFFB8A9E8), 38),
          ),
          Positioned(
            left: size * 0.08,
            bottom: size * 0.15,
            child: _buildGear(const Color(0xFF8B7CD8), 44),
          ),
          Positioned(
            left: size * 0.22,
            bottom: size * 0.05,
            child: _buildGear(const Color(0xFF7060C4), 32),
          ),

          // 3. Quyển Lịch pastel góc trên bên phải
          Positioned(
            right: size * 0.14,
            top: size * 0.10,
            child: _buildCalendar(size * 0.48),
          ),

          // 4. Quả đồng hồ 3D màu hồng/cam pastel trung tâm
          Positioned(
            left: size * 0.15,
            top: size * 0.22,
            child: _buildClock(size * 0.58),
          ),

          // 5. Đồng hồ cát 3D phía trước góc dưới bên phải
          Positioned(
            right: size * 0.10,
            bottom: size * 0.08,
            child: _buildHourglass(size * 0.34),
          ),
        ],
      ),
    );
  }

  /// Vẽ đồng hồ tròn 3D
  Widget _buildClock(double d) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFF9E94),
            Color(0xFFFF7B72),
            Color(0xFFE85950),
          ],
          center: Alignment(-0.2, -0.2),
          radius: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85950).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(-2, -3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: d * 0.74,
          height: d * 0.74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFF7F6),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vạch số 12, 3, 6, 9
              for (int i = 0; i < 12; i++)
                Transform.rotate(
                  angle: i * math.pi / 6,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: i % 3 == 0 ? 3 : 1.5,
                      height: i % 3 == 0 ? 6 : 4,
                      decoration: BoxDecoration(
                        color: i % 3 == 0 ? const Color(0xFF6B7280) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

              // Kim giờ
              Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 3.5,
                  height: d * 0.22,
                  margin: EdgeInsets.only(bottom: d * 0.11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5998),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Kim phút
              Transform.rotate(
                angle: math.pi / 6,
                child: Container(
                  width: 2.5,
                  height: d * 0.28,
                  margin: EdgeInsets.only(bottom: d * 0.14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Trục tâm đồng hồ
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE85950),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Vẽ quyển Lịch pastel
  Widget _buildCalendar(double width) {
    return Transform.rotate(
      angle: 0.12,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gáy lịch màu cam san hô
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6E65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Lưới các ô ngày chấm màu pastel
            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: [
                for (int i = 0; i < 8; i++)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i % 3 == 0
                          ? const Color(0xFF67E8F9)
                          : (i % 2 == 0 ? const Color(0xFFF472B6) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Vẽ đồng hồ cát 3D
  Widget _buildHourglass(double h) {
    return Transform.rotate(
      angle: -0.22,
      child: Container(
        width: h * 0.58,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Khung thủy tinh và cát bên trong
            Column(
              children: [
                // Đế trên màu tím
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E22CE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Phần tam giác trên
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                // Phần tam giác dưới
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                // Đế dưới màu tím
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E22CE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Vẽ bánh răng
  Widget _buildGear(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.85),
      ),
      child: Center(
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF8FAFC),
          ),
        ),
      ),
    );
  }

  /// Vẽ ngôi sao lấp lánh (4 cánh)
  Widget _buildSparkle(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
          Container(
            width: size * 0.28,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ],
      ),
    );
  }
}

