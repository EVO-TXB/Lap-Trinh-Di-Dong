import 'package:dio/dio.dart';
import '../../../core/contracts/i_auth_repository.dart';
import '../../../core/mang/api_client.dart';
import '../../../core/mang/api_response.dart';
import '../../../core/bo_nho/bo_nho_dich_vu.dart';
import '../models/nguoi_dung_model.dart';
import '../models/auth_response_model.dart';
import 'mock_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _apiClient;
  final BoNhoDichVu _boNho;
  final MockAuthRepository _mockRepo;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required BoNhoDichVu boNho,
  })  : _apiClient = apiClient,
        _boNho = boNho,
        _mockRepo = MockAuthRepository(boNho);

  @override
  Future<bool> kiemTraSoDienThoaiTonTai(String soDienThoai) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/xac-thuc/kiem-tra-so-dien-thoai',
        queryParameters: {'soDienThoai': soDienThoai},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['duLieu'] as bool? ?? false;
      }
      return false;
    } catch (_) {
      // Fallback tu dong sang mock repository
      return _mockRepo.kiemTraSoDienThoaiTonTai(soDienThoai);
    }
  }

  @override
  Future<ApiResponse<NguoiDungModel>> dangKy({
    required String hoTen,
    required String soDienThoai,
    required String matKhau,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/xac-thuc/dang-ky',
        data: {
          'hoTen': hoTen.trim(),
          'soDienThoai': soDienThoai.trim(),
          'matKhau': matKhau,
        },
      );

      if (response.data != null) {
        final apiRes = ApiResponse<NguoiDungModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => NguoiDungModel.fromJson(json as Map<String, dynamic>),
        );
        return apiRes;
      }

      return const ApiResponse<NguoiDungModel>(
        maTrangThai: 500,
        thongBao: 'Không nhận được dữ liệu từ máy chủ',
      );
    } on DioException catch (dioError) {
      // Neu server tra ve response loi 400 (vi du: SĐT da ton tai)
      if (dioError.response != null && dioError.response?.data != null) {
        try {
          return ApiResponse<NguoiDungModel>.fromJson(
            dioError.response!.data as Map<String, dynamic>,
            (json) => NguoiDungModel.fromJson(json as Map<String, dynamic>),
          );
        } catch (_) {}
      }

      // Neu loi ket noi mang hoac server khong phan hoi -> Fallback sang mock repo
      return _mockRepo.dangKy(
        hoTen: hoTen,
        soDienThoai: soDienThoai,
        matKhau: matKhau,
      );
    } catch (_) {
      return _mockRepo.dangKy(
        hoTen: hoTen,
        soDienThoai: soDienThoai,
        matKhau: matKhau,
      );
    }
  }

  @override
  Future<ApiResponse<AuthResponseModel>> dangNhap({
    required String soDienThoai,
    required String matKhau,
    bool ghiNhoDangNhap = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/xac-thuc/dang-nhap',
        data: {
          'soDienThoai': soDienThoai.trim(),
          'matKhau': matKhau,
        },
      );

      if (response.data != null) {
        final apiRes = ApiResponse<AuthResponseModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiRes.laThanhCong && apiRes.duLieu != null) {
          final authData = apiRes.duLieu!;
          await _boNho.saveToken(authData.token);
          await _boNho.saveNguoiDung(authData.nguoiDung.toJson());
          await _boNho.saveGhiNho(ghiNhoDangNhap, soDienThoai);
        }

        return apiRes;
      }

      return const ApiResponse<AuthResponseModel>(
        maTrangThai: 500,
        thongBao: 'Không nhận được phản hồi hợp lệ từ máy chủ',
      );
    } on DioException catch (dioError) {
      if (dioError.response != null && dioError.response?.data != null) {
        try {
          return ApiResponse<AuthResponseModel>.fromJson(
            dioError.response!.data as Map<String, dynamic>,
            (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
          );
        } catch (_) {}
      }

      // Fallback tu dong sang mock repository
      return _mockRepo.dangNhap(
        soDienThoai: soDienThoai,
        matKhau: matKhau,
        ghiNhoDangNhap: ghiNhoDangNhap,
      );
    } catch (_) {
      return _mockRepo.dangNhap(
        soDienThoai: soDienThoai,
        matKhau: matKhau,
        ghiNhoDangNhap: ghiNhoDangNhap,
      );
    }
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

