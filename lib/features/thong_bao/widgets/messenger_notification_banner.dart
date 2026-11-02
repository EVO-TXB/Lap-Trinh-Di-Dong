import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../../cong_viec/models/cong_viec_model.dart';

/// Thông báo dạng Banner trượt từ đỉnh màn hình phong cách Messenger / iOS
/// (Heads-up Notification Banner)
class MessengerNotificationBanner extends StatefulWidget {
  final CongViecModel congViec;
  final VoidCallback? onXemChiTiet;
  final VoidCallback? onHoanBao;
  final VoidCallback? onDong;
  final Duration thoiGianHienThi;

  const MessengerNotificationBanner({
    super.key,
    required this.congViec,
    this.onXemChiTiet,
    this.onHoanBao,
    this.onDong,
    this.thoiGianHienThi = const Duration(seconds: 5),
  });

  static OverlayEntry? _activeEntry;

  /// Phương thức hiển thị nhanh Banner từ bất kỳ đâu thông qua Overlay
  static OverlayEntry? show(
    BuildContext context, {
    required CongViecModel congViec,
    VoidCallback? onXemChiTiet,
    VoidCallback? onHoanBao,
    VoidCallback? onDong,
    Duration thoiGianHienThi = const Duration(seconds: 5),
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return null;

    // Loại bỏ banner cũ đang hiển thị để tránh đè chéo
    try {
      _activeEntry?.remove();
    } catch (_) {}
    _activeEntry = null;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (ctx) => MessengerNotificationBanner(
        congViec: congViec,
        thoiGianHienThi: thoiGianHienThi,
        onXemChiTiet: () {
          try { entry?.remove(); } catch (_) {}
          if (_activeEntry == entry) _activeEntry = null;
          onXemChiTiet?.call();
        },
        onHoanBao: () {
          try { entry?.remove(); } catch (_) {}
          if (_activeEntry == entry) _activeEntry = null;
          onHoanBao?.call();
        },
        onDong: () {
          try { entry?.remove(); } catch (_) {}
          if (_activeEntry == entry) _activeEntry = null;
          onDong?.call();
        },
      ),
    );

    _activeEntry = entry;
    overlayState.insert(entry);
    return entry;
  }

  @override
  State<MessengerNotificationBanner> createState() => _MessengerNotificationBannerState();
}

class _MessengerNotificationBannerState extends State<MessengerNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _tuDongAnTimer;
  double _dragOffsetY = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 280),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    // Rung nhẹ phản hồi xúc giác cao cấp
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // Kích hoạt animation trượt xuống
    _animController.forward();

    // Hẹn giờ tự động ẩn
    _tuDongAnTimer = Timer(widget.thoiGianHienThi, () {
      _dongBanner();
    });
  }

  @override
  void dispose() {
    _tuDongAnTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _dongBanner() async {
    _tuDongAnTimer?.cancel();
    if (!mounted) return;
    await _animController.reverse();
    widget.onDong?.call();
  }

  @override
  Widget build(BuildContext context) {
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }
    final String timeStr = _dinhDangGio(widget.congViec.thoiGianBatDau);
    final String startsAtStr = settings?.tr('starts_at', params: {'time': timeStr}) ?? 'Bắt đầu lúc $timeStr';
    final String locStr = (widget.congViec.diaDiem ?? '').isNotEmpty
        ? (settings?.tr('at_location', params: {'loc': widget.congViec.diaDiem!}) ?? ' tại ${widget.congViec.diaDiem}')
        : '';
    final String subtitleText = '$startsAtStr$locStr';

    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;
    final double bannerWidth = screenWidth > 500 ? 460 : screenWidth - 28;

    return Positioned(
      top: topPadding + 10 + _dragOffsetY,
      left: (screenWidth - bannerWidth) / 2,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          // Vuốt lên trên để tắt thông báo nhanh
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! < 0) {
              setState(() {
                _dragOffsetY += details.primaryDelta!;
              });
            }
          },
          onVerticalDragEnd: (details) {
            if (_dragOffsetY < -20 || (details.primaryVelocity != null && details.primaryVelocity! < -200)) {
              _dongBanner();
            } else {
              setState(() {
                _dragOffsetY = 0;
              });
            }
          },
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                width: bannerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.sageGreen.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thanh gạt kéo nhẹ ở đỉnh (Messenger drag handle)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Header dòng nhỏ: [Icon Timass] TIMASS • NHẮC NHỞ • Vừa xong
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 13),
                              ),
                              const SizedBox(width: 7),
                              const Text(
                                'TIMASS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                settings?.tr('reminder_tag') ?? ' • NHẮC NHỞ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                settings?.tr('just_now') ?? 'Vừa xong',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: _dongBanner,
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 2. Nội dung chính: Icon chuông 3D nổi bật + Tên công việc + Thời gian
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar chuông báo thức 3D tròn phong cách Messenger
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [Color(0xFFFF9E94), Color(0xFFE85950)],
                                    center: Alignment(-0.2, -0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE85950).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.alarm_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Tên sự kiện & Giờ/Địa điểm
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.congViec.tenCongViec,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkNavy,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitleText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // 3. Thanh hành động nhanh (Quick Action Buttons)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Nút Hoãn 5 phút
                              OutlinedButton.icon(
                                onPressed: () {
                                  _tuDongAnTimer?.cancel();
                                  widget.onHoanBao?.call();
                                  _animController.reverse();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.snooze_rounded, size: 15),
                                label: Text(
                                  settings?.tr('snooze_5m') ?? 'Hoãn 5p',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Nút Xem chi tiết
                              ElevatedButton.icon(
                                onPressed: () {
                                  _tuDongAnTimer?.cancel();
                                  widget.onXemChiTiet?.call();
                                  _animController.reverse();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sageGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                                label: Text(
                                  settings?.tr('view_now_btn') ?? 'Xem ngay',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
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
