import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';

// Screens
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_invitations_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/organisasi_screen.dart';

class StudentServiceGrid extends StatelessWidget {
  const StudentServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Menghitung jumlah kolom optimal (min 4, max 8) berdasarkan lebar yang tersedia
        final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
        
        // Menghitung lebar tiap item
        final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
        
        // Tinggi fix yang dibutuhkan: Container(56) + SizedBox(8) + Text(max ~32) = ~96
        final aspectRatio = itemWidth / 96;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          childAspectRatio: aspectRatio,
          children: [
            _ServiceIcon(
              label: 'Kencana',
              icon: Icons.school_rounded,
              color: AppColors.serviceIndigo,
              target: const KencanaScreen(),
            ),
            _ServiceIcon(
              label: 'Prestasi',
              icon: Icons.emoji_events_rounded,
              color: AppColors.serviceAmber,
              target: const AchievementScreen(),
            ),
            _ServiceIcon(
              label: 'Beasiswa',
              icon: Icons.workspace_premium_rounded,
              color: AppColors.serviceEmerald,
              target: const ScholarshipScreen(),
            ),
            _ServiceIcon(
              label: 'Organisasi',
              icon: Icons.groups_rounded,
              color: AppColors.servicePurple,
              target: const OrganisasiScreen(),
            ),
            _ServiceIcon(
              label: 'Konseling',
              icon: Icons.support_agent_rounded,
              color: AppColors.serviceCyan,
              target: const CounselingScreen(),
            ),
            _ServiceIcon(
              label: 'Kesehatan',
              icon: Icons.monitor_heart_rounded,
              color: AppColors.serviceRose,
              target: const HealthScreen(),
            ),
            _ServiceIcon(
              label: 'Aspirasi',
              icon: Icons.chat_rounded, // Match web icon
              color: AppColors.serviceSky,
              target: const StudentVoiceScreen(),
            ),
            _ServiceIcon(
              label: 'Undangan\nMentor',
              icon: Icons.group_add_rounded,
              color: AppColors.servicePink,
              target: const KencanaInvitationsScreen(),
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
    return BkuBounceButton(
      scaleFactor: 0.90,
      onTap: () {
        if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target!),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(50),
                  color.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withAlpha(60),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(30),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha(35),
                    color.withAlpha(15),
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white.withAlpha(50),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
