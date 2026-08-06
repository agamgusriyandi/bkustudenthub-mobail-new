import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';

class ActivityItem {
  final String description;
  final DateTime createdAt;
  final String? type;
  final String? link;

  ActivityItem({
    required this.description,
    required this.createdAt,
    this.type,
    this.link,
  });
}

class ActivityFeed extends StatelessWidget {
  final List<ActivityItem> activities;

  const ActivityFeed({super.key, this.activities = const []});

  IconData _getIcon(String? type) {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'beasiswa':
        return Icons.menu_book_rounded;
      case 'konseling':
        return Icons.support_agent_rounded;
      case 'kencana':
        return Icons.school_rounded;
      case 'voice':
        return Icons.chat_rounded;
      case 'organisasi':
        return Icons.groups_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconBg(BuildContext context, String? type) {
    switch (type) {
      case 'achievement':
        return AppColors.servicePurple.withValues(alpha: 0.15);
      case 'beasiswa':
        return AppColors.serviceEmerald.withValues(alpha: 0.15);
      case 'konseling':
        return AppColors.serviceRose.withValues(alpha: 0.15);
      case 'kencana':
        return AppColors.serviceIndigo.withValues(alpha: 0.15);
      case 'voice':
        return AppColors.serviceSky.withValues(alpha: 0.15);
      case 'organisasi':
        return AppColors.servicePink.withValues(alpha: 0.15);
      default:
        return AppColors.neutral300.withValues(alpha: 0.3);
    }
  }

  Color _getIconColor(BuildContext context, String? type) {
    switch (type) {
      case 'achievement':
        return AppColors.servicePurple;
      case 'beasiswa':
        return AppColors.serviceEmerald;
      case 'konseling':
        return AppColors.serviceRose;
      case 'kencana':
        return AppColors.serviceIndigo;
      case 'voice':
        return AppColors.serviceSky;
      case 'organisasi':
        return AppColors.servicePink;
      default:
        return AppColors.neutral600;
    }
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.isNegative) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes == 0 ? 1 : diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inHours < 48) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada aktivitas',
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.appColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(activities.length, (index) {
              final item = activities[index];
              return _buildActivityItem(context, item, index == activities.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconBg(context, item.type),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getIconColor(context, item.type).withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  _getIcon(item.type),
                  color: _getIconColor(context, item.type),
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: context.appColors.outline.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: isLast
                  ? null
                  : BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.appColors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRelativeTime(item.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: context.appColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
