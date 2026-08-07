import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

class MentorStatsGrid extends StatelessWidget {
  final MentorDashboardData dashboard;

  const MentorStatsGrid({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final aspectRatio = isTablet ? 1.8 : 1.35;

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          children: [
            _buildStatCard(
              context,
              title: 'TOTAL BIMBINGAN',
              value: '${dashboard.totalMentees} Mahasiswa',
              icon: Icons.school_rounded,
              color: context.appColors.primary,
              badgeText: 'Aktif',
              onTap: () => context.go('/mentor-kencana?tab=1'),
            ),
            _buildStatCard(
              context,
              title: 'REVIEW HANDBOOK',
              value: '${dashboard.pendingHandbooks} Berkas',
              icon: Icons.menu_book_rounded,
              color: context.appColors.warning,
              badgeText: dashboard.pendingHandbooks > 0 ? 'Butuh ACC' : null,
              onTap: () => context.push(AppRoutes.mentorHandbookList),
            ),
            _buildStatCard(
              context,
              title: 'MAHASISWA LULUS',
              value: '${dashboard.passedStudents} Mahasiswa',
              icon: Icons.verified_rounded,
              color: context.appColors.success,
              badgeText: 'Lengkap',
              onTap: () => context.go('/mentor-kencana?tab=3'),
            ),
            _buildStatCard(
              context,
              title: 'PERLU PERBAIKAN',
              value: '${dashboard.remedialStudents} Mahasiswa',
              icon: Icons.error_outline_rounded,
              color: context.appColors.error,
              badgeText: 'Evaluasi',
              onTap: () => context.go('/mentor-kencana?tab=3'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return BkuCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
