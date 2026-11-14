import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timass/features/cong_viec/controllers/checklist_controller.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/repositories/mock_event_repository.dart';
import 'package:timass/features/cong_viec/screens/checklist_screen.dart';
import 'package:timass/features/cong_viec/widgets/checklist_item_widget.dart';

void main() {
  group('ChecklistController Tests', () {
    late ChecklistController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      MockEventRepository().datLaiDuLieuMau();
      controller = ChecklistController(
        eventRepository: MockEventRepository(),
        ngayChon: DateTime(2026, 10, 21),
      );
      await controller.loadDanhSachCongViec();
    });

    test('Khoi tao danh sach viec 21/10/2026 voi du lieu chuan mau', () {
      expect(controller.ngayHienTai, DateTime(2026, 10, 21));
      expect(controller.chuoiNgayHienThi, 'Thứ Tư, 21/10/2026');
      expect(controller.tongSoViec, 8);
      expect(controller.soViecDaHoanThanh, 5);
      expect(controller.phanTramHoanThanh, 65);
    });

    test('Optimistic UI update toggleComplete thay doi trang thai tuc thi', () async {
      // id 202: 'Họp nhóm FootyBook' dang la false
      final CongViecModel target = controller.danhSachCongViec.firstWhere((e) => e.id == 202);
      expect(target.daHoanThanh, isFalse);

      await controller.toggleComplete(202);

      final CongViecModel updated = controller.danhSachCongViec.firstWhere((e) => e.id == 202);
      expect(updated.daHoanThanh, isTrue);
      expect(controller.soViecDaHoanThanh, 6);
      expect(controller.phanTramHoanThanh, 75);

      // Toggle lai lan nua de ve trang thai ban dau
      await controller.toggleComplete(202);
      final CongViecModel reverted = controller.danhSachCongViec.firstWhere((e) => e.id == 202);
      expect(reverted.daHoanThanh, isFalse);
      expect(controller.soViecDaHoanThanh, 5);
      expect(controller.phanTramHoanThanh, 65);
    });

    test('Them cong viec moi va cap nhat tien do', () async {
      final newJob = CongViecModel(
        id: 0,
        maNguoiDung: 1,
        tenCongViec: 'Kiểm thử đồ án',
        thoiGianBatDau: DateTime(2026, 10, 21, 14, 0),
        thoiGianKetThuc: DateTime(2026, 10, 21, 15, 0),
        daHoanThanh: true,
        ngayTao: DateTime(2026, 10, 21),
      );

      await controller.themCongViec(newJob);

      expect(controller.tongSoViec, 9);
      expect(controller.soViecDaHoanThanh, 6);
      expect(controller.danhSachCongViec.any((e) => e.tenCongViec == 'Kiểm thử đồ án'), isTrue);
    });

    test('Xoa cong viec khoi danh sach', () async {
      await controller.xoaCongViec(205); // Xoa 'Tập Gym'

      expect(controller.tongSoViec, 7);
      expect(controller.danhSachCongViec.any((e) => e.id == 205), isFalse);
    });

    test('Thay doi ngay xem danh sach', () async {
      controller.thayDoiNgay(DateTime(2026, 10, 22));
      expect(controller.ngayHienTai, DateTime(2026, 10, 22));
      expect(controller.chuoiNgayHienThi, 'Thứ Năm, 22/10/2026');
    });
  });

  group('ChecklistScreen UI Tests', () {
    setUp(() {
      MockEventRepository().datLaiDuLieuMau();
    });

    testWidgets('Kiem tra render dung 100% thanh phan giao dien theo ui check list.png', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ChecklistScreen(
            initialDate: null, // Mac dinh 21/10/2026
          ),
        ),
      );
      // Advance clock past repository 60ms delay
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 1. Header: Back button, Logo Timass, Chuong thong bao, Avatar
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Timass'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      // 2. Tieu de lon & dong phu ngay thang
      expect(find.textContaining('Danh sách công việc'), findsOneWidget);
      expect(find.textContaining('hôm nay'), findsOneWidget);
      expect(find.text('Thứ Tư, 21/10/2026'), findsOneWidget);

      // 3. Thanh tien do tong quan
      expect(find.text('5/8 việc đã hoàn thành'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // 4. Danh sach checklist & Cac item dac trung
      expect(find.byType(ChecklistItemWidget), findsNWidgets(8));
      expect(find.text('Học Lập trình Web'), findsOneWidget);
      expect(find.text('07:30 - 09:30 | A3-402'), findsOneWidget);

      expect(find.text('Họp nhóm FootyBook'), findsOneWidget);
      expect(find.text('Chủ động'), findsOneWidget); // Badge chu dong

      expect(find.text('Nghỉ trưa & Ăn cơm'), findsOneWidget);
      expect(find.text('Bị động'), findsWidgets); // Badge bi dong

      expect(find.text('Tự học TOEIC Listening'), findsOneWidget);
      expect(find.text('Tập Gym'), findsOneWidget);

      // 5. Footer: Huong dan & Nut to "Them cong viec"
      expect(find.text('Tích vào ô tròn để đánh dấu hoàn thành nhanh'), findsOneWidget);
      expect(find.text('Thêm công việc'), findsOneWidget);
    });

    testWidgets('Kiem tra tich checkbox cap nhat tuc thi tren UI (Optimistic)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ChecklistScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Ban dau: 5/8 viec da hoan thanh (65%)
      expect(find.text('5/8 việc đã hoàn thành'), findsOneWidget);

      // Tich vao 'Họp nhóm FootyBook' de danh dau hoan thanh
      await tester.tap(find.text('Họp nhóm FootyBook'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Sau khi tich: Tien do tang len 6/8 (75%)
      expect(find.text('6/8 việc đã hoàn thành'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);

      // Tich lai vao 'Họp nhóm FootyBook' de bo hoan thanh
      await tester.tap(find.text('Họp nhóm FootyBook'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Quay lai 5/8 (65%)
      expect(find.text('5/8 việc đã hoàn thành'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
    });
  });
}
