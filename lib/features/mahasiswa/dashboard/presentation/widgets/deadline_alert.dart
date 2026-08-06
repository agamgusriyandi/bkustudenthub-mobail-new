import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

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
            context.appColors.primary.withValues(alpha: 0.05),
            context.appColors.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.2),
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
                    color: context.appColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pengingat Jatuh Tempo',
                    style: AppTextStyles.titleSm.copyWith(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  AppSnackbar.showSuccess(context, 'Menampilkan seluruh pengingat tenggat waktu...');
                },
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.primary,
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
                color: context.appColors.primary,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.appColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              _getIcon(item.type),
              color: context.appColors.primary,
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
    );
  }
}
