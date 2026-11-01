import '../models/cong_viec_model.dart';
import 'i_event_repository.dart';

/// Triển khai Mock Repository với dữ liệu mẫu khớp 100% bản vẽ UI Lịch Tuần
class MockEventRepository implements IEventRepository {
  final List<CongViecModel> _danhSachMock = [];

  MockEventRepository() {
    _khoiTaoDuLieuMau();
  }

  void _khoiTaoDuLieuMau() {
    // Tuần 42 năm 2026 bắt đầu từ Thứ Hai ngày 12/10/2026
    final DateTime t2 = DateTime(2026, 10, 12);
    final DateTime t3 = DateTime(2026, 10, 13);
    final DateTime t5 = DateTime(2026, 10, 15);

    _danhSachMock.addAll([
      // Sự kiện 1: Học Lập trình Web (Thứ 2, 08:00 - 11:00, Phòng A3-402)
      CongViecModel(
        id: 1,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(t2.year, t2.month, t2.day, 8, 0),
        thoiGianKetThuc: DateTime(t2.year, t2.month, t2.day, 11, 0),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(2026, 10, 1, 8, 0),
        ghiChu: 'Mang theo laptop và chuẩn bị bài tập lớn',
      ),

      // Sự kiện 2: Nghỉ trưa & Ăn cơm (Thứ 3, 12:00 - 13:30, Thiết yếu, Đã hoàn thành)
      CongViecModel(
        id: 2,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 12, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 13, 30),
        diaDiem: 'Căn-tin trường',
        laThietYeu: true,
        daHoanThanh: true,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(2026, 10, 1, 8, 0),
      ),

      // Sự kiện 3: Học TOEIC (Thứ 5, 18:00 - 20:00)
      CongViecModel(
        id: 3,
        maNguoiDung: 1,
        tenCongViec: 'Học TOEIC',
        thoiGianBatDau: DateTime(t5.year, t5.month, t5.day, 18, 0),
        thoiGianKetThuc: DateTime(t5.year, t5.month, t5.day, 20, 0),
        diaDiem: 'Phòng học Online',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(2026, 10, 1, 8, 0),
      ),

      // Các việc khác trong tuần phục vụ tính toán Tiến độ ngày (Ví dụ ngày Thứ 3 có 8 việc, 5 việc đã xong = 62.5%)
      CongViecModel(
        id: 4,
        maNguoiDung: 1,
        tenCongViec: 'Tập thể dục buổi sáng',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 6, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 6, 45),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 5,
        maNguoiDung: 1,
        tenCongViec: 'Ăn sáng & Uống cà phê',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 7, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 7, 30),
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 6,
        maNguoiDung: 1,
        tenCongViec: 'Đọc tài liệu Flutter Architecture',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 8, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 9, 30),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 7,
        maNguoiDung: 1,
        tenCongViec: 'Họp nhóm Sprint Review',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 10, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 11, 30),
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 8,
        maNguoiDung: 1,
        tenCongViec: 'Code giao diện Weekly Grid',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 14, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 17, 0),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 9,
        maNguoiDung: 1,
        tenCongViec: 'Nấu cơm tối',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 18, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 19, 0),
        laThietYeu: true,
        daHoanThanh: false,
        ngayTao: DateTime(2026, 10, 1),
      ),
      CongViecModel(
        id: 10,
        maNguoiDung: 1,
        tenCongViec: 'Ôn tập từ vựng tiếng Anh',
        thoiGianBatDau: DateTime(t3.year, t3.month, t3.day, 20, 0),
        thoiGianKetThuc: DateTime(t3.year, t3.month, t3.day, 21, 30),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: DateTime(2026, 10, 1),
      ),
    ]);
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoTuan({
    required DateTime ngayDauTuan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final DateTime ngayCuoiTuan = ngayDauTuan.add(const Duration(days: 7));
    return _danhSachMock.where((congViec) {
      return congViec.thoiGianBatDau.isAfter(ngayDauTuan.subtract(const Duration(seconds: 1))) &&
             congViec.thoiGianBatDau.isBefore(ngayCuoiTuan);
    }).toList();
  }

  @override
  Future<CongViecModel> createCongViec(CongViecModel congViec) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final int newId = _danhSachMock.isEmpty ? 1 : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final CongViecModel newItem = congViec.copyWith(id: newId);
    _danhSachMock.add(newItem);
    return newItem;
  }

  @override
  Future<CongViecModel> updateCongViec(CongViecModel congViec) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final int index = _danhSachMock.indexWhere((e) => e.id == congViec.id);
    if (index != -1) {
      _danhSachMock[index] = congViec;
      return congViec;
    }
    _danhSachMock.add(congViec);
    return congViec;
  }

  @override
  Future<bool> deleteCongViec(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final int initialLength = _danhSachMock.length;
    _danhSachMock.removeWhere((e) => e.id == id);
    return _danhSachMock.length < initialLength;
  }
}
