import 'dart:convert';

/// Model cấu hình cài đặt và tùy chọn người dùng (Settings Model)
/// Tuân thủ quy chuẩn AI_rules.md: đặt tên camelCase tiếng Việt, đầy đủ phương thức toMap/fromMap/copyWith.
class CaiDatModel {
  // Cấu hình Lịch trình & Tự động hóa
  final bool tuDongTichViecThietYeu;
  final String ngayBatDauTuan; // 'Thứ Hai' | 'Chủ Nhật'

  // Thông báo & Nhắc nhở
  final bool batThongBaoDay;
  final int thoiGianNhacTruoc; // Số phút: 5, 10, 15, 30, 60
  final bool amThanhRung;
  final String kieuThongBao; // 'Cả hai (Banner + Bong bóng)' | 'Banner trượt Messenger' | 'Bong bóng nổi (Chat Head)' | 'Hộp thoại Popup'

  // Giao diện & Ngôn ngữ
  final String ngonNgu; // 'Tiếng Việt' | 'English'
  final String cheDoGiaoDien; // 'Sáng' | 'Tối' | 'Hệ thống'

  // Dữ liệu & Ngoại tuyến
  final DateTime thoiGianDongBoLanCuoi;

  const CaiDatModel({
    this.tuDongTichViecThietYeu = true,
    this.ngayBatDauTuan = 'Thứ Hai',
    this.batThongBaoDay = true,
    this.thoiGianNhacTruoc = 15,
    this.amThanhRung = true,
    this.kieuThongBao = 'Cả hai (Banner + Bong bóng)',
    this.ngonNgu = 'Tiếng Việt',
    this.cheDoGiaoDien = 'Sáng',
    required this.thoiGianDongBoLanCuoi,
  });

  /// Khởi tạo mặc định
  factory CaiDatModel.macDinh() {
    return CaiDatModel(
      tuDongTichViecThietYeu: true,
      ngayBatDauTuan: 'Thứ Hai',
      batThongBaoDay: true,
      thoiGianNhacTruoc: 15,
      amThanhRung: true,
      kieuThongBao: 'Cả hai (Banner + Bong bóng)',
      ngonNgu: 'Tiếng Việt',
      cheDoGiaoDien: 'Sáng',
      thoiGianDongBoLanCuoi: DateTime.now().subtract(const Duration(minutes: 10)),
    );
  }

  /// Chuỗi hiển thị thời gian nhắc nhở (ví dụ: "Trước 15 phút")
  String get moTaThoiGianNhacTruoc {
    if (thoiGianNhacTruoc >= 60) {
      return 'Trước ${thoiGianNhacTruoc ~/ 60} tiếng';
    }
    return 'Trước $thoiGianNhacTruoc phút';
  }

  /// Chuỗi mô tả lần đồng bộ gần nhất
  String get moTaDongBoLanCuoi {
    final difference = DateTime.now().difference(thoiGianDongBoLanCuoi);
    if (difference.inMinutes < 1) {
      return 'Vừa mới xong';
    } else if (difference.inMinutes < 60) {
      return 'Đồng bộ lần cuối: ${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return 'Đồng bộ lần cuối: ${difference.inHours} giờ trước';
    } else {
      return 'Đồng bộ lần cuối: ${thoiGianDongBoLanCuoi.day}/${thoiGianDongBoLanCuoi.month}';
    }
  }

  CaiDatModel copyWith({
    bool? tuDongTichViecThietYeu,
    String? ngayBatDauTuan,
    bool? batThongBaoDay,
    int? thoiGianNhacTruoc,
    bool? amThanhRung,
    String? kieuThongBao,
    String? ngonNgu,
    String? cheDoGiaoDien,
    DateTime? thoiGianDongBoLanCuoi,
  }) {
    return CaiDatModel(
      tuDongTichViecThietYeu: tuDongTichViecThietYeu ?? this.tuDongTichViecThietYeu,
      ngayBatDauTuan: ngayBatDauTuan ?? this.ngayBatDauTuan,
      batThongBaoDay: batThongBaoDay ?? this.batThongBaoDay,
      thoiGianNhacTruoc: thoiGianNhacTruoc ?? this.thoiGianNhacTruoc,
      amThanhRung: amThanhRung ?? this.amThanhRung,
      kieuThongBao: kieuThongBao ?? this.kieuThongBao,
      ngonNgu: ngonNgu ?? this.ngonNgu,
      cheDoGiaoDien: cheDoGiaoDien ?? this.cheDoGiaoDien,
      thoiGianDongBoLanCuoi: thoiGianDongBoLanCuoi ?? this.thoiGianDongBoLanCuoi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tu_dong_tich_viec_thiet_yeu': tuDongTichViecThietYeu,
      'ngay_bat_dau_tuan': ngayBatDauTuan,
      'bat_thong_bao_day': batThongBaoDay,
      'thoi_gian_nhac_truoc': thoiGianNhacTruoc,
      'am_thanh_rung': amThanhRung,
      'kieu_thong_bao': kieuThongBao,
      'ngon_ngu': ngonNgu,
      'che_do_giao_dien': cheDoGiaoDien,
      'thoi_gian_dong_bo_lan_cuoi': thoiGianDongBoLanCuoi.toIso8601String(),
    };
  }

  factory CaiDatModel.fromMap(Map<String, dynamic> map) {
    return CaiDatModel(
      tuDongTichViecThietYeu: map['tu_dong_tich_viec_thiet_yeu'] as bool? ?? true,
      ngayBatDauTuan: map['ngay_bat_dau_tuan'] as String? ?? 'Thứ Hai',
      batThongBaoDay: map['bat_thong_bao_day'] as bool? ?? true,
      thoiGianNhacTruoc: map['thoi_gian_nhac_truoc'] as int? ?? 15,
      amThanhRung: map['am_thanh_rung'] as bool? ?? true,
      kieuThongBao: map['kieu_thong_bao'] as String? ?? 'Cả hai (Banner + Bong bóng)',
      ngonNgu: map['ngon_ngu'] as String? ?? 'Tiếng Việt',
      cheDoGiaoDien: map['che_do_giao_dien'] as String? ?? 'Sáng',
      thoiGianDongBoLanCuoi: map['thoi_gian_dong_bo_lan_cuoi'] != null
          ? DateTime.tryParse(map['thoi_gian_dong_bo_lan_cuoi'].toString()) ?? DateTime.now()
          : DateTime.now().subtract(const Duration(minutes: 10)),
    );
  }

  String toJson() => json.encode(toMap());

  factory CaiDatModel.fromJson(String source) =>
      CaiDatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

