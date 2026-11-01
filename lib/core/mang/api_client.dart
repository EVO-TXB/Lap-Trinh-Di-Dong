import 'package:dio/dio.dart';
import '../bo_nho/bo_nho_dich_vu.dart';

class ApiClient {
  static const String baseUrlDefault = 'http://10.0.2.2:8080'; // 10.0.2.2 cho Android Emulator, localhost cho Windows/Web
  final Dio _dio;

  ApiClient({String baseUrl = baseUrlDefault})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final boNho = await BoNhoDichVu.getInstance();
          final token = await boNho.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

