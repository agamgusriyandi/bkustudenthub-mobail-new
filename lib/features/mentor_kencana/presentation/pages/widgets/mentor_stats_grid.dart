import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_kpi_card.dart';
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
        final aspectRatio = isTablet ? 1.4 : 1.18;

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            BkuKpiCard(
              title: 'Total Bimbingan',
              value: '${dashboard.totalMentees}',
              subtitle: 'Mahasiswa bimbingan',
              icon: Icons.school_rounded,
              badgeColor: BkuTheme.primary,
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
            BkuKpiCard(
              title: 'Review Handbook',
              value: '${dashboard.pendingHandbooks}',
              subtitle: 'Berkas evaluasi',
              icon: Icons.menu_book_rounded,
              badgeColor: BkuTheme.amber,
              badgeText: dashboard.pendingHandbooks > 0 ? 'Butuh ACC' : 'Tuntas',
              onTap: () => context.push(AppRoutes.mentorHandbookList),
            ),
            BkuKpiCard(
              title: 'Mahasiswa Lulus',
              value: '${dashboard.passedStudents}',
              subtitle: 'Tuntas orientasi',
              icon: Icons.verified_rounded,
              badgeColor: BkuTheme.emerald,
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
            BkuKpiCard(
              title: 'Perlu Perbaikan',
              value: '${dashboard.remedialStudents}',
              subtitle: 'Tugas remedial',
              icon: Icons.error_outline_rounded,
              badgeColor: BkuTheme.rose,
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
}