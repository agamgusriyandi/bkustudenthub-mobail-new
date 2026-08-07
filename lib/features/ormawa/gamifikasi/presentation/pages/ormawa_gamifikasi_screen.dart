import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrmawaGamifikasiScreen extends StatefulWidget {
  const OrmawaGamifikasiScreen({super.key});

  @override
  State<OrmawaGamifikasiScreen> createState() => _OrmawaGamifikasiScreenState();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: RefreshIndicator(
          onRefresh: () => context.read<OrmawaProvider>().refreshData(),
          child: CustomScrollView(
            slivers: [
              BkuAppBar(
                title: 'Gamifikasi',
                subtitle: 'Poin & Peringkat',
                variant: AppBarVariant.ormawa,
                expandedHeight: 130.0,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: context.appColors.primary,
                    unselectedLabelColor: AppColors.neutral500,
                    indicatorColor: context.appColors.primary,
                    indicatorWeight: 3,
                    labelStyle: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Ringkasan'),
                      Tab(text: 'Peringkat'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, _) {
                    return TabBarView(
                      children: [
                        _buildRingkasanTab(provider),
                        _buildLeaderboardTab(provider),
                        _buildHistoryTab(provider),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingkasanTab(OrmawaProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildMainCard(provider),
        const SizedBox(height: AppSpacing.xl),
        _buildRulesSection(provider),
        const SizedBox(height: AppSpacing.s100),
      ],
    );
  }

  Widget _buildLeaderboardTab(OrmawaProvider provider) {
    if (provider.isLoading && provider.gamifikasiLeaderboard.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList());
    }

    if (provider.gamifikasiLeaderboard.isEmpty) {
      return _buildEmptyState('Belum ada papan peringkat saat ini.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: provider.gamifikasiLeaderboard.length,
      separatorBuilder:
          (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = provider.gamifikasiLeaderboard[index];
        final isTop3 = index < 3;
        final color = isTop3 ? AppColors.warning : AppColors.neutral300;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isTop3 ? AppColors.warning : AppColors.neutral700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  item['nama']?.toString() ?? 'Ormawa',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: context.appColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${item['total_poin'] ?? 0} Poin',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(OrmawaProvider provider) {
    if (provider.isLoading && provider.gamifikasiHistory.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList());
    }

    if (provider.gamifikasiHistory.isEmpty) {
      return _buildEmptyState('Belum ada riwayat poin.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: provider.gamifikasiHistory.length,
      separatorBuilder:
          (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = provider.gamifikasiHistory[index];
        final poin = int.tryParse(item['poin']?.toString() ?? '0') ?? 0;
        final isMinus = poin < 0;
        final color = isMinus ? AppColors.error : AppColors.success;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  isMinus
                      ? Icons.remove_circle_rounded
                      : Icons.add_circle_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['deskripsi']?.toString() ?? 'Aktivitas',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item['created_at'] != null
                          ? item['created_at'].toString().split('T').first
                          : '',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isMinus ? '' : '+'}$poin',
                style: AppTextStyles.bodyLg.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, color: AppColors.neutral300, size: 64),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            color: AppColors.onSurface.withAlpha(12),
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
              color: context.appColors.primary.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: context.appColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${provider.gamifikasiPoin}',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: context.appColors.primary,
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

  Widget _buildRulesSection(OrmawaProvider provider) {
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
            'ATURAN POIN',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (provider.gamifikasiRules.isEmpty)
            Text(
              'Poin gamifikasi diperoleh dari partisipasi aktif dalam kegiatan ormawa, '
              'pengiriman proposal, pelaporan LPJ, dan pencapaian lainnya. '
              'Peringkat ormawa ditentukan berdasarkan jumlah poin yang terkumpul.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
                fontSize: 13,
              ),
            )
          else
            ...provider.gamifikasiRules.map((rule) {
              final poin = int.tryParse(rule['poin']?.toString() ?? '0') ?? 0;
              final isMinus = poin < 0;
              final color = isMinus ? AppColors.error : AppColors.success;
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
                      child: Icon(Icons.star_rounded, color: color, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        rule['aksi']?.toString() ?? 'Aktivitas',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${isMinus ? '' : '+'}$poin',
                      style: AppTextStyles.labelSm.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.appColors.surface, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
