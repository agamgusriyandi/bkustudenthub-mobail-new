import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class PsychologistServiceGrid extends StatelessWidget {
  const PsychologistServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 8 : 4;
        final aspectRatio = isTablet ? 1.0 : 0.68;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: aspectRatio,
          children: [
            _ServiceItem(
              title: 'Kelola Jadwal',
              icon: Icons.calendar_month_rounded,
              color: context.appColors.primary,
              onTap: () => context.push(AppRoutes.scheduleManagement),
            ),
            _ServiceItem(
              title: 'Booking Sesi',
              icon: Icons.event_note_rounded,
              color: context.appColors.info,
              onTap: () => context.read<NavigationProvider>().setIndex(1),
            ),
            _ServiceItem(
              title: 'Daftar Pasien',
              icon: Icons.people_rounded,
              color: AppColors.success,
              onTap: () => context.read<NavigationProvider>().setIndex(2),
            ),
            _ServiceItem(
              title: 'Rujukan',
              icon: Icons.send_rounded,
              color: AppColors.neutral700,
              onTap: () => context.push(AppRoutes.referralManagement),
            ),
            _ServiceItem(
              title: 'Analitik',
              icon: Icons.analytics_rounded,
              color: AppColors.warning,
              onTap: () => context.push(AppRoutes.psychologistAnalytics),
            ),
            _ServiceItem(
              title: 'Edit Profil',
              icon: Icons.manage_accounts_rounded,
              color: context.appColors.info,
              onTap: () => context.push(AppRoutes.psychologistEditProfile),
            ),
            _ServiceItem(
              title: 'Catatan Sesi',
              icon: Icons.edit_document,
              color: context.appColors.info,
              onTap: () => context.push(AppRoutes.psychologistBookings),
            ),
            _ServiceItem(
              title: 'Asesmen',
              icon: Icons.assignment_rounded,
              color: context.appColors.primary,
              onTap: () => context.push(AppRoutes.assessmentManagement),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
