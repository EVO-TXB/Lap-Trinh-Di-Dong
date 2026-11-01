import 'package:flutter_test/flutter_test.dart';
import 'package:timass/features/xac_thuc/services/auth_validation.dart';

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
      expect(AuthValidation.validateSoDienThoai('098765432'), isNotNull); // 9 so
      expect(AuthValidation.validateSoDienThoai('09876543210'), isNotNull); // 11 so
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
}
