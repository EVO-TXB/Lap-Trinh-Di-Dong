import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';
import '../repositories/i_event_repository.dart';

/// Dữ liệu biểu thị các chấm chỉ báo màu sắc cho từng ngày
class DayIndicatorDots {
  final List<Color> dotColors;
  final bool hasMore;

  const DayIndicatorDots({
    required this.dotColors,
    required this.hasMore,
  });
}

/// Controller quản lý nghiệp vụ và trạng thái của Màn hình Lịch Tháng (Monthly Calendar)
class MonthCalendarController extends ChangeNotifier {
  final IEventRepository _eventRepository;

  late DateTime _thangHienTai;
  late DateTime _ngayDangChon;
  late DateTime _ngayHomNay;

  List<CongViecModel> _danhSachCongViecTrongThang = [];
  Map<String, List<CongViecModel>> _suKienTheoNgay = {};
  bool _isLoading = false;

  MonthCalendarController({
    required IEventRepository eventRepository,
    DateTime? ngayKhoiTao,
  })  : _eventRepository = eventRepository {
    // Luôn đồng bộ với thời gian thực trên thiết bị DateTime.now()
    final DateTime now = DateTime.now();
    _ngayHomNay = DateTime(now.year, now.month, now.day);

    // Mặc định khởi tạo theo ngày được chỉ định hoặc ngày hôm nay thực tế
    final DateTime target = ngayKhoiTao ?? _ngayHomNay;
    _thangHienTai = DateTime(target.year, target.month, 1);
    _ngayDangChon = DateTime(target.year, target.month, target.day);

    loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }

  // Getters
  DateTime get thangHienTai => _thangHienTai;
  DateTime get ngayDangChon => _ngayDangChon;
  DateTime get ngayHomNay => _ngayHomNay;
  List<CongViecModel> get danhSachCongViecTrongThang => _danhSachCongViecTrongThang;
  bool get isLoading => _isLoading;

  String get tieuDeThangHienTai => 'Tháng ${_thangHienTai.month}, ${_thangHienTai.year}';

  String get tieuDeNgayDuocChon {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return 'Lịch trình ngày ${formatter.format(_ngayDangChon)}';
  }

  List<CongViecModel> get danhSachCongViecNgayDuocChon {
    return getDanhSachCongViecNgay(_ngayDangChon);
  }

  // =========================================================================
  // THUẬT TOÁN TÍNH TOÁN MA TRẬN LỊCH THÁNG (7 CỘT x 5 ĐẾN 6 HÀNG)
  // =========================================================================

  /// Sinh danh sách ngày hoàn chỉnh cho ma trận lịch tháng
  /// - Tính đúng ngày đầu tháng rơi vào thứ mấy (Thứ 2 = 1 ... Chủ Nhật = 7)
  /// - Xử lý năm nhuận tự động qua DateTime
  /// - Bù đủ các ngày cuối của tháng trước và các ngày đầu của tháng sau
  List<DateTime> taoMaTranLichThang(int nam, int thang) {
    final DateTime dauThang = DateTime(nam, thang, 1);
    final int soNgayTrongThang = DateTime(nam, thang + 1, 0).day;

    // Quy đổi: Thứ Hai = 1 -> số ngày bù = 0; Thứ Ba = 2 -> số ngày bù = 1, ...
    final int soNgayBuThangTruoc = dauThang.weekday - 1;
    final DateTime ngayBatDauMaTran = dauThang.subtract(Duration(days: soNgayBuThangTruoc));

    // Tổng số ô hiển thị: 35 (5 hàng x 7) hoặc 42 (6 hàng x 7)
    final int tongSoO = (soNgayBuThangTruoc + soNgayTrongThang <= 35) ? 35 : 42;

    return List.generate(tongSoO, (index) => ngayBatDauMaTran.add(Duration(days: index)));
  }

  /// Khóa định dạng ngày dùng cho Map: yyyy-MM-dd
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Lấy danh sách công việc của một ngày bất kỳ
  List<CongViecModel> getDanhSachCongViecNgay(DateTime date) {
    final String key = _formatDateKey(date);
    return _suKienTheoNgay[key] ?? [];
  }

  /// Tính toán các chấm chỉ báo màu sắc (Event Indicator Dots) cho từng ô ngày:
  /// - Chấm Xanh lam: Có việc Chủ động
  /// - Chấm Cam: Có việc Bị động / Thiết yếu
  /// - Chấm Xanh lá: Công việc đã hoàn thành
  /// - Nếu > 3 việc: Hiển thị 2 chấm + dấu '+' nhỏ
  DayIndicatorDots getChiBaoChamNgay(DateTime date) {
    final List<CongViecModel> events = getDanhSachCongViecNgay(date);
    if (events.isEmpty) {
      return const DayIndicatorDots(dotColors: [], hasMore: false);
    }

    if (events.length > 3) {
      final List<Color> dots = [];
      for (int i = 0; i < 2; i++) {
        dots.add(_layMauChoCongViec(events[i]));
      }
      return DayIndicatorDots(dotColors: dots, hasMore: true);
    }

    final List<Color> dots = events.map((e) => _layMauChoCongViec(e)).toList();
    return DayIndicatorDots(dotColors: dots, hasMore: false);
  }

