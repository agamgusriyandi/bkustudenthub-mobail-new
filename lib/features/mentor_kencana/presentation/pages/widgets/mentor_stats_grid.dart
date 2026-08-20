import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_main_screen.dart';

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
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            _buildStatCard(
              context,
              title: 'Total Bimbingan',
              value: '${dashboard.totalMentees}',
              unit: 'Mahasiswa',
              icon: Icons.school_rounded,
              color: BkuTheme.primary,
              badgeText: 'Aktif',
              onTap: () {
                final state = context.findAncestorStateOfType<MentorMainScreenState>();
                if (state != null) {
                  state.setSelectedIndex(1);
                } else {
                  context.go('/mentor-kencana?tab=1');
                }
              },
            ),
            _buildStatCard(
              context,
              title: 'Review Handbook',
              value: '${dashboard.pendingHandbooks}',
              unit: 'Berkas',
              icon: Icons.menu_book_rounded,
              color: BkuTheme.amber,
              badgeText: dashboard.pendingHandbooks > 0 ? 'Butuh ACC' : null,
              onTap: () => context.push(AppRoutes.mentorHandbookList),
            ),
            _buildStatCard(
              context,
              title: 'Mahasiswa Lulus',
              value: '${dashboard.passedStudents}',
              unit: 'Mahasiswa',
              icon: Icons.verified_rounded,
              color: BkuTheme.emerald,
              badgeText: 'Lengkap',
              onTap: () {
                final state = context.findAncestorStateOfType<MentorMainScreenState>();
                if (state != null) {
                  state.setSelectedIndex(3);
                } else {
                  context.go('/mentor-kencana?tab=3');
                }
              },
            ),
            _buildStatCard(
              context,
              title: 'Perlu Perbaikan',
              value: '${dashboard.remedialStudents}',
              unit: 'Mahasiswa',
              icon: Icons.error_outline_rounded,
              color: BkuTheme.rose,
              badgeText: 'Evaluasi',
              onTap: () {
                final state = context.findAncestorStateOfType<MentorMainScreenState>();
                if (state != null) {
                  state.setSelectedIndex(3);
                } else {
                  context.go('/mentor-kencana?tab=3');
                }
              },
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
    required String unit,
    required IconData icon,
    required Color color,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BkuTheme.r16,
        child: InkWell(
          onTap: onTap,
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                        style: BkuTheme.textBadge.copyWith(
                          color: BkuTheme.textMuted,
                          fontSize: 9.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BkuTheme.r8,
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: BkuTheme.textMetricValue.copyWith(fontSize: 22),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withAlpha(15),
                      borderRadius: BkuTheme.rPill,
                    ),
                    child: Text(
                      badgeText,
                      style: BkuTheme.textBadge.copyWith(
                        color: color,
                        fontSize: 8.5,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}