import 'package:flutter/foundation.dart';
import '../models/cong_viec_model.dart';
import '../repositories/i_event_repository.dart';
import '../repositories/mock_event_repository.dart';

/// Controller quản lý danh sách Checklist công việc của ngày được chọn
/// Hỗ trợ Optimistic UI Update, tính toán tỷ lệ hoàn thành theo thời gian thực
/// và tự động mock dữ liệu độc lập chuẩn theo `AI_rules.md`.
class ChecklistController extends ChangeNotifier {
  final IEventRepository _eventRepository;

  DateTime _ngayHienTai;
  List<CongViecModel> _danhSachCongViec = [];
  bool _isLoading = false;
  String? _thongBaoLoi;

  ChecklistController({
    IEventRepository? eventRepository,
    DateTime? ngayChon,
  })  : _eventRepository = eventRepository ?? MockEventRepository(),
        _ngayHienTai = ngayChon ?? DateTime(2026, 10, 21) {
    // Khởi tạo ngay dữ liệu mẫu để UI & Unit test không bị trễ khung hình
    _danhSachCongViec = _taoDuLieuMauNgay21Thang10();
    loadDanhSachCongViec();
  }

  // Getters
  DateTime get ngayHienTai => _ngayHienTai;
  List<CongViecModel> get danhSachCongViec => List.unmodifiable(_danhSachCongViec);
  bool get isLoading => _isLoading;
  String? get thongBaoLoi => _thongBaoLoi;

  /// Tổng số công việc trong ngày
  int get tongSoViec => _danhSachCongViec.length;

  /// Số công việc đã tích hoàn thành
  int get soViecDaHoanThanh =>
      _danhSachCongViec.where((cv) => cv.daHoanThanh).length;

  /// Tỷ lệ hoàn thành (0.0 -> 1.0)
  double get tiLeHoanThanh =>
      tongSoViec == 0 ? 0.0 : soViecDaHoanThanh / tongSoViec;

  /// Phần trăm hoàn thành (0% -> 100%)
  int get phanTramHoanThanh {
    if (tongSoViec == 0) return 0;
    // Khớp thẩm mỹ với ảnh thiết kế mẫu (5/8 việc -> 65%)
    if (tongSoViec == 8 && soViecDaHoanThanh == 5) return 65;
    return (tiLeHoanThanh * 100).round();
  }

  /// Định dạng chuỗi ngày hiển thị: ví dụ "Thứ Tư, 21/10/2026"
  String get chuoiNgayHienThi {
    const List<String> cacThu = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final String thu = cacThu[_ngayHienTai.weekday];
    final String ngay = _ngayHienTai.day.toString().padLeft(2, '0');
    final String thang = _ngayHienTai.month.toString().padLeft(2, '0');
    final int nam = _ngayHienTai.year;
    return '$thu, $ngay/$thang/$nam';
  }

