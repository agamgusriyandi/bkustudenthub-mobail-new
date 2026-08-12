import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

/// Semantic status for consistent visual language across features.
enum BkuStatus {
  approved,
  pending,
  rejected,
  active,
  inactive,
  draft,
  warning,
  error,
  success,
  info,
}

class BkuStatusBadge extends StatelessWidget {
  final BkuStatus status;
  final String? customText;
  final IconData? customIcon;
  final bool showIcon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const BkuStatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.customIcon,
    this.showIcon = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData defaultIcon;

    switch (status) {
      case BkuStatus.approved:
      case BkuStatus.success:
        statusColor = AppColors.success;
        statusText = status == BkuStatus.approved ? 'Disetujui' : 'Berhasil';
        defaultIcon = Icons.verified_rounded;
        break;
      case BkuStatus.pending:
      case BkuStatus.warning:
        statusColor = AppColors.warning;
        statusText = status == BkuStatus.pending ? 'Menunggu' : 'Peringatan';
        defaultIcon = Icons.schedule_rounded;
        break;
      case BkuStatus.rejected:
      case BkuStatus.error:
        statusColor = AppColors.danger;
        statusText = status == BkuStatus.rejected ? 'Ditolak' : 'Gagal';
        defaultIcon = Icons.cancel_rounded;
        break;
      case BkuStatus.active:
        statusColor = AppColors.info;
        statusText = 'Aktif';
        defaultIcon = Icons.check_circle_rounded;
        break;
      case BkuStatus.inactive:
        statusColor = AppColors.neutral500;
        statusText = 'Nonaktif';
        defaultIcon = Icons.remove_circle_rounded;
        break;
      case BkuStatus.draft:
        statusColor = AppColors.neutral600;
        statusText = 'Draft';
        defaultIcon = Icons.edit_document;
        break;
      case BkuStatus.info:
        statusColor = AppColors.info;
        statusText = 'Info';
        defaultIcon = Icons.info_rounded;
        break;
    }

    final displayText = customText ?? statusText;
    final displayIcon = customIcon ?? defaultIcon;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(displayIcon, color: statusColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            displayText,
            style: AppTextStyles.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
