import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import "package:bkuhub_mobile/core/providers/navigation_provider.dart";
import "package:provider/provider.dart";
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class QuickStatsCard extends StatelessWidget {
  final int totalAppointments;
  final String finishedToday;
  final String waiting;
  final String newAppointments;
  final String finishedMonth;

  const QuickStatsCard({
    super.key,
    required this.totalAppointments,
    required this.finishedToday,
    required this.waiting,
    required this.newAppointments,
    required this.finishedMonth,
  });

  String _todayLabel() {
    try {
      final now = DateTime.now();
      const dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final day = dayNames[now.weekday - 1];
      final month = monthNames[now.month - 1];
      return '$day, ${now.day} $month ${now.year}'.toUpperCase();
    } catch (_) {
      return DateTime.now().toString().substring(0, 10).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Navigate to Booking tab (index 1) and sub-tab Dikonfirmasi (index 2)
              context.read<NavigationProvider>().navigateToBookingsWithTab(2);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _todayLabel(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        'Janji Temu Disetujui',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        totalAppointments.toString(),
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.primary,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        'sesi konseling yang telah disetujui',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem(
                Icons.task_alt_rounded,
                finishedToday,
                'Selesai\nHari Ini',
                AppColors.success,
                onTap: () {
                  // Navigate to Booking tab (index 1) and sub-tab Selesai (index 3)
                  context.read<NavigationProvider>().navigateToBookingsWithTab(
                    3,
                  );
                },
              ),
              _buildSummaryItem(
                Icons.pending_actions_rounded,
                waiting,
                'Menunggu',
                context.appColors.warning,
                onTap: () {
                  // Navigate to Booking tab (index 1) and sub-tab Menunggu (index 1)
                  context.read<NavigationProvider>().navigateToBookingsWithTab(
                    1,
                  );
                },
              ),
              _buildSummaryItem(
                Icons.notification_important_rounded,
                newAppointments,
                'Baru\nHari Ini',
                const Color(0xFFF43F5E),
                onTap: () {
                  // Navigate to Booking tab (index 1) and sub-tab Menunggu (index 1)
                  context.read<NavigationProvider>().navigateToBookingsWithTab(
                    1,
                  );
                },
              ),
              _buildSummaryItem(
                Icons.calendar_month_rounded,
                finishedMonth,
                'Selesai\nBulan Ini',
                const Color(0xFF60A5FA),
                onTap: () {
                  // Navigate to Booking tab (index 1) and sub-tab Selesai (index 3)
                  context.read<NavigationProvider>().navigateToBookingsWithTab(
                    3,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: AppRadius.radiusLg,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.titleMd.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
