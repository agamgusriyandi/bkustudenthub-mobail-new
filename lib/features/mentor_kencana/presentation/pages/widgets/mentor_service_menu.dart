import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_main_screen.dart';

class MentorServiceMenu extends StatelessWidget {
  const MentorServiceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Handbook',
        'icon': Icons.menu_book_rounded,
        'color': BkuTheme.violet,
        'onTap': () => context.push(AppRoutes.mentorHandbookList),
      },
      {
        'title': 'Materi & Tugas',
        'icon': Icons.auto_stories_rounded,
        'color': BkuTheme.cyan,
        'onTap': () => context.push(AppRoutes.mentorMaterials),
      },
      {
        'title': 'Skoring',
        'icon': Icons.star_rounded,
        'color': BkuTheme.indigo,
        'onTap': () {
          final state = context.findAncestorStateOfType<MentorMainScreenState>();
          if (state != null) {
            state.setSelectedIndex(3);
          } else {
            context.go('/mentor-kencana?tab=3');
          }
        },
      },
      {
        'title': 'Nilai Essay',
        'icon': Icons.rate_review_rounded,
        'color': BkuTheme.cyan,
        'onTap': () => context.push(AppRoutes.mentorEssayGrading),
      },
      {
        'title': 'Izin Presensi',
        'icon': Icons.edit_note_rounded,
        'color': BkuTheme.rose,
        'onTap': () => context.push(AppRoutes.mentorAbsenceRequests),
      },
      {
        'title': 'Kelompok Saya',
        'icon': Icons.diversity_3_rounded,
        'color': BkuTheme.primary,
        'onTap': () => context.push(AppRoutes.mentorGroups),
      },
      {
        'title': 'Catatan Bimbingan',
        'icon': Icons.speaker_notes_rounded,
        'color': BkuTheme.amber,
        'onTap': () => context.push(AppRoutes.mentorNotes),
      },
      {
        'title': 'Input Presensi',
        'icon': Icons.how_to_reg_rounded,
        'color': BkuTheme.emerald,
        'onTap': () {
          final state = context.findAncestorStateOfType<MentorMainScreenState>();
          if (state != null) {
            state.setSelectedIndex(2);
          } else {
            context.go('/mentor-kencana?tab=2');
          }
        },
      },
      {
        'title': 'Pengaturan',
        'icon': Icons.settings_rounded,
        'color': BkuTheme.slate,
        'onTap': () {
          final state = context.findAncestorStateOfType<MentorMainScreenState>();
          if (state != null) {
            state.setSelectedIndex(4);
          } else {
            context.go('/mentor-kencana?tab=4');
          }
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
        final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
        final aspectRatio = itemWidth / 96;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          childAspectRatio: aspectRatio,
          children: actions.map((action) {
            return _ServiceIcon(
              label: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceIcon({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BkuBounceButton(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BkuTheme.r16,
              border: Border.all(color: color.withAlpha(40)),
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
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: BkuTheme.textBadge.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: BkuTheme.textPrimary,
                height: 1.1,
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