import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrmawaGamifikasiScreen extends StatefulWidget {
  const OrmawaGamifikasiScreen({super.key});

  @override
  State<OrmawaGamifikasiScreen> createState() =>
      _OrmawaGamifikasiScreenState();
}

class _OrmawaGamifikasiScreenState extends State<OrmawaGamifikasiScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'GAMIFIKASI',
              subtitle: 'POIN & PERINGKAT',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainCard(provider),
                        const SizedBox(height: AppSpacing.xl),
                        _buildLeaderboardSection(provider),
                        const SizedBox(height: AppSpacing.xl),
                        _buildAchievementsSection(provider),
                        const SizedBox(height: AppSpacing.s100),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(OrmawaProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events_rounded,
                color: Theme.of(context).colorScheme.primary, size: 40),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${provider.gamifikasiPoin}',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            'POIN GAMIFIKASI',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _buildMiniStat(
                Icons.leaderboard_rounded,
                'Peringkat #${provider.gamifikasiPeringkat}',
                AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildMiniStat(
                Icons.groups_rounded,
                'dari ${provider.totalOrmawa} Ormawa',
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: AppRadius.radiusLg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(OrmawaProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PENCAPAIAN',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAchievementTile(
            Icons.check_circle_rounded,
            'Progres Aktif',
            'Terus pertahankan performa ormawa',
            AppColors.success,
          ),
          _buildAchievementTile(
            Icons.star_rounded,
            'Poin Terkumpul',
            '${provider.gamifikasiPoin} poin dari kegiatan',
            AppColors.warning,
          ),
          _buildAchievementTile(
            Icons.emoji_events_rounded,
            'Peringkat',
            'Peringkat #${provider.gamifikasiPeringkat} dari ${provider.totalOrmawa}',
            Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(
      IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w900, fontSize: 13)),
                Text(subtitle,
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.neutral500, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(OrmawaProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TENTANG GAMIFIKASI',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Poin gamifikasi diperoleh dari partisipasi aktif dalam kegiatan ormawa, '
            'pengiriman proposal, pelaporan LPJ, dan pencapaian lainnya. '
            'Peringkat ormawa ditentukan berdasarkan jumlah poin yang terkumpul.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral600,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
