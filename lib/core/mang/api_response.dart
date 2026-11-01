class ApiResponse<T> {
  final int maTrangThai;
  final String thongBao;
  final T? duLieu;

  const ApiResponse({
    required this.maTrangThai,
    required this.thongBao,
    this.duLieu,
  });

  bool get laThanhCong => maTrangThai >= 200 && maTrangThai < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic duLieuJson)? parserDuLieu,
  ) {
    return ApiResponse<T>(
      maTrangThai: json['maTrangThai'] as int? ?? 200,
      thongBao: json['thongBao'] as String? ?? '',
      duLieu: json['duLieu'] != null && parserDuLieu != null
          ? parserDuLieu(json['duLieu'])
          : json['duLieu'] as T?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T duLieu)? serializerDuLieu) {
    return {
      'maTrangThai': maTrangThai,
      'thongBao': thongBao,
      'duLieu': duLieu != null && serializerDuLieu != null
          ? serializerDuLieu(duLieu as T)
          : duLieu,
    };
  }
}

