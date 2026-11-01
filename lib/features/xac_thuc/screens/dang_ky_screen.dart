import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../providers/auth_controller.dart';
import '../services/auth_validation.dart';
import '../widgets/auth_header_illustration.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sage_green_button.dart';
import '../widgets/thanh_do_do_manh_mat_khau.dart';

class DangKyScreen extends StatefulWidget {
  const DangKyScreen({super.key});

  @override
  State<DangKyScreen> createState() => _DangKyScreenState();
}

class _DangKyScreenState extends State<DangKyScreen> {
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final TextEditingController _xacNhanMatKhauController = TextEditingController();

  bool _hienMatKhau = false;
  bool _hienXacNhanMatKhau = false;
  bool _dongYDieuKhoan = true;
  int _diemDoManhMatKhau = 0;

  String? _loiHoTen;
  String? _loiSoDienThoai;
  String? _loiMatKhau;
  String? _loiXacNhanMatKhau;

  @override
  void dispose() {
    _hoTenController.dispose();
    _soDienThoaiController.dispose();
    _matKhauController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  void _thucHienDangKy() async {
    setState(() {
      _loiHoTen = AuthValidation.validateHoTen(_hoTenController.text);
      _loiSoDienThoai = AuthValidation.validateSoDienThoai(_soDienThoaiController.text);
      _loiMatKhau = AuthValidation.validateMatKhau(_matKhauController.text);
      _loiXacNhanMatKhau = AuthValidation.validateXacNhanMatKhau(
        _matKhauController.text,
        _xacNhanMatKhauController.text,
      );
    });

    if (_loiHoTen != null ||
        _loiSoDienThoai != null ||
        _loiMatKhau != null ||
        _loiXacNhanMatKhau != null) {
      return;
    }

    if (!_dongYDieuKhoan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với Điều khoản dịch vụ và Chính sách bảo mật'),
          backgroundColor: AppColors.matKhauTrungBinh,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final thanhCong = await authController.handleDangKy(
      hoTen: _hoTenController.text,
      soDienThoai: _soDienThoaiController.text,
      matKhau: _matKhauController.text,
    );

    if (!mounted) return;

    if (thanhCong) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(authController.thongBaoThanhCong ?? 'Tạo tài khoản thành công!'),
              ),
            ],
          ),
          backgroundColor: AppColors.sageGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Tự động chuyển về màn hình Đăng nhập sau khi đăng ký thành công
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(authController.thongBaoLoi ?? 'Đăng ký thất bại'),
              ),
            ],
          ),
          backgroundColor: AppColors.matKhauYeu,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _hienThiDieuKhoanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text('Điều khoản & Chính sách', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'Khi sử dụng ứng dụng Timass, bạn đồng ý cho phép ứng dụng lưu trữ và quản lý lịch trình, công việc và gửi thông báo nhắc nhở theo thời gian thực.\n\nThông tin người dùng được mã hóa và bảo mật tối đa theo chính sách bảo mật của Timass.',
            style: TextStyle(fontSize: 14.0, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu', style: TextStyle(color: AppColors.sageGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool laManHinhRong = screenWidth > 500;

    Widget noiDungChinh = Container(
      color: AppColors.peachBackground,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 1. Header Minh hoa 3D
            const AuthHeaderIllustration(height: 250.0),

            // 2. Form Card bo tron 4 goc om noi
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 24.0),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppStyles.cardRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    const Center(
                      child: Text(
                        'Tạo tài khoản',
                        style: AppStyles.authTitle,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Họ và tên
                    CustomTextField(
                      label: 'Họ và tên',
                      hintText: 'Nguyễn Văn A',
                      controller: _hoTenController,
                      thongBaoLoi: _loiHoTen,
                      onChanged: (val) {
                        if (_loiHoTen != null) {
                          setState(() {
                            _loiHoTen = AuthValidation.validateHoTen(val);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // Số điện thoại
                    CustomTextField(
                      label: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      controller: _soDienThoaiController,
                      kieuBanPhim: TextInputType.phone,
                      thongBaoLoi: _loiSoDienThoai,
                      onChanged: (val) {
                        if (_loiSoDienThoai != null) {
                          setState(() {
                            _loiSoDienThoai = AuthValidation.validateSoDienThoai(val);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // Mật khẩu
                    CustomTextField(
                      label: 'Mật khẩu',
                      hintText: '••••••••',
                      controller: _matKhauController,
                      laMatKhau: true,
                      hienMatKhau: _hienMatKhau,
                      onToggleHienMatKhau: () {
                        setState(() {
                          _hienMatKhau = !_hienMatKhau;
                        });
                      },
                      thongBaoLoi: _loiMatKhau,
                      onChanged: (val) {
                        setState(() {
                          _diemDoManhMatKhau = AuthValidation.tinhDoManhMatKhau(val);
                          if (_loiMatKhau != null) {
                            _loiMatKhau = AuthValidation.validateMatKhau(val);
                          }
                        });
                      },
                    ),

                    // Thanh do do manh mat khau 4 vach (Do - Cam - Xanh nhat - Xanh dam)
                    ThanhDoDoManhMatKhau(diemDoManh: _diemDoManhMatKhau),
                    const SizedBox(height: 8.0),

                    // Xác nhận mật khẩu
                    CustomTextField(
                      label: 'Xác nhận mật khẩu',
                      hintText: '••••••••',
                      controller: _xacNhanMatKhauController,
                      laMatKhau: true,
                      hienMatKhau: _hienXacNhanMatKhau,
                      onToggleHienMatKhau: () {
                        setState(() {
                          _hienXacNhanMatKhau = !_hienXacNhanMatKhau;
                        });
                      },
                      thongBaoLoi: _loiXacNhanMatKhau,
                      onChanged: (val) {
                        if (_loiXacNhanMatKhau != null) {
                          setState(() {
                            _loiXacNhanMatKhau = AuthValidation.validateXacNhanMatKhau(
                              _matKhauController.text,
                              val,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12.0),

                    // Checkbox Điều khoản & Chính sách
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: Checkbox(
                            value: _dongYDieuKhoan,
                            activeColor: AppColors.sageGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: const BorderSide(
                              color: AppColors.borderGrey,
                              width: 1.5,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _dongYDieuKhoan = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _dongYDieuKhoan = !_dongYDieuKhoan;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Tôi đồng ý với ',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  color: AppColors.textDark,
                                  height: 1.25,
                                ),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: _hienThiDieuKhoanDialog,
                                      child: const Text(
                                        'Điều khoản dịch vụ',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: AppColors.textDark,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' và '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: _hienThiDieuKhoanDialog,
                                      child: const Text(
                                        'Chính sách bảo mật',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: AppColors.textDark,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Nút Tạo tài khoản Sage Green
                    SageGreenButton(
                      text: 'Tạo tài khoản',
                      dangXuLy: authController.dangXuLy,
                      onPressed: _thucHienDangKy,
                    ),
                    const SizedBox(height: 16.0),

                    // Footer chuyển về Đăng nhập
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Đã có tài khoản? ',
                            style: AppStyles.footerText,
                            children: [
                              TextSpan(
                                text: 'Đăng nhập',
                                style: AppStyles.footerLink,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (laManHinhRong) {
      return Scaffold(
        backgroundColor: AppColors.screenMockupBackground,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420.0, maxHeight: 880.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.peachBackground,
                borderRadius: BorderRadius.circular(36.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: noiDungChinh,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.peachBackground,
      body: SafeArea(
        top: false,
        child: noiDungChinh,
      ),
    );
  }
}