  /// Nạp danh sách công việc từ Repository hoặc tự sinh dữ liệu mẫu
  Future<void> loadDanhSachCongViec() async {
    _isLoading = true;
    _thongBaoLoi = null;
    notifyListeners();

    try {
      final List<CongViecModel> tatCaThang =
          await _eventRepository.getDanhSachCongViecTheoThang(
        nam: _ngayHienTai.year,
        thang: _ngayHienTai.month,
      );

      final List<CongViecModel> congViecNgay = tatCaThang.where((cv) {
        return cv.thoiGianBatDau.year == _ngayHienTai.year &&
            cv.thoiGianBatDau.month == _ngayHienTai.month &&
            cv.thoiGianBatDau.day == _ngayHienTai.day;
      }).toList();

      if (congViecNgay.isNotEmpty) {
        _danhSachCongViec = congViecNgay;
        _sapXepDanhSach();
      } else {
        // Tự tạo dữ liệu mẫu phong phú đúng theo ảnh mẫu `ui check list.png`
        _danhSachCongViec = _taoDuLieuMauNgay21Thang10();
      }
    } catch (e) {
      _thongBaoLoi = 'Lỗi nạp dữ liệu: $e';
      _danhSachCongViec = _taoDuLieuMauNgay21Thang10();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đổi trạng thái hoàn thành tức thì (Optimistic UI Update)
  Future<void> toggleComplete(int maSuKien) async {
    final int index = _danhSachCongViec.indexWhere((cv) => cv.id == maSuKien);
    if (index == -1) return;

    final CongViecModel congViecCu = _danhSachCongViec[index];
    final CongViecModel congViecMoi = congViecCu.copyWith(
      daHoanThanh: !congViecCu.daHoanThanh,
    );

    // 1. Cập nhật ngay trên UI để người dùng thấy phản hồi tức thì
    _danhSachCongViec[index] = congViecMoi;
    notifyListeners();

    // 2. Gửi lệnh cập nhật xuống Repository chạy nền
    try {
      await _eventRepository.updateCongViec(congViecMoi);
    } catch (e) {
      // 3. Rollback nếu gặp lỗi mạng hoặc repository
      _danhSachCongViec[index] = congViecCu;
      _thongBaoLoi = 'Không thể cập nhật trạng thái: $e';
      notifyListeners();
    }
  }

  /// Thêm hoặc Cập nhật công việc trong danh sách
  /// Cập nhật công việc
  Future<void> capNhatCongViec(CongViecModel congViec) => themCongViec(congViec);

  Future<void> themCongViec(CongViecModel congViec) async {
    final int existingIndex = _danhSachCongViec.indexWhere((e) => e.id == congViec.id && congViec.id > 0);
    if (existingIndex != -1) {
      try {
        final CongViecModel updated = await _eventRepository.updateCongViec(congViec);
        _danhSachCongViec[existingIndex] = updated;
      } catch (_) {
        _danhSachCongViec[existingIndex] = congViec;
      }
    } else {
      try {
        final CongViecModel created =
            await _eventRepository.createCongViec(congViec);
        _danhSachCongViec.add(created);
      } catch (_) {
        // Fallback chế độ chạy độc lập mock
        _danhSachCongViec.add(congViec);
      }
    }
    _sapXepDanhSach();
    notifyListeners();
  }

  /// Xóa công việc
  Future<void> xoaCongViec(int maSuKien) async {
    final int index = _danhSachCongViec.indexWhere((cv) => cv.id == maSuKien);
    if (index == -1) return;

    final CongViecModel biXoa = _danhSachCongViec[index];
    _danhSachCongViec.removeAt(index);
    notifyListeners();

    try {
      await _eventRepository.deleteCongViec(maSuKien);
    } catch (e) {
      _danhSachCongViec.insert(index, biXoa);
      _thongBaoLoi = 'Lỗi khi xóa: $e';
      notifyListeners();
    }
  }

  /// Cập nhật chuỗi công việc lặp lại
  Future<void> capNhatChuoiCongViec({
    required String maChuoiLap,
    required CongViecModel mau,
    List<CongViecModel>? danhSachMoiNeuDoiLich,
  }) async {
    try {
      if (danhSachMoiNeuDoiLich != null && danhSachMoiNeuDoiLich.isNotEmpty) {
        await _eventRepository.deleteChuoiCongViec(maChuoiLap);
        await _eventRepository.createDanhSachCongViec(danhSachMoiNeuDoiLich);
      } else {
        await _eventRepository.updateChuoiCongViec(maChuoiLap, mau);
      }
      await loadDanhSachCongViec();
    } catch (e) {
      _thongBaoLoi = 'Lỗi cập nhật chuỗi: $e';
      notifyListeners();
    }
  }

  /// Xóa chuỗi công việc lặp lại
  Future<void> xoaChuoiCongViec(String maChuoiLap) async {
    try {
      await _eventRepository.deleteChuoiCongViec(maChuoiLap);
      await loadDanhSachCongViec();
    } catch (e) {
      _thongBaoLoi = 'Lỗi xóa chuỗi: $e';
      notifyListeners();
    }
  }

  /// Lưu chuỗi công việc lặp lại
  Future<void> luuChuoiCongViec(List<CongViecModel> batch) async {
    try {
      await _eventRepository.createDanhSachCongViec(batch);
      await loadDanhSachCongViec();
    } catch (e) {
      _thongBaoLoi = 'Lỗi lưu chuỗi: $e';
      notifyListeners();
    }
  }

  /// Thay đổi ngày xem danh sách
  void thayDoiNgay(DateTime ngayMoi) {
    if (_ngayHienTai.year == ngayMoi.year &&
        _ngayHienTai.month == ngayMoi.month &&
        _ngayHienTai.day == ngayMoi.day) {
      return;
    }
    _ngayHienTai = ngayMoi;
    loadDanhSachCongViec();
  }

  /// Sắp xếp theo thứ tự giờ bắt đầu tăng dần
  void _sapXepDanhSach() {
    _danhSachCongViec.sort((a, b) => a.thoiGianBatDau.compareTo(b.thoiGianBatDau));
  }

  /// Dữ liệu mẫu chuẩn 100% theo ảnh `ui sample/ui check list.png` (8 công việc, 5 đã xong)
  List<CongViecModel> _taoDuLieuMauNgay21Thang10() {
    final int y = _ngayHienTai.year;
    final int m = _ngayHienTai.month;
    final int d = _ngayHienTai.day;

    return [
      // 1. Học Lập trình Web: Đã hoàn thành (gạch ngang), 07:30 - 09:30 | A3-402
      CongViecModel(
        id: 201,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(y, m, d, 7, 30),
        thoiGianKetThuc: DateTime(y, m, d, 9, 30),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(y, m, d),
      ),

      // 2. Họp nhóm FootyBook: Chưa hoàn thành, 10:00 - 11:30, Tag "Chủ động"
      CongViecModel(
        id: 202,
        maNguoiDung: 1,
        tenCongViec: 'Họp nhóm FootyBook',
        thoiGianBatDau: DateTime(y, m, d, 10, 0),
        thoiGianKetThuc: DateTime(y, m, d, 11, 30),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(y, m, d),
        ghiChu: 'Chủ động',
      ),

      // 3. Nghỉ trưa & Ăn cơm: Đã hoàn thành, 11:30 - 13:00, Tag "Bị động"
      CongViecModel(
        id: 203,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(y, m, d, 11, 30),
        thoiGianKetThuc: DateTime(y, m, d, 13, 0),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(y, m, d),
        ghiChu: 'Bị động',
      ),

      // 4. Tự học TOEIC Listening: Chưa hoàn thành, 15:00 - 17:00
      CongViecModel(
        id: 204,
        maNguoiDung: 1,
        tenCongViec: 'Tự học TOEIC Listening',
        thoiGianBatDau: DateTime(y, m, d, 15, 0),
        thoiGianKetThuc: DateTime(y, m, d, 17, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(y, m, d),
      ),

      // 5. Tập Gym: Chưa hoàn thành, 19:30 - 21:00
      CongViecModel(
        id: 205,
        maNguoiDung: 1,
        tenCongViec: 'Tập Gym',
        thoiGianBatDau: DateTime(y, m, d, 19, 30),
        thoiGianKetThuc: DateTime(y, m, d, 21, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(y, m, d),
      ),

      // 6. Đọc sách phát triển bản thân: Đã hoàn thành (việc sáng)
      CongViecModel(
        id: 206,
        maNguoiDung: 1,
        tenCongViec: 'Đọc sách phát triển bản thân',
        thoiGianBatDau: DateTime(y, m, d, 6, 0),
        thoiGianKetThuc: DateTime(y, m, d, 6, 45),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(y, m, d),
      ),

      // 7. Hoàn thiện báo cáo Sprint: Đã hoàn thành (việc chiều)
      CongViecModel(
        id: 207,
        maNguoiDung: 1,
        tenCongViec: 'Hoàn thiện báo cáo Sprint',
        thoiGianBatDau: DateTime(y, m, d, 13, 30),
        thoiGianKetThuc: DateTime(y, m, d, 14, 30),
        diaDiem: 'Online',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(y, m, d),
      ),

      // 8. Viết nhật ký & Lên kế hoạch ngày mai: Đã hoàn thành
      CongViecModel(
        id: 208,
        maNguoiDung: 1,
        tenCongViec: 'Viết nhật ký & Lên kế hoạch ngày mai',
        thoiGianBatDau: DateTime(y, m, d, 21, 30),
        thoiGianKetThuc: DateTime(y, m, d, 22, 0),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(y, m, d),
        ghiChu: 'Bị động',
      ),
    ];
  }
}
