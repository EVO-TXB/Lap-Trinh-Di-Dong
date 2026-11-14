import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Dịch vụ thông báo hệ thống (System & Lock Screen Notification)
/// Đưa thông báo ra màn hình khóa / thanh trạng thái điện thoại kèm chuông báo
/// Hoạt động cả khi tắt màn hình điện thoại hoặc đóng ứng dụng
class ThongBaoHeThong {
  static final ThongBaoHeThong _instance = ThongBaoHeThong._internal();
  factory ThongBaoHeThong() => _instance;
  static ThongBaoHeThong get instance => _instance;

  ThongBaoHeThong._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _daKhoiTao = false;
  bool get daKhoiTao => _daKhoiTao;

  static bool enablePlatform = true;

  /// Kiểm tra có thể gọi channel native hay không (tránh lỗi khi chạy test)
  bool get _coTheChayPlatform {
    if (!enablePlatform) return false;
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    return true;
  }

  // Bộ nhớ theo dõi thông báo đã lên lịch (phục vụ kiểm tra và quản lý)
  final Map<int, Map<String, dynamic>> _danhSachHenGio = {};
  Map<int, Map<String, dynamic>> get danhSachHenGio => Map.unmodifiable(_danhSachHenGio);

  static const String channelId = 'timass_events_channel';
  static const String channelName = 'Nhắc nhở Timass';
  static const String channelDescription =
      'Thông báo nhắc nhở lịch trình công việc và sự kiện Timass';

  /// Khởi tạo plugin thông báo và xin quyền
  Future<void> khoiTao() async {
    if (_daKhoiTao) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Lỗi khởi tạo timezone: $e');
    }

    if (!_coTheChayPlatform) {
      _daKhoiTao = true;
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Đã bấm vào thông báo: ${response.payload}');
        },
      );

      // Thiết lập kênh thông báo Android với độ ưu tiên cao nhất, rung và phát chuông
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        // Xin quyền gửi thông báo trên Android 13+
        await androidImpl.requestNotificationsPermission();
        // Xin quyền báo thức chính xác (Exact Alarm)
        await androidImpl.requestExactAlarmsPermission();

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidImpl.createNotificationChannel(channel);
      }

      _daKhoiTao = true;
      debugPrint('ThongBaoHeThong: Khởi tạo thành công');
    } catch (e) {
      debugPrint('ThongBaoHeThong: Lỗi khi khởi tạo plugin thông báo: $e');
    }
  }

  /// Cấu hình chi tiết thông báo Android (Hiển thị Heads-Up trên màn hình khóa + Âm thanh)
  NotificationDetails _layNotificationDetails({
    required String tieuDe,
    required String noiDung,
  }) {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public, // Hiện rõ ràng ngoài màn hình khóa
      styleInformation: BigTextStyleInformation(
        noiDung,
        contentTitle: tieuDe,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  /// Phát thông báo hệ thống ngay lập tức kèm âm thanh
  Future<void> hienThiThongBaoNgay({
    required int id,
    required String tieuDe,
    required String noiDung,
    String? payload,
  }) async {
    _danhSachHenGio[id] = {
      'id': id,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'daPhat': true,
      'thoiGian': DateTime.now(),
    };

    if (!_coTheChayPlatform) return;

    if (!_daKhoiTao) {
      await khoiTao();
    }

    try {
      await _notificationsPlugin.show(
        id: id,
        title: tieuDe,
        body: noiDung,
        notificationDetails: _layNotificationDetails(tieuDe: tieuDe, noiDung: noiDung),
        payload: payload,
      );
      debugPrint('ThongBaoHeThong: Đã phát thông báo hệ thống id=$id "$tieuDe"');
    } catch (e) {
      debugPrint('ThongBaoHeThong: Lỗi phát thông báo hệ thống: $e');
    }
  }

  /// Hẹn giờ thông báo trước khi sự kiện diễn ra (ngay cả khi điện thoại tắt/khóa màn hình)
  Future<void> henGioThongBao({
    required int id,
    required String tieuDe,
    required String noiDung,
    required DateTime thoiGianThongBao,
    String? payload,
  }) async {
    // Nếu thời gian hẹn đã qua thì không lên lịch nữa
    if (thoiGianThongBao.isBefore(DateTime.now())) {
      return;
    }

    _danhSachHenGio[id] = {
      'id': id,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'thoiGianThongBao': thoiGianThongBao,
      'daPhat': false,
    };

    if (!_coTheChayPlatform) return;

    if (!_daKhoiTao) {
      await khoiTao();
    }

    try {
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.from(thoiGianThongBao, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: tieuDe,
        body: noiDung,
        scheduledDate: scheduledDate,
        notificationDetails: _layNotificationDetails(tieuDe: tieuDe, noiDung: noiDung),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint(
          'ThongBaoHeThong: Đã hẹn giờ thông báo id=$id vào lúc $thoiGianThongBao');
    } catch (e) {
      debugPrint('ThongBaoHeThong: Lỗi hẹn giờ thông báo: $e');
    }
  }

  /// Hủy thông báo theo ID (khi người dùng sửa giờ hoặc xóa công việc)
  Future<void> huyThongBao(int id) async {
    _danhSachHenGio.remove(id);
    if (!_coTheChayPlatform) return;

    try {
      await _notificationsPlugin.cancel(id: id);
      debugPrint('ThongBaoHeThong: Đã hủy thông báo id=$id');
    } catch (e) {
      debugPrint('ThongBaoHeThong: Lỗi hủy thông báo id=$id: $e');
    }
  }

  /// Hủy toàn bộ thông báo hệ thống
  Future<void> huyTatCaThongBao() async {
    _danhSachHenGio.clear();
    if (!_coTheChayPlatform) return;

    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('ThongBaoHeThong: Đã hủy tất cả thông báo hệ thống');
    } catch (e) {
      debugPrint('ThongBaoHeThong: Lỗi hủy tất cả thông báo: $e');
    }
  }
}
