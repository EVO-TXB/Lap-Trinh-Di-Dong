import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cong_viec_model.dart';
import 'i_event_repository.dart';

/// Triển khai Mock Repository hỗ trợ đa tài khoản và lưu trữ bền vững (SharedPreferences)
class MockEventRepository implements IEventRepository {
  static final Map<int, MockEventRepository> _instances = {};
  static int currentUserId = 1;

  final int userId;
  final List<CongViecModel> _danhSachMock = [];
  bool _daKhoiTao = false;

  factory MockEventRepository({int? userId}) {
    final int uid = userId ?? currentUserId;
    return _instances.putIfAbsent(uid, () => MockEventRepository._internal(uid));
  }

  List<CongViecModel> get tatCaCongViecHienCo =>
      List.unmodifiable(_danhSachMock.where((e) => e.maNguoiDung == userId));

  MockEventRepository._internal(this.userId) {
    if (userId == 1) {
      _khoiTaoDuLieuMau();
    }
  }

  SharedPreferences? _cachedPrefs;

  Future<SharedPreferences?> _getPrefsSafely() async {
    if (_cachedPrefs != null) return _cachedPrefs;
    try {
      _cachedPrefs = await SharedPreferences.getInstance();
      return _cachedPrefs;
    } catch (_) {
      return null;
    }
  }

