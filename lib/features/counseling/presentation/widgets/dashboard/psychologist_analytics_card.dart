import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class PsychologistAnalyticsCard extends StatelessWidget {
  const PsychologistAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final weekTrends = provider.analytics['week_trends'] as List? ?? [];
        final stats = provider.analytics['stats'] as List? ?? [];
        String totalPasien = '0';
        String sesiSelesai = '0';
        for (var s in stats) {
          if (s['label'] == 'Total Pasien Unik') {
            totalPasien = s['value']?.toString() ?? '0';
          }
          if (s['label'] == 'Sesi Selesai') {
            sesiSelesai = s['value']?.toString() ?? '0';
          }
        }
        final isLoading = provider.analyticsLoading;

        return BkuCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analitik & Tren',
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Ringkasan data minggu ini',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push(AppRoutes.psychologistAnalytics),
                    borderRadius: AppRadius.radiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Text(
                        'Detail',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatBadge(
                      'Total Pasien',
                      totalPasien,
                      Icons.group_rounded,
                      AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBadge(
                      'Sesi Selesai',
                      sesiSelesai,
                      Icons.check_circle_rounded,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'Topik Terbanyak',
                style: AppTextStyles.titleMd.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? Center(
                    child: SizedBox(
                      height: 140,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : weekTrends.isEmpty
                  ? _buildEmpty()
                  : _buildBars(weekTrends),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: color.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.neutral600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: AppColors.neutral300,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada data minggu ini',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.neutral500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBars(List weekTrends) {
    // Ambil max 4 topik
    final items = weekTrends.take(4).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          items.map((t) {
            final trend = t as Map<String, dynamic>;
            final label = trend['name']?.toString() ?? '-';
            final val = (trend['val'] as num?)?.toDouble() ?? 0.0;
            final count = (trend['count'] as num?)?.toInt() ?? 0;
            // Potong label panjang
            final shortLabel =
                label.length > 8 ? '${label.substring(0, 7)}..' : label;
            return _SimpleBar(
              label: shortLabel,
              val: val.clamp(0.0, 1.0),
              count: count,
            );
          }).toList(),
    );
  }
}

class _SimpleBar extends StatelessWidget {
  final String label;
  final double val;
  final int count;

  const _SimpleBar({
    required this.label,
    required this.val,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          count.toString(),
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: 20,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: AppRadius.radiusMd,
          ),
          child: FractionallySizedBox(
            heightFactor: val > 0 ? val : 0.05,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: AppRadius.radiusMd,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.neutral600,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
