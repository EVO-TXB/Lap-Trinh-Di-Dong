import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget tiến độ ngày (Progress Card): "Hôm nay: 5/8 việc đã xong (62%)",
/// thanh tròn Radial Progress và chú thích màu (Chủ động, Bị động, Đã hoàn thành)
class ProgressCardWidget extends StatelessWidget {
  final int tongSoViec;
  final int soViecDaXong;
  final double tiLe;
  final int phanTram;
  final VoidCallback? onTap;

  const ProgressCardWidget({
    super.key,
    required this.tongSoViec,
    required this.soViecDaXong,
    required this.tiLe,
    required this.phanTram,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.sageGreen.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.03),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Nhóm văn bản số lượng việc
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hôm nay: $soViecDaXong/$tongSoViec việc',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'đã xong ($phanTram%)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (onTap != null) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: AppColors.sageGreen,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Thanh tròn Radial Progress
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: tiLe.clamp(0.0, 1.0),
                          strokeWidth: 6.5,
                          backgroundColor: AppColors.progressTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.progressCircle,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // 3. Cột chú thích màu sắc
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(
                        color: AppColors.activeBlueLegend,
                        label: 'Công việc chủ động',
                      ),
                      const SizedBox(height: 4),
                      _buildLegendItem(
                        color: AppColors.passiveOrangeLegend,
                        label: 'Thiết yếu / Bị động',
                      ),
                      const SizedBox(height: 4),
                      _buildLegendItem(
                        color: AppColors.completedGreenLegend,
                        label: 'Đã hoàn thành',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
