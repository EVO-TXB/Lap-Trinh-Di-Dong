import '../models/cong_viec_model.dart';

/// Kết quả phân tích kiểm tra xung đột thời gian
class KetQuaKiemTraTrungLich {
  final bool coTrungLich;
  final bool thoiGianKhongHopLe;
  final CongViecModel? congViecBiTrung;
  final List<CongViecModel> danhSachBiTrung;
  final String thongBao;

  const KetQuaKiemTraTrungLich({
    required this.coTrungLich,
    this.thoiGianKhongHopLe = false,
    this.congViecBiTrung,
    this.danhSachBiTrung = const [],
    this.thongBao = '',
  });

  /// Trạng thái hợp lệ hoàn toàn (không trùng lịch và thời gian hợp lệ)
  bool get hopLe => !coTrungLich && !thoiGianKhongHopLe;
}

/// Tiện ích thuật toán kiểm tra trùng lịch (Time Conflict Check)
/// Dựa trên công thức giao thoa đoạn thời gian:
/// max(start1, start2) < min(end1, end2)  <=> (startNew < endOld) && (endNew > startOld)
class TimeConflictChecker {
  /// Kiểm tra xung đột cho một sự kiện đơn lẻ
  static KetQuaKiemTraTrungLich kiemTraTrungLich({
    required DateTime thoiGianBatDau,
    required DateTime thoiGianKetThuc,
    required List<CongViecModel> danhSachHienCo,
    int? idHienTai,
    String? maChuoiLapHienTai,
    bool loaiBoCungChuoiLap = false,
  }) {
    // 1. Kiểm tra tính hợp lệ cơ bản của thời gian
    if (!thoiGianKetThuc.isAfter(thoiGianBatDau)) {
      return const KetQuaKiemTraTrungLich(
        coTrungLich: false,
        thoiGianKhongHopLe: true,
        thongBao: 'Giờ bắt đầu phải sớm hơn giờ kết thúc.',
      );
    }

    final List<CongViecModel> danhSachTrung = [];

    for (final cv in danhSachHienCo) {
      // Bỏ qua chính nó khi đang chỉnh sửa
      if (idHienTai != null && cv.id == idHienTai && idHienTai > 0) {
        continue;
      }

      // Bỏ qua các sự kiện cùng chuỗi lặp nếu đang chỉnh sửa toàn bộ chuỗi
      if (loaiBoCungChuoiLap &&
          maChuoiLapHienTai != null &&
          maChuoiLapHienTai.isNotEmpty &&
          cv.maChuoiLap == maChuoiLapHienTai) {
        continue;
      }

      // Chỉ so sánh các sự kiện trong cùng một ngày
      final bool cungNgay = cv.thoiGianBatDau.year == thoiGianBatDau.year &&
          cv.thoiGianBatDau.month == thoiGianBatDau.month &&
          cv.thoiGianBatDau.day == thoiGianBatDau.day;

      if (!cungNgay) continue;

      // Áp dụng thuật toán giao thoa: max(start1, start2) < min(end1, end2)
      final DateTime maxStart = thoiGianBatDau.isAfter(cv.thoiGianBatDau)
          ? thoiGianBatDau
          : cv.thoiGianBatDau;
      final DateTime minEnd = thoiGianKetThuc.isBefore(cv.thoiGianKetThuc)
          ? thoiGianKetThuc
          : cv.thoiGianKetThuc;

      final bool isConflict = maxStart.isBefore(minEnd);

      if (isConflict) {
        danhSachTrung.add(cv);
      }
    }

    if (danhSachTrung.isNotEmpty) {
      final CongViecModel dauTien = danhSachTrung.first;
      final String gioDau =
          '${dauTien.thoiGianBatDau.hour.toString().padLeft(2, '0')}:${dauTien.thoiGianBatDau.minute.toString().padLeft(2, '0')}';
      final String gioCuoi =
          '${dauTien.thoiGianKetThuc.hour.toString().padLeft(2, '0')}:${dauTien.thoiGianKetThuc.minute.toString().padLeft(2, '0')}';

      return KetQuaKiemTraTrungLich(
        coTrungLich: true,
        thoiGianKhongHopLe: false,
        congViecBiTrung: dauTien,
        danhSachBiTrung: danhSachTrung,
        thongBao:
            'Khung giờ này đã bị trùng với sự kiện "${dauTien.tenCongViec}" ($gioDau - $gioCuoi)! Vui lòng sửa lại khung giờ.',
      );
    }

    return const KetQuaKiemTraTrungLich(
      coTrungLich: false,
      thoiGianKhongHopLe: false,
    );
  }

  /// Kiểm tra trùng lịch cho chuỗi sự kiện lặp lại trên nhiều ngày
  static KetQuaKiemTraTrungLich kiemTraTrungLichChuoiLap({
    required List<CongViecModel> danhSachSuKienMoi,
    required List<CongViecModel> danhSachHienCo,
    int? idHienTai,
    String? maChuoiLapHienTai,
  }) {
    for (final suKienMoi in danhSachSuKienMoi) {
      final ketQua = kiemTraTrungLich(
        thoiGianBatDau: suKienMoi.thoiGianBatDau,
        thoiGianKetThuc: suKienMoi.thoiGianKetThuc,
        danhSachHienCo: danhSachHienCo,
        idHienTai: idHienTai,
        maChuoiLapHienTai: maChuoiLapHienTai,
        loaiBoCungChuoiLap: true,
      );

      if (!ketQua.hopLe) {
        return ketQua;
      }
    }

    return const KetQuaKiemTraTrungLich(
      coTrungLich: false,
      thoiGianKhongHopLe: false,
    );
  }
}

