import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../providers/auth_controller.dart';
import '../services/auth_validation.dart';
import '../widgets/auth_header_illustration.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/sage_green_button.dart';
import 'dang_ky_screen.dart';

class DangNhapScreen extends StatefulWidget {
  const DangNhapScreen({super.key});

  @override
  State<DangNhapScreen> createState() => _DangNhapScreenState();
}

class _DangNhapScreenState extends State<DangNhapScreen> {
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();

  bool _hienMatKhau = false;
  bool _ghiNhoDangNhap = true;
  String? _loiSoDienThoai;
  String? _loiMatKhau;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      if (authController.ghiNhoDangNhap && authController.soDienThoaiGhiNho != null) {
        setState(() {
          _soDienThoaiController.text = authController.soDienThoaiGhiNho!;
          _ghiNhoDangNhap = true;
        });
      } else {
        _soDienThoaiController.text = '0987654321';
        _matKhauController.text = '123456';
      }
    });
  }

  @override
  void dispose() {
    _soDienThoaiController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  void _thucHienDangNhap() async {
    setState(() {
      _loiSoDienThoai = AuthValidation.validateSoDienThoai(_soDienThoaiController.text);
      _loiMatKhau = AuthValidation.validateMatKhau(_matKhauController.text);
    });

    if (_loiSoDienThoai != null || _loiMatKhau != null) {
      return;
    }

    final authController = context.read<AuthController>();
    authController.setGhiNhoDangNhap(_ghiNhoDangNhap);

    final thanhCong = await authController.handleDangNhap(
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
              Text(authController.thongBaoThanhCong ?? 'Đăng nhập thành công!'),
            ],
          ),
          backgroundColor: AppColors.sageGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(authController.thongBaoLoi ?? 'Đăng nhập thất bại'),
            ],
          ),
          backgroundColor: AppColors.matKhauYeu,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _hienThiDialogQuenMatKhau() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Vui lòng liên hệ quản trị viên hoặc sử dụng số điện thoại đã đăng ký để thiết lập lại mật khẩu.',
          style: TextStyle(fontSize: 14.0),
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
            // 1. Header Minh hoa 3D noi bat
            const AuthHeaderIllustration(height: 275.0),

            // 2. Form Card bo tron 4 goc om noi theo dung UI mau
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
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề & Lời chào
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Chào mừng trở lại',
                            style: AppStyles.authTitle,
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            'Đăng nhập để theo dõi lịch trình hôm nay',
                            style: AppStyles.authSubtitle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // O nhap So dien thoai
                    CustomTextField(
                      label: 'Số điện thoại',
                      hintText: '09xx xxx xxx',
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
                    const SizedBox(height: 18.0),

                    // O nhap Mat khau
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
                        if (_loiMatKhau != null) {
                          setState(() {
                            _loiMatKhau = AuthValidation.validateMatKhau(val);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // Hang Ghi nho dang nhap & Quen mat khau
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22.0,
                              height: 22.0,
                              child: Checkbox(
                                value: _ghiNhoDangNhap,
                                activeColor: AppColors.sageGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                side: const BorderSide(
                                  color: AppColors.borderGrey,
                                  width: 1.5,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _ghiNhoDangNhap = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _ghiNhoDangNhap = !_ghiNhoDangNhap;
                                });
                              },
                              child: const Text(
                                'Ghi nhớ đăng\nnhập',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: AppColors.textDark,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _hienThiDialogQuenMatKhau,
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22.0),

                    // Nut Dang nhap Sage Green
                    SageGreenButton(
                      text: 'Đăng nhập',
                      dangXuLy: authController.dangXuLy,
                      onPressed: _thucHienDangNhap,
                    ),
                    const SizedBox(height: 20.0),

                    // Footer chuyen sang Dang ky
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DangKyScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Chưa có tài khoản? ',
                            style: AppStyles.footerText,
                            children: [
                              TextSpan(
                                text: 'Đăng ký ngay',
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
            constraints: const BoxConstraints(maxWidth: 420.0, maxHeight: 860.0),
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
