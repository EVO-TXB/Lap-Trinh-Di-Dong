import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/repositories/mock_event_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kiem thu phan lap du lieu giua cac tai khoan & Luu tru ben vung', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      MockEventRepository.xoaBoNhoDem();
    });

    test('Tai khoan mau mac dinh (userId = 1) co du lieu mau san', () async {
      final repoUser1 = MockEventRepository(userId: 1);
      final tasksUser1 = await repoUser1.getAllCongViec();

      expect(tasksUser1.isNotEmpty, isTrue);
      expect(tasksUser1.every((e) => e.maNguoiDung == 1), isTrue);
    });

    test('Tai khoan moi tao (userId != 1) bat dau voi lich trong hoan toan', () async {
      final repoUser2 = MockEventRepository(userId: 2);
      final tasksUser2 = await repoUser2.getAllCongViec();

      expect(tasksUser2.isEmpty, isTrue);
    });

    test('Tao cong viec cho User 2, chuyen doi tai khoan khong bi lan lon hoac mat du lieu', () async {
      final repoUser1 = MockEventRepository(userId: 1);
      final repoUser2 = MockEventRepository(userId: 2);

      final initialUser1Tasks = await repoUser1.getAllCongViec();
      final initialCountUser1 = initialUser1Tasks.length;

      // User 2 tao cong viec moi
      final now = DateTime.now();
      final newEventUser2 = CongViecModel(
        id: 0,
        maNguoiDung: 2,
        tenCongViec: 'Hoc bai Flutter cua User 2',
        thoiGianBatDau: DateTime(now.year, now.month, now.day, 10, 0),
        thoiGianKetThuc: DateTime(now.year, now.month, now.day, 11, 30),
        ngayTao: now,
      );

      final createdEventUser2 = await repoUser2.createCongViec(newEventUser2);
      expect(createdEventUser2.maNguoiDung, 2);

      // Kiem tra User 2 co dung 1 cong viec vua tao
      final user2Tasks = await repoUser2.getAllCongViec();
      expect(user2Tasks.length, 1);
      expect(user2Tasks.first.tenCongViec, 'Hoc bai Flutter cua User 2');

      // Chuyen sang User 1: Du lieu User 1 nguyen ven, khong lan lon cong viec cua User 2
      final user1Tasks = await repoUser1.getAllCongViec();
      expect(user1Tasks.length, initialCountUser1);
      expect(user1Tasks.any((e) => e.tenCongViec == 'Hoc bai Flutter cua User 2'), isFalse);

      // Chuyen lai User 2 tu instance moi (mo phong khoi dong lai / chuyen tai khoan)
      MockEventRepository.xoaBoNhoDem();
      final reloadedRepoUser2 = MockEventRepository(userId: 2);
      final reloadedUser2Tasks = await reloadedRepoUser2.getAllCongViec();

      expect(reloadedUser2Tasks.length, 1);
      expect(reloadedUser2Tasks.first.tenCongViec, 'Hoc bai Flutter cua User 2');
      expect(reloadedUser2Tasks.first.maNguoiDung, 2);
    });
  });
}
