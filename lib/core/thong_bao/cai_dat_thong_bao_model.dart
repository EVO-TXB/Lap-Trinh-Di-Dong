import 'dart:convert';

/// Model cấu hình cài đặt thông báo và tự động hóa theo chuẩn AI_rules.md
class CaiDatThongBaoModel {
  final bool batThongBao;
  final int nhacTruocPhut;
  final bool tuDongTichViecThietYeu;
  final bool batAmThanh;
  final bool batRung;

  const CaiDatThongBaoModel({
    this.batThongBao = true,
    this.nhacTruocPhut = 15,
    this.tuDongTichViecThietYeu = true,
    this.batAmThanh = true,
    this.batRung = true,
  });

  CaiDatThongBaoModel copyWith({
    bool? batThongBao,
    int? nhacTruocPhut,
    bool? tuDongTichViecThietYeu,
    bool? batAmThanh,
    bool? batRung,
  }) {
    return CaiDatThongBaoModel(
      batThongBao: batThongBao ?? this.batThongBao,
      nhacTruocPhut: nhacTruocPhut ?? this.nhacTruocPhut,
      tuDongTichViecThietYeu: tuDongTichViecThietYeu ?? this.tuDongTichViecThietYeu,
      batAmThanh: batAmThanh ?? this.batAmThanh,
      batRung: batRung ?? this.batRung,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bat_thong_bao': batThongBao,
      'nhac_truoc_phut': nhacTruocPhut,
      'tu_dong_tich_viec_thiet_yeu': tuDongTichViecThietYeu,
      'bat_am_thanh': batAmThanh,
      'bat_rung': batRung,
    };
  }

  factory CaiDatThongBaoModel.fromMap(Map<String, dynamic> map) {
    return CaiDatThongBaoModel(
      batThongBao: map['bat_thong_bao'] as bool? ?? true,
      nhacTruocPhut: map['nhac_truoc_phut'] as int? ?? 15,
      tuDongTichViecThietYeu: map['tu_dong_tich_viec_thiet_yeu'] as bool? ?? true,
      batAmThanh: map['bat_am_thanh'] as bool? ?? true,
      batRung: map['bat_rung'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory CaiDatThongBaoModel.fromJson(String source) =>
      CaiDatThongBaoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
