import 'package:flutter/material.dart';

/// Họa tiết nền trang trí với các đường cong hữu cơ (Organic Waves)
/// uốn lượn xuyên suốt từ Header, xuyên qua Progress Card và xuyên qua Lưới thời gian (Weekly Grid)
class BackgroundWavePainter extends CustomPainter {
  const BackgroundWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // 1. Lớp nền Gradient ấm áp (Kem đào -> Hồng đào pastel)
    final Paint basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF2EF),
          Color(0xFFFDE4DE),
          Color(0xFFFFF5F2),
        ],
        stops: [0.0, 0.4, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Mảng hữu cơ san hô lớn (Coral Wave) ở góc trên bên phải
    // Bao bọc vùng Avatar, Bell và kéo dài xuống phía sau Progress Card
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
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF9785),
          Color(0xFFFFB1A3),
        ],
      ).createShader(rect);
    canvas.drawPath(waveTopRight, waveTopRightPaint);

    // 3. Dải sóng hữu cơ chuyển tiếp xuyên qua bên dưới Progress Card và chảy vào Lưới thời gian (T3, T4, T5)
    // Đường cong này lộ rõ xuyên qua các ô 06:00 -> 10:00 của cột T4 14 và T5 15
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
        colors: [
          const Color(0xFFFF9C8C).withValues(alpha: 0.85),
          const Color(0xFFFFBBAF).withValues(alpha: 0.70),
          const Color(0xFFFFD8D0).withValues(alpha: 0.55),
        ],
      ).createShader(rect);
    canvas.drawPath(waveGridPenetrate, waveGridPaint);

    // 4. Mảng sóng mềm mại phụ tạo chiều sâu ở giữa bên phải (khoảng mốc 07:00 - 10:00)
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
      ..color = const Color(0xFFFFC0B3).withValues(alpha: 0.40);
    canvas.drawPath(softWave, softWavePaint);

    // 5. Đường cong phụ trang trí nhẹ nhàng bên trái (dưới tiêu đề tháng)
    final Path waveLeft = Path();
    waveLeft.moveTo(0, size.height * 0.14);
    waveLeft.cubicTo(
      size.width * 0.22, size.height * 0.17,
      size.width * 0.18, size.height * 0.27,
      0, size.height * 0.30,
    );
    waveLeft.close();

    final Paint waveLeftPaint = Paint()
      ..color = const Color(0xFFFFDDD5).withValues(alpha: 0.45);
    canvas.drawPath(waveLeft, waveLeftPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
