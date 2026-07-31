import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class AllSchedulesScreen extends StatefulWidget {
  const AllSchedulesScreen({super.key});

  @override
  State<AllSchedulesScreen> createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPsychologistProvider>().loadAllSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPsychologistProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                title: 'Semua Jadwal',
                subtitle: 'Jadwal konseling psikolog',
                variant: AppBarVariant.psychologist,
                isExpandable: false,
                showBackButton: true,
              ),
              if (provider.schedulesLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 5, itemHeight: 100),
                  ),
                )
              else if (provider.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.error.withAlpha(80),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            provider.error!,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: provider.loadAllSchedules,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (provider.allSchedules.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 64,
                            color: AppColors.neutral300,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Belum ada jadwal',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.s120,
                  ),
                  sliver: SliverList.separated(
                    itemCount: provider.allSchedules.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _buildScheduleCard(provider.allSchedules[index]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final day = (schedule['day'] ?? schedule['hari'] ?? '-').toString();
    final psychologist =
        (schedule['psychologist_name'] ?? schedule['psikolog_nama'] ?? schedule['psikolog'] ?? '-').toString();
    final slots = schedule['slots'];
    final slotCount = slots is List ? slots.length : 0;
    final isActive = schedule['enabled'] ?? schedule['is_active'] ?? true;

    final dayEmoji = _dayEmoji(day);

    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isActive
                        ? context.appColors.primary.withAlpha(15)
                        : AppColors.neutral200,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: isActive
                        ? context.appColors.primary
                        : AppColors.neutral500,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayEmoji $day',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isActive
                              ? AppColors.neutral800
                              : AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        psychologist,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withAlpha(20)
                        : AppColors.neutral200,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Nonaktif',
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.success : AppColors.neutral500,
                    ),
                  ),
                ),
              ],
            ),
            if (slotCount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$slotCount slot waktu tersedia',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _dayEmoji(String day) {
    final d = day.toLowerCase();
    if (d.contains('senin')) return '📅';
    if (d.contains('selasa')) return '📅';
    if (d.contains('rabu')) return '📅';
    if (d.contains('kamis')) return '📅';
    if (d.contains('jumat')) return '🕌';
    if (d.contains('sabtu')) return '🎉';
    if (d.contains('minggu')) return '🌴';
    return '📅';
  }
}
