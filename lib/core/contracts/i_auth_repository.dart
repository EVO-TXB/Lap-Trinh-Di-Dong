import '../mang/api_response.dart';
import '../../features/xac_thuc/models/nguoi_dung_model.dart';
import '../../features/xac_thuc/models/auth_response_model.dart';

abstract class IAuthRepository {
  /// Dang ky tai khoan nguoi dung moi
  Future<ApiResponse<NguoiDungModel>> dangKy({
    required String hoTen,
    required String soDienThoai,
    required String matKhau,
  });

  /// Dang nhap vao he thong
  Future<ApiResponse<AuthResponseModel>> dangNhap({
    required String soDienThoai,
    required String matKhau,
    bool ghiNhoDangNhap = false,
  });

  /// Dang xuat khoi he thong
  Future<void> dangXuat();

  /// Lay thong tin nguoi dung hien tai dang luu trong bo nho
  Future<NguoiDungModel?> layNguoiDungHienTai();

  /// Lay token xac thuc hien tai
  Future<String?> layToken();

  /// Kiem tra so dien thoai da ton tai chua
  Future<bool> kiemTraSoDienThoaiTonTai(String soDienThoai);
}

