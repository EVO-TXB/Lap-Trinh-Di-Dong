import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ThanhDoDoManhMatKhau extends StatelessWidget {
  final int diemDoManh; // 0 den 4

  const ThanhDoDoManhMatKhau({
    super.key,
    required this.diemDoManh,
  });

  @override
  Widget build(BuildContext context) {
    if (diemDoManh <= 0) {
      return const SizedBox(height: 10.0);
    }

    final List<Color> mauTieuChuan = [
      AppColors.matKhauYeu,       // Do
      AppColors.matKhauTrungBinh, // Cam
      AppColors.matKhauKha,       // Xanh la nhat
      AppColors.matKhauManh,      // Xanh la dam
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: List.generate(4, (index) {
          final daDatMuc = index < diemDoManh;
          final mauHienThi = daDatMuc ? mauTieuChuan[index] : AppColors.matKhauTrong;

          return Expanded(
            child: Container(
              height: 4.0,
              margin: EdgeInsets.only(
                left: index == 0 ? 0.0 : 4.0,
                right: index == 3 ? 0.0 : 4.0,
              ),
              decoration: BoxDecoration(
                color: mauHienThi,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}

