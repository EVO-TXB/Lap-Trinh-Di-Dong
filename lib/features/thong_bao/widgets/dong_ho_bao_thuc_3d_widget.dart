import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget minh họa Đồng hồ báo thức 3D Pastel tông cam/vàng cam
/// Tái hiện chính xác theo ảnh mẫu `ui sample/ui thông báo.png`:
/// - Thân đồng hồ tròn 3D claymorphism màu cam/vàng cam ấm áp
/// - 2 chuông vòm phía trên cùng búa gõ và chân đế đứng
/// - Mặt số trắng kem chỉ 07:30 với các vạch giờ sắc nét
/// - Hiệu ứng tia sóng âm thanh phát ra biểu thị chuông đang reo
class DongHoBaoThuc3DWidget extends StatefulWidget {
  final double size;
  final bool animate;

  const DongHoBaoThuc3DWidget({
    super.key,
    this.size = 110.0,
    this.animate = true,
  });

  @override
  State<DongHoBaoThuc3DWidget> createState() => _DongHoBaoThuc3DWidgetState();
}

class _DongHoBaoThuc3DWidgetState extends State<DongHoBaoThuc3DWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lacAnimation;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng rung lắc chuông báo thức nhẹ nhàng
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }

    _lacAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lacAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.animate ? _lacAnimation.value : 0.0,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hình ảnh asset đã trích xuất từ UI mẫu nếu khả dụng
                Image.asset(
                  'assets/images/alarm_clock_hd.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback tự động vẽ vector 3D chi tiết
                    return CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _AlarmClock3DPainter(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlarmClock3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.04);
    final radius = size.width * 0.36;

    // 1. Chân đế đồng hồ bên dưới (2 chân nghiêng màu kim loại ấm)
    final footPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = radius * 0.18
      ..strokeCap = StrokeCap.round;

    final leftFootStart = center + Offset(-radius * 0.65, radius * 0.65);
    final leftFootEnd = center + Offset(-radius * 0.95, radius * 1.05);
    canvas.drawLine(leftFootStart, leftFootEnd, footPaint);

    final rightFootStart = center + Offset(radius * 0.65, radius * 0.65);
    final rightFootEnd = center + Offset(radius * 0.95, radius * 1.05);
    canvas.drawLine(rightFootStart, rightFootEnd, footPaint);

    // 2. Hai quả chuông vòm phía trên bên trái & phải
    final bellPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFCC80), Color(0xFFFF9800), Color(0xFFE65100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final bellRadius = radius * 0.36;
    final leftBellCenter = center + Offset(-radius * 0.76, -radius * 0.72);
    canvas.drawCircle(leftBellCenter, bellRadius, bellPaint);

    final rightBellCenter = center + Offset(radius * 0.76, -radius * 0.72);
    canvas.drawCircle(rightBellCenter, bellRadius, bellPaint);

    // Búa gõ ở giữa hai chuông
    final hammerPaint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = radius * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + Offset(0, -radius * 0.8),
      center + Offset(0, -radius * 1.08),
      hammerPaint,
    );
    canvas.drawCircle(center + Offset(0, -radius * 1.12), radius * 0.1, bellPaint);

    // 3. Bóng đổ 3D bên dưới thân đồng hồ
    final shadowPaint = Paint()
      ..color = const Color(0x30E65100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(center + const Offset(0, 6), radius * 1.02, shadowPaint);

    // 4. Vành ngoài thân đồng hồ màu cam pastel 3D
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          Color(0xFFFFB74D), // Cam sáng nổi
          Color(0xFFFF8A65), // Cam san hô
          Color(0xFFF4511E), // Cam đậm bóng
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    // Điểm sáng phản quang trên viền (Specular Highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      highlightPaint,
    );

    // 5. Mặt đồng hồ trắng kem
    final dialRadius = radius * 0.75;
    final dialPaint = Paint()..color = const Color(0xFFFAFAFC);
    canvas.drawCircle(center, dialRadius, dialPaint);

    // 6. Các vạch chỉ giờ (12, 3, 6, 9)
    final tickPaint = Paint()
      ..color = const Color(0xFF424242)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final double angle = i * (math.pi / 6) - (math.pi / 2);
      final double outerR = dialRadius * 0.88;
      final double innerR = (i % 3 == 0) ? dialRadius * 0.68 : dialRadius * 0.78;
      final p1 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));
      final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 7. Kim đồng hồ chỉ 07:30
    final handPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeCap = StrokeCap.round;

    // Kim phút chỉ số 6 (thẳng xuống dưới)
    handPaint.strokeWidth = dialRadius * 0.12;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + dialRadius * 0.62),
      handPaint,
    );

    // Kim giờ chỉ khoảng giữa số 7 và 8 (~ 225 độ)
    handPaint.strokeWidth = dialRadius * 0.16;
    const double hourAngle = 125 * (math.pi / 180);
    canvas.drawLine(
      center,
      Offset(
        center.dx - dialRadius * 0.45 * math.cos(hourAngle - math.pi / 2),
        center.dy - dialRadius * 0.45 * math.sin(hourAngle - math.pi / 2),
      ),
      handPaint,
    );

    // Kim giây màu đỏ cam
    final secondPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + dialRadius * 0.58, center.dy - dialRadius * 0.2),
      secondPaint,
    );

    // Chốt trục kim ở trung tâm
    final centerPinPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(center, dialRadius * 0.1, centerPinPaint);

    // 8. Tia sóng âm thanh phát ra biểu thị chuông reo (Sound Waves)
    final soundWavePaint = Paint()
      ..color = const Color(0xFFFFB74D).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Sóng bên trái
    canvas.drawArc(
      Rect.fromCircle(center: leftBellCenter, radius: bellRadius * 1.5),
      math.pi * 0.8,
      math.pi * 0.6,
      false,
      soundWavePaint,
    );

    // Sóng bên phải
    canvas.drawArc(
      Rect.fromCircle(center: rightBellCenter, radius: bellRadius * 1.5),
      -math.pi * 0.4,
      math.pi * 0.6,
      false,
      soundWavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
