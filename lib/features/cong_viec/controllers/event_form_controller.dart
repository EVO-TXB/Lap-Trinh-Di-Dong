import 'package:flutter/material.dart';
import '../models/cong_viec_model.dart';
import '../utils/batch_event_helper.dart';
import '../utils/time_conflict_checker.dart';

/// Controller độc lập quản lý trạng thái, validation và logic lặp lại / kiểm tra trùng lịch của Form
class EventFormController extends ChangeNotifier {
  final CongViecModel? congViecGoc;

  late String _tenCongViec;
  late String _diaDiem;
  late String _loaiSuKien; // 'CHU_DONG' hoặc 'BI_DONG'
  late DateTime _ngayThucHien;
  late TimeOfDay _gioBatDau;
  late TimeOfDay _gioKetThuc;

  // Cấu hình lặp lại hàng tuần
  late bool _coLapLai;
  late Set<int> _cacThuDaChon; // 2=T2, 3=T3, ..., 7=T7, 8=CN
  late DateTime _ngayBatDauLap;
  late DateTime _ngayKetThucLap;

  bool _isSubmitting = false;
  String? _thongBaoLoi;

  late final Set<int> _cacThuBanDau;

  EventFormController({
    this.congViecGoc,
    DateTime? ngayMacDinh,
    List<CongViecModel>? danhSachHienCo,
  }) {
    final DateTime now = ngayMacDinh ?? DateTime.now();

    if (congViecGoc != null) {
      _tenCongViec = congViecGoc!.tenCongViec;
      _diaDiem = congViecGoc!.diaDiem ?? '';
      _loaiSuKien = congViecGoc!.loaiSuKien;
      _ngayThucHien = DateTime(
        congViecGoc!.thoiGianBatDau.year,
        congViecGoc!.thoiGianBatDau.month,
        congViecGoc!.thoiGianBatDau.day,
      );
      _gioBatDau = TimeOfDay.fromDateTime(congViecGoc!.thoiGianBatDau);
      _gioKetThuc = TimeOfDay.fromDateTime(congViecGoc!.thoiGianKetThuc);
      _coLapLai = congViecGoc!.coLapLai;

      final String? maChuoi = congViecGoc!.maChuoiLap ?? congViecGoc!.maQuyTacLap?.toString();
      final List<CongViecModel> seriesEvents = (danhSachHienCo != null && maChuoi != null)
          ? danhSachHienCo.where((e) => e.maChuoiLap == maChuoi || e.maQuyTacLap?.toString() == maChuoi).toList()
          : [];

      if (seriesEvents.isNotEmpty) {
        _cacThuDaChon = seriesEvents
            .map((e) => BatchEventHelper.weekdayToThuTimass(e.thoiGianBatDau.weekday))
            .toSet();
        seriesEvents.sort((a, b) => a.thoiGianBatDau.compareTo(b.thoiGianBatDau));
        _ngayBatDauLap = DateTime(
          seriesEvents.first.thoiGianBatDau.year,
          seriesEvents.first.thoiGianBatDau.month,
          seriesEvents.first.thoiGianBatDau.day,
        );
        _ngayKetThucLap = DateTime(
          seriesEvents.last.thoiGianKetThuc.year,
          seriesEvents.last.thoiGianKetThuc.month,
          seriesEvents.last.thoiGianKetThuc.day,
        );
      } else {
        _cacThuDaChon = {BatchEventHelper.weekdayToThuTimass(congViecGoc!.thoiGianBatDau.weekday)};
        _ngayBatDauLap = _ngayThucHien;
        _ngayKetThucLap = _ngayThucHien.add(const Duration(days: 70));
      }
      _cacThuBanDau = Set<int>.from(_cacThuDaChon);
    } else {
      _tenCongViec = '';
      _diaDiem = '';
      _loaiSuKien = 'CHU_DONG';
      _ngayThucHien = DateTime(now.year, now.month, now.day);
      _gioBatDau = const TimeOfDay(hour: 8, minute: 0);
      _gioKetThuc = const TimeOfDay(hour: 10, minute: 0);
      _coLapLai = false;
      // Mặc định chọn T2, T4, T6 như ảnh mẫu ui
      _cacThuDaChon = {2, 4, 6};
      _ngayBatDauLap = _ngayThucHien;
      _ngayKetThucLap = DateTime(_ngayThucHien.year, 12, 30);
      _cacThuBanDau = Set<int>.from(_cacThuDaChon);
    }
  }

