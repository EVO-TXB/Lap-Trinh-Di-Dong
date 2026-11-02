import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../../cong_viec/models/cong_viec_model.dart';

/// Bong bóng thông báo nổi kéo thả phong cách Messenger (Chat Head Bubble)
class ChatHeadBubbleWidget extends StatefulWidget {
  final List<CongViecModel> danhSachCongViec;
  final Function(CongViecModel congViec)? onXemChiTiet;
  final Function(CongViecModel congViec)? onHoanBao;
  final VoidCallback? onDongBongBong;

  const ChatHeadBubbleWidget({
    super.key,
    required this.danhSachCongViec,
    this.onXemChiTiet,
    this.onHoanBao,
    this.onDongBongBong,
  });

  @override
  State<ChatHeadBubbleWidget> createState() => _ChatHeadBubbleWidgetState();
}

class _ChatHeadBubbleWidgetState extends State<ChatHeadBubbleWidget>
    with TickerProviderStateMixin {
  // Tọa độ vị trí của bong bóng
  Offset _viTri = const Offset(20, 160);
  bool _dangKeo = false;
  bool _dangMoHopThoai = false;
  bool _hienThiTooltip = true;
  Timer? _tooltipTimer;

  // Animation controller cho hiệu ứng nảy (Pulse/Bounce)
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tự động thu gọn tooltip sau 4.5 giây
    _tooltipTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        setState(() => _hienThiTooltip = false);
      }
    });
  }

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _snapToEdge(Size screenSize) {
    const double bubbleSize = 58;
    const double margin = 16;
    final double midX = screenSize.width / 2;

    double targetX = _viTri.dx < midX ? margin : screenSize.width - bubbleSize - margin;
    double targetY = _viTri.dy.clamp(80.0, screenSize.height - 120.0);

    setState(() {
      _viTri = Offset(targetX, targetY);
      _dangKeo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.danhSachCongViec.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final congViecMoiNhat = widget.danhSachCongViec.first;
    final bool isLeft = _viTri.dx < screenSize.width / 2;

    return Stack(
      children: [
        // 1. Vùng hủy dưới đáy khi đang kéo (Drop zone 'X' giống Messenger)
        if (_dangKeo)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),

        // 2. Bong bóng nổi chính (Draggable Chat Head)
        Positioned(
          left: _viTri.dx,
          top: _viTri.dy,
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _dangKeo = true;
                _hienThiTooltip = false;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _viTri += details.delta;
              });
            },
            onPanEnd: (details) {
              // Nếu thả gần đáy màn hình -> Đóng bong bóng
              if (_viTri.dy > screenSize.height - 130) {
                widget.onDongBongBong?.call();
              } else {
                _snapToEdge(screenSize);
              }
            },
            onTap: () {
              setState(() {
                _dangMoHopThoai = !_dangMoHopThoai;
                _hienThiTooltip = false;
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // A. Tooltip lời thoại trượt ra bên cạnh (Speech bubble preview)
                if (_hienThiTooltip && !_dangMoHopThoai)
                  Positioned(
                    left: isLeft ? 64 : null,
                    right: !isLeft ? 64 : null,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 210),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.alarm_on_rounded, size: 13, color: Color(0xFFEF4444)),
                              const SizedBox(width: 4),
                              Text(
                                'Sắp đến giờ (${widget.danhSachCongViec.length})',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            congViecMoiNhat.tenCongViec,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                // B. Quả bóng Avatar tròn Messenger (Chat Head Circle)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF9E94), Color(0xFFE85950)],
                        center: Alignment(-0.25, -0.25),
                      ),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE85950).withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.alarm_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                // C. Badge đếm số lượng thông báo (Huy hiệu đỏ)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.danhSachCongViec.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Cửa sổ Mini Flyout Popup khi bấm vào bong bóng
        if (_dangMoHopThoai)
          _buildMiniFlyoutPopup(screenSize, congViecMoiNhat, isLeft),
      ],
    );
  }

  /// Cửa sổ Popup bung ra từ bong bóng (Messenger Chat Flyout)
  Widget _buildMiniFlyoutPopup(Size screenSize, CongViecModel congViec, bool isLeft) {
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }
    final double cardWidth = 300;
    double left = isLeft ? _viTri.dx + 65 : _viTri.dx - cardWidth - 8;
    double top = _viTri.dy - 10;

    // Đảm bảo không tràn màn hình
    if (left + cardWidth > screenSize.width) {
      left = screenSize.width - cardWidth - 16;
    }
    if (left < 16) left = 16;
    if (top + 220 > screenSize.height) {
      top = screenSize.height - 230;
    }

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Flyout
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.sageGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      settings?.tr('reminder_upcoming') ?? 'Nhắc nhở Timass',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () => setState(() => _dangMoHopThoai = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Divider(height: 16),

              // Thông tin công việc
              Text(
                congViec.tenCongViec,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '${_dinhDangGio(congViec.thoiGianBatDau)} - ${_dinhDangGio(congViec.thoiGianKetThuc)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  if ((congViec.diaDiem ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        congViec.diaDiem ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // Các nút hành động
              Row(
                children: [
                  // Nút Hoãn 5 phút
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _dangMoHopThoai = false);
                        widget.onHoanBao?.call(congViec);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(settings?.tr('snooze_5m') ?? 'Hoãn 5p', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Nút Xem chi tiết
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _dangMoHopThoai = false);
                        widget.onXemChiTiet?.call(congViec);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(settings?.tr('view_now_btn') ?? 'Xem ngay', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dinhDangGio(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
