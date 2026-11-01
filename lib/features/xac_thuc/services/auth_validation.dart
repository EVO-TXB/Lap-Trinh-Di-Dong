class AuthValidation {
  /// Kiem tra so dien thoai Viet Nam hop le
  /// 10 chu so, bat dau bang cac dau so 03, 05, 07, 08, 09
  static String? validateSoDienThoai(String? soDienThoai) {
    if (soDienThoai == null || soDienThoai.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final sdtClean = soDienThoai.trim().replaceAll(' ', '');
    final regexSdt = RegExp(r'^(03|05|07|08|09)[0-9]{8}$');

    if (!regexSdt.hasMatch(sdtClean)) {
      return 'Số điện thoại không hợp lệ (10 chữ số, đầu số 03, 05, 07, 08, 09)';
    }

    return null;
  }

  /// Kiem tra mat khau (toi thieu 6 ky tu)
  static String? validateMatKhau(String? matKhau) {
    if (matKhau == null || matKhau.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (matKhau.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  /// Kiem tra xac nhan mat khau
  static String? validateXacNhanMatKhau(String? matKhau, String? xacNhanMatKhau) {
    if (xacNhanMatKhau == null || xacNhanMatKhau.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }

    if (matKhau != xacNhanMatKhau) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  /// Kiem tra ho ten
  static String? validateHoTen(String? hoTen) {
    if (hoTen == null || hoTen.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    if (hoTen.trim().length < 2) {
      return 'Họ và tên quá ngắn';
    }

    return null;
  }

  /// Tinh toan do manh mat khau theo thang diem tu 0 den 4:
  /// 0: Trong
  /// 1: Yeu (Do)
  /// 2: Trung binh (Cam)
  /// 3: Kha (Xanh la nhat)
  /// 4: Manh (Xanh la dam)
  static int tinhDoManhMatKhau(String matKhau) {
    if (matKhau.isEmpty) return 0;

    int diem = 0;

    // Do dai toi thieu
    if (matKhau.length >= 6) diem++;
    if (matKhau.length >= 8) diem++;

    // Co chua chu va so
    final coChuThuong = RegExp(r'[a-z]').hasMatch(matKhau);
    final coChuHoa = RegExp(r'[A-Z]').hasMatch(matKhau);
    final coSo = RegExp(r'[0-9]').hasMatch(matKhau);
    final coKyTuDacBiet = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(matKhau);

    if ((coChuThuong || coChuHoa) && coSo) {
      diem++;
    }

    if (coChuHoa && coChuThuong && coSo && coKyTuDacBiet) {
      diem++;
    }

    if (diem > 4) diem = 4;
    if (diem == 0 && matKhau.isNotEmpty) diem = 1;

    return diem;
  }
}

