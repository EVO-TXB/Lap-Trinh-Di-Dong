import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BoNhoDichVu {
  static const String keyToken = 'token_xac_thuc';
  static const String keyNguoiDung = 'thong_tin_nguoi_dung';
  static const String keyGhiNho = 'ghi_nho_dang_nhap';
  static const String keySoDienThoaiGhiNho = 'so_dien_thoai_ghi_nho';
  static const String keyDanhSachNguoiDungLocal = 'danh_sach_nguoi_dung_local';

  static BoNhoDichVu? _instance;
  static SharedPreferences? _prefs;

  BoNhoDichVu._();

  static Future<BoNhoDichVu> getInstance() async {
    if (_instance == null) {
      _instance = BoNhoDichVu._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Token xac thuc
  Future<bool> saveToken(String token) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  Future<bool> removeToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.remove(keyToken);
  }

  // Thong tin nguoi dung dang nhap
  Future<bool> saveNguoiDung(Map<String, dynamic> thongTinNguoiDung) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(keyNguoiDung, jsonEncode(thongTinNguoiDung));
  }

  Future<Map<String, dynamic>?> getNguoiDung() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyNguoiDung);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeNguoiDung() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.remove(keyNguoiDung);
  }

  // Tuy chon ghi nho dang nhap
  Future<bool> saveGhiNho(bool ghiNho, String soDienThoai) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(keyGhiNho, ghiNho);
    if (ghiNho) {
      await prefs.setString(keySoDienThoaiGhiNho, soDienThoai);
    } else {
      await prefs.remove(keySoDienThoaiGhiNho);
    }
    return true;
  }

  Future<bool> getGhiNho() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(keyGhiNho) ?? false;
  }

  Future<String?> getSoDienThoaiGhiNho() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(keySoDienThoaiGhiNho);
  }

  // Du lieu nguoi dung offline fallback
  Future<List<Map<String, dynamic>>> getDanhSachNguoiDungLocal() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyDanhSachNguoiDungLocal);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveDanhSachNguoiDungLocal(List<Map<String, dynamic>> danhSach) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(keyDanhSachNguoiDungLocal, jsonEncode(danhSach));
  }

  // Dang xuat
  Future<void> clearAuthData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyNguoiDung);
  }

  // Phuong thuc tro giup doc/ghi chuoi tong quat
  Future<bool> luuChuoi(String key, String value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  String? layChuoi(String key) {
    return _prefs?.getString(key);
  }
}
