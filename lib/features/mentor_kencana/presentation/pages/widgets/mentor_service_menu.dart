import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

class MentorServiceMenu extends StatelessWidget {
  const MentorServiceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Handbook',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => context.push(AppRoutes.mentorHandbookList),
      },
      {
        'title': 'Materi\n& Tugas',
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF14B8A6),
        'onTap': () => context.push(AppRoutes.mentorMaterials),
      },
      {
        'title': 'Skoring',
        'icon': Icons.star_rounded,
        'color': const Color(0xFF6366F1),
        'onTap': () => context.go('/mentor-kencana?tab=3'),
      },
      {
        'title': 'Nilai\nEssay',
        'icon': Icons.rate_review_rounded,
        'color': const Color(0xFF06B6D4),
        'onTap': () => context.push(AppRoutes.mentorEssayGrading),
      },
      {
        'title': 'Izin\nPresensi',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFFF43F5E),
        'onTap': () => context.push(AppRoutes.mentorAbsenceRequests),
      },
      {
        'title': 'Kelompok\nSaya',
        'icon': Icons.diversity_3_rounded,
        'color': AppColors.primary,
        'onTap': () => context.push(AppRoutes.mentorGroups),
      },
      {
        'title': 'Catatan\nBimbingan',
        'icon': Icons.speaker_notes_rounded,
        'color': const Color(0xFFF59E0B),
        'onTap': () => context.push(AppRoutes.mentorNotes),
      },
      {
        'title': 'Input\nKehadiran',
        'icon': Icons.how_to_reg_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () => context.go('/mentor-kencana?tab=2'),
      },
      {
        'title': 'Pengaturan',
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF64748B),
        'onTap': () => context.go('/mentor-kencana?tab=4'),
      },
    ];

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
