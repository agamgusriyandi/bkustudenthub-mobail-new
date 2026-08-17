import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

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
  final bool showDot;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? customColor;

  const BkuStatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.customIcon,
    this.showIcon = false,
    this.showDot = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    this.borderRadius = 6.0,
    this.customColor,
  });

  factory BkuStatusBadge.dot({
    Key? key,
    required BkuStatus status,
    String? customText,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) => BkuStatusBadge(
    key: key,
    status: status,
    customText: customText,
    showIcon: false,
    showDot: true,
    padding: padding,
  );

  factory BkuStatusBadge.icon({
    Key? key,
    required BkuStatus status,
    String? customText,
    IconData? customIcon,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => BkuStatusBadge(
    key: key,
    status: status,
    customText: customText,
    customIcon: customIcon,
    showIcon: true,
    showDot: false,
    padding: padding,
  );

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData defaultIcon;

    switch (status) {
      case BkuStatus.approved:
      case BkuStatus.success:
        statusColor = customColor ?? AppColors.success;
        statusText = status == BkuStatus.approved ? 'Disetujui' : 'Berhasil';
        defaultIcon = Icons.verified_rounded;
        break;
      case BkuStatus.pending:
      case BkuStatus.warning:
        statusColor = customColor ?? AppColors.warning;
        statusText = status == BkuStatus.pending ? 'Menunggu' : 'Peringatan';
        defaultIcon = Icons.schedule_rounded;
        break;
      case BkuStatus.rejected:
      case BkuStatus.error:
        statusColor = customColor ?? AppColors.danger;
        statusText = status == BkuStatus.rejected ? 'Ditolak' : 'Gagal';
        defaultIcon = Icons.cancel_rounded;
        break;
      case BkuStatus.active:
        statusColor = customColor ?? AppColors.info;
        statusText = 'Aktif';
        defaultIcon = Icons.check_circle_rounded;
        break;
      case BkuStatus.inactive:
        statusColor = customColor ?? AppColors.neutral500;
        statusText = 'Nonaktif';
        defaultIcon = Icons.remove_circle_rounded;
        break;
      case BkuStatus.draft:
        statusColor = customColor ?? AppColors.neutral600;
        statusText = 'Draft';
        defaultIcon = Icons.edit_document;
        break;
      case BkuStatus.info:
        statusColor = customColor ?? AppColors.info;
        statusText = 'Info';
        defaultIcon = Icons.info_rounded;
        break;
    }

    final displayText = customText ?? statusText;
    final displayIcon = customIcon ?? defaultIcon;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ] else if (showIcon) ...[
            Icon(displayIcon, color: statusColor, size: 12),
            const SizedBox(width: 5),
          ],
          Text(
            displayText,
            style: AppTextStyles.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
