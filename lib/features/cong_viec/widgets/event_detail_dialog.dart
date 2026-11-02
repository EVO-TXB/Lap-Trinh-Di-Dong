import 'package:flutter/material.dart';
import '../models/cong_viec_model.dart';
import 'event_form_bottom_sheet.dart';

/// Popup Xem / Sửa chi tiết công việc
/// Tự động ủy quyền (delegate) sang EventFormBottomSheet mới chuẩn UX/UI
class EventDetailDialog extends StatelessWidget {
  final CongViecModel congViec;
  final ValueChanged<CongViecModel> onSave;
  final ValueChanged<int> onDelete;
  final Future<void> Function(List<CongViecModel>)? onSaveBatch;
  final Future<void> Function(String)? onDeleteSeries;
  final List<CongViecModel>? danhSachHienCo;

  const EventDetailDialog({
    super.key,
    required this.congViec,
    required this.onSave,
    required this.onDelete,
    this.onSaveBatch,
    this.onDeleteSeries,
    this.danhSachHienCo,
  });

  static Future<void> show(
    BuildContext context, {
    required CongViecModel congViec,
    required ValueChanged<CongViecModel> onSave,
    required ValueChanged<int> onDelete,
    Future<void> Function(List<CongViecModel>)? onSaveBatch,
    Future<void> Function(String)? onDeleteSeries,
    List<CongViecModel>? danhSachHienCo,
  }) {
    return EventFormBottomSheet.show(
      context,
      congViec: congViec.tenCongViec.isEmpty && congViec.id == 0 ? null : congViec,
      ngayMacDinh: congViec.thoiGianBatDau,
      danhSachHienCo: danhSachHienCo,
      onSaveSingle: (single) async => onSave(single),
      onSaveBatch: onSaveBatch,
      onDeleteSingle: (id) async => onDelete(id),
      onDeleteSeries: onDeleteSeries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EventFormBottomSheet(
      congViec: congViec.tenCongViec.isEmpty && congViec.id == 0 ? null : congViec,
      danhSachHienCo: danhSachHienCo,
      onSaveSingle: (single) async => onSave(single),
      onSaveBatch: onSaveBatch,
      onDeleteSingle: (id) async => onDelete(id),
      onDeleteSeries: onDeleteSeries,
    );
  }
}
