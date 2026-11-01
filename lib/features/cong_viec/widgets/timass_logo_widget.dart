import 'dart:math';
import 'package:flutter/material.dart';

/// Widget Logo Timass được tái hiện chính xác 100% theo ảnh chi tiết:
/// - Đồng hồ 3D vành bo tròn với hiệu ứng khối (3D Bevel Rim)
/// - Mảng màu cam san hô (Active Time Sector) góc 12h - 4h
/// - 12 chấm mốc giờ và 2 kim chỉ đúng vị trí ~04:00
/// - Chữ "Timass" màu xanh đen bóng đậm (Midnight Navy)
class TimassLogoWidget extends StatelessWidget {
  final double size;
  final double fontSize;

  const TimassLogoWidget({
    super.key,
    this.size = 36.0,
    this.fontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Biểu tượng Đồng hồ 3D
        SizedBox(
          width: size,
          height: size,
          child: const CustomPaint(
            painter: TimassLogoClockPainter(),
          ),
        ),
        const SizedBox(width: 9),

        // Tên thương hiệu "Timass"
        Text(
          'Timass',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F0C3D), // Màu xanh đen đậm đúng như ảnh mẫu
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter vẽ biểu tượng đồng hồ 3D đặc trưng của Timass
class TimassLogoClockPainter extends CustomPainter {
  const TimassLogoClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // 1. Bóng đổ mềm dưới đáy đồng hồ tạo độ nổi (Soft 3D shadow)
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center.translate(0, 1.8), radius: radius));
    canvas.drawShadow(
      shadowPath,
      const Color(0xFF222060).withValues(alpha: 0.38),
      3.5,
      true,
    );

    // 2. Vành tròn 3D kim loại bo dày (3D Torus Bezel)
    final Rect rimRect = Rect.fromCircle(center: center, radius: radius);
    final Paint rimPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6F72F2), // Màu tím xanh sáng phản quang ở góc trên trái
          Color(0xFF5356D8),
          Color(0xFF383BA8), // Đậm dần ở góc dưới phải tạo chiều sâu 3D
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rimRect);
    canvas.drawCircle(center, radius, rimPaint);

    // 3. Mặt số bên trong (Inner Dial Face)
    final double innerRadius = radius * 0.75;
    final Rect dialRect = Rect.fromCircle(center: center, radius: innerRadius);

    final Paint dialPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.85,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF3F1FA),
          Color(0xFFE8E5F6),
        ],
      ).createShader(dialRect);
    canvas.drawCircle(center, innerRadius, dialPaint);

    // 4. Mảng rẻ quạt màu cam san hô (Active Time Sector) từ góc 12 giờ đến 4 giờ
    canvas.save();
    final Path clipDial = Path()..addOval(dialRect);
    canvas.clipPath(clipDial);

    final Paint sectorPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          const Color(0xFFFF8676).withValues(alpha: 0.50),
          const Color(0xFFFF9E90).withValues(alpha: 0.38),
          const Color(0xFFFFC7BF).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 0.85, 1.0],
      ).createShader(dialRect);

    // Vẽ góc quạt từ -90° (12 giờ) quét một góc ~120° (đến vị trí 4 giờ)
    final Path sectorPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(dialRect, -pi / 2, 2 * pi * (4 / 12), false)
      ..close();
    canvas.drawPath(sectorPath, sectorPaint);
    canvas.restore();

    // 5. 12 dấu chấm mốc giờ (12 Hour Dots)
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF4C4DBF)
      ..style = PaintingStyle.fill;

    final double dotRadiusDist = innerRadius * 0.74;
    for (int i = 0; i < 12; i++) {
      final double angle = -pi / 2 + i * (2 * pi / 12);
      final Offset dotPos = Offset(
        center.dx + dotRadiusDist * cos(angle),
        center.dy + dotRadiusDist * sin(angle),
      );
      // Mốc 12h, 3h, 6h, 9h hơi lớn hơn một chút
      final double dotSize = (i % 3 == 0) ? 1.25 : 0.95;
      canvas.drawCircle(dotPos, dotSize, dotPaint);
    }

    // 6. Hai kim đồng hồ (Clock Hands)
    final Paint handPaint = Paint()
      ..color = const Color(0xFF4345B8)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Kim phút: chỉ hướng 12 giờ thẳng đứng
    handPaint.strokeWidth = 2.4;
    final Offset minuteHandEnd = Offset(
      center.dx,
      center.dy - innerRadius * 0.58,
    );
    canvas.drawLine(center, minuteHandEnd, handPaint);

    // Kim giờ: chỉ hướng 4 giờ (~125° tính từ 12h)
    handPaint.strokeWidth = 2.4;
    final double hourAngle = -pi / 2 + (4.15 * (2 * pi / 12));
    final Offset hourHandEnd = Offset(
      center.dx + innerRadius * 0.43 * cos(hourAngle),
      center.dy + innerRadius * 0.43 * sin(hourAngle),
    );
    canvas.drawLine(center, hourHandEnd, handPaint);

    // Điểm trục tâm kim (Center Pin)
    final Paint centerPinPaint = Paint()
      ..color = const Color(0xFF383BA8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
