import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cai_dat/controllers/settings_controller.dart';
import '../controllers/event_form_controller.dart';
import '../models/cong_viec_model.dart';
import '../repositories/mock_event_repository.dart';
import 'conflict_warning_dialog.dart';
import 'recurring_choice_dialog.dart';

/// Modal Bottom Sheet Thêm / Chỉnh Sửa / Xóa Sự Kiện
/// Chuẩn 100% theo `ui sample/thêm&sửa công việc đơn.png` và `ui sample/thêm&sửa công việc lặp.png`
class EventFormBottomSheet extends StatefulWidget {
  final CongViecModel? congViec;
  final DateTime? ngayMacDinh;
  final List<CongViecModel>? danhSachHienCo;
  final Future<void> Function(CongViecModel singleEvent)? onSaveSingle;
  final Future<void> Function(List<CongViecModel> batchEvents)? onSaveBatch;
  final Future<void> Function(int id)? onDeleteSingle;
  final Future<void> Function(String maChuoiLap)? onDeleteSeries;
  final Future<void> Function(String maChuoiLap, CongViecModel mauCapNhat, List<CongViecModel>? danhSachMoi)? onUpdateSeries;

  const EventFormBottomSheet({
    super.key,
    this.congViec,
    this.ngayMacDinh,
    this.danhSachHienCo,
    this.onSaveSingle,
    this.onSaveBatch,
    this.onDeleteSingle,
    this.onDeleteSeries,
    this.onUpdateSeries,
  });

  /// Hiển thị Modal Bottom Sheet dạng bo tròn trên nền mờ
  static Future<T?> show<T>(
    BuildContext context, {
    CongViecModel? congViec,
    DateTime? ngayMacDinh,
    List<CongViecModel>? danhSachHienCo,
    Future<void> Function(CongViecModel singleEvent)? onSaveSingle,
    Future<void> Function(List<CongViecModel> batchEvents)? onSaveBatch,
    Future<void> Function(int id)? onDeleteSingle,
    Future<void> Function(String maChuoiLap)? onDeleteSeries,
    Future<void> Function(String maChuoiLap, CongViecModel mauCapNhat, List<CongViecModel>? danhSachMoi)? onUpdateSeries,
  }) {
    final list = danhSachHienCo ?? MockEventRepository().tatCaCongViecHienCo;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => ChangeNotifierProvider<EventFormController>(
        create: (_) => EventFormController(
          congViecGoc: congViec,
          ngayMacDinh: ngayMacDinh,
          danhSachHienCo: list,
        ),
        child: EventFormBottomSheet(
          congViec: congViec,
          ngayMacDinh: ngayMacDinh,
          danhSachHienCo: list,
          onSaveSingle: onSaveSingle,
          onSaveBatch: onSaveBatch,
          onDeleteSingle: onDeleteSingle,
          onDeleteSeries: onDeleteSeries,
          onUpdateSeries: onUpdateSeries,
        ),
      ),
    );
  }

  @override
  State<EventFormBottomSheet> createState() => _EventFormBottomSheetState();
}

class _EventFormBottomSheetState extends State<EventFormBottomSheet> {
  late TextEditingController _tenController;
  late TextEditingController _diaDiemController;
  List<CongViecModel> _danhSachSuKien = [];

  @override
  void initState() {
    super.initState();
    final controller = context.read<EventFormController>();
    _tenController = TextEditingController(text: controller.tenCongViec);
    _diaDiemController = TextEditingController(text: controller.diaDiem);
    _napDanhSachSuKien();
  }

