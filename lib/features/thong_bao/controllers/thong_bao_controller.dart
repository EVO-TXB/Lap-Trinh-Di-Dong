import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/bo_nho/bo_nho_dich_vu.dart';
import '../../../core/thong_bao/cai_dat_thong_bao_model.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../../cong_viec/models/cong_viec_model.dart';
import '../widgets/popup_nhac_nho_dialog.dart';

/// ============================================================================
/// DỰ ÁN TIMASS - MODULE THÔNG BÁO NGƯỜI DÙNG (NOTIFICATION CONTROLLER)
/// Quản lý trạng thái thông báo, huy hiệu chưa đọc và điều phối Popup nhắc nhở
/// ============================================================================
class ThongBaoController extends ChangeNotifier {
  final DichVuThongBao _dichVuThongBao = DichVuThongBao.instance;
  final BoNhoDichVu? _boNhoDichVu;

  StreamSubscription<CongViecModel>? _thongBaoSubscription;

  // Công việc hiện tại đang được hiển thị popup
  CongViecModel? _congViecHienTai;
  CongViecModel? get congViecHienTai => _congViecHienTai;

  // Số lượng thông báo chưa đọc (để hiển thị badge chấm đỏ trên icon chuông)
  int _soLuongChuaDoc = 0;
  int get soLuongChuaDoc => _soLuongChuaDoc;
  bool get coThongBaoMoi => _soLuongChuaDoc > 0;

  // Cài đặt thông báo
  CaiDatThongBaoModel get caiDat => _dichVuThongBao.caiDat;

  // Lịch sử thông báo
  List<CongViecModel> get lichSuThongBao => _dichVuThongBao.lichSuThongBao;

  ThongBaoController({BoNhoDichVu? boNhoDichVu}) : _boNhoDichVu = boNhoDichVu {
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    final boNho = _boNhoDichVu;
    if (boNho != null) {
      await _dichVuThongBao.khoiTao(boNho);
    }

    // Lắng nghe sự kiện thông báo từ Scanner Service
    _thongBaoSubscription = _dichVuThongBao.streamThongBao.listen((congViec) {
      _congViecHienTai = congViec;
      _soLuongChuaDoc++;
      notifyListeners();
    });
  }

  /// Cập nhật cài đặt
  Future<void> capNhatCaiDat(CaiDatThongBaoModel caiDatMoi) async {
    await _dichVuThongBao.capNhatCaiDat(caiDatMoi, boNho: _boNhoDichVu);
    notifyListeners();
  }

  /// Bật / tắt thông báo nhanh
  Future<void> toggleBatThongBao(bool value) async {
    await capNhatCaiDat(caiDat.copyWith(batThongBao: value));
  }

  /// Bật / tắt tự động tích hoàn thành việc thiết yếu
  Future<void> toggleTuDongTichViecThietYeu(bool value) async {
    await capNhatCaiDat(caiDat.copyWith(tuDongTichViecThietYeu: value));
  }

  /// Đánh dấu đã đọc tất cả thông báo
  void danhDauDaDoc() {
    _soLuongChuaDoc = 0;
    notifyListeners();
  }

  /// Mở Dialog Popup Nhắc nhở cho một công việc
  void moPopupNhacNho(
    BuildContext context,
    CongViecModel congViec, {
    VoidCallback? onXemChiTiet,
  }) {
    PopupNhacNhoDialog.show(
      context,
      congViec: congViec,
      onXemChiTiet: onXemChiTiet,
      onHoanBaoSnooze: () {
        _dichVuThongBao.hoanBaoSnooze(congViec.id, soPhut: 5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hoãn nhắc nhở "${congViec.tenCongViec}" thêm 5 phút.'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onDong: () {
        _dichVuThongBao.boQuaThongBao(congViec.id);
      },
    );
  }

  /// Kích hoạt một thông báo thử nghiệm để kiểm tra tính năng ngay lập tức
  void kichHoatThongBaoThu(BuildContext context, {VoidCallback? onXemChiTiet}) {
    final DateTime now = DateTime.now();
    final CongViecModel congViecMau = CongViecModel(
      id: 9999,
      maNguoiDung: 1,
      tenCongViec: 'Lập trình Web nâng cao',
      thoiGianBatDau: now.add(const Duration(minutes: 15)),
      thoiGianKetThuc: now.add(const Duration(minutes: 105)),
      diaDiem: 'Phòng A3-402',
      laThietYeu: false,
      daHoanThanh: false,
      nhacNhoTruocPhut: 15,
      ngayTao: now,
    );

    _dichVuThongBao.kichHoatThongBaoThuCong(congViecMau);
    moPopupNhacNho(context, congViecMau, onXemChiTiet: onXemChiTiet);
  }

  @override
  void dispose() {
    _thongBaoSubscription?.cancel();
    super.dispose();
  }
}
