import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/schedule_controller.dart';
import '../models/cong_viec_model.dart';
import 'event_card_widget.dart';
import 'event_detail_dialog.dart';

/// Lưới thời gian Lịch Tuần (Weekly Time Grid):
/// - Nền bán trong suốt để các họa tiết hữu cơ bên dưới xuyên qua
/// - Cột mốc giờ bên trái (06:00 -> 22:00)
/// - 7 cột thứ trong tuần: T2 12, T3 13... (hoặc Mon 12, Tue 13...)
/// - Vạch ngang màu đỏ tươi hiển thị GIỜ HIỆN TẠI kèm badge đỏ
/// - Hỗ trợ Dark Mode và Đa ngôn ngữ (Tiếng Việt / English)
class WeeklyGridWidget extends StatefulWidget {
  final ScheduleController controller;
  final bool isDark;
  final String ngonNgu;

  const WeeklyGridWidget({
    super.key,
    required this.controller,
    this.isDark = false,
    this.ngonNgu = 'Tiếng Việt',
  });

  @override
  State<WeeklyGridWidget> createState() => _WeeklyGridWidgetState();
}

class _WeeklyGridWidgetState extends State<WeeklyGridWidget> {
  late final ScrollController _horizontalHeaderController;
  late final ScrollController _horizontalBodyController;
  late final ScrollController _verticalScrollController;

  static const double timeColumnWidth = 52.0;
  static const double dayColumnWidth = 82.0;

