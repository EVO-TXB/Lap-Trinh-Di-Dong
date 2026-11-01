import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/bo_nho/co_so_du_lieu_local.dart';

class DatabaseViewerDialog extends StatelessWidget {
  final List<KhachHangEntity> danhSachKhachHang;
  final Function(String soDienThoai, String matKhau)? onChonKhachHang;
  final VoidCallback? onResetDatabase;

  const DatabaseViewerDialog({
    super.key,
    required this.danhSachKhachHang,
    this.onChonKhachHang,
    this.onResetDatabase,
  });

  static void show(
    BuildContext context, {
    required List<KhachHangEntity> danhSach,
    Function(String soDienThoai, String matKhau)? onChon,
    VoidCallback? onReset,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DatabaseViewerDialog(
        danhSachKhachHang: danhSach,
        onChonKhachHang: onChon,
        onResetDatabase: onReset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo trên cùng
          Center(
            child: Container(
              width: 48.0,
              height: 5.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreenLight,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.storage_rounded, color: AppColors.sageGreen, size: 22.0),
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cơ sở dữ liệu khách hàng',
                        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'Bảng: timass_db.khach_hang (${danhSachKhachHang.length} bản ghi)',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Divider(),
          const SizedBox(height: 8.0),

          // Danh sach ban ghi
          Expanded(
            child: danhSachKhachHang.isEmpty
                ? const Center(
                    child: Text('Chưa có khách hàng nào trong cơ sở dữ liệu'),
                  )
                : ListView.separated(
                    itemCount: danhSachKhachHang.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                    itemBuilder: (context, index) {
                      final kh = danhSachKhachHang[index];
                      final bool laAdmin = kh.vaiTro == 'QUANTRI';
                      final bool laPremium = kh.vaiTro == 'PREMIUM';

                      Color badgeColor = AppColors.sageGreen;
                      String badgeText = 'Khách hàng';
                      if (laAdmin) {
                        badgeColor = Colors.purple.shade600;
                        badgeText = 'Quản trị viên';
                      } else if (laPremium) {
                        badgeColor = Colors.orange.shade700;
                        badgeText = 'Premium VIP';
                      }

                      return InkWell(
                        onTap: () {
                          if (onChonKhachHang != null) {
                            onChonKhachHang!(kh.soDienThoai, '123456');
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(14.0),
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18.0,
                                        backgroundColor: badgeColor.withOpacity(0.15),
                                        child: Text(
                                          kh.hoTen.isNotEmpty ? kh.hoTen[0].toUpperCase() : 'U',
                                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kh.hoTen,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                          ),
                                          Text(
                                            'SĐT: ${kh.soDienThoai}',
                                            style: const TextStyle(fontSize: 13.0, color: AppColors.textMedium),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: TextStyle(color: badgeColor, fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mật khẩu mẫu: 123456',
                                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      'Số lần đăng nhập: ${kh.soLanDangNhap}',
                                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tạo lúc: ${dateFormat.format(kh.ngayTao)}',
                                    style: TextStyle(fontSize: 11.0, color: Colors.grey.shade500),
                                  ),
                                  const Text(
                                    'Chạm để điền nhanh →',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.sageGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 10.0),
          Row(
            children: [
              if (onResetDatabase != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onResetDatabase!();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18.0),
                    label: const Text('Đặt lại CSDL mẫu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

