import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
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
        final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
        final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
        final aspectRatio = itemWidth / 86;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          childAspectRatio: aspectRatio,
          children: const [
            _ServiceIcon(
              label: 'Kencana',
              icon: Icons.school_rounded,
              color: BkuTheme.indigo,
              target: KencanaScreen(),
            ),
            _ServiceIcon(
              label: 'Prestasi',
              icon: Icons.emoji_events_rounded,
              color: BkuTheme.amber,
              target: AchievementScreen(),
            ),
            _ServiceIcon(
              label: 'Beasiswa',
              icon: Icons.workspace_premium_rounded,
              color: BkuTheme.emerald,
              target: ScholarshipScreen(),
            ),
            _ServiceIcon(
              label: 'Organisasi',
              icon: Icons.groups_rounded,
              color: BkuTheme.purple,
              target: OrganisasiScreen(),
            ),
            _ServiceIcon(
              label: 'Konseling',
              icon: Icons.support_agent_rounded,
              color: BkuTheme.teal,
              target: CounselingScreen(),
            ),
            _ServiceIcon(
              label: 'Kesehatan',
              icon: Icons.monitor_heart_rounded,
              color: BkuTheme.rose,
              target: HealthScreen(),
            ),
            _ServiceIcon(
              label: 'Aspirasi',
              icon: Icons.chat_rounded,
              color: BkuTheme.sky,
              target: StudentVoiceScreen(),
            ),
            _ServiceIcon(
              label: 'Undangan',
              icon: Icons.group_add_rounded,
              color: BkuTheme.rose,
              target: KencanaInvitationsScreen(),
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
      scaleFactor: 0.92,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (target != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target!),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.16),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: BkuTheme.textCardSubtitle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: BkuTheme.textHeading,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
