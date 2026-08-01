import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

class AnnouncementItem {
  final String id;
  final String title;
  final String? summary;
  final DateTime? date;
  final String? category;
  final String? imageUrl;
  final String? link;

  AnnouncementItem({
    required this.id,
    required this.title,
    this.summary,
    this.date,
    this.category,
    this.imageUrl,
    this.link,
  });
}

class AnnouncementSection extends StatelessWidget {
  final List<AnnouncementItem> announcements;
  final VoidCallback? onViewAll;

  const AnnouncementSection({
    super.key,
    this.announcements = const [],
    this.onViewAll,
  });

  Color _getCategoryColor(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'umum':
        return const Color(0xFF0EA5E9);
      case 'akademik':
        return const Color(0xFF7C3AED);
      case 'kemahasiswaan':
        return const Color(0xFF16A34A);
      case 'urgent':
        return const Color(0xFFDC2626);
      case 'event':
        return const Color(0xFFF59E0B);
      case 'beasiswa':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getCategoryBgColor(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'umum':
        return const Color(0xFFE0F2FE);
      case 'akademik':
        return const Color(0xFFF3E8FF);
      case 'kemahasiswaan':
        return const Color(0xFFDCFCE7);
      case 'urgent':
        return const Color(0xFFFEE2E2);
      case 'event':
        return const Color(0xFFFEF3C7);
      case 'beasiswa':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.outline.withOpacity(0.1)),
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
                    Icons.feed_rounded,
                    color: context.appColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Berita',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: context.appColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (announcements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: context.appColors.onSurfaceVariant.withOpacity(0.4),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada berita terbaru',
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.appColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...announcements.map((item) => _buildAnnouncementCard(context, item)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementItem item) {
    final catColor = _getCategoryColor(item.category);
    final catBgColor = _getCategoryBgColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.appColors.surface,
                border: Border.all(color: context.appColors.outline.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: context.appColors.surface,
                      child: Icon(
                        Icons.image_rounded,
                        color: context.appColors.onSurfaceVariant.withOpacity(0.3),
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catBgColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: catColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        item.category ?? 'Umum',
                        style: AppTextStyles.caption.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (item.date != null) ...[
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: context.appColors.onSurfaceVariant.withOpacity(0.5),
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(item.date),
                            style: AppTextStyles.caption.copyWith(
                              color: context.appColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.summary != null && item.summary!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.summary!,
                    style: AppTextStyles.caption.copyWith(
                      color: context.appColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