  Future<void> _napDanhSachSuKien() async {
    if (widget.danhSachHienCo != null) {
      _danhSachSuKien = widget.danhSachHienCo!;
    } else {
      final all = await MockEventRepository().getAllCongViec();
      if (mounted) {
        setState(() {
          _danhSachSuKien = all;
        });
      }
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaDiemController.dispose();
    super.dispose();
  }

  // --- Date / Time Picker Handlers ---

  Future<void> _chonNgayThucHien(
    BuildContext context,
    EventFormController controller, {
    SettingsController? settings,
  }) async {
    final bool isDark = settings?.isDarkMode ?? false;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.ngayThucHien,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: settings?.tr('select_date_title') ?? 'CHỌN NGÀY THỰC HIỆN',
      cancelText: settings?.tr('picker_cancel') ?? 'HỦY',
      confirmText: settings?.tr('picker_select') ?? 'CHỌN',
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E293B)),
                )
              : Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    onSurface: AppColors.darkNavy,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.thayDoiNgayThucHien(picked);
    }
  }

  Future<void> _chonGio(
    BuildContext context,
    EventFormController controller, {
    required bool isBatDau,
    SettingsController? settings,
  }) async {
    final bool isDark = settings?.isDarkMode ?? false;
    final TimeOfDay initial = isBatDau ? controller.gioBatDau : controller.gioKetThuc;
    final String defaultHelp = isBatDau ? 'CHỌN GIỜ BẮT ĐẦU' : 'CHỌN GIỜ KẾT THÚC';
    final String helpKey = isBatDau ? 'select_start_time_title' : 'select_end_time_title';

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: settings?.tr(helpKey) ?? defaultHelp,
      cancelText: settings?.tr('picker_cancel') ?? 'HỦY',
      confirmText: settings?.tr('picker_select') ?? 'CHỌN',
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E293B)),
                )
              : Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    onSurface: AppColors.darkNavy,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isBatDau) {
        controller.thayDoiGioBatDau(picked);
      } else {
        controller.thayDoiGioKetThuc(picked);
      }
    }
  }

  Future<void> _chonKhoangNgayLap(
    BuildContext context,
    EventFormController controller, {
    required bool isTuNgay,
    SettingsController? settings,
  }) async {
    final bool isDark = settings?.isDarkMode ?? false;
    final DateTime initial = isTuNgay ? controller.ngayBatDauLap : controller.ngayKetThucLap;
    final String defaultHelp = isTuNgay ? 'CHỌN NGÀY BẮT ĐẦU LẶP' : 'CHỌN NGÀY KẾT THÚC LẶP';
    final String helpKey = isTuNgay ? 'select_repeat_start_date' : 'select_repeat_end_date';

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: settings?.tr(helpKey) ?? defaultHelp,
      cancelText: settings?.tr('picker_cancel') ?? 'HỦY',
      confirmText: settings?.tr('picker_select') ?? 'CHỌN',
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E293B)),
                )
              : Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.sageGreen,
                    onPrimary: Colors.white,
                    onSurface: AppColors.darkNavy,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isTuNgay) {
        controller.thayDoiKhoangNgayLap(tuNgay: picked);
      } else {
        controller.thayDoiKhoangNgayLap(denNgay: picked);
      }
    }
  }

  // --- Submit & Conflict Checking Logic ---

  Future<void> _xuLyLuu(EventFormController controller) async {
    SettingsController? settings;
    try {
      settings = context.read<SettingsController>();
    } catch (_) {
      settings = null;
    }

    // 1. Validate form fields
    final String? loiValidate = controller.validateForm(
      tr: settings != null ? (k) => settings!.tr(k) : null,
    );
    if (loiValidate != null) {
      _hienThiThongBaoLoi(loiValidate);
      return;
    }

    // 2. Thuật toán kiểm tra trùng lịch (Conflict Check)
    final ketQuaTrung = controller.kiemTraTrungLich(_danhSachSuKien);
    if (ketQuaTrung.coTrungLich) {
      // Hiển thị Popup cảnh báo trùng lịch: cho phép người dùng sửa lại hoặc vẫn tiếp tục lưu
      final bool? vanLuu = await ConflictWarningDialog.show(
        context,
        congViecBiTrung: ketQuaTrung.congViecBiTrung,
        choPhepVanLuu: true,
      );
      if (vanLuu != true) {
        return;
      }
    }

    if (!mounted) return;
    controller.setSubmitting(true);

    try {
      // 3. Xử lý trường hợp Sửa sự kiện lặp lại (Chỉ sửa 1 việc hay toàn bộ chuỗi)
      if (controller.isEditing && controller.congViecGoc!.coLapLai) {
        final RecurringScope? luaChon = await RecurringChoiceDialog.show(
          context,
          actionType: RecurringActionType.sua,
        );

        if (luaChon == null) {
          controller.setSubmitting(false);
          return; // Người dùng hủy chọn
        }

        if (luaChon == RecurringScope.single) {
          // Chỉ sửa sự kiện này: Tách chuỗi lặp (maChuoiLap = null)
          final CongViecModel singleEvent = controller.taoCongViecDonLe().copyWith(
            maChuoiLap: null,
            maQuyTacLap: null,
          );
          if (widget.onSaveSingle != null) {
            await widget.onSaveSingle!(singleEvent);
          } else {
            await MockEventRepository().updateCongViec(singleEvent);
          }
        } else {
          // Áp dụng cho toàn bộ chuỗi sự kiện lặp
          final CongViecModel mau = controller.taoCongViecDonLe();
          final String maChuoi = controller.congViecGoc!.maChuoiLap ??
              controller.congViecGoc!.maQuyTacLap?.toString() ??
              '';

          final bool daThayDoiQuyTacLap = controller.daThayDoiQuyTacLap;
          final List<CongViecModel>? danhSachMoi = daThayDoiQuyTacLap
              ? (controller.coLapLai
                  ? controller.sinhDanhSachCongViecLap()
                  : [mau.copyWith(maChuoiLap: null, maQuyTacLap: null)])
              : null;

          if (widget.onUpdateSeries != null) {
            await widget.onUpdateSeries!(maChuoi, mau, danhSachMoi);
          } else {
            if (daThayDoiQuyTacLap && danhSachMoi != null) {
              await MockEventRepository().deleteChuoiCongViec(maChuoi);
              await MockEventRepository().createDanhSachCongViec(danhSachMoi);
            } else {
              await MockEventRepository().updateChuoiCongViec(maChuoi, mau);
            }
          }
        }
      } else if (controller.coLapLai) {
        // 4. Tạo mới chuỗi sự kiện lặp lại
        final List<CongViecModel> danhSachLap = controller.sinhDanhSachCongViecLap();
        if (widget.onSaveBatch != null) {
          await widget.onSaveBatch!(danhSachLap);
        } else {
          await MockEventRepository().createDanhSachCongViec(danhSachLap);
          if (widget.onSaveSingle != null && danhSachLap.isNotEmpty) {
            await widget.onSaveSingle!(danhSachLap.first);
          }
        }

        // Nếu chuyển từ sự kiện đơn lẻ sang lặp lại, xóa sự kiện đơn lẻ gốc
        if (controller.isEditing && controller.congViecGoc != null && !controller.congViecGoc!.coLapLai) {
          if (widget.onDeleteSingle != null) {
            await widget.onDeleteSingle!(controller.congViecGoc!.id);
          } else {
            await MockEventRepository().deleteCongViec(controller.congViecGoc!.id);
          }
        }
      } else {
        // 5. Tạo mới hoặc Cập nhật sự kiện đơn lẻ
        final CongViecModel item = controller.taoCongViecDonLe();
        if (widget.onSaveSingle != null) {
          await widget.onSaveSingle!(item);
        } else {
          if (controller.isEditing) {
            await MockEventRepository().updateCongViec(item);
          } else {
            await MockEventRepository().createCongViec(item);
          }
        }
      }

      if (mounted) {
        final nav = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        nav.pop(true);
        final String thongBao = controller.isEditing
            ? (settings?.tr('update_success') ?? 'Đã cập nhật công việc thành công!')
            : (settings?.tr('save_success') ?? 'Đã lưu công việc thành công!');
        messenger.showSnackBar(
          SnackBar(
            content: Text(thongBao),
            backgroundColor: AppColors.sageGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _hienThiThongBaoLoi(
          settings?.tr('save_error', params: {'error': e.toString()}) ?? 'Lỗi khi lưu: $e',
        );
      }
    } finally {
      if (mounted) {
        controller.setSubmitting(false);
      }
    }
  }

  // --- Delete Handler ---

  Future<void> _xuLyXoa(EventFormController controller) async {
    if (!controller.isEditing || controller.congViecGoc == null) return;

    SettingsController? settings;
    try {
      settings = context.read<SettingsController>();
    } catch (_) {
      settings = null;
    }

    final CongViecModel cv = controller.congViecGoc!;

    if (cv.coLapLai && cv.maChuoiLap != null) {
      final RecurringScope? luaChon = await RecurringChoiceDialog.show(
        context,
        actionType: RecurringActionType.xoa,
      );

      if (luaChon == null) return;

      if (luaChon == RecurringScope.single) {
        if (widget.onDeleteSingle != null) {
          await widget.onDeleteSingle!(cv.id);
        } else {
          await MockEventRepository().deleteCongViec(cv.id);
        }
      } else {
        if (widget.onDeleteSeries != null) {
          await widget.onDeleteSeries!(cv.maChuoiLap!);
        } else {
          await MockEventRepository().deleteChuoiCongViec(cv.maChuoiLap!);
        }
      }
    } else {
      // Xóa đơn lẻ thông thường
      final bool? xacNhan = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            settings?.tr('delete_confirm_title') ?? 'Xác nhận xóa',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            settings?.tr('delete_confirm_msg', params: {'name': cv.tenCongViec}) ??
                'Bạn có chắc chắn muốn xóa "${cv.tenCongViec}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                settings?.tr('cancel_btn') ?? 'Hủy',
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(settings?.tr('delete_btn') ?? 'Xóa'),
            ),
          ],
        ),
      );

      if (xacNhan != true) return;

      if (widget.onDeleteSingle != null) {
        await widget.onDeleteSingle!(cv.id);
      } else {
        await MockEventRepository().deleteCongViec(cv.id);
      }
    }

    if (mounted) {
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      nav.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(settings?.tr('delete_success') ?? 'Đã xóa công việc thành công!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _hienThiThongBaoLoi(String loi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(loi)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    SettingsController? settings;
    try {
      settings = context.watch<SettingsController>();
    } catch (_) {
      settings = null;
    }
    final bool isDark = settings?.isDarkMode ?? false;
    final bool isEnglish = settings?.ngonNgu == 'English';

    final controller = context.watch<EventFormController>();
    final mediaQuery = MediaQuery.of(context);

    final Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : AppColors.darkNavy;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo drag handle nhỏ trên cùng
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // 1. Header: Tiêu đề + Icon đóng X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.isEditing
                        ? (settings?.tr('edit_task_title') ?? 'Chỉnh sửa công việc')
                        : (settings?.tr('add_new_task') ?? 'Thêm công việc mới'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 24, color: textColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Input: Tiêu đề công việc
              Text(
                settings?.tr('task_title') ?? 'Tiêu đề công việc',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tenController,
                onChanged: controller.thayDoiTenCongViec,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontSize: 15, color: textColor),
                decoration: InputDecoration(
                  hintText: settings?.tr('task_title_hint') ?? 'Nhập tên công việc hoặc môn học...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageGreen, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Bộ chọn Loại công việc (2 Tab to)
              Text(
                settings?.tr('task_type') ?? 'Loại công việc',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Tab 1: Chủ động
                  Expanded(
                    child: _buildLoaiCongViecTab(
                      label: settings?.tr('active_task') ?? 'Chủ động',
                      isSelected: controller.laViecChuDong,
                      isChuDong: true,
                      isDark: isDark,
                      onTap: () => controller.thayDoiLoaiSuKien('CHU_DONG'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tab 2: Thiết yếu / Bị động
                  Expanded(
                    child: _buildLoaiCongViecTab(
                      label: settings?.tr('essential_passive') ?? 'Thiết yếu /\nBị động',
                      isSelected: controller.laThietYeu,
                      isChuDong: false,
                      isDark: isDark,
                      onTap: () => controller.thayDoiLoaiSuKien('BI_DONG'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Khu vực chọn Ngày & Thời gian (Thay đổi động theo Switch Lặp lại)
              if (!controller.coLapLai) ...[
                // TRƯỜNG HỢP CÔNG VIỆC ĐƠN LẺ (`thêm&sửa công việc đơn.png`)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột trái: Ngày thực hiện
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings?.tr('task_date') ?? 'Ngày thực hiện',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDateBox(
                            context: context,
                            date: controller.ngayThucHien,
                            isEnglish: isEnglish,
                            isDark: isDark,
                            onTap: () => _chonNgayThucHien(context, controller, settings: settings),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cột phải: Thời gian (Bắt đầu - Kết thúc)
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings?.tr('task_time') ?? 'Thời gian',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimeSingleBox(
                            context: context,
                            controller: controller,
                            isDark: isDark,
                            settings: settings,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // TRƯỜNG HỢP CÔNG VIỆC LẶP LẠI (`thêm&sửa công việc lặp.png`)
                // A. Thời gian: Bắt đầu & Kết thúc
                Text(
                  settings?.tr('task_time') ?? 'Thời gian',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTimeRecurringBox(
                  context: context,
                  controller: controller,
                  isDark: isDark,
                  settings: settings,
                ),
              ],
              const SizedBox(height: 18),

              // 5. Ô nhập: Địa điểm / Phòng học
              Text(
                settings?.tr('location') ?? 'Địa điểm / Phòng học',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _diaDiemController,
                onChanged: controller.thayDoiDiaDiem,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 15, color: textColor),
                decoration: InputDecoration(
                  hintText: settings?.tr('location_hint') ?? 'Nhập địa điểm, phòng học (Ví dụ: A3... )',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14.5),
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF64748B), size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageGreen, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 6. Switch Toggle: Lặp lại hàng tuần
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings?.tr('weekly_repeat') ?? 'Lặp lại hàng tuần',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: controller.coLapLai,
                      onChanged: controller.toggleLapLai,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.sageGreen,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD1D5DB),
                    ),
                  ),
                ],
              ),

              // Khi bật Switch Lặp lại: Hiển thị thanh chọn thứ & khoảng ngày lặp
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Thanh chọn các thứ [ T2 | T3 | T4 | T5 | T6 | T7 | CN ]
                    _buildDayOfWeekSelector(controller, isEnglish: isEnglish, isDark: isDark),
                    const SizedBox(height: 18),

                    // Hai ô ngày: "Thời gian lặp lại" & "Đến ngày"
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings?.tr('repeat_time_range') ?? 'Thời gian lặp lại',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildSimpleDateBox(
                                context: context,
                                date: controller.ngayBatDauLap,
                                isDark: isDark,
                                onTap: () => _chonKhoangNgayLap(context, controller, isTuNgay: true, settings: settings),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings?.tr('until_date') ?? 'Đến ngày',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildSimpleDateBox(
                                context: context,
                                date: controller.ngayKetThucLap,
                                isDark: isDark,
                                onTap: () => _chonKhoangNgayLap(context, controller, isTuNgay: false, settings: settings),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: controller.coLapLai
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),

              const SizedBox(height: 28),

              // 7. Footer: "Hủy bỏ" & "Lưu công việc" (và nút Xóa nếu đang sửa)
              Row(
                children: [
                  // Nút Hủy bỏ
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      settings?.tr('cancel_btn') ?? 'Hủy bỏ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),

                  // Nút Xóa (chỉ hiển thị khi đang sửa sự kiện đã có)
                  if (controller.isEditing) ...[
                    IconButton(
                      onPressed: () => _xuLyXoa(controller),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      tooltip: settings?.tr('delete_btn') ?? 'Xóa công việc',
                    ),
                  ],

                  const Spacer(),

                  // Nút Lưu công việc
                  ElevatedButton(
                    onPressed: controller.isSubmitting
                        ? null
                        : () => _xuLyLuu(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : Text(
                            settings?.tr('save_btn') ?? 'Lưu công việc',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-widgets bám sát UI ---

  /// Widget Tab loại công việc (Chủ động / Thiết yếu)
  Widget _buildLoaiCongViecTab({
    required String label,
    required bool isSelected,
    required bool isChuDong,
    bool isDark = false,
    required VoidCallback onTap,
  }) {
    final Color bgColor = isChuDong
        ? (isSelected
            ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.45) : const Color(0xFFD2E3FC))
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)))
        : (isSelected
            ? (isDark ? const Color(0xFF9A3412).withValues(alpha: 0.45) : const Color(0xFFFFE2CC))
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)));

    final Color borderColor = isChuDong
        ? (isSelected ? const Color(0xFF93C5FD) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)))
        : (isSelected ? const Color(0xFFFDBA74) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)));

    final Color textColor = isChuDong
        ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A))
        : (isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412));

    final Color unselectedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isChuDong) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
              ),
            ] else ...[
              Icon(
                Icons.circle_rounded,
                size: 16,
                color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF94A3B8),
              ),
            ],
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? textColor : unselectedTextColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hộp chọn Ngày thực hiện (Đơn lẻ: Thứ, Ngày/Tháng/Năm + Icon lịch)
  Widget _buildDateBox({
    required BuildContext context,
    required DateTime date,
    bool isEnglish = false,
    bool isDark = false,
    required VoidCallback onTap,
  }) {
    final String thuStr = _dinhDangThu(date.weekday, isEnglish: isEnglish);
    final String ngayStr = DateFormat('dd/MM/yyyy').format(date);
    final Color numberColor = isDark ? Colors.white : AppColors.darkNavy;
    final Color boxBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB);
    final Color iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: boxBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$thuStr,',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: numberColor,
                    ),
                  ),
                  Text(
                    ngayStr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: numberColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }

  /// Hộp chọn Thời gian đơn lẻ: [ 08:00 (clock) | 10:00 (clock) ]
  Widget _buildTimeSingleBox({
    required BuildContext context,
    required EventFormController controller,
    bool isDark = false,
    SettingsController? settings,
  }) {
    final String startStr =
        '${controller.gioBatDau.hour.toString().padLeft(2, '0')}:${controller.gioBatDau.minute.toString().padLeft(2, '0')}';
    final String endStr =
        '${controller.gioKetThuc.hour.toString().padLeft(2, '0')}:${controller.gioKetThuc.minute.toString().padLeft(2, '0')}';
    final Color numberColor = isDark ? Colors.white : AppColors.darkNavy;
    final Color boxBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB);
    final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final Color iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: boxBorder),
      ),
      child: Row(
        children: [
          // Giờ bắt đầu
          Expanded(
            child: InkWell(
              onTap: () => _chonGio(context, controller, isBatDau: true, settings: settings),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startStr,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: numberColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.access_time_rounded, size: 17, color: iconColor),
                  ],
                ),
              ),
            ),
          ),
          // Đường chia dọc
          Container(width: 1, height: 36, color: dividerColor),
          // Giờ kết thúc
          Expanded(
            child: InkWell(
              onTap: () => _chonGio(context, controller, isBatDau: false, settings: settings),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      endStr,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: numberColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.access_time_rounded, size: 17, color: iconColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hộp chọn Thời gian lặp lại: Bắt đầu & Kết thúc dạng 2 ô lớn (`thêm&sửa công việc lặp.png`)
  Widget _buildTimeRecurringBox({
    required BuildContext context,
    required EventFormController controller,
    bool isDark = false,
    SettingsController? settings,
  }) {
    final String startStr =
        '${controller.gioBatDau.hour.toString().padLeft(2, '0')}:${controller.gioBatDau.minute.toString().padLeft(2, '0')}';
    final String endStr =
        '${controller.gioKetThuc.hour.toString().padLeft(2, '0')}:${controller.gioKetThuc.minute.toString().padLeft(2, '0')}';
    final Color numberColor = isDark ? Colors.white : AppColors.darkNavy;
    final Color boxBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB);
    final Color labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final Color iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      children: [
        // Bắt đầu
        Expanded(
          child: InkWell(
            onTap: () => _chonGio(context, controller, isBatDau: true, settings: settings),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: boxBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings?.tr('start_time') ?? 'Bắt đầu',
                    style: TextStyle(fontSize: 13, color: labelColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: numberColor,
                        ),
                      ),
                      Icon(Icons.access_time_rounded, size: 18, color: iconColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Kết thúc
        Expanded(
          child: InkWell(
            onTap: () => _chonGio(context, controller, isBatDau: false, settings: settings),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: boxBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings?.tr('end_time') ?? 'Kết thúc',
                    style: TextStyle(fontSize: 13, color: labelColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: numberColor,
                        ),
                      ),
                      Icon(Icons.access_time_rounded, size: 18, color: iconColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Thanh chọn các thứ [ T2 | T3 | T4 | T5 | T6 | T7 | CN ]
  Widget _buildDayOfWeekSelector(EventFormController controller, {bool isEnglish = false, bool isDark = false}) {
    final List<Map<String, dynamic>> cacThu = [
      {'ma': 2, 'ten': isEnglish ? 'Mon' : 'T2'},
      {'ma': 3, 'ten': isEnglish ? 'Tue' : 'T3'},
      {'ma': 4, 'ten': isEnglish ? 'Wed' : 'T4'},
      {'ma': 5, 'ten': isEnglish ? 'Thu' : 'T5'},
      {'ma': 6, 'ten': isEnglish ? 'Fri' : 'T6'},
      {'ma': 7, 'ten': isEnglish ? 'Sat' : 'T7'},
      {'ma': 8, 'ten': isEnglish ? 'Sun' : 'CN'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cacThu.map((thu) {
        final int ma = thu['ma'] as int;
        final String ten = thu['ten'] as String;
        final bool isSelected = controller.cacThuDaChon.contains(ma);

        return InkWell(
          onTap: () => controller.toggleThu(ma),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.sageGreen
                  : (isDark ? const Color(0xFF0F172A) : Colors.white),
              border: Border.all(
                color: isSelected
                    ? AppColors.sageGreen
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                ten,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Hộp chọn ngày đơn giản (dd/MM/yyyy + icon Lịch)
  Widget _buildSimpleDateBox({
    required BuildContext context,
    required DateTime date,
    bool isDark = false,
    required VoidCallback onTap,
  }) {
    final String str = DateFormat('dd/MM/yyyy').format(date);
    final Color numberColor = isDark ? Colors.white : AppColors.darkNavy;
    final Color boxBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB);
    final Color iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: boxBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              str,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: numberColor,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: iconColor),
          ],
        ),
      ),
    );
  }

  String _dinhDangThu(int weekday, {bool isEnglish = false}) {
    if (isEnglish) {
      switch (weekday) {
        case DateTime.monday: return 'Monday';
        case DateTime.tuesday: return 'Tuesday';
        case DateTime.wednesday: return 'Wednesday';
        case DateTime.thursday: return 'Thursday';
        case DateTime.friday: return 'Friday';
        case DateTime.saturday: return 'Saturday';
        case DateTime.sunday: return 'Sunday';
        default: return '';
      }
    }
    switch (weekday) {
      case DateTime.monday: return 'Thứ Hai';
      case DateTime.tuesday: return 'Thứ Ba';
      case DateTime.wednesday: return 'Thứ Tư';
      case DateTime.thursday: return 'Thứ Năm';
      case DateTime.friday: return 'Thứ Sáu';
      case DateTime.saturday: return 'Thứ Bảy';
      case DateTime.sunday: return 'Chủ Nhật';
      default: return '';
    }
  }
}
