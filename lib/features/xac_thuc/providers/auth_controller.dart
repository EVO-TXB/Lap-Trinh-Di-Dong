import 'package:flutter/material.dart';
import '../../../core/contracts/i_auth_repository.dart';
import '../../../core/bo_nho/bo_nho_dich_vu.dart';
import '../models/nguoi_dung_model.dart';

enum TrangThaiXacThuc {
  khoiTao,
  dangKiemTra,
  daXacThuc,
  chuaXacThuc,
}

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final BoNhoDichVu _boNhoDichVu;

  TrangThaiXacThuc _trangThaiXacThuc = TrangThaiXacThuc.khoiTao;
  NguoiDungModel? _nguoiDungHienTai;
  String? _token;
  bool _dangXuLy = false;
  String? _thongBaoLoi;
  String? _thongBaoThanhCong;
  bool _ghiNhoDangNhap = false;
  String? _soDienThoaiGhiNho;

  AuthController({
    required IAuthRepository authRepository,
    required BoNhoDichVu boNhoDichVu,
  })  : _authRepository = authRepository,
        _boNhoDichVu = boNhoDichVu {
    kiemTraTrangThaiDangNhap();
  }

  // Getters
  TrangThaiXacThuc get trangThaiXacThuc => _trangThaiXacThuc;
  NguoiDungModel? get nguoiDungHienTai => _nguoiDungHienTai;
  String? get token => _token;
  bool get dangXuLy => _dangXuLy;
  String? get thongBaoLoi => _thongBaoLoi;
  String? get thongBaoThanhCong => _thongBaoThanhCong;
  bool get ghiNhoDangNhap => _ghiNhoDangNhap;
  String? get soDienThoaiGhiNho => _soDienThoaiGhiNho;
  bool get daDangNhap => _trangThaiXacThuc == TrangThaiXacThuc.daXacThuc;

  void setGhiNhoDangNhap(bool giaTri) {
    _ghiNhoDangNhap = giaTri;
    notifyListeners();
  }

  void xoaThongBao() {
    _thongBaoLoi = null;
    _thongBaoThanhCong = null;
    notifyListeners();
  }

  /// Kiem tra trang thai dang nhap khi khoi dong ung dung
  Future<void> kiemTraTrangThaiDangNhap() async {
    _trangThaiXacThuc = TrangThaiXacThuc.dangKiemTra;
    notifyListeners();

    try {
      _ghiNhoDangNhap = await _boNhoDichVu.getGhiNho();
      _soDienThoaiGhiNho = await _boNhoDichVu.getSoDienThoaiGhiNho();

      final savedToken = await _authRepository.layToken();
      final savedUser = await _authRepository.layNguoiDungHienTai();

      if (savedToken != null && savedToken.isNotEmpty && savedUser != null) {
        _token = savedToken;
        _nguoiDungHienTai = savedUser;
        _trangThaiXacThuc = TrangThaiXacThuc.daXacThuc;
      } else {
        _trangThaiXacThuc = TrangThaiXacThuc.chuaXacThuc;
      }
    } catch (_) {
      _trangThaiXacThuc = TrangThaiXacThuc.chuaXacThuc;
    } finally {
      notifyListeners();
    }
  }

  /// Xu ly dang nhap
  Future<bool> handleDangNhap({
    required String soDienThoai,
    required String matKhau,
  }) async {
    _dangXuLy = true;
    _thongBaoLoi = null;
    _thongBaoThanhCong = null;
    notifyListeners();

    try {
      final response = await _authRepository.dangNhap(
        soDienThoai: soDienThoai.trim(),
        matKhau: matKhau,
        ghiNhoDangNhap: _ghiNhoDangNhap,
      );

      if (response.laThanhCong && response.duLieu != null) {
        _token = response.duLieu!.token;
        _nguoiDungHienTai = response.duLieu!.nguoiDung;
        _trangThaiXacThuc = TrangThaiXacThuc.daXacThuc;
        _thongBaoThanhCong = response.thongBao.isNotEmpty
            ? response.thongBao
            : 'Đăng nhập thành công!';
        _dangXuLy = false;
        notifyListeners();
        return true;
      } else {
        _thongBaoLoi = response.thongBao.isNotEmpty
            ? response.thongBao
            : 'Đăng nhập không thành công';
        _dangXuLy = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _thongBaoLoi = 'Có lỗi xảy ra: ${e.toString()}';
      _dangXuLy = false;
      notifyListeners();
      return false;
    }
  }

  /// Xu ly dang ky tai khoan
  Future<bool> handleDangKy({
    required String hoTen,
    required String soDienThoai,
    required String matKhau,
  }) async {
    _dangXuLy = true;
    _thongBaoLoi = null;
    _thongBaoThanhCong = null;
    notifyListeners();

    try {
      final response = await _authRepository.dangKy(
        hoTen: hoTen.trim(),
        soDienThoai: soDienThoai.trim(),
        matKhau: matKhau,
      );

      if (response.laThanhCong) {
        _thongBaoThanhCong = response.thongBao.isNotEmpty
            ? response.thongBao
            : 'Đăng ký tài khoản thành công! Vui lòng đăng nhập.';
        _dangXuLy = false;
        notifyListeners();
        return true;
      } else {
        _thongBaoLoi = response.thongBao.isNotEmpty
            ? response.thongBao
            : 'Đăng ký không thành công';
        _dangXuLy = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _thongBaoLoi = 'Có lỗi xảy ra: ${e.toString()}';
      _dangXuLy = false;
      notifyListeners();
      return false;
    }
  }

  /// Xu ly dang xuat
  Future<void> handleDangXuat() async {
    _dangXuLy = true;
    notifyListeners();

    await _authRepository.dangXuat();
    _token = null;
    _nguoiDungHienTai = null;
    _trangThaiXacThuc = TrangThaiXacThuc.chuaXacThuc;
    _dangXuLy = false;
    notifyListeners();
  }

  Future<void> dangXuat() => handleDangXuat();
}

