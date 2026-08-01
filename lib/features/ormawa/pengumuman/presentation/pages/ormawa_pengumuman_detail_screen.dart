import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrmawaPengumumanDetailScreen extends StatelessWidget {
  final dynamic announcement;

  const OrmawaPengumumanDetailScreen({super.key, required this.announcement});

  LinearGradient _getCategoryGradient(BuildContext context, String target) {
    switch (target.toLowerCase()) {
      case 'umum':
        return const LinearGradient(
            colors: [AppColors.neutral600, AppColors.neutral700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case 'kegiatan':
        return LinearGradient(
            colors: [context.appColors.info, context.appColors.infoContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case 'penting':
        return LinearGradient(
            colors: [context.appColors.error, context.appColors.danger],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      default:
        return LinearGradient(
            colors: [context.appColors.info, context.appColors.infoContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    final gradient = _getCategoryGradient(context, a.target);
    final displayDate = a.tanggalMulai ?? a.createdAt;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: gradient),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 60, AppSpacing.xl, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_rounded,
                                color: context.appColors.onPrimary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: context.appColors.onPrimary,
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              a.target.toUpperCase(),
                              style: AppTextStyles.labelSm.copyWith(
                                color: gradient.colors.first,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        a.judul,
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: context.appColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (displayDate != null)
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 14, color: context.appColors.onPrimary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              DateFormat('dd MMMM yyyy, HH:mm', 'id')
                                  .format(displayDate),
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISI PENGUMUMAN',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(color: AppColors.neutral300),
                        ),
                        child: Text(
                          a.isi,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral700,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
