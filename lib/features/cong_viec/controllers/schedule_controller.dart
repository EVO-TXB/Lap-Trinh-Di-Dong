import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../models/cong_viec_model.dart';
import '../repositories/i_event_repository.dart';

/// Controller quản lý nghiệp vụ và tính toán giao diện Lưới Thời Gian (Weekly Grid)
/// Tích hợp tác vụ nền quét thông báo và tự động tích việc thiết yếu (Prompt 2)
class ScheduleController extends ChangeNotifier {
  final IEventRepository _eventRepository;
  final DichVuThongBao _dichVuThongBao = DichVuThongBao.instance;

  // Cấu hình mốc giờ của Lưới thời gian
  static const int startHour = 6;  // 06:00
  static const int endHour = 22;   // 22:00
  static const double hourHeight = 64.0; // Chiều cao mỗi ô 1 giờ (pixels)

  // Trạng thái ngày đang chọn & Ngày đầu tuần (Thứ Hai)
  late DateTime _ngayHienTai;
  late DateTime _ngayDauTuan;

  // Danh sách công việc trong tuần hiện tại
  List<CongViecModel> _danhSachCongViec = [];
  bool _isLoading = false;

  // Chế độ xem: 0 = Lịch tuần, 1 = Lịch tháng
  int _cheDoXem = 0;

  // Thời gian thực để hiển thị Vạch đỏ Realtime & Điều phối quét thông báo
  late DateTime _thoiGianThuc;
  Timer? _realtimeTimer;
  final DateTime? _ngayKhoiTaoTuyChon;
  bool _batDauChuNhat = false;
  final int maNguoiDung;

  ScheduleController({
    required IEventRepository eventRepository,
    DateTime? ngayKhoiTao,
    this.maNguoiDung = 1,
  })  : _eventRepository = eventRepository,
        _ngayKhoiTaoTuyChon = ngayKhoiTao {
    // Truy cập thời gian thực trên thiết bị DateTime.now()
    final DateTime now = ngayKhoiTao ?? DateTime.now();
    _ngayHienTai = DateTime(now.year, now.month, now.day);
    _ngayDauTuan = _tinhNgayDauTuan(_ngayHienTai);
    _thoiGianThuc = now;

    // Kích hoạt Timer cập nhật Realtime mỗi 10s & quét thông báo ngầm
    _startRealtimeTimer();

    // Nạp dữ liệu ban đầu
    loadDanhSachCongViec();
  }

  // Getters
  DateTime get ngayHienTai => _ngayHienTai;
  DateTime get ngayDauTuan => _ngayDauTuan;
  List<CongViecModel> get danhSachCongViec => _danhSachCongViec;
  bool get isLoading => _isLoading;
  int get cheDoXem => _cheDoXem;
  DateTime get thoiGianThuc => _thoiGianThuc;
  bool get batDauChuNhat => _batDauChuNhat;

  /// Cập nhật ngày bắt đầu tuần (Thứ Hai / Chủ Nhật) từ Cài đặt
  void capNhatNgayBatDauTuan(bool laChuNhat) {
    if (_batDauChuNhat != laChuNhat) {
      _batDauChuNhat = laChuNhat;
      _ngayDauTuan = _tinhNgayDauTuan(_ngayHienTai);
      loadDanhSachCongViec();
    }
  }

