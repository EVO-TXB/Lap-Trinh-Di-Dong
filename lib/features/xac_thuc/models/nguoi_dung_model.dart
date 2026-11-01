class NguoiDungModel {
  final int? id;
  final String soDienThoai;
  final String? hoTen;
  final DateTime? ngayTao;

  const NguoiDungModel({
    this.id,
    required this.soDienThoai,
    this.hoTen,
    this.ngayTao,
  });

  factory NguoiDungModel.fromJson(Map<String, dynamic> json) {
    return NguoiDungModel(
      id: json['id'] as int?,
      soDienThoai: json['soDienThoai'] as String? ?? '',
      hoTen: json['hoTen'] as String?,
      ngayTao: json['ngayTao'] != null
          ? DateTime.tryParse(json['ngayTao'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'soDienThoai': soDienThoai,
      if (hoTen != null) 'hoTen': hoTen,
      if (ngayTao != null) 'ngayTao': ngayTao!.toIso8601String(),
    };
  }

  NguoiDungModel copyWith({
    int? id,
    String? soDienThoai,
    String? hoTen,
    DateTime? ngayTao,
  }) {
    return NguoiDungModel(
      id: id ?? this.id,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      hoTen: hoTen ?? this.hoTen,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }
}

