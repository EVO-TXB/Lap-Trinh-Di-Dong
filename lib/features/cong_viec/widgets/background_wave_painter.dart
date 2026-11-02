import 'package:flutter/material.dart';

/// Họa tiết nền trang trí với các đường cong hữu cơ (Organic Waves)
/// uốn lượn xuyên suốt từ Header, xuyên qua Progress Card và xuyên qua Lưới thời gian (Weekly Grid)
/// Hỗ trợ thích ứng màu sắc Dark Mode & Light Mode
class BackgroundWavePainter extends CustomPainter {
  final bool isDark;

  const BackgroundWavePainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // 1. Lớp nền Gradient: Sáng (Kem đào) / Tối (Dark Slate)
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ]
            : const [
                Color(0xFFFFF2EF),
                Color(0xFFFDE4DE),
                Color(0xFFFFF5F2),
              ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Mảng hữu cơ lớn ở góc trên bên phải
    final Path waveTopRight = Path();
    waveTopRight.moveTo(size.width * 0.45, 0);
    waveTopRight.cubicTo(
      size.width * 0.60, size.height * 0.04,
      size.width * 0.92, size.height * 0.05,
      size.width * 0.88, size.height * 0.16,
    );
    waveTopRight.cubicTo(
      size.width * 0.84, size.height * 0.24,
      size.width * 0.98, size.height * 0.28,
      size.width, size.height * 0.22,
    );
    waveTopRight.lineTo(size.width, 0);
    waveTopRight.close();

    final Paint waveTopRightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [
                Color(0xFF1E293B),
                Color(0xFF334155),
              ]
            : const [
                Color(0xFFFF9785),
                Color(0xFFFFB1A3),
              ],
      ).createShader(rect);
    canvas.drawPath(waveTopRight, waveTopRightPaint);

    // 3. Dải sóng hữu cơ chuyển tiếp
    final Path waveGridPenetrate = Path();
    waveGridPenetrate.moveTo(size.width * 0.48, size.height * 0.26);
    waveGridPenetrate.cubicTo(
      size.width * 0.68, size.height * 0.29,
      size.width * 0.95, size.height * 0.28,
      size.width, size.height * 0.33,
    );
    waveGridPenetrate.lineTo(size.width, size.height * 0.52);
    waveGridPenetrate.cubicTo(
      size.width * 0.82, size.height * 0.48,
      size.width * 0.60, size.height * 0.52,
      size.width * 0.52, size.height * 0.42,
    );
    waveGridPenetrate.cubicTo(
      size.width * 0.44, size.height * 0.33,
      size.width * 0.35, size.height * 0.24,
      size.width * 0.48, size.height * 0.26,
    );
    waveGridPenetrate.close();

    final Paint waveGridPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: isDark
            ? [
                const Color(0xFF334155).withValues(alpha: 0.50),
                const Color(0xFF1E293B).withValues(alpha: 0.40),
                const Color(0xFF0F172A).withValues(alpha: 0.30),
              ]
            : [
                const Color(0xFFFF9C8C).withValues(alpha: 0.85),
                const Color(0xFFFFBBAF).withValues(alpha: 0.70),
                const Color(0xFFFFD8D0).withValues(alpha: 0.55),
              ],
      ).createShader(rect);
    canvas.drawPath(waveGridPenetrate, waveGridPaint);

    // 4. Mảng sóng mềm mại phụ
    final Path softWave = Path();
    softWave.moveTo(size.width * 0.55, size.height * 0.36);
    softWave.cubicTo(
      size.width * 0.72, size.height * 0.35,
      size.width * 0.92, size.height * 0.42,
      size.width * 0.90, size.height * 0.50,
    );
    softWave.cubicTo(
      size.width * 0.82, size.height * 0.56,
      size.width * 0.62, size.height * 0.48,
      size.width * 0.55, size.height * 0.36,
    );
    softWave.close();

    final Paint softWavePaint = Paint()
      ..color = isDark
          ? const Color(0xFF334155).withValues(alpha: 0.30)
          : const Color(0xFFFFC0B3).withValues(alpha: 0.40);
    canvas.drawPath(softWave, softWavePaint);

    // 5. Đường cong phụ trang trí bên trái
    final Path waveLeft = Path();
    waveLeft.moveTo(0, size.height * 0.14);
    waveLeft.cubicTo(
      size.width * 0.22, size.height * 0.17,
      size.width * 0.18, size.height * 0.27,
      0, size.height * 0.30,
    );
    waveLeft.close();

    final Paint waveLeftPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.35)
          : const Color(0xFFFFDDD5).withValues(alpha: 0.45);
    canvas.drawPath(waveLeft, waveLeftPaint);
  }

  @override
  bool shouldRepaint(covariant BackgroundWavePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
