import '../models/cong_viec_model.dart';
import 'i_event_repository.dart';

/// Triển khai Mock Repository với dữ liệu mẫu phong phú phục vụ cả Lịch tuần và Lịch tháng
class MockEventRepository implements IEventRepository {
  static final MockEventRepository _instance = MockEventRepository._internal();
  factory MockEventRepository() => _instance;

  final List<CongViecModel> _danhSachMock = [];

  MockEventRepository._internal() {
    _khoiTaoDuLieuMau();
  }

  void _khoiTaoDuLieuMau() {
    // Tháng 10 năm 2026
    const int nam = 2026;
    const int thang = 10;

    _danhSachMock.addAll([
      // --- Ngày 05/10/2026 ---
      CongViecModel(
        id: 101,
        maNguoiDung: 1,
        tenCongViec: 'Khởi động đồ án tốt nghiệp',
        thoiGianBatDau: DateTime(nam, thang, 5, 8, 30),
        thoiGianKetThuc: DateTime(nam, thang, 5, 10, 30),
        diaDiem: 'Phòng Lab 2',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 102,
        maNguoiDung: 1,
        tenCongViec: 'Ăn trưa & Nghỉ ngơi',
        thoiGianBatDau: DateTime(nam, thang, 5, 12, 0),
        thoiGianKetThuc: DateTime(nam, thang, 5, 13, 0),
        diaDiem: 'Căn-tin trường',
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Ngày 08/10/2026 ---
      CongViecModel(
        id: 103,
        maNguoiDung: 1,
        tenCongViec: 'Học ngữ pháp TOEIC căn bản',
        thoiGianBatDau: DateTime(nam, thang, 8, 19, 0),
        thoiGianKetThuc: DateTime(nam, thang, 8, 20, 30),
        diaDiem: 'Online Zoom',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Tuần 42: Thứ Hai 12/10/2026 ---
      CongViecModel(
        id: 1,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(nam, thang, 12, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, 12, 11, 0),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(nam, thang, 1, 8, 0),
        ghiChu: 'Mang theo laptop và chuẩn bị bài tập lớn',
      ),

      // --- Thứ Ba 13/10/2026 (Nhiều việc để hiển thị 2 chấm + dấu "+") ---
      CongViecModel(
        id: 2,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(nam, thang, 13, 12, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 13, 30),
        diaDiem: 'Căn-tin trường',
        laThietYeu: true,
        daHoanThanh: true,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(nam, thang, 1, 8, 0),
      ),
      CongViecModel(
        id: 4,
        maNguoiDung: 1,
        tenCongViec: 'Tập thể dục buổi sáng',
        thoiGianBatDau: DateTime(nam, thang, 13, 6, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 6, 45),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 5,
        maNguoiDung: 1,
        tenCongViec: 'Ăn sáng & Uống cà phê',
        thoiGianBatDau: DateTime(nam, thang, 13, 7, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 7, 30),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 6,
        maNguoiDung: 1,
        tenCongViec: 'Đọc tài liệu Flutter Architecture',
        thoiGianBatDau: DateTime(nam, thang, 13, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 9, 30),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 7,
        maNguoiDung: 1,
        tenCongViec: 'Họp nhóm Sprint Review',
        thoiGianBatDau: DateTime(nam, thang, 13, 10, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 11, 30),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 8,
        maNguoiDung: 1,
        tenCongViec: 'Code giao diện Weekly Grid',
        thoiGianBatDau: DateTime(nam, thang, 13, 14, 0),
        thoiGianKetThuc: DateTime(nam, thang, 13, 17, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Thứ Tư 14/10/2026 ---
      CongViecModel(
        id: 104,
        maNguoiDung: 1,
        tenCongViec: 'Gặp cố vấn hướng dẫn đồ án',
        thoiGianBatDau: DateTime(nam, thang, 14, 9, 0),
        thoiGianKetThuc: DateTime(nam, thang, 14, 10, 30),
        diaDiem: 'Văn phòng khoa CNTT',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Thứ Năm 15/10/2026 ---
      CongViecModel(
        id: 3,
        maNguoiDung: 1,
        tenCongViec: 'Học TOEIC',
        thoiGianBatDau: DateTime(nam, thang, 15, 18, 0),
        thoiGianKetThuc: DateTime(nam, thang, 15, 20, 0),
        diaDiem: 'Phòng học Online',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(nam, thang, 1, 8, 0),
      ),

      // --- Thứ Ba 20/10/2026 ---
      CongViecModel(
        id: 105,
        maNguoiDung: 1,
        tenCongViec: 'Làm bài tập Spring Data JPA',
        thoiGianBatDau: DateTime(nam, thang, 20, 14, 0),
        thoiGianKetThuc: DateTime(nam, thang, 20, 16, 30),
        diaDiem: 'Thư viện trường',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 106,
        maNguoiDung: 1,
        tenCongViec: 'Nấu ăn tối cùng bạn',
        thoiGianBatDau: DateTime(nam, thang, 20, 18, 30),
        thoiGianKetThuc: DateTime(nam, thang, 20, 20, 0),
        laThietYeu: true,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Thứ Tư 21/10/2026 (Checklist Screen UI Sample) ---
      CongViecModel(
        id: 201,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(nam, thang, 21, 7, 30),
        thoiGianKetThuc: DateTime(nam, thang, 21, 9, 30),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 202,
        maNguoiDung: 1,
        tenCongViec: 'Họp nhóm FootyBook',
        thoiGianBatDau: DateTime(nam, thang, 21, 10, 0),
        thoiGianKetThuc: DateTime(nam, thang, 21, 11, 30),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
        ghiChu: 'Chủ động',
      ),
      CongViecModel(
        id: 203,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(nam, thang, 21, 11, 30),
        thoiGianKetThuc: DateTime(nam, thang, 21, 13, 0),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
        ghiChu: 'Bị động',
      ),
      CongViecModel(
        id: 204,
        maNguoiDung: 1,
        tenCongViec: 'Tự học TOEIC Listening',
        thoiGianBatDau: DateTime(nam, thang, 21, 15, 0),
        thoiGianKetThuc: DateTime(nam, thang, 21, 17, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 205,
        maNguoiDung: 1,
        tenCongViec: 'Tập Gym',
        thoiGianBatDau: DateTime(nam, thang, 21, 19, 30),
        thoiGianKetThuc: DateTime(nam, thang, 21, 21, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 206,
        maNguoiDung: 1,
        tenCongViec: 'Đọc sách phát triển bản thân',
        thoiGianBatDau: DateTime(nam, thang, 21, 6, 0),
        thoiGianKetThuc: DateTime(nam, thang, 21, 6, 45),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 207,
        maNguoiDung: 1,
        tenCongViec: 'Hoàn thiện báo cáo Sprint',
        thoiGianBatDau: DateTime(nam, thang, 21, 13, 30),
        thoiGianKetThuc: DateTime(nam, thang, 21, 14, 30),
        diaDiem: 'Online',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 208,
        maNguoiDung: 1,
        tenCongViec: 'Viết nhật ký & Lên kế hoạch ngày mai',
        thoiGianBatDau: DateTime(nam, thang, 21, 21, 30),
        thoiGianKetThuc: DateTime(nam, thang, 21, 22, 0),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(nam, thang, 1),
        ghiChu: 'Bị động',
      ),

      // --- Thứ Bảy 24/10/2026 ---
      CongViecModel(
        id: 107,
        maNguoiDung: 1,
        tenCongViec: 'Hội thảo Mobile Developer 2026',
        thoiGianBatDau: DateTime(nam, thang, 24, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, 24, 11, 30),
        diaDiem: 'Hội trường lớn A1',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),
      CongViecModel(
        id: 108,
        maNguoiDung: 1,
        tenCongViec: 'Gặp gỡ bạn bè cuối tuần',
        thoiGianBatDau: DateTime(nam, thang, 24, 14, 0),
        thoiGianKetThuc: DateTime(nam, thang, 24, 16, 0),
        diaDiem: 'Highlands Coffee',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),

      // --- Thứ Tư 28/10/2026 ---
      CongViecModel(
        id: 109,
        maNguoiDung: 1,
        tenCongViec: 'Thi thử TOEIC Online Mock Test',
        thoiGianBatDau: DateTime(nam, thang, 28, 19, 0),
        thoiGianKetThuc: DateTime(nam, thang, 28, 21, 0),
        diaDiem: 'Phòng làm việc tại nhà',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(nam, thang, 1),
      ),
    ]);
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoTuan({
    required DateTime ngayDauTuan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final DateTime ngayCuoiTuan = ngayDauTuan.add(const Duration(days: 7));
    return _danhSachMock.where((congViec) {
      return congViec.thoiGianBatDau.isAfter(ngayDauTuan.subtract(const Duration(seconds: 1))) &&
             congViec.thoiGianBatDau.isBefore(ngayCuoiTuan);
    }).toList();
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoThang({
    required int nam,
    required int thang,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
    return _danhSachMock.where((congViec) {
      return congViec.thoiGianBatDau.year == nam && congViec.thoiGianBatDau.month == thang;
    }).toList();
  }

  @override
  Future<CongViecModel> createCongViec(CongViecModel congViec) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final int newId = _danhSachMock.isEmpty ? 1 : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final CongViecModel newItem = congViec.copyWith(id: newId);
    _danhSachMock.add(newItem);
    return newItem;
  }

  @override
  Future<CongViecModel> updateCongViec(CongViecModel congViec) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final int index = _danhSachMock.indexWhere((e) => e.id == congViec.id);
    if (index != -1) {
      _danhSachMock[index] = congViec;
      return congViec;
    }
    _danhSachMock.add(congViec);
    return congViec;
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoNgay(DateTime ngay) async {
    await Future.delayed(const Duration(milliseconds: 60));
    return _danhSachMock.where((congViec) {
      return congViec.thoiGianBatDau.year == ngay.year &&
             congViec.thoiGianBatDau.month == ngay.month &&
             congViec.thoiGianBatDau.day == ngay.day;
    }).toList();
  }

  @override
  Future<List<CongViecModel>> getAllCongViec() async {
    await Future.delayed(const Duration(milliseconds: 60));
    return List.from(_danhSachMock);
  }

  @override
  Future<List<CongViecModel>> createDanhSachCongViec(List<CongViecModel> danhSach) async {
    await Future.delayed(const Duration(milliseconds: 60));
    int currentMaxId = _danhSachMock.isEmpty ? 0 : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b);
    final List<CongViecModel> ketQua = [];
    for (final cv in danhSach) {
      currentMaxId++;
      final CongViecModel newItem = cv.copyWith(id: currentMaxId);
      _danhSachMock.add(newItem);
      ketQua.add(newItem);
    }
    return ketQua;
  }

  @override
  Future<List<CongViecModel>> updateChuoiCongViec(String maChuoiLap, CongViecModel mauCapNhat) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final List<CongViecModel> ketQua = [];
    for (int i = 0; i < _danhSachMock.length; i++) {
      final cv = _danhSachMock[i];
      if (cv.maChuoiLap == maChuoiLap || cv.maQuyTacLap?.toString() == maChuoiLap) {
        final DateTime batDauMoi = DateTime(
          cv.thoiGianBatDau.year,
          cv.thoiGianBatDau.month,
          cv.thoiGianBatDau.day,
          mauCapNhat.thoiGianBatDau.hour,
          mauCapNhat.thoiGianBatDau.minute,
        );
        final DateTime ketThucMoi = DateTime(
          cv.thoiGianKetThuc.year,
          cv.thoiGianKetThuc.month,
          cv.thoiGianKetThuc.day,
          mauCapNhat.thoiGianKetThuc.hour,
          mauCapNhat.thoiGianKetThuc.minute,
        );

        final CongViecModel updated = cv.copyWith(
          tenCongViec: mauCapNhat.tenCongViec,
          loaiSuKien: mauCapNhat.loaiSuKien,
          laThietYeu: mauCapNhat.laThietYeu,
          diaDiem: mauCapNhat.diaDiem,
          thoiGianBatDau: batDauMoi,
          thoiGianKetThuc: ketThucMoi,
        );
        _danhSachMock[i] = updated;
        ketQua.add(updated);
      }
    }
    return ketQua;
  }

  @override
  Future<bool> deleteCongViec(int id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final int initialLength = _danhSachMock.length;
    _danhSachMock.removeWhere((e) => e.id == id);
    return _danhSachMock.length < initialLength;
  }

  @override
  Future<bool> deleteChuoiCongViec(String maChuoiLap) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final int initialLength = _danhSachMock.length;
    _danhSachMock.removeWhere((e) => e.maChuoiLap == maChuoiLap || e.maQuyTacLap?.toString() == maChuoiLap);
    return _danhSachMock.length < initialLength;
  }

  /// Đặt lại toàn bộ dữ liệu mẫu ban đầu (dùng cho unit test & reset)
  void datLaiDuLieuMau() {
    _danhSachMock.clear();
    _khoiTaoDuLieuMau();
  }
}
