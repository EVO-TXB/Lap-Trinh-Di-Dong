import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bo_nho/bo_nho_dich_vu.dart';
import 'core/mang/api_client.dart';
import 'core/constants/app_colors.dart';
import 'features/xac_thuc/providers/auth_controller.dart';
import 'features/xac_thuc/repositories/auth_repository_impl.dart';
import 'features/xac_thuc/screens/dang_nhap_screen.dart';
import 'features/xac_thuc/screens/dang_phat_trien_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao cac dich vu he thong
  final boNhoDichVu = await BoNhoDichVu.getInstance();
  final apiClient = ApiClient();
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    boNho: boNhoDichVu,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authRepository: authRepository,
            boNhoDichVu: boNhoDichVu,
          ),
        ),
      ],
      child: const TimassApp(),
    ),
  );
}

class TimassApp extends StatelessWidget {
  const TimassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timass - Quản lý thời gian & lịch trình',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.sageGreen,
        scaffoldBackgroundColor: AppColors.peachBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sageGreen,
          primary: AppColors.sageGreen,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.trangThaiXacThuc == TrangThaiXacThuc.dangKiemTra) {
      return const Scaffold(
        backgroundColor: AppColors.peachBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sageGreen),
        ),
      );
    }

    if (authController.daDangNhap) {
      return const DangPhatTrienScreen();
    }

    return const DangNhapScreen();
  }
}
