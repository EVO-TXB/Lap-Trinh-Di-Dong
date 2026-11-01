import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cong_viec_model.dart';

/// Popup Xem / Sửa chi tiết công việc
class EventDetailDialog extends StatefulWidget {
  final CongViecModel congViec;
  final ValueChanged<CongViecModel> onSave;
  final ValueChanged<int> onDelete;

  const EventDetailDialog({
    super.key,
    required this.congViec,
    required this.onSave,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required CongViecModel congViec,
    required ValueChanged<CongViecModel> onSave,
    required ValueChanged<int> onDelete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EventDetailDialog(
        congViec: congViec,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends State<EventDetailDialog> {
  late TextEditingController _tenController;
  late TextEditingController _diaDiemController;
  late TextEditingController _ghiChuController;
  late DateTime _thoiGianBatDau;
  late DateTime _thoiGianKetThuc;
  late bool _laThietYeu;
  late bool _daHoanThanh;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(text: widget.congViec.tenCongViec);
    _diaDiemController = TextEditingController(text: widget.congViec.diaDiem ?? '');
    _ghiChuController = TextEditingController(text: widget.congViec.ghiChu ?? '');
    _thoiGianBatDau = widget.congViec.thoiGianBatDau;
    _thoiGianKetThuc = widget.congViec.thoiGianKetThuc;
    _laThietYeu = widget.congViec.laThietYeu;
    _daHoanThanh = widget.congViec.daHoanThanh;
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaDiemController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _chonGio(bool isBatDau) async {
    final DateTime initial = isBatDau ? _thoiGianBatDau : _thoiGianKetThuc;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      setState(() {
        if (isBatDau) {
          _thoiGianBatDau = DateTime(
            _thoiGianBatDau.year,
            _thoiGianBatDau.month,
            _thoiGianBatDau.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _thoiGianKetThuc = DateTime(
            _thoiGianKetThuc.year,
            _thoiGianKetThuc.month,
            _thoiGianKetThuc.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề Dialog
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event_note, color: AppColors.sageGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Chi tiết công việc',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Trường: Tên công việc
              const Text('Tên công việc', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _tenController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên công việc...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 14),

              // Trường: Khung giờ & Ngày
              Text(
                'Ngày: ${dateFormat.format(_thoiGianBatDau)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _chonGio(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Từ: ${timeFormat.format(_thoiGianBatDau)}'),
                            const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _chonGio(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đến: ${timeFormat.format(_thoiGianKetThuc)}'),
                            const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Trường: Địa điểm
              const Text('Địa điểm / Phòng học', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _diaDiemController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: A3-402, Google Meet...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),

              // Công tắc: Việc thiết yếu (Ăn/Ngủ/Sinh hoạt)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Việc thiết yếu / Bị động (Ăn, ngủ)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                value: _laThietYeu,
                activeThumbColor: AppColors.passiveOrangeLegend,
                onChanged: (val) => setState(() => _laThietYeu = val),
              ),

              // Công tắc: Trạng thái hoàn thành
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Đã hoàn thành', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                value: _daHoanThanh,
                activeThumbColor: AppColors.completedGreenLegend,
                onChanged: (val) => setState(() => _daHoanThanh = val),
              ),
              const SizedBox(height: 16),

              // Nút Thao tác: Xóa & Lưu
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Xóa việc này',
                    onPressed: () {
                      widget.onDelete(widget.congViec.id);
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final CongViecModel updated = widget.congViec.copyWith(
                        tenCongViec: _tenController.text.trim().isEmpty ? 'Công việc' : _tenController.text.trim(),
                        diaDiem: _diaDiemController.text.trim().isEmpty ? null : _diaDiemController.text.trim(),
                        thoiGianBatDau: _thoiGianBatDau,
                        thoiGianKetThuc: _thoiGianKetThuc,
                        laThietYeu: _laThietYeu,
                        daHoanThanh: _daHoanThanh,
                        ghiChu: _ghiChuController.text.trim(),
                      );
                      widget.onSave(updated);
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu thay đổi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
