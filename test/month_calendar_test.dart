import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timass/features/cong_viec/controllers/month_calendar_controller.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/repositories/mock_event_repository.dart';
import 'package:timass/features/cong_viec/screens/lich_tuan_screen.dart';
import 'package:timass/features/cong_viec/screens/month_calendar_view.dart';
import 'package:timass/features/cong_viec/widgets/monthly_calendar_grid.dart';
import 'package:timass/main.dart';

void main() {
  group('MonthCalendarController Tests', () {
    late MockEventRepository repository;
    late MonthCalendarController controller;

    setUp(() {
      repository = MockEventRepository();
      controller = MonthCalendarController(eventRepository: repository);
    });

    test('Tao ma tran lich thang - kiem tra so o va ngay dau thang', () {
      // Tháng 10 năm 2026: ngày 1/10/2026 là Thứ Năm (weekday = 4)
      // Số ngày bù = 3 ngày (Thứ 2, 3, 4 thuộc tháng 9)
      // Tháng 10 có 31 ngày -> Tổng 3 + 31 = 34 <= 35 ô
      final List<DateTime> matrix1026 = controller.taoMaTranLichThang(2026, 10);
      expect(matrix1026.length, 35);
      expect(matrix1026.first, DateTime(2026, 9, 28)); // Thứ Hai tuần đầu

      // Tháng 2 năm nhuận 2024: 29 ngày
      final List<DateTime> matrix0224 = controller.taoMaTranLichThang(2024, 2);
      expect(matrix0224.length, anyOf(35, 42));
    });

    test('Chi bao cham su kien - hien thi toi da 3 cham hoac 2 cham + dau cong', () async {
      await controller.loadEventsForMonth(2026, 10);

      // Ngày 13/10/2026 có 6 công việc trong Mock data -> >3 việc -> 2 chấm + hasMore = true
      final DayIndicatorDots dots13 = controller.getChiBaoChamNgay(DateTime(2026, 10, 13));
      expect(dots13.hasMore, isTrue);
      expect(dots13.dotColors.length, 2);

      // Ngày 05/10/2026 có 2 công việc -> 2 chấm, hasMore = false
      final DayIndicatorDots dots05 = controller.getChiBaoChamNgay(DateTime(2026, 10, 5));
      expect(dots05.hasMore, isFalse);
      expect(dots05.dotColors.length, 2);

      // Ngày 01/10/2026 không có công việc -> 0 chấm
      final DayIndicatorDots dots01 = controller.getChiBaoChamNgay(DateTime(2026, 10, 1));
      expect(dots01.hasMore, isFalse);
      expect(dots01.dotColors.isEmpty, isTrue);
    });

    test('Chon ngay va cap nhat danh sach cong viec', () async {
      await controller.loadEventsForMonth(2026, 10);

      controller.selectDate(DateTime(2026, 10, 13));
      expect(controller.ngayDangChon, DateTime(2026, 10, 13));
      expect(controller.danhSachCongViecNgayDuocChon.isNotEmpty, isTrue);

      controller.selectDate(DateTime(2026, 10, 1));
      expect(controller.danhSachCongViecNgayDuocChon.isEmpty, isTrue);
    });

    test('Dieu huong thang truoc / sau va ve hom nay', () {
      controller.chuyenThangSau();
      expect(controller.thangHienTai.month, 11);

      controller.chuyenThangTruoc();
      expect(controller.thangHienTai.month, 10);

      controller.chuyenDenHomNay();
      expect(controller.thangHienTai.month, 10);
      expect(controller.ngayDangChon, controller.ngayHomNay);
    });

    test('Danh dau hoan thanh cong viec', () async {
      await controller.loadEventsForMonth(2026, 10);
      final List<CongViecModel> events = controller.getDanhSachCongViecNgay(DateTime(2026, 10, 13));
      final CongViecModel target = events.firstWhere((e) => !e.daHoanThanh);

      await controller.toggleTrangThaiHoanThanh(target);
      final List<CongViecModel> updatedEvents = controller.getDanhSachCongViecNgay(DateTime(2026, 10, 13));
      final CongViecModel updated = updatedEvents.firstWhere((e) => e.id == target.id);
      expect(updated.daHoanThanh, isTrue);
    });
  });

  group('UI Integration Tests - Chuyen doi Lich Tuan & Lich Thang', () {
    testWidgets('Kiem tra chuyen doi muot ma qua nut [Lich thang] va chi hien thi ma tran lich thang', (WidgetTester tester) async {
      // Set kích thước màn hình test
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const TimassApp(home: LichTuanScreen()));
      await tester.pumpAndSettle();

      // Kiểm tra đang ở màn hình Lịch tuần ban đầu
      expect(find.byType(LichTuanScreen), findsOneWidget);
      expect(find.text('Lịch tuần'), findsOneWidget);
      expect(find.text('Lịch tháng'), findsOneWidget);

      // Chuyển sang tab "Lịch tháng"
      await tester.tap(find.text('Lịch tháng'));
      await tester.pumpAndSettle();

      // Kiểm tra Giao diện Lịch Tháng đã được render
      expect(find.byType(MonthCalendarView), findsOneWidget);
      expect(find.text('Tháng 10, 2026'), findsOneWidget);
      expect(find.text('T2'), findsOneWidget);
      expect(find.text('CN'), findsOneWidget);

      // Đã loại bỏ panel kéo checklist theo đúng yêu cầu
      expect(find.byType(DraggableScrollableSheet), findsNothing);

      // Chuyển lại về Lịch tuần
      await tester.tap(find.text('Lịch tuần'));
      await tester.pumpAndSettle();

      // Kiểm tra quay lại Lịch tuần
      expect(find.textContaining('(Tuần 42)'), findsOneWidget);
    });

    testWidgets('Kiem tra dieu huong thang tren giao dien lich thang', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const TimassApp(home: LichTuanScreen()));
      await tester.pumpAndSettle();

      // Sang Lịch tháng
      await tester.tap(find.text('Lịch tháng'));
      await tester.pumpAndSettle();

      expect(find.text('Tháng 10, 2026'), findsOneWidget);

      // Bấm nút chuyển sang tháng sau > bên trong MonthlyCalendarGrid
      final Finder nextMonthBtn = find.descendant(
        of: find.byType(MonthlyCalendarGrid),
        matching: find.byIcon(Icons.chevron_right_rounded),
      );
      expect(nextMonthBtn, findsOneWidget);
      await tester.tap(nextMonthBtn);
      await tester.pumpAndSettle();

      expect(find.text('Tháng 11, 2026'), findsOneWidget);

      // Bấm nút "Hôm nay" bên trong MonthlyCalendarGrid để quay về tháng 10
      final Finder todayBtn = find.descendant(
        of: find.byType(MonthlyCalendarGrid),
        matching: find.text('Hôm nay'),
      );
      expect(todayBtn, findsOneWidget);
      await tester.tap(todayBtn);
      await tester.pumpAndSettle();

      expect(find.text('Tháng 10, 2026'), findsOneWidget);
    });
  });
}
