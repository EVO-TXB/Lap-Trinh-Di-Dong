import 'package:flutter/material.dart';
import '../../../core/bo_nho/bo_nho_dich_vu.dart';
import '../../../core/thong_bao/cai_dat_thong_bao_model.dart';
import '../../../core/thong_bao/dich_vu_thong_bao.dart';
import '../models/cai_dat_model.dart';

/// Bộ điều khiển quản lý Cài đặt hệ thống & Tùy chọn ứng dụng (SettingsController)
/// Tuân thủ quy chuẩn AI_rules.md: ChangeNotifier, lưu trữ SharedPreferences/BoNhoDichVu,
/// đồng bộ tức thời với DichVuThongBao.
class SettingsController extends ChangeNotifier {
  static const String _khoaLuuTru = 'timass_cai_dat_he_thong';

  final BoNhoDichVu _boNhoDichVu;
  CaiDatModel _caiDat = CaiDatModel.macDinh();
  bool _dangTai = false;
  double _dungLuongBoNhoDemMB = 12.4; // Dung lượng bộ nhớ đệm giả lập

  SettingsController({required BoNhoDichVu boNhoDichVu})
      : _boNhoDichVu = boNhoDichVu {
    khoiTao();
  }

  // Getters
  CaiDatModel get caiDat => _caiDat;
  bool get dangTai => _dangTai;
  double get dungLuongBoNhoDemMB => _dungLuongBoNhoDemMB;

  bool get tuDongTichViecThietYeu => _caiDat.tuDongTichViecThietYeu;
  String get ngayBatDauTuan => _caiDat.ngayBatDauTuan;
  bool get batThongBaoDay => _caiDat.batThongBaoDay;
  int get thoiGianNhacTruoc => _caiDat.thoiGianNhacTruoc;
  bool get amThanhRung => _caiDat.amThanhRung;
  String get ngonNgu => _caiDat.ngonNgu;
  String get cheDoGiaoDien => _caiDat.cheDoGiaoDien;
  DateTime get thoiGianDongBoLanCuoi => _caiDat.thoiGianDongBoLanCuoi;

  /// Khởi tạo và nạp cấu hình từ bộ nhớ cục bộ
  Future<void> khoiTao() async {
    _dangTai = true;
    notifyListeners();

    try {
      final chuoiCaiDat = _boNhoDichVu.layChuoi(_khoaLuuTru);
      if (chuoiCaiDat != null && chuoiCaiDat.isNotEmpty) {
        _caiDat = CaiDatModel.fromJson(chuoiCaiDat);
      } else {
        _caiDat = CaiDatModel.macDinh();
      }
      _dongBoSangDichVuThongBao();
    } catch (e) {
      debugPrint('Lỗi nạp cài đặt: $e');
      _caiDat = CaiDatModel.macDinh();
    } finally {
      _dangTai = false;
      notifyListeners();
    }
  }

  /// Cập nhật switch Tự động tích việc thiết yếu
  Future<void> capNhatTuDongTichViecThietYeu(bool giaTri) async {
    _caiDat = _caiDat.copyWith(tuDongTichViecThietYeu: giaTri);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Ngày bắt đầu tuần (Thứ Hai / Chủ Nhật)
  Future<void> capNhatNgayBatDauTuan(String ngay) async {
    _caiDat = _caiDat.copyWith(ngayBatDauTuan: ngay);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Bật/Tắt thông báo đẩy
  Future<void> capNhatBatThongBaoDay(bool giaTri) async {
    _caiDat = _caiDat.copyWith(batThongBaoDay: giaTri);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Thời gian nhắc trước (phút)
  Future<void> capNhatThoiGianNhacTruoc(int soPhut) async {
    _caiDat = _caiDat.copyWith(thoiGianNhacTruoc: soPhut);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Âm thanh & Rung
  Future<void> capNhatAmThanhRung(bool giaTri) async {
    _caiDat = _caiDat.copyWith(amThanhRung: giaTri);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Ngôn ngữ (Tiếng Việt / English)
  Future<void> capNhatNgonNgu(String ngonNguMoi) async {
    _caiDat = _caiDat.copyWith(ngonNgu: ngonNguMoi);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Cập nhật Chế độ giao diện (Sáng / Tối / Hệ thống)
  Future<void> capNhatCheDoGiaoDien(String cheDoMoi) async {
    _caiDat = _caiDat.copyWith(cheDoGiaoDien: cheDoMoi);
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Xóa bộ nhớ đệm (Clear Cache)
  Future<double> xoaBoNhoDem() async {
    final double daXoa = _dungLuongBoNhoDemMB;
    _dungLuongBoNhoDemMB = 0.0;
    notifyListeners();
    return daXoa;
  }

  /// Làm mới thời gian đồng bộ
  Future<void> dongBoDuLieu() async {
    _caiDat = _caiDat.copyWith(thoiGianDongBoLanCuoi: DateTime.now());
    notifyListeners();
    await _luuVaDongBo();
  }

  /// Lưu cài đặt vào SharedPreferences và đồng bộ sang DichVuThongBao
  Future<void> _luuVaDongBo() async {
    await _boNhoDichVu.luuChuoi(_khoaLuuTru, _caiDat.toJson());
    _dongBoSangDichVuThongBao();
  }

  /// Đồng bộ tức thời sang module Dịch vụ Thông báo ngầm
  void _dongBoSangDichVuThongBao() {
    try {
      final thongBaoModel = CaiDatThongBaoModel(
        batThongBao: _caiDat.batThongBaoDay,
        nhacTruocPhut: _caiDat.thoiGianNhacTruoc,
        tuDongTichViecThietYeu: _caiDat.tuDongTichViecThietYeu,
        batAmThanh: _caiDat.amThanhRung,
        batRung: _caiDat.amThanhRung,
      );
      DichVuThongBao.instance.capNhatCaiDat(thongBaoModel, boNho: _boNhoDichVu);
    } catch (e) {
      debugPrint('Lỗi đồng bộ sang DichVuThongBao: $e');
    }
  }
}

/// Bí danh chuẩn tiếng Việt theo yêu cầu AI_rules
typedef CaiDatController = SettingsController;

