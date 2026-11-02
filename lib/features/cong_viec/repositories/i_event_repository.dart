import '../models/cong_viec_model.dart';

/// Interface trừu tượng phục vụ việc đọc/ghi dữ liệu lịch trình
abstract class IEventRepository {
  /// Lấy danh sách công việc theo tuần (tính từ ngày đầu tuần - Thứ Hai)
  Future<List<CongViecModel>> getDanhSachCongViecTheoTuan({
    required DateTime ngayDauTuan,
  });

  /// Lấy danh sách công việc theo tháng
  Future<List<CongViecModel>> getDanhSachCongViecTheoThang({
    required int nam,
    required int thang,
  });

  /// Lấy danh sách công việc theo một ngày cụ thể
  Future<List<CongViecModel>> getDanhSachCongViecTheoNgay(DateTime ngay);

  /// Lấy toàn bộ danh sách công việc hiện có (phục vụ kiểm tra trùng lịch và đồng bộ)
  Future<List<CongViecModel>> getAllCongViec();

  /// Tạo mới công việc đơn lẻ
  Future<CongViecModel> createCongViec(CongViecModel congViec);

  /// Tạo hàng loạt công việc (dùng cho chuỗi sự kiện lặp lại)
  Future<List<CongViecModel>> createDanhSachCongViec(List<CongViecModel> danhSach);

  /// Cập nhật công việc hiện có
  Future<CongViecModel> updateCongViec(CongViecModel congViec);

  /// Cập nhật toàn bộ chuỗi công việc lặp lại theo mã chuỗi lặp
  Future<List<CongViecModel>> updateChuoiCongViec(String maChuoiLap, CongViecModel mauCapNhat);

  /// Xóa công việc đơn lẻ theo ID
  Future<bool> deleteCongViec(int id);

  /// Xóa toàn bộ chuỗi sự kiện lặp lại theo mã chuỗi lặp
  Future<bool> deleteChuoiCongViec(String maChuoiLap);
}
