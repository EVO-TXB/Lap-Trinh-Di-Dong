import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget Logo Timass hiển thị biểu tượng đồng hồ 3D và chữ "Timass"
/// Tái hiện chuẩn xác theo hình ảnh nhận diện thương hiệu từ UI mẫu:
/// - Đồng hồ 3D viền tím pastel/periwinkle bo tròn mềm mại
/// - Mặt đồng hồ trắng kem có 12 chấm giờ đen và kim chỉ ~4 giờ
/// - Vệt sáng hồng đào phản chiếu nhẹ ở góc trên bên phải
/// - Chữ "Timass" màu xanh navy đậm, nét dày hiện đại
class TimassLogo extends StatelessWidget {
  final double height;

  const TimassLogo({
    super.key,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    // Tỷ lệ khung hình của logo gốc xấp xỉ 2.8 : 1 (447 x 160)
    final double width = height * 2.8;

    return SizedBox(
      height: height,
      width: width,
      child: Image.asset(
        'assets/images/timass_logo_transparent.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback sang file jpg gốc nếu có
          return Image.asset(
            'assets/images/timass_logo.jpg',
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context2, error2, stackTrace2) {
              // Fallback an toàn tuyệt đối: Vẽ vector 3D sắc nét bằng CustomPainter
              return _VectorTimassLogo(height: height);
            },
          );
        },
      ),
    );
  }
}

/// Fallback vẽ vector 3D chi tiết trong trường hợp không tải được file asset
class _VectorTimassLogo extends StatelessWidget {
  final double height;

  const _VectorTimassLogo({required this.height});

  @override
  Widget build(BuildContext context) {
    final double clockSize = height * 0.95;
    final double fontSize = height * 0.72;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Đồng hồ 3D
        CustomPaint(
          size: Size(clockSize, clockSize),
          painter: _Clock3DPainter(),
        ),
        SizedBox(width: height * 0.22),
        // Chữ Timass
        Text(
          'Timass',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF040836),
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _Clock3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Bóng đổ 3D bên dưới đồng hồ
    final shadowPaint = Paint()
      ..color = const Color(0x354048B8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(center + const Offset(1.5, 3.5), radius * 0.92, shadowPaint);

    // 2. Vành ngoài 3D màu tím periwinkle
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF757BF8),
          Color(0xFF5B63EA),
          Color(0xFF4249C8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.96, rimPaint);

    // Điểm sáng phản quang trên vành
    final rimHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      -math.pi * 0.85,
      math.pi * 0.75,
      false,
      rimHighlightPaint,
    );

    // 3. Mặt đồng hồ trắng kem
    final dialRadius = radius * 0.76;
    final dialPaint = Paint()..color = const Color(0xFFFAF9FC);
    canvas.drawCircle(center, dialRadius, dialPaint);

    // Vệt sáng hồng đào phản chiếu ở góc trên bên phải
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.4),
        radius: 0.75,
        colors: [
          const Color(0xFFFFB8B0).withOpacity(0.45),
          const Color(0xFFFAF9FC).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: dialRadius));
    canvas.drawCircle(center, dialRadius, glowPaint);

    // 4. 12 Chấm giờ màu đen navy
    final dotPaint = Paint()
      ..color = const Color(0xFF0A0D38)
      ..style = PaintingStyle.fill;
    final dotDistance = dialRadius * 0.76;
    final dotRadius = dialRadius * 0.085;

    for (int i = 0; i < 12; i++) {
      final angle = i * (math.pi / 6) - (math.pi / 2);
      final dotOffset = Offset(
        center.dx + dotDistance * math.cos(angle),
        center.dy + dotDistance * math.sin(angle),
      );
      canvas.drawCircle(dotOffset, dotRadius, dotPaint);
    }

    // 5. Kim đồng hồ (Kim phút chỉ thẳng 12h, kim giờ chỉ ~4h)
    final handPaint = Paint()
      ..color = const Color(0xFF0A0D38)
      ..strokeCap = StrokeCap.round;

    // Kim phút (12 giờ)
    handPaint.strokeWidth = dialRadius * 0.16;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - dialRadius * 0.65),
      handPaint,
    );

    // Kim giờ (khoảng 4 giờ, góc ~ 35 độ dưới phương ngang)
    handPaint.strokeWidth = dialRadius * 0.18;
    const hourAngle = 35 * (math.pi / 180);
    canvas.drawLine(
      center,
      Offset(
        center.dx + dialRadius * 0.48 * math.cos(hourAngle),
        center.dy + dialRadius * 0.48 * math.sin(hourAngle),
      ),
      handPaint,
    );

    // Chốt trục kim ở giữa
    canvas.drawCircle(center, dialRadius * 0.14, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