  bool get daThayDoiQuyTacLap {
    if (congViecGoc == null) return false;
    if (_coLapLai != congViecGoc!.coLapLai) return true;
    if (!_coLapLai) return false;
    if (_cacThuDaChon.length != _cacThuBanDau.length) return true;
    return !_cacThuDaChon.containsAll(_cacThuBanDau);
  }

  // Getters
  bool get isEditing => congViecGoc != null && congViecGoc!.id > 0;
  String get tenCongViec => _tenCongViec;
  String get diaDiem => _diaDiem;
  String get loaiSuKien => _loaiSuKien;
  bool get laViecChuDong => _loaiSuKien == 'CHU_DONG';
  bool get laThietYeu => _loaiSuKien == 'BI_DONG';
  DateTime get ngayThucHien => _ngayThucHien;
  TimeOfDay get gioBatDau => _gioBatDau;
  TimeOfDay get gioKetThuc => _gioKetThuc;
  bool get coLapLai => _coLapLai;
  Set<int> get cacThuDaChon => Set.unmodifiable(_cacThuDaChon);
  DateTime get ngayBatDauLap => _ngayBatDauLap;
  DateTime get ngayKetThucLap => _ngayKetThucLap;
  bool get isSubmitting => _isSubmitting;
  String? get thongBaoLoi => _thongBaoLoi;

  // DateTime kết hợp
  DateTime get thoiGianBatDauHopNhat => DateTime(
        _ngayThucHien.year,
        _ngayThucHien.month,
        _ngayThucHien.day,
        _gioBatDau.hour,
        _gioBatDau.minute,
      );

  DateTime get thoiGianKetThucHopNhat => DateTime(
        _ngayThucHien.year,
        _ngayThucHien.month,
        _ngayThucHien.day,
        _gioKetThuc.hour,
        _gioKetThuc.minute,
      );

  // Setters & Actions
  void thayDoiTenCongViec(String val) {
    _tenCongViec = val;
    if (_thongBaoLoi != null) {
      _thongBaoLoi = null;
      notifyListeners();
    }
  }

  void thayDoiDiaDiem(String val) {
    _diaDiem = val;
    notifyListeners();
  }

  void thayDoiLoaiSuKien(String loai) {
    if (_loaiSuKien != loai) {
      _loaiSuKien = loai;
      notifyListeners();
    }
  }

  void thayDoiNgayThucHien(DateTime ngay) {
    _ngayThucHien = DateTime(ngay.year, ngay.month, ngay.day);
    _ngayBatDauLap = _ngayThucHien;
    notifyListeners();
  }

  void thayDoiGioBatDau(TimeOfDay gio) {
    _gioBatDau = gio;
    notifyListeners();
  }

  void thayDoiGioKetThuc(TimeOfDay gio) {
    _gioKetThuc = gio;
    notifyListeners();
  }

  void toggleLapLai(bool val) {
    _coLapLai = val;
    notifyListeners();
  }

  void toggleThu(int thu) {
    if (_cacThuDaChon.contains(thu)) {
      if (_cacThuDaChon.length > 1) {
        _cacThuDaChon.remove(thu);
      }
    } else {
      _cacThuDaChon.add(thu);
    }
    notifyListeners();
  }

  void thayDoiKhoangNgayLap({DateTime? tuNgay, DateTime? denNgay}) {
    if (tuNgay != null) _ngayBatDauLap = tuNgay;
    if (denNgay != null) _ngayKetThucLap = denNgay;
    notifyListeners();
  }

