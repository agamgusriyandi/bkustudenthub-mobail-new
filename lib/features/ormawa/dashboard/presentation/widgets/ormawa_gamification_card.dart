import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class _GamificationTheme {
  final Color titleColor;
  final Color textColor;
  final Color valueColor;
  final Color iconColor;
  final Color iconBgColor;
  final Color iconBorderColor;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color progressBgColor;
  final Color progressColor;
  final Color borderColor;

  _GamificationTheme({
    required this.titleColor,
    required this.textColor,
    required this.valueColor,
    required this.iconColor,
    required this.iconBgColor,
    required this.iconBorderColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.progressBgColor,
    required this.progressColor,
    required this.borderColor,
  });
}

class OrmawaGamificationCard extends StatelessWidget {
  const OrmawaGamificationCard({super.key});

  _GamificationTheme _getTheme(int rank) {
    if (rank == 1) {
      return _GamificationTheme(
        titleColor: BkuTheme.textHeading,
        textColor: BkuTheme.amber,
        valueColor: BkuTheme.textHeading,
        iconColor: BkuTheme.amber,
        iconBgColor: BkuTheme.amberSoft,
        iconBorderColor: BkuTheme.amberBorder,
        badgeBgColor: BkuTheme.amber,
        badgeTextColor: Colors.white,
        progressBgColor: BkuTheme.amberSoft,
        progressColor: BkuTheme.amber,
        borderColor: BkuTheme.amberBorder,
      );
    } else if (rank == 2) {
      return _GamificationTheme(
        titleColor: BkuTheme.textHeading,
        textColor: BkuTheme.slate,
        valueColor: BkuTheme.textHeading,
        iconColor: BkuTheme.slate,
        iconBgColor: BkuTheme.slateSoft,
        iconBorderColor: BkuTheme.slateBorder,
        badgeBgColor: BkuTheme.slate,
        badgeTextColor: Colors.white,
        progressBgColor: BkuTheme.slateSoft,
        progressColor: BkuTheme.slate,
        borderColor: BkuTheme.slateBorder,
      );
    } else if (rank == 3) {
      return _GamificationTheme(
        titleColor: BkuTheme.textHeading,
        textColor: const Color(0xFFC2410C),
        valueColor: BkuTheme.textHeading,
        iconColor: const Color(0xFFEA580C),
        iconBgColor: const Color(0xFFFFEDD5),
        iconBorderColor: const Color(0xFFFED7AA),
        badgeBgColor: const Color(0xFFFB923C),
        badgeTextColor: Colors.white,
        progressBgColor: const Color(0xFFFFEDD5),
        progressColor: const Color(0xFFEA580C),
        borderColor: const Color(0xFFFED7AA),
      );
    } else {
      return _GamificationTheme(
        titleColor: BkuTheme.textHeading,
        textColor: BkuTheme.textMuted,
        valueColor: BkuTheme.textHeading,
        iconColor: BkuTheme.primary,
        iconBgColor: BkuTheme.primarySoft,
        iconBorderColor: BkuTheme.primaryBorder,
        badgeBgColor: BkuTheme.primary,
        badgeTextColor: Colors.white,
        progressBgColor: BkuTheme.borderSubtle,
        progressColor: BkuTheme.primary,
        borderColor: BkuTheme.border,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();

    if (ormawa.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: BkuShimmer(
          width: double.infinity,
          height: 100,
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
      child: BkuCard(
        onTap: () => context.push(AppRoutes.ormawaGamifikasi),
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 20,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.iconBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.iconBorderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: theme.iconColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gamifikasi Ormawa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.titleColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Peringkat keaktifan se-Universitas',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.iconColor.withValues(alpha: 0.25), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.iconColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 13,
                        color: theme.iconColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.badgeBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$peringkat',
                        style: TextStyle(
                          color: theme.badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'dari $total Ormawa',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$poin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.progressBgColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.progressColor),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}