  Color _layMauChoCongViec(CongViecModel congViec) {
    if (congViec.trangThaiHoanThanhHienThi) {
      return AppColors.completedGreenLegend; // Xanh lá (#729B79 / #6C987A)
    }
    if (congViec.laThietYeu) {
      return AppColors.passiveOrangeLegend; // Cam (#FB923C / #FFE2C6)
    }
    return AppColors.activeBlueLegend; // Xanh lam (#4A72F5 / #D1E4FA)
  }

  // =========================================================================
  // THAO TÁC DỮ LIỆU & ĐIỀU HƯỚNG THÁNG
  // =========================================================================

  /// Lấy dữ liệu công việc trong tháng từ Repository và gom nhóm (group by) theo từng ngày
  Future<void> loadEventsForMonth(int nam, int thang) async {
    _isLoading = true;
    notifyListeners();

    try {
      _danhSachCongViecTrongThang = await _eventRepository.getDanhSachCongViecTheoThang(
        nam: nam,
        thang: thang,
      );

      // Gom nhóm theo key yyyy-MM-dd
      final Map<String, List<CongViecModel>> grouped = {};
      for (final CongViecModel item in _danhSachCongViecTrongThang) {
        final String key = _formatDateKey(item.thoiGianBatDau);
        grouped.putIfAbsent(key, () => []).add(item);
      }
      _suKienTheoNgay = grouped;
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu lịch tháng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật ngày được chọn và lọc danh sách sự kiện
  void selectDate(DateTime date) {
    _ngayDangChon = date;
    // Nếu người dùng chọn một ngày thuộc tháng trước/tháng sau trong lưới, chuyển sang tháng đó
    if (date.year != _thangHienTai.year || date.month != _thangHienTai.month) {
      _thangHienTai = DateTime(date.year, date.month, 1);
      loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
    } else {
      notifyListeners();
    }
  }

  /// Chuyển sang tháng trước
  void chuyenThangTruoc() {
    _thangHienTai = DateTime(_thangHienTai.year, _thangHienTai.month - 1, 1);
    loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }

  /// Chuyển sang tháng sau
  void chuyenThangSau() {
    _thangHienTai = DateTime(_thangHienTai.year, _thangHienTai.month + 1, 1);
    loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }

  /// Nhảy về ngày hôm nay theo thời gian thực tế
  void chuyenDenHomNay() {
    final DateTime now = DateTime.now();
    _ngayHomNay = DateTime(now.year, now.month, now.day);
    _thangHienTai = DateTime(_ngayHomNay.year, _ngayHomNay.month, 1);
    _ngayDangChon = _ngayHomNay;
    loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }

  /// Đánh dấu nhanh trạng thái hoàn thành từ Panel danh sách ngày
  Future<void> toggleTrangThaiHoanThanh(CongViecModel congViec) async {
    final bool newStatus = !congViec.daHoanThanh;
    final CongViecModel updated = congViec.copyWith(daHoanThanh: newStatus);

    await _eventRepository.updateCongViec(updated);

    // Cập nhật local
    final int index = _danhSachCongViecTrongThang.indexWhere((e) => e.id == congViec.id);
    if (index != -1) {
      _danhSachCongViecTrongThang[index] = updated;
    }

    final String key = _formatDateKey(congViec.thoiGianBatDau);
    final List<CongViecModel>? dayList = _suKienTheoNgay[key];
    if (dayList != null) {
      final int dayIndex = dayList.indexWhere((e) => e.id == congViec.id);
      if (dayIndex != -1) {
        dayList[dayIndex] = updated;
      }
    }

    notifyListeners();
  }

  /// Thêm hoặc cập nhật công việc
  Future<void> luuCongViec(CongViecModel congViec) async {
    if (congViec.id <= 0) {
      final CongViecModel created = await _eventRepository.createCongViec(congViec);
      _danhSachCongViecTrongThang.add(created);
    } else {
      final CongViecModel updated = await _eventRepository.updateCongViec(congViec);
      final int index = _danhSachCongViecTrongThang.indexWhere((e) => e.id == congViec.id);
      if (index != -1) {
        _danhSachCongViecTrongThang[index] = updated;
      }
    }
    // Tải lại nhóm
    await loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }

  /// Xóa công việc
  Future<void> xoaCongViec(int id) async {
    await _eventRepository.deleteCongViec(id);
    _danhSachCongViecTrongThang.removeWhere((e) => e.id == id);
    await loadEventsForMonth(_thangHienTai.year, _thangHienTai.month);
  }
}