  @override
  void initState() {
    super.initState();
    _horizontalHeaderController = ScrollController();
    _horizontalBodyController = ScrollController();
    _verticalScrollController = ScrollController();

    // Đồng bộ cuộn ngang giữa Header các thứ và Thân lưới thời gian
    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.hasClients &&
          _horizontalHeaderController.offset != _horizontalBodyController.offset) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });

    // Tự động cuộn đến gần vạch đỏ sau khi dựng xong giao diện
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verticalScrollController.hasClients) {
        final double targetOffset = (7.5 - ScheduleController.startHour) * ScheduleController.hourHeight;
        _verticalScrollController.animateTo(
          targetOffset.clamp(0.0, _verticalScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalHours = ScheduleController.endHour - ScheduleController.startHour;
    final double totalGridHeight = totalHours * ScheduleController.hourHeight;

    // Danh sách 7 ngày trong tuần
    final List<DateTime> cacNgayTrongTuan = List.generate(7, (index) {
      return widget.controller.ngayDauTuan.add(Duration(days: index));
    });

    final double redLineTop = widget.controller.calculateRedLineTop();
    final String redLineTimeText = DateFormat('HH:mm').format(widget.controller.thoiGianThuc);

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        // Nền màu bán trong suốt thích ứng Light / Dark Mode
        color: widget.isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 1. DÒNG HEADER: Cột trống + 7 Cột Thứ trong tuần
          _buildHeaderRow(cacNgayTrongTuan),

          Divider(
            height: 1,
            thickness: 1,
            color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFEADBDB),
          ),

          // 2. THÂN LƯỚI THỜI GIAN (Cuộn dọc)
          Expanded(
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: totalGridHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột mốc giờ bên trái
                    _buildTimeAxisColumn(totalHours, redLineTop, redLineTimeText),

                    // 7 cột ngày của lưới lịch
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _horizontalBodyController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: dayColumnWidth * 7,
                          height: totalGridHeight,
                          child: Stack(
                            children: [
                              // Các đường kẻ ngang và dọc của lưới
                              _buildGridLines(totalHours),

                              // Các cột chứa sự kiện
                              Row(
                                children: List.generate(7, (colIndex) {
                                  return _buildDayEventColumn(
                                    colIndex: colIndex,
                                    totalGridHeight: totalGridHeight,
                                  );
                                }),
                              ),

                              // Vạch ngang đỏ tươi hiển thị GIỜ HIỆN TẠI
                              if (widget.controller.tuanDangXemChuaHomNay &&
                                  redLineTop >= 0 &&
                                  redLineTop <= totalGridHeight)
                                Positioned(
                                  top: redLineTop,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2.0,
                                    color: AppColors.redIndicator,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dòng Header hiển thị tiêu đề các thứ (T2 12, T3 13... hoặc Mon 12, Tue 13...)
  Widget _buildHeaderRow(List<DateTime> cacNgayTrongTuan) {
    final bool isEnglish = widget.ngonNgu == 'English';
    final List<String> tenThuVietTat;
    if (widget.controller.batDauChuNhat) {
      tenThuVietTat = isEnglish
          ? ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          : ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    } else {
      tenThuVietTat = isEnglish
          ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          : ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const SizedBox(width: timeColumnWidth),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalHeaderController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: dayColumnWidth * 7,
                child: Row(
                  children: List.generate(7, (index) {
                    final DateTime date = cacNgayTrongTuan[index];
                    final String thuText = '${tenThuVietTat[index]} ${date.day}';
                    final bool isToday = widget.controller.laNgayHomNay(date);

                    return Container(
                      width: dayColumnWidth,
                      alignment: Alignment.center,
                      child: isToday
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sageGreen.withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: Text(
                                thuText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            )
                          : Text(
                              thuText,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.textDark,
                              ),
                            ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cột mốc giờ bên trái (06:00 -> 22:00) kèm Badge đỏ realtime
  Widget _buildTimeAxisColumn(int totalHours, double redLineTop, String redLineTimeText) {
    return Container(
      width: timeColumnWidth,
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.35),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: List.generate(totalHours, (index) {
              final int hour = ScheduleController.startHour + index;
              final String hourString = '${hour.toString().padLeft(2, '0')}:00';

              return Container(
                height: ScheduleController.hourHeight,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  hourString,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.timeText,
                  ),
                ),
              );
            }),
          ),

          if (widget.controller.tuanDangXemChuaHomNay &&
              redLineTop >= 0 &&
              redLineTop <= totalHours * ScheduleController.hourHeight)
            Positioned(
              top: redLineTop - 10.0,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.redIndicatorBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  redLineTimeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Vẽ các đường kẻ lưới ngang và dọc
  Widget _buildGridLines(int totalHours) {
    final Color gridColor = widget.isDark ? const Color(0xFF334155) : const Color(0xFFEADBDB);

    return Stack(
      children: [
        Column(
          children: List.generate(totalHours, (index) {
            return Container(
              height: ScheduleController.hourHeight,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: gridColor, width: 1.0),
                ),
              ),
            );
          }),
        ),
        Row(
          children: List.generate(7, (index) {
            return Container(
              width: dayColumnWidth,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: gridColor, width: 1.0),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Cột chứa các sự kiện của một ngày cụ thể
  Widget _buildDayEventColumn({
    required int colIndex,
    required double totalGridHeight,
  }) {
    final List<CongViecModel> events = widget.controller.getDanhSachCongViecTheoThu(colIndex);
    final DateTime targetDate = widget.controller.ngayDauTuan.add(Duration(days: colIndex));
    final bool isToday = widget.controller.laNgayHomNay(targetDate);

    return Container(
      width: dayColumnWidth,
      height: totalGridHeight,
      color: isToday ? AppColors.sageGreen.withValues(alpha: widget.isDark ? 0.08 : 0.035) : Colors.transparent,
      child: Stack(
        children: events.map((congViec) {
          final double top = widget.controller.calculateTopPosition(congViec.thoiGianBatDau);
          final double height = widget.controller.calculateHeight(
            congViec.thoiGianBatDau,
            congViec.thoiGianKetThuc,
          );

          return Positioned(
            top: top,
            left: 1.5,
            right: 1.5,
            height: height,
            child: EventCardWidget(
              congViec: congViec,
              onTap: () {
                EventDetailDialog.show(
                  context,
                  congViec: congViec,
                  danhSachHienCo: widget.controller.danhSachCongViec,
                  onSave: (updated) => widget.controller.luuCongViec(updated),
                  onDelete: (id) => widget.controller.xoaCongViec(id),
                  onSaveBatch: (batch) => widget.controller.luuChuoiCongViec(batch),
                  onDeleteSeries: (maChuoi) => widget.controller.xoaChuoiCongViec(maChuoi),
                  onUpdateSeries: (maChuoi, mau, batch) => widget.controller.capNhatChuoiCongViec(
                    maChuoiLap: maChuoi,
                    mau: mau,
                    danhSachMoiNeuDoiLich: batch,
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
