import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/cong_viec/models/cong_viec_model.dart';
import '../bo_nho/bo_nho_dich_vu.dart';
import 'cai_dat_thong_bao_model.dart';

/// Dịch vụ quét thông báo nhắc nhở & tác vụ tự động chạy ngầm (Notification Scanner & Background Automation)
/// Tuân thủ quy chuẩn AI_rules.md: đặt tên camelCase tiếng Việt, độc lập, không hardcode.
class DichVuThongBao {
  static final DichVuThongBao _instance = DichVuThongBao._internal();
  factory DichVuThongBao() => _instance;
  static DichVuThongBao get instance => _instance;

  DichVuThongBao._internal();

  // Khóa lưu SharedPreferences
  static const String _khoaCaiDat = 'timass_cai_dat_thong_bao';

  // Cấu hình cài đặt
  CaiDatThongBaoModel _caiDat = const CaiDatThongBaoModel();
  CaiDatThongBaoModel get caiDat => _caiDat;

  // Stream phát sự kiện popup thông báo cho UI toàn app lắng nghe
  final StreamController<CongViecModel> _streamThongBao =
      StreamController<CongViecModel>.broadcast();
  Stream<CongViecModel> get streamThongBao => _streamThongBao.stream;

  // Bộ nhớ đệm danh sách sự kiện đã thông báo và danh sách hẹn báo lại (Snooze)
  final Set<int> _danhSachIdDaThongBao = {};
  final Map<int, DateTime> _danhSachSnooze = {};

  // Lịch sử các thông báo gần đây
  final List<CongViecModel> _lichSuThongBao = [];
  List<CongViecModel> get lichSuThongBao => List.unmodifiable(_lichSuThongBao);

  // Timer tác vụ nền định kỳ (Worker)
  Timer? _automationTimer;
  bool get dangChayNen => _automationTimer != null && _automationTimer!.isActive;

  /// Khởi tạo nạp cài đặt từ bộ nhớ
  Future<void> khoiTao(BoNhoDichVu boNho) async {
    final String? duLieuCaiDat = boNho.layChuoi(_khoaCaiDat);
    if (duLieuCaiDat != null && duLieuCaiDat.isNotEmpty) {
      try {
        _caiDat = CaiDatThongBaoModel.fromJson(duLieuCaiDat);
      } catch (e) {
        debugPrint('Lỗi nạp cài đặt thông báo: $e');
      }
    }
  }

  /// Cập nhật cài đặt thông báo
  Future<void> capNhatCaiDat(CaiDatThongBaoModel caiDatMoi, {BoNhoDichVu? boNho}) async {
    _caiDat = caiDatMoi;
    if (boNho != null) {
      await boNho.luuChuoi(_khoaCaiDat, _caiDat.toJson());
    }
  }

  /// Khởi động tác vụ chạy ngầm quét định kỳ (mỗi 30s - 1 phút)
  void batDauTacVuNen({
    Duration chuKy = const Duration(seconds: 30),
    required VoidCallback onTick,
  }) {
    _automationTimer?.cancel();
    _automationTimer = Timer.periodic(chuKy, (_) => onTick());
  }

  /// Dừng tác vụ chạy ngầm
  void dungTacVuNen() {
    _automationTimer?.cancel();
    _automationTimer = null;
  }

