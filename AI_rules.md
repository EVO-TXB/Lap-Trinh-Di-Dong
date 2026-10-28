# SYSTEM RULES & CODING STANDARDS: TIMASS PROJECT

## 1. TỔNG QUAN HỆ THỐNG & CÔNG NGHỆ
- Tên dự án: Timass (Time Management & Scheduling System).
- Kiến trúc: Client - Server độc lập (RESTful API).
- Backend: Java 17+, Spring Boot 3.x, Spring Data JPA, Spring Security, MySQL 8.x.
- Mobile: Flutter 3.x (Null-safety), State Management: `Provider`.
- Lưu trữ ngoại tuyến (Offline cache): `shared_preferences` (Lưu chuỗi JSON lịch tuần).
- Thông báo: `flutter_local_notifications` (Lên lịch báo trước 15 phút).
- Đa ngôn ngữ: Hỗ trợ tiếng Việt và tiếng Anh.

## 2. QUY ƯỚC ĐẶT TÊN BẮT BUỘC (NAMING CONVENTIONS)
AI phải tuân thủ chính xác 100% các quy ước ngôn ngữ dưới đây, tuyệt đối không pha trộn:

### 2.1. Biến, Thuộc tính & Tham số (Variables, Fields, Parameters)
- Sử dụng TIẾNG VIỆT KHÔNG DẤU theo chuẩn `camelCase`.
- Áp dụng trên cả Backend (Java) và Mobile (Dart):
  - Hợp lệ: `soDienThoai`, `matKhau`, `tenCongViec`, `thoiGianBatDau`, `thoiGianKetThuc`, `daHoanThanh`, `laThietYeu`, `maNguoiDung`.
  - Nghiêm cấm: `phone`, `password`, `taskName`, `startTime`, `so_dien_thoai`, `tênCôngViệc`.

### 2.2. Cơ sở dữ liệu MySQL (Tables & Columns)
- Sử dụng TIẾNG VIỆT KHÔNG DẤU theo chuẩn `snake_case`, danh từ số ít hoặc số nhiều có tiền tố rõ ràng.
- Tên bảng: `nguoi_dung`, `cong_viec`, `cong_viec_con`, `quy_tac_lap`.
- Tên cột: `id`, `so_dien_thoai`, `mat_khau`, `ten_cong_viec`, `thoi_gian_bat_dau`, `thoi_gian_ket_thuc`, `da_hoan_thanh`, `la_thiet_yeu`, `ngay_tao`.

### 2.3. Endpoint API (RESTful URLs)
- Sử dụng TIẾNG VIỆT KHÔNG DẤU theo chuẩn `kebab-case`.
- Tiền tố API: `/api/v1`
- Danh sách định tuyến chuẩn:
  - Xác thực: `POST /api/v1/xac-thuc/dang-ky`, `POST /api/v1/xac-thuc/dang-nhap`
  - Lịch trình & Công việc:
    - `GET /api/v1/cong-viec/tuan?ngayBatDau=YYYY-MM-DD`
    - `POST /api/v1/cong-viec` (Thêm công việc đơn hoặc lặp lại)
    - `PUT /api/v1/cong-viec/{id}` (Cập nhật)
    - `DELETE /api/v1/cong-viec/{id}` (Xóa công việc)
    - `DELETE /api/v1/cong-viec/hang-loat` (Xóa các công việc lặp lại)
  - Công việc con (Sub-tasks):
    - `POST /api/v1/cong-viec/{idCongViec}/cong-viec-con`
    - `PATCH /api/v1/cong-viec-con/{id}/trang-thai`

### 2.4. Class, Interface & Methods
- Tên Class/Interface: Chuẩn `PascalCase`, kết hợp danh từ nghiệp vụ tiếng Việt không dấu và hậu tố vai trò kỹ thuật:
  - Backend: `NguoiDung`, `CongViec`, `XacThucController`, `CongViecService`, `CongViecRepository`, `JwtBoLocXacThuc`.
  - Flutter: `CongViecModel`, `NguoiDungModel`, `CongViecProvider`, `XacThucProvider`, `LichTuanScreen`.
