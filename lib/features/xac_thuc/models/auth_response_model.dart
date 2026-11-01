import 'nguoi_dung_model.dart';

class AuthResponseModel {
  final String token;
  final String loaiToken; // Bearer
  final int? thoiGianHetHan; // Tinh bang giay hoac timestamp
  final NguoiDungModel nguoiDung;

  const AuthResponseModel({
    required this.token,
    this.loaiToken = 'Bearer',
    this.thoiGianHetHan,
    required this.nguoiDung,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      loaiToken: json['loaiToken'] as String? ?? 'Bearer',
      thoiGianHetHan: json['thoiGianHetHan'] as int?,
      nguoiDung: json['nguoiDung'] != null
          ? NguoiDungModel.fromJson(json['nguoiDung'] as Map<String, dynamic>)
          : const NguoiDungModel(soDienThoai: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'loaiToken': loaiToken,
      if (thoiGianHetHan != null) 'thoiGianHetHan': thoiGianHetHan,
      'nguoiDung': nguoiDung.toJson(),
    };
  }
}