  /// Đảm bảo dữ liệu của tài khoản đã được nạp từ SharedPreferences
  Future<void> _damBaoDaKhoiTao() async {
    if (_daKhoiTao) return;
    _daKhoiTao = true;

    try {
      final prefs = await _getPrefsSafely();
      if (prefs == null) {
        if (_danhSachMock.isEmpty && userId == 1) {
          _khoiTaoDuLieuMau();
        }
        return;
      }

      final String key = 'timass_events_user_$userId';
      final String? jsonStr = prefs.getString(key);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _danhSachMock.clear();
        for (final item in list) {
          try {
            _danhSachMock.add(CongViecModel.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (e) {
            debugPrint('Lỗi parse công việc: $e');
          }
        }
      } else {
        // Chưa có dữ liệu lưu trong SharedPreferences cho user này
        _danhSachMock.clear();
        if (userId == 1) {
          // Tài khoản mặc định hệ thống: nạp dữ liệu mẫu ban đầu
          _khoiTaoDuLieuMau();
          await _luuVaoPrefs();
        } else {
          // Tài khoản mới tạo: khởi tạo danh sách rỗng hoàn toàn
          await _luuVaoPrefs();
        }
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo MockEventRepository: $e');
      if (_danhSachMock.isEmpty && userId == 1) {
        _khoiTaoDuLieuMau();
      }
    }
  }

  /// Lưu danh sách công việc của tài khoản hiện tại vào SharedPreferences
  Future<void> _luuVaoPrefs() async {
    try {
      final prefs = await _getPrefsSafely();
      if (prefs == null) return;
      final String key = 'timass_events_user_$userId';
      final String jsonStr = jsonEncode(
        _danhSachMock.where((e) => e.maNguoiDung == userId).map((e) => e.toJson()).toList(),
      );
      await prefs.setString(key, jsonStr);
    } catch (e) {
      debugPrint('Lỗi lưu danh sách công việc vào SharedPreferences: $e');
    }
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
        maChuoiLap: 'chuoi_hoc_web',
      ),
      CongViecModel(
        id: 108,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(nam, thang, 14, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, 14, 11, 0),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(nam, thang, 1, 8, 0),
        maChuoiLap: 'chuoi_hoc_web',
      ),
      CongViecModel(
        id: 109,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Web',
        thoiGianBatDau: DateTime(nam, thang, 16, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, 16, 11, 0),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(nam, thang, 1, 8, 0),
        maChuoiLap: 'chuoi_hoc_web',
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

    // Tự động sinh dữ liệu thời gian thực xoay quanh ngày hôm nay trên thiết bị
    _sinhDuLieuThoiGianThuc(DateTime.now());
  }

  /// Sinh dữ liệu mẫu xoay quanh thời gian thực tế của thiết bị
  void _sinhDuLieuThoiGianThuc(DateTime now) {
    final int nam = now.year;
    final int thang = now.month;
    final int ngay = now.day;

    // Nếu ngày hôm nay đã trùng với dữ liệu mẫu tháng 10/2026 thì không sinh thêm để tránh trùng lặp
    if (nam == 2026 && thang == 10 && (ngay == 12 || ngay == 13 || ngay == 14 || ngay == 15 || ngay == 21)) {
      return;
    }

    int currentMaxId = _danhSachMock.isEmpty ? 500 : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b);

    _danhSachMock.addAll([
      CongViecModel(
        id: ++currentMaxId,
        maNguoiDung: 1,
        tenCongViec: 'Học Lập trình Flutter & Dart',
        thoiGianBatDau: DateTime(nam, thang, ngay, 8, 0),
        thoiGianKetThuc: DateTime(nam, thang, ngay, 10, 30),
        diaDiem: 'Phòng Lab 3',
        laThietYeu: false,
        daHoanThanh: true,
        ngayTao: now,
      ),
      CongViecModel(
        id: ++currentMaxId,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(nam, thang, ngay, 11, 30),
        thoiGianKetThuc: DateTime(nam, thang, ngay, 13, 0),
        diaDiem: 'Căn-tin trường',
        laThietYeu: true,
        daHoanThanh: true,
        ngayTao: now,
      ),
      CongViecModel(
        id: ++currentMaxId,
        maNguoiDung: 1,
        tenCongViec: 'Thực hành dự án Timass',
        thoiGianBatDau: DateTime(nam, thang, ngay, 14, 0),
        thoiGianKetThuc: DateTime(nam, thang, ngay, 16, 30),
        diaDiem: 'A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: now,
      ),
      CongViecModel(
        id: ++currentMaxId,
        maNguoiDung: 1,
        tenCongViec: 'Tập thể thao & Tự học',
        thoiGianBatDau: DateTime(nam, thang, ngay, 18, 0),
        thoiGianKetThuc: DateTime(nam, thang, ngay, 19, 30),
        diaDiem: 'Sân trường',
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: now,
      ),
    ]);

    // Bổ sung dữ liệu sự kiện cho các ngày lân cận trong tháng thực tế để lịch tháng hiển thị phong phú
    final List<int> offsetDays = [-5, -3, -1, 1, 2, 4, 6];
    for (final offset in offsetDays) {
      final DateTime targetDate = now.add(Duration(days: offset));
      _danhSachMock.addAll([
        CongViecModel(
          id: ++currentMaxId,
          maNguoiDung: 1,
          tenCongViec: offset.isEven ? 'Học Lập trình Di động' : 'Họp nhóm đồ án Timass',
          thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 30),
          thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 11, 0),
          diaDiem: 'Phòng Lab 3',
          laThietYeu: false,
          daHoanThanh: offset < 0,
          ngayTao: now,
        ),
        CongViecModel(
          id: ++currentMaxId,
          maNguoiDung: 1,
          tenCongViec: 'Ăn trưa & Nghỉ ngơi',
          thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0),
          thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 13, 0),
          diaDiem: 'Căn-tin',
          laThietYeu: true,
          daHoanThanh: offset < 0,
          ngayTao: now,
        ),
        CongViecModel(
          id: ++currentMaxId,
          maNguoiDung: 1,
          tenCongViec: 'Luyện tập & Thực hành code',
          thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 15, 0),
          thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 17, 0),
          diaDiem: 'Thư viện',
          laThietYeu: false,
          daHoanThanh: false,
          ngayTao: now,
        ),
      ]);
    }
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoTuan({
    required DateTime ngayDauTuan,
  }) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final DateTime ngayCuoiTuan = ngayDauTuan.add(const Duration(days: 7));
    return _danhSachMock.where((congViec) {
      return congViec.maNguoiDung == userId &&
             congViec.thoiGianBatDau.isAfter(ngayDauTuan.subtract(const Duration(seconds: 1))) &&
             congViec.thoiGianBatDau.isBefore(ngayCuoiTuan);
    }).toList();
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoThang({
    required int nam,
    required int thang,
  }) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    return _danhSachMock.where((congViec) {
      return congViec.maNguoiDung == userId &&
             congViec.thoiGianBatDau.year == nam &&
             congViec.thoiGianBatDau.month == thang;
    }).toList();
  }

  @override
  Future<CongViecModel> createCongViec(CongViecModel congViec) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final int newId = _danhSachMock.isEmpty
        ? (userId * 1000 + 1)
        : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final CongViecModel newItem = congViec.copyWith(id: newId, maNguoiDung: userId);
    _danhSachMock.add(newItem);
    await _luuVaoPrefs();
    return newItem;
  }

  @override
  Future<CongViecModel> updateCongViec(CongViecModel congViec) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final CongViecModel itemToSave = congViec.copyWith(maNguoiDung: userId);
    final int index = _danhSachMock.indexWhere((e) => e.id == congViec.id);
    if (index != -1) {
      _danhSachMock[index] = itemToSave;
    } else {
      _danhSachMock.add(itemToSave);
    }
    await _luuVaoPrefs();
    return itemToSave;
  }

  @override
  Future<List<CongViecModel>> getDanhSachCongViecTheoNgay(DateTime ngay) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    return _danhSachMock.where((congViec) {
      return congViec.maNguoiDung == userId &&
             congViec.thoiGianBatDau.year == ngay.year &&
             congViec.thoiGianBatDau.month == ngay.month &&
             congViec.thoiGianBatDau.day == ngay.day;
    }).toList();
  }

  @override
  Future<List<CongViecModel>> getAllCongViec() async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    return _danhSachMock.where((e) => e.maNguoiDung == userId).toList();
  }

  @override
  Future<List<CongViecModel>> createDanhSachCongViec(List<CongViecModel> danhSach) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    int currentMaxId = _danhSachMock.isEmpty
        ? (userId * 1000)
        : _danhSachMock.map((e) => e.id).reduce((a, b) => a > b ? a : b);
    final List<CongViecModel> ketQua = [];
    for (final cv in danhSach) {
      currentMaxId++;
      final CongViecModel newItem = cv.copyWith(id: currentMaxId, maNguoiDung: userId);
      _danhSachMock.add(newItem);
      ketQua.add(newItem);
    }
    await _luuVaoPrefs();
    return ketQua;
  }

  @override
  Future<List<CongViecModel>> updateChuoiCongViec(String maChuoiLap, CongViecModel mauCapNhat) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final List<CongViecModel> ketQua = [];
    for (int i = 0; i < _danhSachMock.length; i++) {
      final cv = _danhSachMock[i];
      if ((cv.maChuoiLap == maChuoiLap || cv.maQuyTacLap?.toString() == maChuoiLap) && cv.maNguoiDung == userId) {
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
          ghiChu: mauCapNhat.ghiChu,
          nhacNhoTruocPhut: mauCapNhat.nhacNhoTruocPhut,
          thoiGianBatDau: batDauMoi,
          thoiGianKetThuc: ketThucMoi,
          maNguoiDung: userId,
        );
        _danhSachMock[i] = updated;
        ketQua.add(updated);
      }
    }
    await _luuVaoPrefs();
    return ketQua;
  }

  @override
  Future<bool> deleteCongViec(int id) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final int initialLength = _danhSachMock.length;
    _danhSachMock.removeWhere((e) => e.id == id && e.maNguoiDung == userId);
    final bool removed = _danhSachMock.length < initialLength;
    if (removed) {
      await _luuVaoPrefs();
    }
    return removed;
  }

  @override
  Future<bool> deleteChuoiCongViec(String maChuoiLap) async {
    await _damBaoDaKhoiTao();
    await Future.delayed(const Duration(milliseconds: 60));
    final int initialLength = _danhSachMock.length;
    _danhSachMock.removeWhere((e) =>
        (e.maChuoiLap == maChuoiLap || e.maQuyTacLap?.toString() == maChuoiLap) &&
        e.maNguoiDung == userId);
    final bool removed = _danhSachMock.length < initialLength;
    if (removed) {
      await _luuVaoPrefs();
    }
    return removed;
  }

  /// Đặt lại toàn bộ dữ liệu mẫu ban đầu (dùng cho unit test & reset)
  Future<void> datLaiDuLieuMau() async {
    _danhSachMock.clear();
    if (userId == 1) {
      _khoiTaoDuLieuMau();
    }
    await _luuVaoPrefs();
  }

  /// Xóa toàn bộ bộ nhớ đệm đa tài khoản
  static void xoaBoNhoDem() {
    _instances.clear();
  }
}
