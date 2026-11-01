import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/xac_thuc/models/nguoi_dung_model.dart';

/// Lop mo hinh luu tru khach hang trong Co So Du Lieu
class KhachHangEntity {
  final int id;
  final String soDienThoai;
  final String hoTen;
  final String matKhauHash;
  final String vaiTro; // "KHACH_HANG", "PREMIUM", "QUANTRI"
  final DateTime ngayTao;
  final DateTime? lanDangNhapCuoi;
  final int soLanDangNhap;
  final String trangThai; // "HOAT_DONG", "TAM_KHOA"

  KhachHangEntity({
    required this.id,
    required this.soDienThoai,
    required this.hoTen,
    required this.matKhauHash,
    this.vaiTro = 'KHACH_HANG',
    required this.ngayTao,
    this.lanDangNhapCuoi,
    this.soLanDangNhap = 0,
    this.trangThai = 'HOAT_DONG',
  });

  factory KhachHangEntity.fromJson(Map<String, dynamic> json) {
    return KhachHangEntity(
      id: json['id'] as int? ?? 0,
      soDienThoai: json['soDienThoai'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      matKhauHash: json['matKhauHash'] as String? ?? '',
      vaiTro: json['vaiTro'] as String? ?? 'KHACH_HANG',
      ngayTao: json['ngayTao'] != null
          ? DateTime.tryParse(json['ngayTao'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lanDangNhapCuoi: json['lanDangNhapCuoi'] != null
          ? DateTime.tryParse(json['lanDangNhapCuoi'].toString())
          : null,
      soLanDangNhap: json['soLanDangNhap'] as int? ?? 0,
      trangThai: json['trangThai'] as String? ?? 'HOAT_DONG',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soDienThoai': soDienThoai,
      'hoTen': hoTen,
      'matKhauHash': matKhauHash,
      'vaiTro': vaiTro,
      'ngayTao': ngayTao.toIso8601String(),
      if (lanDangNhapCuoi != null) 'lanDangNhapCuoi': lanDangNhapCuoi!.toIso8601String(),
      'soLanDangNhap': soLanDangNhap,
      'trangThai': trangThai,
    };
  }

  NguoiDungModel toNguoiDungModel() {
    return NguoiDungModel(
      id: id,
      soDienThoai: soDienThoai,
      hoTen: hoTen,
      ngayTao: ngayTao,
    );
  }

  KhachHangEntity copyWith({
    int? id,
    String? soDienThoai,
    String? hoTen,
    String? matKhauHash,
    String? vaiTro,
    DateTime? ngayTao,
    DateTime? lanDangNhapCuoi,
    int? soLanDangNhap,
    String? trangThai,
  }) {
    return KhachHangEntity(
      id: id ?? this.id,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      hoTen: hoTen ?? this.hoTen,
      matKhauHash: matKhauHash ?? this.matKhauHash,
      vaiTro: vaiTro ?? this.vaiTro,
      ngayTao: ngayTao ?? this.ngayTao,
      lanDangNhapCuoi: lanDangNhapCuoi ?? this.lanDangNhapCuoi,
      soLanDangNhap: soLanDangNhap ?? this.soLanDangNhap,
      trangThai: trangThai ?? this.trangThai,
    );
  }
}

/// Co So Du Lieu Cuc Bo (Local Database Engine)
/// Luu tru toan bo khach hang va thong tin tai khoan xac thuc
class CoSoDuLieuLocal {
  static const String _keyTableKhachHang = 'timass_db_bang_khach_hang';
  static CoSoDuLieuLocal? _instance;
  final SharedPreferences _prefs;

  CoSoDuLieuLocal._(this._prefs);

  static Future<CoSoDuLieuLocal> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = CoSoDuLieuLocal._(prefs);
      await _instance!._khoiTaoDuLieuMauNeuTrong();
    }
    return _instance!;
  }

  static String hashMatKhau(String matKhau) {
    final bytes = utf8.encode(matKhau);
    return sha256.convert(bytes).toString();
  }

  /// Khoi tao cac ban ghi khach hang mau vao Co So Du Lieu neu database con trong
  Future<void> _khoiTaoDuLieuMauNeuTrong() async {
    final tonTai = _prefs.getString(_keyTableKhachHang);
    if (tonTai == null || tonTai.trim().isEmpty) {
      final now = DateTime.now();
      final List<KhachHangEntity> danhSachMau = [
        KhachHangEntity(
          id: 1,
          soDienThoai: '0987654321',
          hoTen: 'Nguyễn Văn An',
          matKhauHash: hashMatKhau('123456'),
          vaiTro: 'KHACH_HANG',
          ngayTao: now.subtract(const Duration(days: 30)),
          lanDangNhapCuoi: now.subtract(const Duration(hours: 2)),
          soLanDangNhap: 15,
        ),
        KhachHangEntity(
          id: 2,
          soDienThoai: '0912345678',
          hoTen: 'Trần Thị Mai',
          matKhauHash: hashMatKhau('123456'),
          vaiTro: 'PREMIUM',
          ngayTao: now.subtract(const Duration(days: 15)),
          lanDangNhapCuoi: now.subtract(const Duration(days: 1)),
          soLanDangNhap: 8,
        ),
        KhachHangEntity(
          id: 3,
          soDienThoai: '0905999888',
          hoTen: 'Lê Hoàng Nam',
          matKhauHash: hashMatKhau('123456'),
          vaiTro: 'QUANTRI',
          ngayTao: now.subtract(const Duration(days: 60)),
          lanDangNhapCuoi: now.subtract(const Duration(minutes: 30)),
          soLanDangNhap: 42,
        ),
      ];

      await _luuDanhSachKhachHang(danhSachMau);
    }
  }

  /// Lay toan bo danh sach khach hang tu Co So Du Lieu
  Future<List<KhachHangEntity>> layTatCaKhachHang() async {
    final rawJson = _prefs.getString(_keyTableKhachHang);
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> listMap = jsonDecode(rawJson);
      return listMap.map((item) => KhachHangEntity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Luu danh sach vao CSDL
  Future<bool> _luuDanhSachKhachHang(List<KhachHangEntity> danhSach) async {
    final listMap = danhSach.map((e) => e.toJson()).toList();
    return _prefs.setString(_keyTableKhachHang, jsonEncode(listMap));
  }

  /// Tim kiem khach hang theo so dien thoai
  Future<KhachHangEntity?> timKhachHangTheoSoDienThoai(String soDienThoai) async {
    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    final danhSach = await layTatCaKhachHang();
    for (final kh in danhSach) {
      if (kh.soDienThoai == cleanPhone) return kh;
    }
    return null;
  }

  /// Kiem tra so dien thoai da co trong Co So Du Lieu chua
  Future<bool> tonTaiSoDienThoai(String soDienThoai) async {
    final kh = await timKhachHangTheoSoDienThoai(soDienThoai);
    return kh != null;
  }

  /// Them moi mot khach hang vao CSDL
  Future<KhachHangEntity> themKhachHang({
    required String hoTen,
    required String soDienThoai,
    required String matKhau,
  }) async {
    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    final danhSach = await layTatCaKhachHang();

    if (danhSach.any((k) => k.soDienThoai == cleanPhone)) {
      throw Exception('Số điện thoại này đã tồn tại trong cơ sở dữ liệu!');
    }

    final newId = danhSach.isEmpty ? 1 : (danhSach.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final now = DateTime.now();

    final khachHangMoi = KhachHangEntity(
      id: newId,
      soDienThoai: cleanPhone,
      hoTen: hoTen.trim(),
      matKhauHash: hashMatKhau(matKhau),
      vaiTro: 'KHACH_HANG',
      ngayTao: now,
      lanDangNhapCuoi: null,
      soLanDangNhap: 0,
      trangThai: 'HOAT_DONG',
    );

    danhSach.add(khachHangMoi);
    await _luuDanhSachKhachHang(danhSach);
    return khachHangMoi;
  }

  /// Cap nhat thong tin sau khi dang nhap thanh cong
  Future<void> capNhatDangNhapThanhCong(String soDienThoai) async {
    final cleanPhone = soDienThoai.trim().replaceAll(' ', '');
    final danhSach = await layTatCaKhachHang();
    final index = danhSach.indexWhere((k) => k.soDienThoai == cleanPhone);

    if (index != -1) {
      final kh = danhSach[index];
      danhSach[index] = kh.copyWith(
        lanDangNhapCuoi: DateTime.now(),
        soLanDangNhap: kh.soLanDangNhap + 1,
      );
      await _luuDanhSachKhachHang(danhSach);
    }
  }

  /// Xoa khach hang theo ID (Quan tri)
  Future<bool> xoaKhachHang(int id) async {
    final danhSach = await layTatCaKhachHang();
    danhSach.removeWhere((k) => k.id == id);
    return _luuDanhSachKhachHang(danhSach);
  }

  /// Xoa toan bo du lieu va dat lai mac dinh
  Future<void> resetDatabase() async {
    await _prefs.remove(_keyTableKhachHang);
    await _khoiTaoDuLieuMauNeuTrong();
  }
}

