import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';

class MentorAnnouncements extends StatelessWidget {
  final MentorKencanaProvider provider;

  const MentorAnnouncements({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.announcements.isEmpty) {
      return BkuCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            'Tidak ada pengumuman terbaru.',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: provider.announcements.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final ann = provider.announcements[index];
        return BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ann.title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!ann.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.error.withAlpha(15),
                        border: Border.all(
                          color: context.appColors.error.withAlpha(30),
                        ),
                        borderRadius: AppRadius.radiusXs,
                      ),
                      child: Text(
                        'BARU',
                        style: AppTextStyles.labelSm.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _cleanHtml(ann.content),
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _formatDate(ann.date),
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  color: context.appColors.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      String dayName = days[dt.weekday - 1];
      String monthName = months[dt.month - 1];
      String dayNum = dt.day.toString().padLeft(2, '0');
      return '$dayName, $dayNum $monthName ${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    var document = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    document = document
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    return document.trim();
  }
}
