import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timass/core/thong_bao/cai_dat_thong_bao_model.dart';
import 'package:timass/core/thong_bao/dich_vu_thong_bao.dart';
import 'package:timass/features/xac_thuc/services/auth_validation.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/screens/lich_tuan_screen.dart';
import 'package:timass/features/thong_bao/widgets/popup_nhac_nho_dialog.dart';

void main() {
  group('AuthValidation Tests', () {
    test('Validate so dien thoai Viet Nam hop le', () {
      expect(AuthValidation.validateSoDienThoai('0987654321'), isNull);
      expect(AuthValidation.validateSoDienThoai('0321234567'), isNull);
      expect(AuthValidation.validateSoDienThoai('0561234567'), isNull);
      expect(AuthValidation.validateSoDienThoai('0701234567'), isNull);
      expect(AuthValidation.validateSoDienThoai('0891234567'), isNull);

      // Khong hop le
      expect(AuthValidation.validateSoDienThoai(''), isNotNull);
      expect(AuthValidation.validateSoDienThoai('0123456789'), isNotNull);
      expect(AuthValidation.validateSoDienThoai('098765432'), isNotNull);
      expect(AuthValidation.validateSoDienThoai('09876543210'), isNotNull);
    });

    test('Validate mat khau hop le', () {
      expect(AuthValidation.validateMatKhau('123456'), isNull);
      expect(AuthValidation.validateMatKhau('12345'), isNotNull);
      expect(AuthValidation.validateMatKhau(''), isNotNull);
    });

    test('Validate xac nhan mat khau hop le', () {
      expect(AuthValidation.validateXacNhanMatKhau('123456', '123456'), isNull);
      expect(AuthValidation.validateXacNhanMatKhau('123456', '654321'), isNotNull);
    });

    test('Tinh do manh mat khau', () {
      expect(AuthValidation.tinhDoManhMatKhau(''), equals(0));
      expect(AuthValidation.tinhDoManhMatKhau('123'), equals(1));
      expect(AuthValidation.tinhDoManhMatKhau('abc1234'), equals(2));
      expect(AuthValidation.tinhDoManhMatKhau('Abc12345'), equals(3));
      expect(AuthValidation.tinhDoManhMatKhau('Abc@12345'), equals(4));
    });
  });

  group('Module Thong Bao & Tac Vu Nen Tests (Prompt 2)', () {
    late DichVuThongBao dichVu;

    setUp(() {
      dichVu = DichVuThongBao.instance;
      dichVu.datLaiBoNhoThongBao();
    });

    test('Notification Scanner quet va phat thong bao su kien trong vong 15 phut toi', () async {
      final now = DateTime(2026, 10, 13, 7, 15);
      final congViec = CongViecModel(
        id: 101,
        maNguoiDung: 1,
        tenCongViec: 'Lập trình Web nâng cao',
        thoiGianBatDau: DateTime(2026, 10, 13, 7, 30), // Bắt đầu sau 15 phút
        thoiGianKetThuc: DateTime(2026, 10, 13, 9, 0),
        diaDiem: 'Phòng A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: now,
      );

      CongViecModel? suKienDuocPhat;

      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [congViec],
        thoiGianHienTai: now,
        onPhatThongBao: (cv) {
          suKienDuocPhat = cv;
        },
      );

      // Kiem tra su kien da duoc phat hien va thong bao
      expect(suKienDuocPhat, isNotNull);
      expect(suKienDuocPhat!.id, equals(101));
      expect(suKienDuocPhat!.tenCongViec, equals('Lập trình Web nâng cao'));

      // Lan quet tiep theo se khong phat lai (da danh dau da thong bao)
      CongViecModel? suKienPhatLai;
      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [congViec],
        thoiGianHienTai: now.add(const Duration(minutes: 1)),
        onPhatThongBao: (cv) {
          suKienPhatLai = cv;
        },
      );
      expect(suKienPhatLai, isNull);
    });

    test('Chuc nang Snooze hoan bao 5 phut va kich hoat lai sau khi het gio hoan', () async {
      final now = DateTime(2026, 10, 13, 7, 15);
      final congViec = CongViecModel(
        id: 102,
        maNguoiDung: 1,
        tenCongViec: 'Họp nhóm đồ án',
        thoiGianBatDau: DateTime(2026, 10, 13, 7, 30),
        thoiGianKetThuc: DateTime(2026, 10, 13, 8, 30),
        laThietYeu: false,
        daHoanThanh: false,
        ngayTao: now,
      );

      // Thong bao lan 1
      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [congViec],
        thoiGianHienTai: now,
      );

      // Nguoi dung chon hoan bao 5 phut (Snooze)
      dichVu.hoanBaoSnooze(congViec.id, soPhut: 5, tuThoiDiem: now);

      // Sau 2 phut chua thong bao lai
      CongViecModel? phatLaiSau2Phut;
      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [congViec],
        thoiGianHienTai: now.add(const Duration(minutes: 2)),
        onPhatThongBao: (cv) => phatLaiSau2Phut = cv,
      );
      expect(phatLaiSau2Phut, isNull);

      // Sau 6 phut (qua thoi gian Snooze) phat thong bao lai
      CongViecModel? phatLaiSau6Phut;
      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [congViec],
        thoiGianHienTai: now.add(const Duration(minutes: 6)),
        onPhatThongBao: (cv) => phatLaiSau6Phut = cv,
      );
      expect(phatLaiSau6Phut, isNotNull);
      expect(phatLaiSau6Phut!.id, equals(102));
    });

    test('Auto-Complete Passive Events tu dong tich hoan thanh viec thiet yeu khi qua gio', () async {
      final now = DateTime(2026, 10, 13, 13, 30);
      final viecThietYeu = CongViecModel(
        id: 201,
        maNguoiDung: 1,
        tenCongViec: 'Nghỉ trưa & Ăn cơm',
        thoiGianBatDau: DateTime(2026, 10, 13, 11, 30),
        thoiGianKetThuc: DateTime(2026, 10, 13, 13, 0), // Da ket thuc luc 13:00
        laThietYeu: true, // Viec thiet yeu / bi dong
        daHoanThanh: false,
        ngayTao: now,
      );

      final viecChuDong = CongViecModel(
        id: 202,
        maNguoiDung: 1,
        tenCongViec: 'Làm bài tập Lập trình di động',
        thoiGianBatDau: DateTime(2026, 10, 13, 10, 0),
        thoiGianKetThuc: DateTime(2026, 10, 13, 12, 0), // Da ket thuc nhung la viec chu dong
        laThietYeu: false, // Viec chu dong khong tu dong tich
        daHoanThanh: false,
        ngayTao: now,
      );

      final List<int> danhSachTuDongHoanThanh = [];

      await dichVu.quetThongBaoVaTuDongHoa(
        danhSachCongViec: [viecThietYeu, viecChuDong],
        thoiGianHienTai: now,
        onTuDongHoanThanh: (cv) {
          danhSachTuDongHoanThanh.add(cv.id);
        },
      );

      // Chi viec thiet yeu 201 duoc tu dong hoan thanh, viec chu dong 202 giu nguyen
      expect(danhSachTuDongHoanThanh, contains(201));
      expect(danhSachTuDongHoanThanh, isNot(contains(202)));
    });

    testWidgets('Kiem tra render PopupNhacNhoDialog dung anh mau ui thong bao.png', (WidgetTester tester) async {
      final now = DateTime(2026, 10, 13, 7, 15);
      final congViec = CongViecModel(
        id: 301,
        maNguoiDung: 1,
        tenCongViec: 'Lập trình Web nâng cao',
        thoiGianBatDau: DateTime(2026, 10, 13, 7, 30),
        thoiGianKetThuc: DateTime(2026, 10, 13, 9, 0),
        diaDiem: 'Phòng A3-402',
        laThietYeu: false,
        daHoanThanh: false,
        nhacNhoTruocPhut: 15,
        ngayTao: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PopupNhacNhoDialog(
              congViec: congViec,
              animate: false,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Xac nhan Header & Icon chuong do
      expect(find.text('Timass • Nhắc nhở sắp đến giờ'), findsOneWidget);

      // Xac nhan Ten su kien in dam noi bat
      expect(find.text('Lập trình Web nâng cao'), findsOneWidget);

      // Xac nhan Dong phu
      expect(find.text('Bắt đầu sau 15 phút nữa (07:30 tại Phòng A3-402)'), findsOneWidget);

      // Xac nhan 2 nut hanh dong
      expect(find.text('Đóng'), findsOneWidget);
      expect(find.text('Xem chi tiết'), findsOneWidget);
    });
  });

  group('LichTuanScreen Tests', () {
    testWidgets('Kiem tra render man hinh lich tuan', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LichTuanScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Timass'), findsOneWidget);
      expect(find.text('Thêm việc'), findsOneWidget);
    });
  });
}
