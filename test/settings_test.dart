import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timass/core/bo_nho/bo_nho_dich_vu.dart';
import 'package:timass/features/cai_dat/controllers/settings_controller.dart';
import 'package:timass/features/cai_dat/models/cai_dat_model.dart';
import 'package:timass/features/cai_dat/screens/cai_dat_screen.dart';
import 'package:timass/features/cai_dat/screens/thong_tin_san_pham_screen.dart';
import 'package:timass/features/xac_thuc/providers/auth_controller.dart';
import 'package:timass/features/xac_thuc/repositories/auth_repository_impl.dart';
import 'package:timass/core/mang/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BoNhoDichVu boNhoDichVu;
  late SettingsController settingsController;
  late AuthController authController;

  setUp(() async {
    BoNhoDichVu.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    boNhoDichVu = await BoNhoDichVu.getInstance();
    settingsController = SettingsController(boNhoDichVu: boNhoDichVu);
    authController = AuthController(
      authRepository: AuthRepositoryImpl(
        apiClient: ApiClient(),
        boNho: boNhoDichVu,
      ),
      boNhoDichVu: boNhoDichVu,
    );
  });

  group('CaiDatModel & SettingsController Tests', () {

    test('Kiem tra chuyen doi ngon ngu va dich chuoi AppTranslations', () async {
      expect(settingsController.tr('settings'), equals('Cài đặt'));
      expect(settingsController.tr('weekly_schedule'), equals('Lịch tuần'));

      await settingsController.capNhatNgonNgu('English');
      expect(settingsController.ngonNgu, equals('English'));
      expect(settingsController.tr('settings'), equals('Settings'));
      expect(settingsController.tr('weekly_schedule'), equals('Weekly View'));
      expect(settingsController.tr('today'), equals('Today'));
      expect(settingsController.tr('week_label'), equals('Week'));
      expect(
        settingsController.tr('today_task_count', params: {'done': '5', 'total': '8'}),
        equals('Today: 5/8 tasks'),
      );
      expect(
        settingsController.tr('completed_percent', params: {'percent': '63'}),
        equals('done (63%)'),
      );

      // Đổi lại Tiếng Việt
      await settingsController.capNhatNgonNgu('Tiếng Việt');
      expect(settingsController.ngonNgu, equals('Tiếng Việt'));
      expect(settingsController.tr('settings'), equals('Cài đặt'));
    });

    test('Kiem tra chuyen doi che do giao dien Sang va Toi (Dark Mode)', () async {
      expect(settingsController.cheDoGiaoDien, equals('Sáng'));
      expect(settingsController.themeMode, equals(ThemeMode.light));
      expect(settingsController.isDarkMode, isFalse);

      await settingsController.capNhatCheDoGiaoDien('Tối');
      expect(settingsController.cheDoGiaoDien, equals('Tối'));
      expect(settingsController.themeMode, equals(ThemeMode.dark));
      expect(settingsController.isDarkMode, isTrue);

      await settingsController.capNhatCheDoGiaoDien('Sáng');
      expect(settingsController.themeMode, equals(ThemeMode.light));
      expect(settingsController.isDarkMode, isFalse);
    });
    test('Khoi tao cai dat mac dinh chinh xac', () {
      final caiDat = CaiDatModel.macDinh();
      expect(caiDat.tuDongTichViecThietYeu, isTrue);
      expect(caiDat.ngayBatDauTuan, equals('Thứ Hai'));
      expect(caiDat.batThongBaoDay, isTrue);
      expect(caiDat.thoiGianNhacTruoc, equals(15));
      expect(caiDat.amThanhRung, isTrue);
      expect(caiDat.ngonNgu, equals('Tiếng Việt'));
      expect(caiDat.cheDoGiaoDien, equals('Sáng'));
      expect(caiDat.moTaThoiGianNhacTruoc, equals('Trước 15 phút'));
    });

    test('Cap nhat cac truong trong SettingsController va dong bo', () async {
      await settingsController.capNhatTuDongTichViecThietYeu(false);
      expect(settingsController.tuDongTichViecThietYeu, isFalse);

      await settingsController.capNhatNgayBatDauTuan('Chủ Nhật');
      expect(settingsController.ngayBatDauTuan, equals('Chủ Nhật'));

      await settingsController.capNhatBatThongBaoDay(false);
      expect(settingsController.batThongBaoDay, isFalse);

      await settingsController.capNhatThoiGianNhacTruoc(30);
      expect(settingsController.thoiGianNhacTruoc, equals(30));

      await settingsController.capNhatAmThanhRung(false);
      expect(settingsController.amThanhRung, isFalse);

      await settingsController.capNhatNgonNgu('English');
      expect(settingsController.ngonNgu, equals('English'));

      await settingsController.capNhatCheDoGiaoDien('Tối');
      expect(settingsController.cheDoGiaoDien, equals('Tối'));
    });

    test('Xoa bo nho dem (Clear Cache)', () async {
      final daXoa = await settingsController.xoaBoNhoDem();
      expect(daXoa, greaterThan(0));
      expect(settingsController.dungLuongBoNhoDemMB, equals(0.0));
    });
  });

  group('UI Integration Tests - CaiDatScreen', () {
    Widget buildTestScreen(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsController>.value(value: settingsController),
          ChangeNotifierProvider<AuthController>.value(value: authController),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('Kiem tra render day du cac Section tren man hinh Cai dat', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestScreen(const CaiDatScreen()));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Cài đặt'), findsOneWidget);

      // Section 1: Tài khoản & Bảo mật
      expect(find.text('Tài khoản & Bảo mật'), findsOneWidget);
      expect(find.text('Thẻ Thông tin cá nhân'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('09xx xxx xxx'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      // Section 2: Cấu hình Lịch trình & Tự động hóa
      expect(find.text('Cấu hình Lịch trình & Tự động hóa'), findsOneWidget);
      expect(find.text('Tự động tích việc thiết yếu'), findsOneWidget);
      expect(find.text('Tự động hoàn thành khi qua khung giờ'), findsOneWidget);
      expect(find.text('Ngày bắt đầu tuần'), findsOneWidget);

      // Section 3: Thông báo & Nhắc nhở
      expect(find.text('Thông báo & Nhắc nhở'), findsOneWidget);
      expect(find.text('Bật/Tắt thông báo đẩy'), findsOneWidget);
      expect(find.text('Thời gian nhắc trước'), findsOneWidget);
      expect(find.text('Âm thanh & Rung'), findsOneWidget);

      // Section 4: Giao diện & Ngôn ngữ
      expect(find.text('Giao diện & Ngôn ngữ'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Chế độ giao diện'), findsOneWidget);

      // Section 5: Dữ liệu & Ngoại tuyến
      expect(find.text('Dữ liệu & Ngoại tuyến'), findsOneWidget);
      expect(find.text('Trạng thái đồng bộ'), findsOneWidget);
      expect(find.text('Xóa bộ nhớ đệm (Clear Cache)'), findsOneWidget);
      expect(find.text('Xóa đệm'), findsOneWidget);
      expect(find.text('Thông tin về sản phẩm'), findsOneWidget);
    });

    testWidgets('Kiem tra nhan nut Xoa dem hien thi SnackBar thong bao', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestScreen(const CaiDatScreen()));
      await tester.pumpAndSettle();

      final xoaDemButton = find.text('Xóa đệm');
      expect(xoaDemButton, findsOneWidget);

      await tester.tap(xoaDemButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Đã dọn dẹp'), findsOneWidget);
    });
  });

  group('UI Integration Tests - ThongTinSanPhamScreen', () {
    testWidgets('Kiem tra render dung 100% thong tin san pham theo mau ui', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ThongTinSanPhamScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Thông tin sản phẩm'), findsOneWidget);

      // Hero
      expect(find.text('Timass'), findsOneWidget);
      expect(find.text('Ứng dụng quản lý thời gian & tối ưu hiệu suất'), findsOneWidget);
      expect(find.text('Phiên bản: 1.0.0 (MVP)'), findsOneWidget);

      // Project & Members
      expect(find.textContaining('CSE702027-1-1-26(N02)'), findsOneWidget);
      expect(find.textContaining('Nhóm 1'), findsOneWidget);
      expect(find.text('Trịnh Xuân Bắc'), findsOneWidget);
      expect(find.textContaining('24105823'), findsOneWidget);
      expect(find.text('Nguyễn Tiến Vinh'), findsOneWidget);
      expect(find.textContaining('24100226'), findsOneWidget);
      expect(find.text('ThS. Nguyễn Xuân Quế'), findsOneWidget);

      // Nút quay lại
      expect(find.text('Quay lại Cài đặt'), findsOneWidget);
    });
  });
}

