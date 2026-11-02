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

  /// Tạo mới công việc
  Future<CongViecModel> createCongViec(CongViecModel congViec);

  /// Cập nhật công việc hiện có
  Future<CongViecModel> updateCongViec(CongViecModel congViec);

  /// Xóa công việc theo ID
  Future<bool> deleteCongViec(int id);
}
