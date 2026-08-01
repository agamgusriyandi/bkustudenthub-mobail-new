import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class _GamificationTheme {
  final List<Color> gradientColors;
  final Color titleColor;
  final Color textColor;
  final Color valueColor;
  final Color iconColor;
  final Color iconBgColor;
  final Color progressBgColor;
  final Color progressColor;
  final Color borderColor;

  _GamificationTheme({
    required this.gradientColors,
    required this.titleColor,
    required this.textColor,
    required this.valueColor,
    required this.iconColor,
    required this.iconBgColor,
    required this.progressBgColor,
    required this.progressColor,
    required this.borderColor,
  });
}

class OrmawaGamificationCard extends StatelessWidget {
  const OrmawaGamificationCard({super.key});

  _GamificationTheme _getTheme(BuildContext context, int rank) {
    if (rank == 1) {
      // Gold
      return _GamificationTheme(
        gradientColors: [AppColors.secondaryFixed, AppColors.secondary],
        titleColor: context.appColors.secondary,
        textColor: context.appColors.secondary,
        valueColor: AppColors.onWarningContainer,
        iconColor: context.appColors.secondary,
        iconBgColor: context.appColors.surface.withAlpha(150),
        progressBgColor: context.appColors.surface.withAlpha(100),
        progressColor: context.appColors.secondary,
        borderColor: Colors.transparent,
      );
    } else if (rank == 2) {
      // Silver
      return _GamificationTheme(
        gradientColors: [AppColors.neutral200, AppColors.neutral500],
        titleColor: AppColors.neutral900,
        textColor: AppColors.neutral700,
        valueColor: AppColors.neutral900,
        iconColor: AppColors.neutral900,
        iconBgColor: context.appColors.surface.withAlpha(150),
        progressBgColor: context.appColors.surface.withAlpha(100),
        progressColor: AppColors.neutral900,
        borderColor: Colors.transparent,
      );
    } else if (rank == 3) {
      // Bronze
      return _GamificationTheme(
        gradientColors: [AppColors.neutral300, AppColors.neutral700],
        titleColor: context.appColors.surface,
        textColor: context.appColors.surface.withAlpha(178),
        valueColor: context.appColors.surface,
        iconColor: context.appColors.surface,
        iconBgColor: context.appColors.surface.withAlpha(50),
        progressBgColor: context.appColors.onSurface.withAlpha(50),
        progressColor: context.appColors.surface,
        borderColor: Colors.transparent,
      );
    } else {
      // Default (Polos Putih)
      return _GamificationTheme(
        gradientColors: [context.appColors.surface, context.appColors.surface],
        titleColor: context.appColors.onSurface,
        textColor: AppColors.neutral600,
        valueColor: context.appColors.onSurface,
        iconColor: AppColors.warning,
        iconBgColor: AppColors.warning.withAlpha(30),
        progressBgColor: AppColors.neutral200,
        progressColor: AppColors.info,
        borderColor: AppColors.neutral300,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();

    if (ormawa.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: const BkuShimmer(
          width: double.infinity,
          height: 180,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
        ),
      );
    }

    final poin = ormawa.gamifikasiPoin;
    final peringkat = ormawa.gamifikasiPeringkat;
    final total = ormawa.totalOrmawa;

    final progress =
        total > 0 ? ((total - peringkat + 1) / total).clamp(0.0, 1.0) : 0.0;
    final theme = _getTheme(context, peringkat);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: theme.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.iconBgColor,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: theme.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gamifikasi Ormawa',
                        style: AppTextStyles.labelMd.copyWith(
                          color: theme.titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tingkatkan terus keaktifan organisasi!',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.textColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peringkat',
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '#$peringkat',
                            style: AppTextStyles.titleLg.copyWith(
                              color: theme.valueColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'dari $total',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.textColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akumulasi Poin',
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$poin',
                            style: AppTextStyles.titleLg.copyWith(
                              color: theme.valueColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Pts',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.textColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.progressBgColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bawah',
                  style: AppTextStyles.labelSm.copyWith(
                    color: theme.textColor,
                    fontSize: 9,
                  ),
                ),
                Text(
                  'Top 1',
                  style: AppTextStyles.labelSm.copyWith(
                    color: theme.titleColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
