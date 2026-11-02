import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timass/features/cong_viec/controllers/event_form_controller.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/utils/batch_event_helper.dart';
import 'package:timass/features/cong_viec/utils/time_conflict_checker.dart';
import 'package:timass/features/cong_viec/widgets/conflict_warning_dialog.dart';
import 'package:timass/features/cong_viec/widgets/event_form_bottom_sheet.dart';
import 'package:timass/features/cong_viec/widgets/recurring_choice_dialog.dart';
import 'package:timass/features/cong_viec/widgets/time_navigation_widget.dart';
import 'package:timass/features/cong_viec/widgets/weekly_grid_widget.dart';
import 'package:timass/features/cong_viec/controllers/schedule_controller.dart';
import 'package:timass/features/cong_viec/repositories/mock_event_repository.dart';

void main() {
  group('1. TimeConflictChecker Unit Tests (Thuật toán Trùng Lịch)', () {
    final DateTime targetDate = DateTime(2026, 10, 21);

    final CongViecModel existingEvent = CongViecModel(
      id: 1,
      maNguoiDung: 1,
      tenCongViec: 'Học Lập trình Web',
      thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 0),
      thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 0),
      ngayTao: DateTime.now(),
    );

    test('Phat hien trung lich khi khung gio giao thoa trong cung ngay (8:30 - 9:30)', () {
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 30),
        thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 9, 30),
        danhSachHienCo: [existingEvent],
      );

      expect(ketQua.coTrungLich, isTrue);
      expect(ketQua.congViecBiTrung?.id, equals(1));
      expect(ketQua.hopLe, isFalse);
    });

    test('Phat hien trung lich khi khung gio bao trum (7:30 - 10:30)', () {
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 7, 30),
        thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 30),
        danhSachHienCo: [existingEvent],
      );

      expect(ketQua.coTrungLich, isTrue);
      expect(ketQua.congViecBiTrung?.tenCongViec, equals('Học Lập trình Web'));
    });

    test('Khong trung khi hai khung gio lien ke tiep xuc (10:00 - 11:30)', () {
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 0),
        thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 11, 30),
        danhSachHienCo: [existingEvent],
      );

      expect(ketQua.coTrungLich, isFalse);
      expect(ketQua.hopLe, isTrue);
    });

    test('Khong trung khi cung gio nhung khac ngay (22/10/2026)', () {
      final DateTime otherDay = DateTime(2026, 10, 22);
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(otherDay.year, otherDay.month, otherDay.day, 8, 0),
        thoiGianKetThuc: DateTime(otherDay.year, otherDay.month, otherDay.day, 10, 0),
        danhSachHienCo: [existingEvent],
      );

      expect(ketQua.coTrungLich, isFalse);
      expect(ketQua.hopLe, isTrue);
    });

    test('Bao loi khi gio bat dau >= gio ket thuc', () {
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 0),
        thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 0),
        danhSachHienCo: [existingEvent],
      );

      expect(ketQua.thoiGianKhongHopLe, isTrue);
      expect(ketQua.hopLe, isFalse);
    });

    test('Loai tru chinh su kien dang sua, khong tu bao trung voi chinh minh', () {
      final ketQua = TimeConflictChecker.kiemTraTrungLich(
        thoiGianBatDau: DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 0),
        thoiGianKetThuc: DateTime(targetDate.year, targetDate.month, targetDate.day, 10, 0),
        danhSachHienCo: [existingEvent],
        idHienTai: 1, // Chinh la existingEvent
      );

      expect(ketQua.coTrungLich, isFalse);
      expect(ketQua.hopLe, isTrue);
    });
  });

  group('2. BatchEventHelper Unit Tests (Xu Ly Chuoi Su Kien Lap)', () {
    test('Sinh danh sach cong viec lap theo Thu 2, Thu 4, Thu 6 gan chung maChuoiLap', () {
      final CongViecModel mau = CongViecModel(
        id: 0,
        maNguoiDung: 1,
        tenCongViec: 'Hoc Toeic Hang Tuan',
        thoiGianBatDau: DateTime(2026, 10, 19, 18, 0), // Thu Hai
        thoiGianKetThuc: DateTime(2026, 10, 19, 19, 30),
        ngayTao: DateTime.now(),
      );

      // Tu 19/10/2026 (Thu 2) den 25/10/2026 (Chu nhat) -> 1 tuan gom T2(19), T4(21), T6(23)
      final List<CongViecModel> ketQua = BatchEventHelper.sinhDanhSachCongViecLap(
        mau: mau,
        cacThu: {2, 4, 6},
        ngayBatDau: DateTime(2026, 10, 19),
        ngayKetThuc: DateTime(2026, 10, 25),
      );

      expect(ketQua.length, equals(3));
      final String maChuoi = ketQua.first.maChuoiLap!;
      expect(maChuoi, isNotEmpty);
      expect(ketQua.every((e) => e.maChuoiLap == maChuoi), isTrue);

      // Kiem tra gio bat dau / ket thuc
      expect(ketQua[0].thoiGianBatDau.day, equals(19));
      expect(ketQua[1].thoiGianBatDau.day, equals(21));
      expect(ketQua[2].thoiGianBatDau.day, equals(23));
      expect(ketQua[0].thoiGianBatDau.hour, equals(18));
      expect(ketQua[0].thoiGianKetThuc.hour, equals(19));
      expect(ketQua[0].thoiGianKetThuc.minute, equals(30));
    });
  });

  group('3. EventFormController Unit Tests', () {
    test('Khoi tao mac dinh cho Form tao moi cong viec', () {
      final controller = EventFormController(ngayMacDinh: DateTime(2026, 10, 21));

      expect(controller.isEditing, isFalse);
      expect(controller.tenCongViec, isEmpty);
      expect(controller.loaiSuKien, equals('CHU_DONG'));
      expect(controller.coLapLai, isFalse);
      expect(controller.cacThuDaChon, containsAll([2, 4, 6]));
      expect(controller.gioBatDau.hour, equals(8));
      expect(controller.gioKetThuc.hour, equals(10));
    });

    test('Validate form tra ve loi khi tieu de rong hoac gio khong hop le', () {
      final controller = EventFormController();

      // Tieu de rong
      expect(controller.validateForm(), isNotNull);

      controller.thayDoiTenCongViec('Do an tot nghiep');
      expect(controller.validateForm(), isNull);

      // Gio ket thuc truoc gio bat dau
      controller.thayDoiGioBatDau(const TimeOfDay(hour: 10, minute: 0));
      controller.thayDoiGioKetThuc(const TimeOfDay(hour: 9, minute: 0));
      expect(controller.validateForm(), contains('Giờ bắt đầu phải sớm hơn giờ kết thúc'));
    });

    test('Toggle switch lap lai va chon cac thu trong tuan', () {
      final controller = EventFormController();
      controller.toggleLapLai(true);
      expect(controller.coLapLai, isTrue);

      controller.toggleThu(8); // Them CN
      expect(controller.cacThuDaChon, contains(8));

      controller.toggleThu(8); // Bo CN
      expect(controller.cacThuDaChon.contains(8), isFalse);
    });
  });

  group('4. UI Widget Tests (Modal Bottom Sheet & Dialogs)', () {
    testWidgets('Kiem tra render Modal Bottom Sheet tao moi va toggle lap lai', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EventFormBottomSheet.show(
                    context,
                    ngayMacDinh: DateTime(2026, 10, 21),
                  );
                },
                child: const Text('Mo Form'),
              ),
            ),
          ),
        ),
      );

      // Bấm nút mở form
      await tester.tap(find.text('Mo Form'));
      await tester.pumpAndSettle();

      // Kiểm tra Header & Title
      expect(find.text('Thêm công việc mới'), findsOneWidget);
      expect(find.text('Tiêu đề công việc'), findsOneWidget);
      expect(find.text('Loại công việc'), findsOneWidget);
      expect(find.text('Chủ động'), findsOneWidget);
      expect(find.text('Thiết yếu /\nBị động'), findsOneWidget);
      expect(find.text('Lặp lại hàng tuần'), findsOneWidget);
      expect(find.text('Lưu công việc'), findsOneWidget);

      // Kiểm tra khi bật Toggle lặp lại hàng tuần
      final Finder switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Kiểm tra các thứ T2, T3, T4, T5, T6, T7, CN xuất hiện
      expect(find.text('T2'), findsOneWidget);
      expect(find.text('T3'), findsOneWidget);
      expect(find.text('T4'), findsOneWidget);
      expect(find.text('T5'), findsOneWidget);
      expect(find.text('T6'), findsOneWidget);
      expect(find.text('T7'), findsOneWidget);
      expect(find.text('CN'), findsOneWidget);
      expect(find.text('Thời gian lặp lại'), findsOneWidget);
      expect(find.text('Đến ngày'), findsOneWidget);
    });

    testWidgets('Kiem tra ConflictWarningDialog render dung thong tin canh bao', (WidgetTester tester) async {
      final CongViecModel biTrung = CongViecModel(
        id: 99,
        maNguoiDung: 1,
        tenCongViec: 'Kiem thu he thong',
        thoiGianBatDau: DateTime(2026, 10, 21, 8, 0),
        thoiGianKetThuc: DateTime(2026, 10, 21, 10, 0),
        ngayTao: DateTime.now(),
      );

      bool suaLaiClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictWarningDialog(
              congViecBiTrung: biTrung,
              onSuaLai: () {
                suaLaiClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Cảnh báo trùng lịch!'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Kiem thu he thong'),
        ),
        findsOneWidget,
      );
      expect(find.text('Sửa lại khung giờ'), findsOneWidget);

      await tester.tap(find.text('Sửa lại khung giờ'));
      await tester.pumpAndSettle();
      expect(suaLaiClicked, isTrue);
    });

    testWidgets('Kiem tra RecurringChoiceDialog cho phep lua chon pham vi sua/xoa', (WidgetTester tester) async {
      RecurringScope? chosenScope;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecurringChoiceDialog(
              actionType: RecurringActionType.sua,
              onScopeSelected: (scope) {
                chosenScope = scope;
              },
            ),
          ),
        ),
      );

      expect(find.text('Chỉnh sửa công việc lặp lại'), findsOneWidget);
      expect(find.text('Áp dụng chỉ 1 sự kiện này'), findsOneWidget);
      expect(find.text('Áp dụng cho toàn bộ chuỗi sự kiện lặp'), findsOneWidget);

      await tester.tap(find.text('Áp dụng chỉ 1 sự kiện này'));
      await tester.pumpAndSettle();
      expect(chosenScope, equals(RecurringScope.single));
    });

    testWidgets('Kiem tra ConflictWarningDialog ho tro nut Van tiep tuc luu khi choPhepVanLuu la true', (WidgetTester tester) async {
      bool tiepTucLuuClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConflictWarningDialog(
              onSuaLai: () {},
              onVanTiepTucLuu: () {
                tiepTucLuuClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Cảnh báo trùng lịch!'), findsOneWidget);
      expect(find.text('Sửa lại khung giờ'), findsOneWidget);
      expect(find.text('Vẫn tiếp tục lưu'), findsOneWidget);

      await tester.tap(find.text('Vẫn tiếp tục lưu'));
      await tester.pumpAndSettle();
      expect(tiepTucLuuClicked, isTrue);
    });

    testWidgets('Kiem tra TimeNavigationWidget hien thi 1 dong duy nhat ngay va tuan, khong ghi thu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeNavigationWidget(
              tieuDe: '13/10/2026 (Tuần 42)',
              onTuanTruoc: () {},
              onTuanSau: () {},
              onHomNay: () {},
            ),
          ),
        ),
      );

      expect(find.text('13/10/2026 (Tuần 42)'), findsOneWidget);
      expect(find.textContaining('Thứ Ba'), findsNothing);
      expect(find.text('Hôm nay'), findsOneWidget);
    });

    testWidgets('Kiem tra WeeklyGridWidget danh dau ngay hom nay (T3 13) bang pill badge', (WidgetTester tester) async {
      final repository = MockEventRepository();
      final controller = ScheduleController(eventRepository: repository, ngayKhoiTao: DateTime(2026, 10, 13));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: WeeklyGridWidget(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tim T3 13 la cot ngay hom nay o tuan 42
      expect(find.text('T3 13'), findsOneWidget);
      expect(find.text('T2 12'), findsOneWidget);
      expect(find.text('T4 14'), findsOneWidget);
      expect(controller.tuanDangXemChuaHomNay, isTrue);

      // Khi chuyen sang tuan sau: tuanDangXemChuaHomNay tro thanh false
      controller.chuyenTuanSau();
      await tester.pumpAndSettle();
      expect(controller.tuanDangXemChuaHomNay, isFalse);

      // Khi bam chuyenDenHomNay: quay lai tuan chua hom nay
      controller.chuyenDenHomNay();
      await tester.pumpAndSettle();
      expect(controller.tuanDangXemChuaHomNay, isTrue);

      controller.dispose();
    });
  });

  group('5. Recurring Series Editing Tests (Cap nhat chuoi su kien)', () {
    test('MockEventRepository.updateChuoiCongViec cap nhat tat ca cac su kien cung chuoi lap', () async {
      final repo = MockEventRepository();
      final List<CongViecModel> events = repo.tatCaCongViecHienCo;
      final chuoiWebEvents = events.where((e) => e.maChuoiLap == 'chuoi_hoc_web').toList();
      expect(chuoiWebEvents.length, greaterThanOrEqualTo(2));

      final mauMoi = CongViecModel(
        id: 1,
        maNguoiDung: 1,
        maChuoiLap: 'chuoi_hoc_web',
        tenCongViec: 'Hoc Lap Trinh Web Nang Cao',
        diaDiem: 'Phong Lab 502',
        thoiGianBatDau: DateTime(2026, 10, 12, 9, 30),
        thoiGianKetThuc: DateTime(2026, 10, 12, 11, 30),
        ngayTao: DateTime.now(),
        ghiChu: 'Mang theo laptop',
      );

      final capNhat = await repo.updateChuoiCongViec('chuoi_hoc_web', mauMoi);
      expect(capNhat.length, equals(chuoiWebEvents.length));

      for (final cv in capNhat) {
        expect(cv.tenCongViec, equals('Hoc Lap Trinh Web Nang Cao'));
        expect(cv.diaDiem, equals('Phong Lab 502'));
        expect(cv.ghiChu, equals('Mang theo laptop'));
        expect(cv.thoiGianBatDau.hour, equals(9));
        expect(cv.thoiGianBatDau.minute, equals(30));
        expect(cv.thoiGianKetThuc.hour, equals(11));
        expect(cv.thoiGianKetThuc.minute, equals(30));
      }
    });

    test('ScheduleController.capNhatChuoiCongViec cap nhat danh sach cong viec trong tuan', () async {
      final repo = MockEventRepository();
      final controller = ScheduleController(
        eventRepository: repo,
        ngayKhoiTao: DateTime(2026, 10, 12),
      );
      await controller.loadDanhSachCongViec();

      final mauMoi = CongViecModel(
        id: 1,
        maNguoiDung: 1,
        maChuoiLap: 'chuoi_hoc_web',
        tenCongViec: 'Hoc React & Flutter Web',
        diaDiem: 'Phong B201',
        thoiGianBatDau: DateTime(2026, 10, 12, 8, 30),
        thoiGianKetThuc: DateTime(2026, 10, 12, 10, 30),
        ngayTao: DateTime.now(),
      );

      await controller.capNhatChuoiCongViec(
        maChuoiLap: 'chuoi_hoc_web',
        mau: mauMoi,
      );

      final suKienSauCapNhat = controller.danhSachCongViec
          .where((e) => e.maChuoiLap == 'chuoi_hoc_web')
          .toList();
      expect(suKienSauCapNhat.isNotEmpty, isTrue);
      for (final e in suKienSauCapNhat) {
        expect(e.tenCongViec, equals('Hoc React & Flutter Web'));
        expect(e.diaDiem, equals('Phong B201'));
      }
    });

    test('EventFormController khoi tao day du cac thu trong chuoi tu danhSachHienCo', () {
      final repo = MockEventRepository();
      final allEvents = repo.tatCaCongViecHienCo;
      final event1 = allEvents.firstWhere((e) => e.maChuoiLap == 'chuoi_hoc_web');

      final formCtrl = EventFormController(
        congViecGoc: event1,
        danhSachHienCo: allEvents,
      );

      expect(formCtrl.coLapLai, isTrue);
      // Chuoi hoc web lap vao Thu 2, Thu 4, Thu 6 (int: 2, 4, 6)
      expect(formCtrl.cacThuDaChon.contains(2), isTrue);
      expect(formCtrl.cacThuDaChon.contains(4), isTrue);
      expect(formCtrl.cacThuDaChon.contains(6), isTrue);
      expect(formCtrl.daThayDoiQuyTacLap, isFalse);
    });
  });
}
