import '../models/cong_viec_model.dart';

/// Helper chuyên biệt xử lý sinh và điều phối chuỗi sự kiện lặp (Batch Event Handling)
class BatchEventHelper {
  /// Chuyển đổi DateTime.weekday (1=Thứ Hai ... 7=Chủ Nhật) sang mã Thứ Timass:
  /// 2 = T2, 3 = T3, 4 = T4, 5 = T5, 6 = T6, 7 = T7, 8 = CN
  static int weekdayToThuTimass(int weekday) {
    if (weekday == DateTime.sunday) return 8; // CN
    return weekday + 1; // 1 (Mon) -> 2 (T2), ..., 6 (Sat) -> 7 (T7)
  }

  /// Sinh danh sách hàng loạt các sự kiện con gắn chung một `maChuoiLap`
  static List<CongViecModel> sinhDanhSachCongViecLap({
    required CongViecModel mau,
    required Set<int> cacThu, // {2, 3, 4, 5, 6, 7, 8}
    required DateTime ngayBatDau,
    required DateTime ngayKetThuc,
    String? maChuoiLap,
  }) {
    if (cacThu.isEmpty) return [];

    // Tự sinh mã chuỗi lặp duy nhất nếu chưa có
    final String chuoiId = maChuoiLap ??
        'lap_${DateTime.now().millisecondsSinceEpoch}_${mau.tenCongViec.hashCode.abs()}';

    final List<CongViecModel> danhSachSinhRa = [];
    DateTime ngayChay = DateTime(ngayBatDau.year, ngayBatDau.month, ngayBatDau.day);
    final DateTime ngayDung = DateTime(ngayKetThuc.year, ngayKetThuc.month, ngayKetThuc.day);

    while (!ngayChay.isAfter(ngayDung)) {
      final int thuHienTai = weekdayToThuTimass(ngayChay.weekday);

      if (cacThu.contains(thuHienTai)) {
        final DateTime batDau = DateTime(
          ngayChay.year,
          ngayChay.month,
          ngayChay.day,
          mau.thoiGianBatDau.hour,
          mau.thoiGianBatDau.minute,
        );
        final DateTime ketThuc = DateTime(
          ngayChay.year,
          ngayChay.month,
          ngayChay.day,
          mau.thoiGianKetThuc.hour,
          mau.thoiGianKetThuc.minute,
        );

        danhSachSinhRa.add(
          mau.copyWith(
            id: 0, // Id tự sinh khi lưu repository
            maChuoiLap: chuoiId,
            thoiGianBatDau: batDau,
            thoiGianKetThuc: ketThuc,
            daHoanThanh: false,
            ngayTao: DateTime.now(),
          ),
        );
      }

      ngayChay = DateTime(ngayChay.year, ngayChay.month, ngayChay.day + 1);
    }

    return danhSachSinhRa;
  }
}