- Tên hàm (Methods): Chuẩn `camelCase`, bắt đầu bằng động từ tiếng Anh mô tả hành vi, sau đó là tân ngữ tiếng Việt không dấu:
  - Ví dụ: `getDanhSachCongViecTheoTuan()`, `createCongViec()`, `updateTrangThaiHoanThanh()`, `kiemTraTrungLich()`.

## 3. QUY CHUẨN BACKEND SPRING BOOT
- Mô hình phân lớp: `Controller` -> `Service` -> `Repository` -> `Entity`.
- Định dạng dữ liệu phản hồi (Response Wrapper) chuẩn duy nhất:
  ```java
  public class ApiResponse<T> {
      private int maTrangThai; // 200, 400, 401, 403, 500
      private String thongBao;
      private T duLieu;
  }
  Xác thực & Phân quyền:Đăng ký & Đăng nhập bằng soDienThoai và matKhau. 
     Mật khẩu mã hóa bằng BCryptPasswordEncoder[cite: 1].
     Cấp mã JWT Token hết hạn chính xác sau 24 giờ[cite: 1].
     JwtAuthenticationFilter phân tích Header Authorization: Bearer <token> để xác thực người dùng cho mọi request (ngoại trừ /api/v1/xac-thuc/**)[cite: 1].Xử lý Ngoại lệ: Dùng @RestControllerAdvice bắt các lỗi MethodArgumentNotValidException, BadCredentialsException, và Custom Exception, chuyển đổi thành ApiResponse lỗi đồng nhất.
4. QUY CHUẨN MOBILE FLUTTER
    - State Management: BẮT BUỘC dùng Provider[cite: 1].
    - Mọi màn hình cần truy xuất logic phải dùng ChangeNotifierProvider, tương tác dữ liệu qua Consumer hoặc context.read<T>()/context.watch<T>().
    - Tuyệt đối không dùng GetX, Riverpod, Bloc hoặc lạm dụng setState trong logic nghiệp vụ.
    - Cấu trúc thư mục:
      lib/
        core/
        ├── mang/ (Dio/Http Client, Interceptors gắn JWT)
        ├── bo_nho/ (SharedPreferences Service)
        ├── thong_bao/ (Notification Service)
        └── constants/ (AppColors, AppStyles)
      features/
        ├── xac_thuc/ (screens, widgets, providers, models)
        └── cong_viec/ (screens, widgets, providers, models)
      └── main.dart

    - Cơ chế Ngoại tuyến (Offline-first Cache):
        - Khi tải thành công lịch tuần từ API: Tuần tự hóa (Serialize) danh sách sang JSON String và lưu vào SharedPreferences với key 'lich_trinh_tuan_cache'[cite: 1].
        - Khi mở ứng dụng hoặc mất mạng: Đọc dữ liệu từ 'lich_trinh_tuan_cache' hiển thị lên màn hình trước, đồng thời hiển thị thông báo trạng thái ngoại tuyến[cite: 1].
        - Logic việc thiết yếu tự động tích hoàn thành:
            - Nếu laThietYeu == true (ăn, ngủ) và thoiGianHienTai > thoiGianKetThuc, giao diện tự động render trạng thái đã hoàn thành (daHoanThanh = true)[cite: 1].

5. RÀNG BUỘC ĐẦU RA KHI XUẤT MÃ NGUỒN CỦA AI
    - Xuất code hoàn chỉnh, không viết tắt, không để // Code cũ giữ nguyên, không để comment // TODO.
    - Khai báo đầy đủ các import, annotation, cấu hình dependency injection.
    - Kiểm tra tính tương thích giữa kiểu dữ liệu LocalDateTime (Spring Boot) và chuỗi ISO-8601 UTC trên Flutter.