import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timass/core/bo_nho/bo_nho_dich_vu.dart';
import 'package:timass/core/mang/api_client.dart';
import 'package:timass/features/cai_dat/controllers/settings_controller.dart';
import 'package:timass/features/cong_viec/screens/lich_tuan_screen.dart';
import 'package:timass/features/thong_bao/controllers/thong_bao_controller.dart';
import 'package:timass/features/xac_thuc/providers/auth_controller.dart';
import 'package:timass/features/xac_thuc/repositories/auth_repository_impl.dart';
import 'package:timass/features/xac_thuc/screens/dang_nhap_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BoNhoDichVu boNhoDichVu;
  late AuthController authController;
  late SettingsController settingsController;
  late ThongBaoController thongBaoController;

  setUp(() async {
    BoNhoDichVu.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    boNhoDichVu = await BoNhoDichVu.getInstance();

    final apiClient = ApiClient();
    final authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
      boNho: boNhoDichVu,
    );

    authController = AuthController(
      authRepository: authRepository,
      boNhoDichVu: boNhoDichVu,
    );
    await authController.kiemTraTrangThaiDangNhap();
    settingsController = SettingsController(boNhoDichVu: boNhoDichVu);
    thongBaoController = ThongBaoController(boNhoDichVu: boNhoDichVu);
  });

  Widget createTestApp({Widget? home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<SettingsController>.value(value: settingsController),
        ChangeNotifierProvider<ThongBaoController>.value(value: thongBaoController),
      ],
      child: MaterialApp(
        home: home ?? const DangNhapScreen(),
      ),
    );
  }

  group('Auth Navigation Flow Tests (Login -> Dashboard -> Logout -> Login)', () {
    testWidgets('DangNhapScreen navigates to LichTuanScreen (Dashboard) on successful login', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Currently on DangNhapScreen
      expect(find.byType(DangNhapScreen), findsOneWidget);
      expect(find.byType(LichTuanScreen), findsNothing);

      // Verify textfields exist
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), '0987654321');
      await tester.enterText(textFields.at(1), '123456');
      await tester.pumpAndSettle();

      // Tap Login button
      final loginBtn = find.text('Đăng nhập');
      expect(loginBtn, findsOneWidget);
      await tester.tap(loginBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // MUST navigate to LichTuanScreen (Dashboard) and NOT be stuck on DangNhapScreen
      expect(find.byType(LichTuanScreen), findsOneWidget);
      expect(find.byType(DangNhapScreen), findsNothing);

      // Verify user is now authenticated
      expect(authController.daDangNhap, isTrue);

      // Now simulate Logout (as in CaiDatScreen)
      await authController.handleDangXuat();
      expect(authController.daDangNhap, isFalse);

      // Push DangNhapScreen as CaiDatScreen does
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DangNhapScreen()),
        (route) => false,
      );
      await tester.pumpAndSettle();

      // Verify we are back on DangNhapScreen
      expect(find.byType(DangNhapScreen), findsOneWidget);
      expect(find.byType(LichTuanScreen), findsNothing);

      // Now log in AGAIN
      final textFieldsAgain = find.byType(TextField);
      expect(textFieldsAgain, findsNWidgets(2));

      await tester.enterText(textFieldsAgain.at(0), '0987654321');
      await tester.enterText(textFieldsAgain.at(1), '123456');
      await tester.pumpAndSettle();

      final loginBtnAgain = find.text('Đăng nhập');
      await tester.tap(loginBtnAgain);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // MUST successfully navigate back into Dashboard (LichTuanScreen) without hanging!
      expect(find.byType(LichTuanScreen), findsOneWidget);
      expect(find.byType(DangNhapScreen), findsNothing);
      expect(authController.daDangNhap, isTrue);
    });
  });
}
