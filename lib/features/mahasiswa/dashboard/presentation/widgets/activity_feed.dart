import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

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

  Color _getIconBg(String? type) {
    switch (type) {
      case 'achievement':
        return const Color(0xFFF3E8FF);
      case 'beasiswa':
        return const Color(0xFFDCFCE7);
      case 'konseling':
        return const Color(0xFFFEE2E2);
      case 'kencana':
        return const Color(0xFFDBEAFE);
      case 'voice':
        return const Color(0xFFE0F2FE);
      case 'organisasi':
        return const Color(0xFFFCE7F3);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'achievement':
        return const Color(0xFF7C3AED);
      case 'beasiswa':
        return const Color(0xFF16A34A);
      case 'konseling':
        return const Color(0xFFDC2626);
      case 'kencana':
        return const Color(0xFF2563EB);
      case 'voice':
        return const Color(0xFF0284C7);
      case 'organisasi':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
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
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: context.appColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  color: _getIconBg(item.type),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getIconColor(item.type).withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  _getIcon(item.type),
                  color: _getIconColor(item.type),
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
