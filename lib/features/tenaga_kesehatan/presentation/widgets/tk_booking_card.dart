import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import "package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart";
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class TkBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final bool showActions;

  const TkBookingCard({
    super.key,
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onTap,
    this.showActions = true,
  });

  Color get statusColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return AppColors.info;
    } else if (s.contains('selesai') || s.contains('completed')) {
      return AppColors.success;
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return AppColors.warning;
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return AppColors.danger;
    }
    return AppColors.neutral700;
  }

  Color get statusBgColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return AppColors.info.withAlpha(15);
    } else if (s.contains('selesai') || s.contains('completed')) {
      return AppColors.success.withAlpha(15);
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return AppColors.warning.withAlpha(15);
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return AppColors.danger.withAlpha(15);
    }
    return AppColors.neutral100;
  }

  Color get statusBorderColor {
    final s = booking.status.toLowerCase();
    if (s.contains('dikonfirmasi') || s.contains('terjadwal') || s.contains('confirmed')) {
      return AppColors.info.withAlpha(50);
    } else if (s.contains('selesai') || s.contains('completed')) {
      return AppColors.success.withAlpha(50);
    } else if (s.contains('menunggu') || s.contains('pending')) {
      return AppColors.warning.withAlpha(50);
    } else if (s.contains('ditolak') || s.contains('dibatalkan') || s.contains('rejected')) {
      return AppColors.danger.withAlpha(50);
    }
    return AppColors.neutral300;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.neutral300, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.infoContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      booking.initials,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.nama,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: context.appColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        booking.nim,
                          style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.secondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        booking.prodi,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(color: statusBorderColor),
                  ),
                  child: Text(
                    booking.status.capitalizeFirstLetter(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Details
            Row(
              children: [
                _buildInfoItem(
                  Icons.calendar_today_rounded,
                  booking.jadwalTanggal ?? '-',
                ),
                const SizedBox(width: AppSpacing.lg),
                _buildInfoItem(Icons.access_time_rounded, booking.waktu ?? '-'),
                const SizedBox(width: AppSpacing.lg),
                _buildInfoItem(
                  Icons.medical_services_rounded,
                  booking.tipeLayanan ?? 'Umum',
                ),
              ],
            ),

            // Keluhan
            if (booking.keluhan != null && booking.keluhan!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s10),
              Container(
                width: double.infinity,
                padding: AppSpacing.padding10,
                decoration: BoxDecoration(
                  color: context.appColors.background,
                  borderRadius: AppRadius.br10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        booking.keluhan!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (showActions && booking.isPending) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withAlpha(50)),
                        backgroundColor: AppColors.danger.withAlpha(15),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.br10,
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  SizedBox(
                    height: 44,
                    child: BkuButton.success(
                      onPressed: onAccept,
                      icon: Icons.check_rounded,
                      text: 'Terima',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: AppColors.neutral600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