  /// Ngày hôm nay thực tế trên thiết bị
  DateTime get ngayHomNayThucTe {
    final now = _ngayKhoiTaoTuyChon ?? DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Kiểm tra một ngày cụ thể có phải là ngày hôm nay trên thiết bị hay không
  bool laNgayHomNay(DateTime date) {
    final today = ngayHomNayThucTe;
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  /// Kiểm tra tuần đang xem có chứa ngày hôm nay thực tế hay không
  bool get tuanDangXemChuaHomNay {
    final DateTime dauTuanHomNay = _tinhNgayDauTuan(ngayHomNayThucTe);
    return dauTuanHomNay.year == _ngayDauTuan.year &&
           dauTuanHomNay.month == _ngayDauTuan.month &&
           dauTuanHomNay.day == _ngayDauTuan.day;
  }

  /// Tính ngày đầu tuần (Thứ Hai hoặc Chủ Nhật)
  DateTime _tinhNgayDauTuan(DateTime date) {
    if (_batDauChuNhat) {
      final int diff = date.weekday % 7; // Sunday=0, Monday=1, ...
      return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
    }
    final int weekday = date.weekday; // 1 = Monday, 7 = Sunday
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }

  /// Khởi động đồng hồ thời gian thực & tác vụ quét thông báo / tự động hóa
  void _startRealtimeTimer() {
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_ngayKhoiTaoTuyChon == null) {
        _thoiGianThuc = DateTime.now();
      } else {
        _thoiGianThuc = _thoiGianThuc.add(const Duration(seconds: 10));
      }
      quetThongBaoVaTuDongHoa();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  /// Quét thông báo định kỳ & Tự động tích hoàn thành các việc bị động/thiết yếu khi quá giờ
  Future<void> quetThongBaoVaTuDongHoa() async {
    await _dichVuThongBao.quetThongBaoVaTuDongHoa(
      danhSachCongViec: _danhSachCongViec,
      thoiGianHienTai: _thoiGianThuc,
      onPhatThongBao: (congViec) {
        notifyListeners();
      },
      onTuDongHoanThanh: (congViec) async {
        await capNhatTrangThaiHoanThanh(congViec, true);
      },
    );
  }

  /// Kích hoạt một thông báo thử nghiệm ("Lập trình Web nâng cao" trước 15 phút)
  void kichHoatThongBaoThu() {
    final now = _thoiGianThuc;
    final CongViecModel sample = CongViecModel(
      id: 9999,
      maNguoiDung: maNguoiDung,
      tenCongViec: 'Lập trình Web nâng cao',
      thoiGianBatDau: now.add(const Duration(minutes: 15)),
      thoiGianKetThuc: now.add(const Duration(minutes: 105)),
      diaDiem: 'Phòng A3-402',
      laThietYeu: false,
      daHoanThanh: false,
      nhacNhoTruocPhut: 15,
      ngayTao: now,
    );
    _dichVuThongBao.kichHoatThongBaoThuCong(sample);
  }

  /// Nạp danh sách công việc từ Repository
  Future<void> loadDanhSachCongViec() async {
    _isLoading = true;
    notifyListeners();

    try {
      _danhSachCongViec = await _eventRepository.getDanhSachCongViecTheoTuan(
        ngayDauTuan: _ngayDauTuan,
      );
      // Quét tự động ngay sau khi nạp xong dữ liệu
      await quetThongBaoVaTuDongHoa();
    } catch (e) {
      debugPrint('Lỗi tải danh sách công việc: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chuyển sang tuần trước
  void chuyenTuanTruoc() {
    _ngayHienTai = _ngayHienTai.subtract(const Duration(days: 7));
    _ngayDauTuan = _tinhNgayDauTuan(_ngayHienTai);
    loadDanhSachCongViec();
  }

  /// Chuyển sang tuần kế tiếp
  void chuyenTuanSau() {
    _ngayHienTai = _ngayHienTai.add(const Duration(days: 7));
    _ngayDauTuan = _tinhNgayDauTuan(_ngayHienTai);
    loadDanhSachCongViec();
  }

  /// Nút "Hôm nay": Trở về ngày hôm nay thực tế trên thiết bị
  void chuyenDenHomNay() {
    final now = _ngayKhoiTaoTuyChon ?? DateTime.now();
    _ngayHienTai = DateTime(now.year, now.month, now.day);
    _ngayDauTuan = _tinhNgayDauTuan(_ngayHienTai);
    _thoiGianThuc = now;
    loadDanhSachCongViec();
  }

  /// Chuyển đổi Segmented Control (Lịch tuần / Lịch tháng)
  void doiCheDoXem(int index) {
    if (_cheDoXem != index) {
      _cheDoXem = index;
      notifyListeners();
    }
  }

  // =========================================================================
  // THUẬT TOÁN TÍNH TOÁN LAYOUT GRID (TOP / HEIGHT / INDEX)
  // =========================================================================

  /// Tính vị trí Top của thẻ sự kiện dựa trên giờ bắt đầu
  double calculateTopPosition(DateTime thoiGianBatDau) {
    final double minutesFromStart = (thoiGianBatDau.hour - startHour) * 60.0 + thoiGianBatDau.minute;
    return (minutesFromStart / 60.0) * hourHeight;
  }

  /// Tính chiều cao của thẻ sự kiện dựa trên thời lượng (thoiGianKetThuc - thoiGianBatDau)
  double calculateHeight(DateTime thoiGianBatDau, DateTime thoiGianKetThuc) {
    final int durationMinutes = thoiGianKetThuc.difference(thoiGianBatDau).inMinutes;
    // Đảm bảo tối thiểu chiều cao 28px để chữ không bị tràn
    final double computedHeight = (durationMinutes / 60.0) * hourHeight;
    return computedHeight < 28.0 ? 28.0 : computedHeight;
  }

  /// Tính vị trí Top của Vạch đỏ hiển thị thời gian hiện tại
  double calculateRedLineTop() {
    final double minutesFromStart = (_thoiGianThuc.hour - startHour) * 60.0 + _thoiGianThuc.minute;
    return (minutesFromStart / 60.0) * hourHeight;
  }

  /// Xác định cột thứ trong tuần (0: Thứ Hai -> 6: Chủ Nhật)
  int getColumnIndex(DateTime date) {
    return date.weekday - 1;
  }

  /// Lấy danh sách công việc thuộc về một cột thứ cụ thể
  List<CongViecModel> getDanhSachCongViecTheoThu(int columnIndex) {
    final DateTime targetDate = _ngayDauTuan.add(Duration(days: columnIndex));
    return _danhSachCongViec.where((cv) {
      return cv.thoiGianBatDau.year == targetDate.year &&
             cv.thoiGianBatDau.month == targetDate.month &&
             cv.thoiGianBatDau.day == targetDate.day;
    }).toList();
  }

  // =========================================================================
  // TÍNH TOÁN TIẾN ĐỘ NGÀY (PROGRESS CARD: 5/8 việc đã xong (62%))
  // =========================================================================

  List<CongViecModel> get danhSachViecHomNay {
    return _danhSachCongViec.where((cv) {
      return cv.thoiGianBatDau.year == _ngayHienTai.year &&
             cv.thoiGianBatDau.month == _ngayHienTai.month &&
             cv.thoiGianBatDau.day == _ngayHienTai.day;
    }).toList();
  }

  int get tongSoViecHomNay => danhSachViecHomNay.length;

  int get soViecDaXongHomNay =>
      danhSachViecHomNay.where((e) => e.trangThaiHoanThanhHienThi).length;

  double get tiLeHoanThanh {
    if (tongSoViecHomNay == 0) return 0.0;
    return soViecDaXongHomNay / tongSoViecHomNay;
  }

  int get phanTramHoanThanh => (tiLeHoanThanh * 100).round();

  /// Chuỗi tiêu đề tuần gọn gàng trên 1 dòng duy nhất, hỗ trợ đa ngôn ngữ Tuần / Week
  String layTieuDeTuan({String nhanTuan = 'Tuần'}) {
    final int tuanSo = _tinhSoTuanTrongNam(_ngayDauTuan);
    final String ngayStr =
        '${_ngayHienTai.day.toString().padLeft(2, '0')}/${_ngayHienTai.month.toString().padLeft(2, '0')}/${_ngayHienTai.year}';
    return '$ngayStr ($nhanTuan $tuanSo)';
  }

  String get tieuDeTuan => layTieuDeTuan();

  /// Chuỗi ngày hiện tại (định dạng dd/MM/yyyy không ghi thứ): ví dụ "13/10/2026"
  String get chuoiNgayHienTai {
    return '${_ngayHienTai.day.toString().padLeft(2, '0')}/${_ngayHienTai.month.toString().padLeft(2, '0')}/${_ngayHienTai.year}';
  }

  /// Thuật toán tính số tuần ISO trong năm
  int _tinhSoTuanTrongNam(DateTime date) {
    final DateTime thuNamDauTien = DateTime(date.year, 1, 4);
    final int ngayThuNam = thuNamDauTien.weekday;
    final DateTime dauTuan1 = thuNamDauTien.subtract(Duration(days: ngayThuNam - 1));
    final int diff = date.difference(dauTuan1).inDays;
    return (diff / 7).floor() + 1;
  }

  // =========================================================================
  // THAO TÁC CẬP NHẬT & SỰ KIỆN XEM / SỬA CHI TIẾT
  // =========================================================================

  Future<void> capNhatTrangThaiHoanThanh(CongViecModel congViec, bool daHoanThanh) async {
    final CongViecModel updated = congViec.copyWith(daHoanThanh: daHoanThanh);
    await _eventRepository.updateCongViec(updated);
    final int index = _danhSachCongViec.indexWhere((e) => e.id == congViec.id);
    if (index != -1) {
      _danhSachCongViec[index] = updated;
      notifyListeners();
    }
  }

  Future<void> luuCongViec(CongViecModel congViec) async {
    if (congViec.id <= 0) {
      await _eventRepository.createCongViec(congViec);
    } else {
      await _eventRepository.updateCongViec(congViec);
    }
    await loadDanhSachCongViec();
  }

  Future<void> xoaCongViec(int id) async {
    await _eventRepository.deleteCongViec(id);
    await loadDanhSachCongViec();
  }

  Future<void> luuChuoiCongViec(List<CongViecModel> batch) async {
    await _eventRepository.createDanhSachCongViec(batch);
    await loadDanhSachCongViec();
  }

  Future<void> xoaChuoiCongViec(String maChuoiLap) async {
    await _eventRepository.deleteChuoiCongViec(maChuoiLap);
    await loadDanhSachCongViec();
  }

  /// Cập nhật toàn bộ chuỗi công việc lặp lại
  Future<void> capNhatChuoiCongViec({
    required String maChuoiLap,
    required CongViecModel mau,
    List<CongViecModel>? danhSachMoiNeuDoiLich,
  }) async {
    if (danhSachMoiNeuDoiLich != null && danhSachMoiNeuDoiLich.isNotEmpty) {
      await _eventRepository.deleteChuoiCongViec(maChuoiLap);
      await _eventRepository.createDanhSachCongViec(danhSachMoiNeuDoiLich);
    } else {
      await _eventRepository.updateChuoiCongViec(maChuoiLap, mau);
    }
    await loadDanhSachCongViec();
  }
}
