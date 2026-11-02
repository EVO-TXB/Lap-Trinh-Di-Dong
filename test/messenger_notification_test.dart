import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/thong_bao/widgets/messenger_notification_banner.dart';
import 'package:timass/features/thong_bao/widgets/chat_head_bubble_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final CongViecModel congViecMau = CongViecModel(
    id: 101,
    maNguoiDung: 1,
    tenCongViec: 'Lập trình Web nâng cao',
    thoiGianBatDau: DateTime(2026, 11, 2, 7, 30),
    thoiGianKetThuc: DateTime(2026, 11, 2, 9, 30),
    diaDiem: 'Phòng A3-402',
    laThietYeu: true,
    daHoanThanh: false,
    nhacNhoTruocPhut: 15,
    ngayTao: DateTime.now(),
  );

  group('MessengerNotificationBanner Tests (Kiểu 1: Top Floating Banner)', () {
    testWidgets('Kiem tra render Banner truot phong cach Messenger', (WidgetTester tester) async {
      bool daBamXem = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                MessengerNotificationBanner(
                  congViec: congViecMau,
                  onXemChiTiet: () => daBamXem = true,
                  onHoanBao: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Header Banner
      expect(find.text('TIMASS'), findsOneWidget);
      expect(find.text(' • NHẮC NHỞ'), findsOneWidget);
      expect(find.text('Vừa xong'), findsOneWidget);

      // Noi dung
      expect(find.text('Lập trình Web nâng cao'), findsOneWidget);
      expect(find.textContaining('Phòng A3-402'), findsOneWidget);

      // 2 nut hanh dong
      final nutHoan = find.text('Hoãn 5p');
      final nutXem = find.text('Xem ngay');
      expect(nutHoan, findsOneWidget);
      expect(nutXem, findsOneWidget);

      // Tap Xem ngay
      await tester.tap(nutXem);
      await tester.pump();
      expect(daBamXem, isTrue);
    });
  });

  group('ChatHeadBubbleWidget Tests (Kiểu 2: Floating Chat Head Bubble)', () {
    testWidgets('Kiem tra render Bong bong noi keo tha va Mini Flyout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatHeadBubbleWidget(
              danhSachCongViec: [congViecMau],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Kiem tra huy hieu so dem thong bao
      expect(find.text('1'), findsOneWidget);

      // Kiem tra tooltip loi thoai truat ra
      expect(find.textContaining('Sắp đến giờ'), findsOneWidget);
      expect(find.text('Lập trình Web nâng cao'), findsWidgets);

      // Tap vao bong bong de bung ra Mini Flyout
      final Finder bubble = find.byType(GestureDetector).first;
      await tester.tap(bubble);
      await tester.pump();

      // Kiem tra cua so Mini Flyout
      expect(find.text('Nhắc nhở Timass'), findsOneWidget);
      expect(find.text('Hoãn 5p'), findsOneWidget);
      expect(find.text('Xem ngay'), findsOneWidget);
    });
  });
}