  void setSubmitting(bool val) {
    _isSubmitting = val;
    notifyListeners();
  }

  /// Kiểm tra hợp lệ dữ liệu nhập (Validation)
  String? validateForm({String? Function(String key)? tr}) {
    if (_tenCongViec.trim().isEmpty) {
      return tr != null
          ? tr('err_empty_task_title')
          : 'Vui lòng nhập tên công việc hoặc môn học.';
    }

    final int startMinutes = _gioBatDau.hour * 60 + _gioBatDau.minute;
    final int endMinutes = _gioKetThuc.hour * 60 + _gioKetThuc.minute;

    if (startMinutes >= endMinutes) {
      return tr != null
          ? tr('err_time_order')
          : 'Giờ bắt đầu phải sớm hơn giờ kết thúc.';
    }

    if (_coLapLai) {
      if (_cacThuDaChon.isEmpty) {
        return tr != null
            ? tr('err_select_weekday')
            : 'Vui lòng chọn ít nhất một thứ trong tuần để lặp lại.';
      }
      if (_ngayKetThucLap.isBefore(_ngayBatDauLap)) {
        return tr != null
            ? tr('err_repeat_dates')
            : 'Ngày kết thúc lặp phải sau hoặc bằng ngày bắt đầu.';
      }
    }

    return null;
  }

  /// Thuật toán kiểm tra trùng lịch (Conflict Check)
  KetQuaKiemTraTrungLich kiemTraTrungLich(List<CongViecModel> danhSachHienCo) {
    if (!_coLapLai) {
      return TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: thoiGianBatDauHopNhat,
        thoiGianKetThuc: thoiGianKetThucHopNhat,
        danhSachHienCo: danhSachHienCo,
        idHienTai: congViecGoc?.id,
        maChuoiLapHienTai: congViecGoc?.maChuoiLap,
        loaiBoCungChuoiLap: false,
      );
    } else {
      final List<CongViecModel> danhSachLap = sinhDanhSachCongViecLap();
      return TimeConflictChecker.kiemTraTrungLichChuoiLap(
        danhSachSuKienMoi: danhSachLap,
        danhSachHienCo: danhSachHienCo,
        idHienTai: congViecGoc?.id,
        maChuoiLapHienTai: congViecGoc?.maChuoiLap,
      );
    }
  }

  /// Sinh đối tượng công việc đơn lẻ
  CongViecModel taoCongViecDonLe() {
    final DateTime now = DateTime.now();
    return CongViecModel(
      id: congViecGoc?.id ?? 0,
      maNguoiDung: congViecGoc?.maNguoiDung ?? 1,
      maChuoiLap: _coLapLai ? congViecGoc?.maChuoiLap : null,
      tenCongViec: _tenCongViec.trim(),
      thoiGianBatDau: thoiGianBatDauHopNhat,
      thoiGianKetThuc: thoiGianKetThucHopNhat,
      diaDiem: _diaDiem.trim().isEmpty ? null : _diaDiem.trim(),
      laThietYeu: laThietYeu,
      daHoanThanh: congViecGoc?.daHoanThanh ?? false,
      nhacNhoTruocPhut: congViecGoc?.nhacNhoTruocPhut ?? 15,
      ngayTao: congViecGoc?.ngayTao ?? now,
      loaiSuKien: _loaiSuKien,
    );
  }

  /// Sinh danh sách công việc chuỗi lặp lại
  List<CongViecModel> sinhDanhSachCongViecLap() {
    final CongViecModel mau = taoCongViecDonLe();
    return BatchEventHelper.sinhDanhSachCongViecLap(
      mau: mau,
      cacThu: _cacThuDaChon,
      ngayBatDau: _ngayBatDauLap,
      ngayKetThuc: _ngayKetThucLap,
      maChuoiLap: congViecGoc?.maChuoiLap,
    );
  }
}

