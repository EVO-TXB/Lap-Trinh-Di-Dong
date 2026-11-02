/// Model Công việc tuân thủ 100% quy ước đặt tên AI_rules.md
class CongViecModel {
  final int id;
  final int maNguoiDung;
  final int? maQuyTacLap;
  final String tenCongViec;
  final DateTime thoiGianBatDau;
  final DateTime thoiGianKetThuc;
  final String? diaDiem;
  final bool laThietYeu;
  final bool daHoanThanh;
  final int nhacNhoTruocPhut;
  final DateTime ngayTao;
  final String? ghiChu;
  final bool daThongBao;
  final DateTime? thoiGianSnooze;
  final String loaiSuKien; // 'CHU_DONG' hoặc 'BI_DONG'

  CongViecModel({
    required this.id,
    required this.maNguoiDung,
    this.maQuyTacLap,
    required this.tenCongViec,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    this.diaDiem,
    this.laThietYeu = false,
    this.daHoanThanh = false,
    this.nhacNhoTruocPhut = 15,
    required this.ngayTao,
    this.ghiChu,
    this.daThongBao = false,
    this.thoiGianSnooze,
    String? loaiSuKien,
  }) : loaiSuKien = loaiSuKien ?? (laThietYeu ? 'BI_DONG' : 'CHU_DONG');

  /// Kiểm tra có phải công việc bị động/thiết yếu (ăn, ngủ, nghỉ)
  bool get laViecBiDong => loaiSuKien == 'BI_DONG' || laThietYeu;

  /// Logic tự động tích hoàn thành theo AI_rules.md:
  /// Nếu laThietYeu == true (hoặc việc bị động) và thời gian hiện tại > thoiGianKetThuc
  /// thì giao diện tự động render trạng thái đã hoàn thành (daHoanThanh = true).
  bool get trangThaiHoanThanhHienThi {
    if (daHoanThanh) return true;
    if (laViecBiDong && DateTime.now().isAfter(thoiGianKetThuc)) {
      return true;
    }
    return false;
  }

  /// Thời lượng công việc tính theo phút
  int get thoiLuongPhut => thoiGianKetThuc.difference(thoiGianBatDau).inMinutes;

  CongViecModel copyWith({
    int? id,
    int? maNguoiDung,
    int? maQuyTacLap,
    String? tenCongViec,
    DateTime? thoiGianBatDau,
    DateTime? thoiGianKetThuc,
    String? diaDiem,
    bool? laThietYeu,
    bool? daHoanThanh,
    int? nhacNhoTruocPhut,
    DateTime? ngayTao,
    String? ghiChu,
    bool? daThongBao,
    DateTime? thoiGianSnooze,
    String? loaiSuKien,
  }) {
    return CongViecModel(
      id: id ?? this.id,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      maQuyTacLap: maQuyTacLap ?? this.maQuyTacLap,
      tenCongViec: tenCongViec ?? this.tenCongViec,
      thoiGianBatDau: thoiGianBatDau ?? this.thoiGianBatDau,
      thoiGianKetThuc: thoiGianKetThuc ?? this.thoiGianKetThuc,
      diaDiem: diaDiem ?? this.diaDiem,
      laThietYeu: laThietYeu ?? this.laThietYeu,
      daHoanThanh: daHoanThanh ?? this.daHoanThanh,
      nhacNhoTruocPhut: nhacNhoTruocPhut ?? this.nhacNhoTruocPhut,
      ngayTao: ngayTao ?? this.ngayTao,
      ghiChu: ghiChu ?? this.ghiChu,
      daThongBao: daThongBao ?? this.daThongBao,
      thoiGianSnooze: thoiGianSnooze ?? this.thoiGianSnooze,
      loaiSuKien: loaiSuKien ?? this.loaiSuKien,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_nguoi_dung': maNguoiDung,
      'ma_quy_tac_lap': maQuyTacLap,
      'ten_cong_viec': tenCongViec,
      'thoi_gian_bat_dau': thoiGianBatDau.toIso8601String(),
      'thoi_gian_ket_thuc': thoiGianKetThuc.toIso8601String(),
      'dia_diem': diaDiem,
      'la_thiet_yeu': laThietYeu,
      'da_hoan_thanh': daHoanThanh,
      'nhac_nho_truoc_phut': nhacNhoTruocPhut,
      'ngay_tao': ngayTao.toIso8601String(),
      'ghi_chu': ghiChu,
      'da_thong_bao': daThongBao,
      'thoi_gian_snooze': thoiGianSnooze?.toIso8601String(),
      'loai_su_kien': loaiSuKien,
    };
  }

  factory CongViecModel.fromJson(Map<String, dynamic> json) {
    return CongViecModel(
      id: json['id'] as int,
      maNguoiDung: json['ma_nguoi_dung'] as int,
      maQuyTacLap: json['ma_quy_tac_lap'] as int?,
      tenCongViec: json['ten_cong_viec'] as String,
      thoiGianBatDau: DateTime.parse(json['thoi_gian_bat_dau'] as String),
      thoiGianKetThuc: DateTime.parse(json['thoi_gian_ket_thuc'] as String),
      diaDiem: json['dia_diem'] as String?,
      laThietYeu: json['la_thiet_yeu'] == true || json['la_thiet_yeu'] == 1,
      daHoanThanh: json['da_hoan_thanh'] == true || json['da_hoan_thanh'] == 1,
      nhacNhoTruocPhut: json['nhac_nho_truoc_phut'] as int? ?? 15,
      ngayTao: DateTime.parse(json['ngay_tao'] as String),
      ghiChu: json['ghi_chu'] as String?,
      daThongBao: json['da_thong_bao'] == true || json['da_thong_bao'] == 1,
      thoiGianSnooze: json['thoi_gian_snooze'] != null
          ? DateTime.tryParse(json['thoi_gian_snooze'] as String)
          : null,
      loaiSuKien: json['loai_su_kien'] as String?,
    );
  }
}
