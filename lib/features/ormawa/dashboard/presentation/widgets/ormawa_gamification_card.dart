import 'package:bkuhub_mobile/core/theme/app_colors.dart';
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

  _GamificationTheme _getTheme(int rank) {
    if (rank == 1) {
      // Gold
      return _GamificationTheme(
        gradientColors: [const Color(0xFFFFD54F), const Color(0xFFFF8F00)],
        titleColor: const Color(0xFFE65100),
        textColor: const Color(0xFFE65100),
        valueColor: const Color(0xFFBF360C),
        iconColor: const Color(0xFFE65100),
        iconBgColor: Colors.white.withAlpha(150),
        progressBgColor: Colors.white.withAlpha(100),
        progressColor: const Color(0xFFE65100),
        borderColor: Colors.transparent,
      );
    } else if (rank == 2) {
      // Silver
      return _GamificationTheme(
        gradientColors: [const Color(0xFFE0E0E0), const Color(0xFF9E9E9E)],
        titleColor: const Color(0xFF212121),
        textColor: const Color(0xFF424242),
        valueColor: const Color(0xFF212121),
        iconColor: const Color(0xFF212121),
        iconBgColor: Colors.white.withAlpha(150),
        progressBgColor: Colors.white.withAlpha(100),
        progressColor: const Color(0xFF212121),
        borderColor: Colors.transparent,
      );
    } else if (rank == 3) {
      // Bronze
      return _GamificationTheme(
        gradientColors: [const Color(0xFFBCAAA4), const Color(0xFF795548)],
        titleColor: Colors.white,
        textColor: Colors.white70,
        valueColor: Colors.white,
        iconColor: Colors.white,
        iconBgColor: Colors.white.withAlpha(50),
        progressBgColor: Colors.black.withAlpha(50),
        progressColor: Colors.white,
        borderColor: Colors.transparent,
      );
    } else {
      // Default (Polos Putih)
      return _GamificationTheme(
        gradientColors: [Colors.white, Colors.white],
        titleColor: Colors.black87,
        textColor: AppColors.neutral600,
        valueColor: Colors.black87,
        iconColor: AppColors.warning,
        iconBgColor: AppColors.warning.withAlpha(30),
        progressBgColor: Colors.grey[200]!,
        progressColor: Colors.blueAccent,
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
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      );
    }

    final poin = ormawa.gamifikasiPoin;
    final peringkat = ormawa.gamifikasiPeringkat;
    final total = ormawa.totalOrmawa;

    final progress =
        total > 0 ? ((total - peringkat + 1) / total).clamp(0.0, 1.0) : 0.0;
    final theme = _getTheme(peringkat);

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
              color: Colors.black.withAlpha(10),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 16),
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
                          const SizedBox(width: 4),
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
                const SizedBox(width: 24),
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
                          const SizedBox(width: 4),
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
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.progressBgColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
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
