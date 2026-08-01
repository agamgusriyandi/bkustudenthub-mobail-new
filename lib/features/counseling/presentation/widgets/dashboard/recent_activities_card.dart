import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class RecentActivitiesCard extends StatelessWidget {
  const RecentActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistDashboardProvider>(
      builder: (context, provider, _) {
        final activities = provider.recentActivities;
        final isLoading = provider.isLoading;

        if (isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (activities.isEmpty) {
          return _buildEmpty();
        }

        return Column(
          children:
              activities.map((act) {
                String title = act['title']?.toString() ?? 'Aktivitas';
                if (title == 'Booking Confirmed') title = 'Sesi Dikonfirmasi';
                if (title == 'Booking Cancelled') title = 'Sesi Dibatalkan';
                if (title == 'Booking Rescheduled') {
                  title = 'Sesi Dijadwalkan Ulang';
                }

                return _ActivityItem(
                  title: title,
                  description: act['description']?.toString() ?? '-',
                  time: act['time']?.toString() ?? '-',
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return BkuCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 40, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada aktivitas terbaru',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSuccess =
        title.toLowerCase().contains('dikonfirmasi') ||
        title.toLowerCase().contains('confirmed');
    final Color iconColor = isSuccess ? AppColors.success : AppColors.info;
    final IconData icon =
        isSuccess
            ? Icons.check_circle_outline_rounded
            : Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral500.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      time,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
