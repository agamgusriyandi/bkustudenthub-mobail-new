import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

// Screens
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/organisasi_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/profile/presentation/pages/profile_screen.dart';

class StudentServiceGrid extends StatelessWidget {
  const StudentServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 8 : 4;
        final aspectRatio = isTablet ? 1.0 : 0.70;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: aspectRatio,
          children: [
            _ServiceIcon(
              label: 'Beasiswa',
              icon: Icons.school_rounded,
              color: AppColors.success,
              target: const ScholarshipScreen(),
            ),
            _ServiceIcon(
              label: 'Prestasi',
              icon: Icons.emoji_events_rounded,
              color: AppColors.info,
              target: const AchievementScreen(),
            ),
            _ServiceIcon(
              label: 'Kencana',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.warning,
              target: const KencanaScreen(),
            ),
            _ServiceIcon(
              label: 'Konseling',
              icon: Icons.psychology_rounded,
              color: Colors.purple,
              target: const CounselingScreen(),
            ),
            _ServiceIcon(
              label: 'Aspirasi',
              icon: Icons.campaign_rounded,
              color: AppColors.error,
              target: const StudentVoiceScreen(),
            ),
            _ServiceIcon(
              label: 'Kesehatan',
              icon: Icons.monitor_heart_rounded,
              color: Colors.teal,
              target: const HealthScreen(),
            ),
            _ServiceIcon(
              label: 'Organisasi',
              icon: Icons.groups_rounded,
              color: Colors.cyan,
              target: const OrganisasiScreen(),
            ),
            _ServiceIcon(
              label: 'Profil',
              icon: Icons.person_rounded,
              color: Colors.blueGrey,
              target: const ProfileScreen(),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget? target;

  const _ServiceIcon({
    required this.label,
    required this.icon,
    required this.color,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target!),
          );
        }
      },
      child: BkuCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        width: double.infinity,
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
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
