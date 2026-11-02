# MODULE THÔNG BÁO NHẮC NHỞ & TÁC VỤ NỀN (TIMASS NOTIFICATION & AUTOMATION)

Module quản lý thông báo nhắc nhở sắp đến giờ và tác vụ tự động chạy ngầm theo chuẩn thiết kế và quy tắc `AI_rules.md`.

## 1. Thành phần kiến trúc

### 1.1. Core Services (`lib/core/thong_bao/`)
* **`CaiDatThongBaoModel`** (`cai_dat_thong_bao_model.dart`):
  - Model lưu trữ cấu hình người dùng: `batThongBao`, `nhacTruocPhut` (mặc định 15 phút), `tuDongTichViecThietYeu`, `batAmThanh`, `batRung`.
  - Tuần tự hóa JSON tương thích với `SharedPreferences` thông qua `BoNhoDichVu`.
* **`DichVuThongBao`** (`dich_vu_thong_bao.dart`):
  - Singleton Service độc lập quản lý logic quét thông báo và tự động hóa.
  - Quản lý `StreamController<CongViecModel>` broadcast sự kiện popup nhắc nhở tới UI.
  - Bộ đệm `_danhSachIdDaThongBao` và `_danhSachSnooze` ngăn chặn phát trùng lặp.
  - Timer tác vụ nền định kỳ (Worker) hỗ trợ quét ngầm.

### 1.2. Features UI & Controller (`lib/features/thong_bao/`)
* **`ThongBaoController`** (`controllers/thong_bao_controller.dart`):
  - `ChangeNotifier` quản lý trạng thái hiển thị, số lượng thông báo chưa đọc (badge chấm đỏ trên icon chuông).
  - Tích hợp với `Provider` toàn app.
* **`PopupNhacNhoDialog`** (`widgets/popup_nhac_nho_dialog.dart`):
  - Dialog Popup tái lập chính xác theo mẫu thiết kế `ui sample/ui thông báo.png`.
  - Header với icon chuông đỏ, tiêu đề "Timass • Nhắc nhở sắp đến giờ", nút đóng `X`.
  - Minh họa đồng hồ 3D pastel cam, tên sự kiện in đậm và dòng phụ chi tiết.
  - 2 Nút hành động: Nút phụ "Đóng" và Nút chính "Xem chi tiết" (màu Sage green bo tròn).
  - Tiện ích hoãn báo 5 phút (Snooze).
* **`DongHoBaoThuc3DWidget`** (`widgets/dong_ho_bao_thuc_3d_widget.dart`):
  - Widget đồng hồ báo thức 3D pastel claymorphism tông cam với hiệu ứng rung lắc chuông và sóng âm thanh.
* **`HopThoaiThongBao`** (`widgets/hop_thoai_thong_bao.dart`):
  - Modal Bottom Sheet hiển thị danh sách lịch sử thông báo, nút toggle cấu hình và kiểm thử nhanh khi bấm vào icon chuông ở Header.

---

## 2. Các luồng xử lý chính

### 2.1. Notification Scanner
1. Quét danh sách công việc trong tuần hoặc ngày hiện tại.
2. Kiểm tra các sự kiện có `thoiGianBatDau - now <= nhacTruocPhut` (mặc định 15 phút) và chưa được thông báo (`daThongBao == false`).
3. Nếu cài đặt thông báo đang BẬT:
   - Phát sự kiện qua `streamThongBao`.
   - Hiển thị `PopupNhacNhoDialog` trên màn hình.
   - Đánh dấu đã thông báo để không nhắc lại trùng lặp.

### 2.2. Chức năng Snooze (Hoãn 5 phút)
- Khi người dùng nhấn "Nhắc lại sau 5 phút (Snooze)", công việc được đưa vào danh sách tạm hoãn `_danhSachSnooze`.
- Trong thời gian 5 phút tới, scanner bỏ qua không nhắc lại.
- Khi thời gian hiện tại vượt qua mốc hẹn lại, scanner kích hoạt lại thông báo.

### 2.3. Auto-Complete Passive Events (Tự động tích việc thiết yếu)
- Quét các công việc có `laViecBiDong == true` (như Ăn trưa, Ngủ nghỉ, Đi lại...).
- Nếu `thoiGianHienTai > thoiGianKetThuc` và người dùng bật "Tự động tích việc thiết yếu", hệ thống tự động đổi `daHoanThanh = true` mà không cần người dùng thao tác thủ công.

