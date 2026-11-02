import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Hộp thoại Đổi mật khẩu
class DoiMatKhauDialog extends StatefulWidget {
  const DoiMatKhauDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DoiMatKhauDialog(),
    );
  }

  @override
  State<DoiMatKhauDialog> createState() => _DoiMatKhauDialogState();
}

class _DoiMatKhauDialogState extends State<DoiMatKhauDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matKhauCuController = TextEditingController();
  final _matKhauMoiController = TextEditingController();
  final _xacNhanController = TextEditingController();

  bool _anMatKhauCu = true;
  bool _anMatKhauMoi = true;
  bool _anXacNhan = true;
  bool _dangLuu = false;

  @override
  void dispose() {
    _matKhauCuController.dispose();
    _matKhauMoiController.dispose();
    _xacNhanController.dispose();
    super.dispose();
  }

  void _xuLyDoiMatKhau() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangLuu = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _dangLuu = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: const Row(
        children: [
          Icon(Icons.lock_reset_rounded, color: AppColors.sageGreen, size: 26),
          SizedBox(width: 10),
          Text(
            'Đổi mật khẩu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Mật khẩu hiện tại
              TextFormField(
                controller: _matKhauCuController,
                obscureText: _anMatKhauCu,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  hintText: 'Nhập mật khẩu đang dùng',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_anMatKhauCu ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _anMatKhauCu = !_anMatKhauCu),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu cũ';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 2. Mật khẩu mới
              TextFormField(
                controller: _matKhauMoiController,
                obscureText: _anMatKhauMoi,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  hintText: 'Tối thiểu 6 ký tự',
                  prefixIcon: const Icon(Icons.key_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_anMatKhauMoi ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _anMatKhauMoi = !_anMatKhauMoi),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 3. Xác nhận mật khẩu mới
              TextFormField(
                controller: _xacNhanController,
                obscureText: _anXacNhan,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  hintText: 'Nhập lại mật khẩu mới',
                  prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_anXacNhan ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _anXacNhan = !_anXacNhan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val != _matKhauMoiController.text) return 'Mật khẩu xác nhận không khớp';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _dangLuu ? null : _xuLyDoiMatKhau,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sageGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _dangLuu
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Cập nhật mật khẩu', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

