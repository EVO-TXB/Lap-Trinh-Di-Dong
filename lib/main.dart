import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/bo_nho/bo_nho_dich_vu.dart';
import 'core/mang/api_client.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_themes.dart';
import 'core/thong_bao/dich_vu_thong_bao.dart';
import 'features/xac_thuc/providers/auth_controller.dart';
import 'features/xac_thuc/repositories/auth_repository_impl.dart';
import 'features/xac_thuc/screens/dang_nhap_screen.dart';
import 'features/cong_viec/screens/lich_tuan_screen.dart';
import 'features/thong_bao/controllers/thong_bao_controller.dart';
import 'features/cai_dat/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo các dịch vụ hệ thống
  final boNhoDichVu = await BoNhoDichVu.getInstance();
  final apiClient = ApiClient();
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    boNho: boNhoDichVu,
  );

  // Khởi tạo dịch vụ thông báo
  await DichVuThongBao.instance.khoiTao(boNhoDichVu);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authRepository: authRepository,
            boNhoDichVu: boNhoDichVu,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThongBaoController(
            boNhoDichVu: boNhoDichVu,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(
            boNhoDichVu: boNhoDichVu,
          ),
        ),
      ],
      child: const TimassApp(),
    ),
  );
}

class TimassApp extends StatelessWidget {
  final Widget? home;
  const TimassApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }

    return MaterialApp(
      title: 'Timass - Quản lý Lịch trình & Thời gian',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: settings?.themeMode ?? ThemeMode.light,
      home: home ?? const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    try {
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
        return const LichTuanScreen();
      }

      return const DangNhapScreen();
    } catch (_) {
      return const LichTuanScreen();
    }
  }
}