  /// Quét thông báo & Thực hiện tự động hóa
  /// 1. Notification Scanner: Tìm các sự kiện bắt đầu trong vòng 15 phút tới chưa thông báo
  /// 2. Auto-Complete Passive Events: Tự động tích hoàn thành việc thiết yếu/bị động khi quá giờ
  Future<void> quetThongBaoVaTuDongHoa({
    required List<CongViecModel> danhSachCongViec,
    required DateTime thoiGianHienTai,
    Function(CongViecModel congViec)? onPhatThongBao,
    Function(CongViecModel congViec)? onTuDongHoanThanh,
  }) async {
    // -------------------------------------------------------------
    // LOGIC 1: NOTIFICATION SCANNER (Nhắc nhở sắp đến giờ)
    // -------------------------------------------------------------
    if (_caiDat.batThongBao) {
      for (final cv in danhSachCongViec) {
        if (cv.daHoanThanh) continue;

        // Tính khoảng cách thời gian từ hiện tại tới giờ bắt đầu
        final int chenhLechPhut = cv.thoiGianBatDau.difference(thoiGianHienTai).inMinutes;

        // Kiểm tra xem sự kiện có đang trong khoảng báo trước (ví dụ <= 15 phút và >= -2 phút)
        final bool trongKhoangBao = chenhLechPhut <= _caiDat.nhacTruocPhut && chenhLechPhut >= -2;

        // Kiểm tra điều kiện Snooze (Nhắc lại sau 5 phút)
        final DateTime? thoiGianSnooze = _danhSachSnooze[cv.id];
        final bool dangSnooze = thoiGianSnooze != null;
        final bool hetHanSnooze = dangSnooze &&
            (thoiGianHienTai.isAfter(thoiGianSnooze) ||
                thoiGianHienTai.isAtSameMomentAs(thoiGianSnooze));

        final bool chuaBao = !_danhSachIdDaThongBao.contains(cv.id);

        if ((!dangSnooze && trongKhoangBao && chuaBao) || hetHanSnooze) {
          // Đánh dấu đã thông báo và xóa trạng thái Snooze cũ
          _danhSachIdDaThongBao.add(cv.id);
          _danhSachSnooze.remove(cv.id);

          // Thêm vào lịch sử thông báo
          if (!_lichSuThongBao.any((e) => e.id == cv.id)) {
            _lichSuThongBao.insert(0, cv);
          }

          // Phát ra Stream để UI hiển thị Popup PopupNhacNhoDialog
          _streamThongBao.add(cv);

          // Kích hoạt callback nghiệp vụ
          onPhatThongBao?.call(cv);
        }
      }
    }

    // -------------------------------------------------------------
    // LOGIC 2: AUTO-COMPLETE PASSIVE EVENTS (Tự động tích việc thiết yếu)
    // -------------------------------------------------------------
    if (_caiDat.tuDongTichViecThietYeu) {
      for (final cv in danhSachCongViec) {
        // Chỉ xử lý các công việc thiết yếu / bị động (ăn, ngủ, nghỉ...)
        if (cv.laViecBiDong && !cv.daHoanThanh) {
          // Nếu thời gian hiện tại đã vượt qua thời gian kết thúc
          if (thoiGianHienTai.isAfter(cv.thoiGianKetThuc)) {
            onTuDongHoanThanh?.call(cv);
          }
        }
      }
    }
  }

  /// Xử lý hoãn báo (Snooze) - Nhắc lại sau 5 phút
  void hoanBaoSnooze(int congViecId, {int soPhut = 5, DateTime? tuThoiDiem}) {
    final mocBatDau = tuThoiDiem ?? DateTime.now();
    _danhSachSnooze[congViecId] = mocBatDau.add(Duration(minutes: soPhut));
    _danhSachIdDaThongBao.add(congViecId);
  }

  /// Bỏ qua không nhắc lại công việc này nữa
  void boQuaThongBao(int congViecId) {
    _danhSachIdDaThongBao.add(congViecId);
    _danhSachSnooze.remove(congViecId);
  }

  /// Xóa sạch bộ nhớ đệm thông báo (dùng khi đăng xuất hoặc test lại)
  void datLaiBoNhoThongBao() {
    _danhSachIdDaThongBao.clear();
    _danhSachSnooze.clear();
    _lichSuThongBao.clear();
  }

  /// Kích hoạt thông báo thủ công (phục vụ người dùng bấm kiểm thử hoặc bấm vào chuông)
  void kichHoatThongBaoThuCong(CongViecModel congViec) {
    _streamThongBao.add(congViec);
  }

  void dispose() {
    _automationTimer?.cancel();
    _streamThongBao.close();
  }
}
