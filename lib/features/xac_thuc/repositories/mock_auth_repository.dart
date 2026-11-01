import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/contracts/i_auth_repository.dart';
import '../../../core/mang/api_response.dart';
import '../../../core/bo_nho/bo_nho_dich_vu.dart';
import '../models/nguoi_dung_model.dart';
import '../models/auth_response_model.dart';

class MockAuthRepository implements IAuthRepository {
  final BoNhoDichVu _boNho;

  MockAuthRepository(this._boNho);

  String _hashMatKhau(String matKhau) {
    final bytes = utf8.encode(matKhau);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _khoiTaoDuLieuMauNeuChuaCo() async {
    final danhSach = await _boNho.getDanhSachNguoiDungLocal();
    if (danhSach.isEmpty) {
      // Khoi tao tai khoan mac dinh nhu trong database schema.sql
      // So dien thoai: 0987654321, Mat khau: 123456
      final taiKhoanMau = {
        'id': 1,
        'soDienThoai': '0987654321',
        'matKhauHash': _hashMatKhau('123456'),
        'hoTen': 'Nguyễn Văn An',
        'ngayTao': DateTime.now().toIso8601String(),
      };
      await _boNho.saveDanhSachNguoiDungLocal([taiKhoanMau]);
    }
  }

  @override
  Future<bool> kiemTraSoDienThoaiTonTai(String soDienThoai) async {
    await _khoiTaoDuLieuMauNeuChuaCo();
    final danhSach = await _boNho.getDanhSachNguoiDungLocal();
    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    return danhSach.any((item) => item['soDienThoai'] == cleanPhone);
  }

  @override
  Future<ApiResponse<NguoiDungModel>> dangKy({
    required String hoTen,
    required String soDienThoai,
    required String matKhau,
  }) async {
    await _khoiTaoDuLieuMauNeuChuaCo();

    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    final daTonTai = await kiemTraSoDienThoaiTonTai(cleanPhone);
    if (daTonTai) {
      return const ApiResponse<NguoiDungModel>(
        maTrangThai: 400,
        thongBao: 'Số điện thoại này đã được đăng ký. Vui lòng đăng nhập!',
      );
    }

    final danhSach = await _boNho.getDanhSachNguoiDungLocal();
    final newId = danhSach.length + 1;
    final now = DateTime.now();

    final nguoiDungMoiMap = {
      'id': newId,
      'soDienThoai': cleanPhone,
      'matKhauHash': _hashMatKhau(matKhau),
      'hoTen': hoTen.trim(),
      'ngayTao': now.toIso8601String(),
    };

    danhSach.add(nguoiDungMoiMap);
    await _boNho.saveDanhSachNguoiDungLocal(danhSach);

    final nguoiDung = NguoiDungModel(
      id: newId,
      soDienThoai: cleanPhone,
      hoTen: hoTen.trim(),
      ngayTao: now,
    );

    return ApiResponse<NguoiDungModel>(
      maTrangThai: 201,
      thongBao: 'Tạo tài khoản thành công',
      duLieu: nguoiDung,
    );
  }

  @override
  Future<ApiResponse<AuthResponseModel>> dangNhap({
    required String soDienThoai,
    required String matKhau,
    bool ghiNhoDangNhap = false,
  }) async {
    await _khoiTaoDuLieuMauNeuChuaCo();

    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    final danhSach = await _boNho.getDanhSachNguoiDungLocal();

    final userMap = danhSach.firstWhere(
      (item) => item['soDienThoai'] == cleanPhone,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return const ApiResponse<AuthResponseModel>(
        maTrangThai: 404,
        thongBao: 'Số điện thoại chưa được đăng ký trong hệ thống!',
      );
    }

    final inputHash = _hashMatKhau(matKhau);
    if (userMap['matKhauHash'] != inputHash) {
      return const ApiResponse<AuthResponseModel>(
        maTrangThai: 401,
        thongBao: 'Mật khẩu không chính xác!',
      );
    }

    final nguoiDung = NguoiDungModel(
      id: userMap['id'] as int?,
      soDienThoai: userMap['soDienThoai'] as String,
      hoTen: userMap['hoTen'] as String?,
      ngayTao: userMap['ngayTao'] != null
          ? DateTime.tryParse(userMap['ngayTao'].toString())
          : null,
    );

    final mockJwtToken = 'mock_jwt_header.${base64Url.encode(utf8.encode(jsonEncode(nguoiDung.toJson())))}.mock_signature';

    final authResponse = AuthResponseModel(
      token: mockJwtToken,
      loaiToken: 'Bearer',
      thoiGianHetHan: 86400, // 24 gio
      nguoiDung: nguoiDung,
    );

    // Luu phien dang nhap vao bo nho
    await _boNho.saveToken(mockJwtToken);
    await _boNho.saveNguoiDung(nguoiDung.toJson());
    await _boNho.saveGhiNho(ghiNhoDangNhap, cleanPhone);

    return ApiResponse<AuthResponseModel>(
      maTrangThai: 200,
      thongBao: 'Đăng nhập thành công',
      duLieu: authResponse,
    );
  }

  @override
  Future<void> dangXuat() async {
    await _boNho.clearAuthData();
  }

  @override
  Future<NguoiDungModel?> layNguoiDungHienTai() async {
    final map = await _boNho.getNguoiDung();
    if (map == null) return null;
    return NguoiDungModel.fromJson(map);
  }

  @override
  Future<String?> layToken() async {
    return _boNho.getToken();
  }
}
