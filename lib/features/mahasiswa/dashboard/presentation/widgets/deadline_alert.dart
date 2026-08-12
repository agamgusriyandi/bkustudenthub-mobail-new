import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:go_router/go_router.dart';

class DeadlineItem {
  final String name;
  final int daysLeft;
  final String? type;
  final String? link;

  DeadlineItem({
    required this.name,
    required this.daysLeft,
    this.type,
    this.link,
  });
}

class DeadlineAlert extends StatelessWidget {
  final List<DeadlineItem> deadlines;

  const DeadlineAlert({super.key, this.deadlines = const []});

  IconData _getIcon(String? type) {
    switch (type) {
      case 'beasiswa':
        return Icons.menu_book_rounded;
      case 'konseling':
        return Icons.support_agent_rounded;
      case 'kampus':
        return Icons.calendar_today_rounded;
      case 'kencana':
        return Icons.info_outline_rounded;
      case 'organisasi':
        return Icons.groups_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getUrgencyColor(BuildContext context, int daysLeft) {
    if (daysLeft < 3) return context.appColors.error;
    if (daysLeft < 7) return context.appColors.primary;
    return context.appColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    if (deadlines.isEmpty) return const SizedBox.shrink();

    final visibleDeadlines = deadlines.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.03),
            AppColors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pengingat Jatuh Tempo',
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScholarshipScreen(),
                    ),
                  );
                },
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visibleDeadlines.map((item) => _buildDeadlineItem(context, item)),
          if (deadlines.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '+${deadlines.length - 3} pengingat lainnya',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(BuildContext context, DeadlineItem item) {
    final urgencyColor = _getUrgencyColor(context, item.daysLeft);

    return GestureDetector(
      onTap: () {
        if (item.link != null && item.link!.isNotEmpty) {
          context.push(item.link!);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScholarshipScreen(),
            ),
          );
        }
      },
      child: BkuCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        borderOnly: true,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                _getIcon(item.type),
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: urgencyColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '${item.daysLeft} Hari Lagi',
                      style: AppTextStyles.caption.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
