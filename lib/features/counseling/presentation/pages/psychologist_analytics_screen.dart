import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class PsychologistAnalyticsScreen extends StatefulWidget {
  const PsychologistAnalyticsScreen({super.key});

  @override
  State<PsychologistAnalyticsScreen> createState() =>
      _PsychologistAnalyticsScreenState();
}

class _PsychologistAnalyticsScreenState
    extends State<PsychologistAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final analytics = provider.analytics;
        final stats = analytics['stats'] as List? ?? [];
        final monthly = analytics['monthly'] as List? ?? List.filled(12, 0);
        final topIssues = analytics['top_issues'] as List? ?? [];
        final recommendations = analytics['recommendations'] as List? ?? [];

        final prodiPopularity = analytics['prodi_popularity'] as List? ?? [];
        final academicCount = analytics['academic_count'] as num? ?? 0;
        final nonAcademicCount = analytics['non_academic_count'] as num? ?? 0;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                title: 'Analitik Konseling',
                variant: AppBarVariant.psychologist,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child:
                    provider.analyticsLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              if (stats.isNotEmpty) ...[
                                _buildSectionTitle('Ringkasan'),
                                const SizedBox(height: 12),
                                _buildSummaryCards(stats),
                                const SizedBox(height: 28),
                              ],
                              _buildSectionTitle('Tren Sesi Bulanan'),
                              const SizedBox(height: 12),
                              _buildTrendChart(monthly),
                              const SizedBox(height: 28),

                              if (prodiPopularity.isNotEmpty ||
                                  academicCount > 0 ||
                                  nonAcademicCount > 0) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (prodiPopularity.isNotEmpty)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionTitle(
                                              'Prodi Terbanyak',
                                            ),
                                            const SizedBox(height: 12),
                                            _buildProdiPopularity(
                                              prodiPopularity,
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (prodiPopularity.isNotEmpty &&
                                        (academicCount > 0 ||
                                            nonAcademicCount > 0))
                                      const SizedBox(width: 12),
                                    if (academicCount > 0 ||
                                        nonAcademicCount > 0)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionTitle(
                                              'Kategori Masalah',
                                            ),
                                            const SizedBox(height: 12),
                                            _buildCategoryChart(
                                              academicCount,
                                              nonAcademicCount,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                              ],

                              _buildSectionTitle('Distribusi Masalah (Isu)'),
                              const SizedBox(height: 12),
                              _buildIssueDistribution(topIssues),
                              const SizedBox(height: 28),
                              _buildSectionTitle('Rekomendasi Sistem'),
                              const SizedBox(height: 12),
                              _buildRecommendations(recommendations),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        color: AppColors.neutral900,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  // ─── Summary Cards ────────────────────────────────────────────────────────
  // Pakai Row 2x2 manual, bukan GridView, biar height bisa auto

  Widget _buildSummaryCards(List stats) {
    if (stats.isEmpty) return const SizedBox();

    final count = stats.length > 3 ? 3 : stats.length;
    final colors = [AppColors.primary, AppColors.success, AppColors.warning];
    final icons = [
      Icons.groups_rounded,
      Icons.check_circle_rounded,
      Icons.warning_amber_rounded,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (c) {
        final s = stats[c] as Map<String, dynamic>;
        final color = colors[c % colors.length];
        return Expanded(
          child: BkuCard(
            margin: EdgeInsets.only(right: c < count - 1 ? 12 : 0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Icon(icons[c % icons.length], color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  '${s['value'] ?? 0}',
                  style: AppTextStyles.titleLg.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Trend Chart ──────────────────────────────────────────────────────────

  Widget _buildTrendChart(List monthly) {
    final nums = monthly.map((e) => (e as num).toDouble()).toList();
    final maxVal = nums.fold<double>(1.0, (prev, e) => e > prev ? e : prev);
    const monthLabels = [
      '01 Jul',
      '03 Jul',
      '05 Jul',
      '08 Jul',
      '10 Jul',
      '12 Jul',
      '15 Jul',
      '18 Jul',
      '20 Jul',
      '22 Jul',
      '25 Jul',
      '28 Jul',
    ];

    return BkuCard(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: maxVal == 0 ? 10 : maxVal * 1.2,
          lineTouchData: LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i > 11) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        monthLabels[i],
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral600,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxVal > 0 ? (maxVal / 4).ceilToDouble() : 2,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    '${value.toInt()}',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal > 0 ? (maxVal / 4).ceilToDouble() : 2,
            getDrawingHorizontalLine:
                (value) =>
                    const FlLine(color: AppColors.neutral200, strokeWidth: 1.5),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots:
                  nums
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3B82F6), // Blue
                  Color(0xFF8B5CF6), // Purple
                  Color(0xFFF59E0B), // Orange
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF8B5CF6),
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8B5CF6).withAlpha(50),
                    const Color(0xFF8B5CF6).withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Prodi Popularity ─────────────────────────────────────────────────────

  Widget _buildProdiPopularity(List prodiPopularity) {
    if (prodiPopularity.isEmpty) return _buildEmptyCard('Belum ada data prodi');

    final totalPerc = prodiPopularity.fold<double>(
      0,
      (sum, item) => sum + ((item['percentage'] as num?)?.toDouble() ?? 0.0),
    );
    if (totalPerc <= 0) return _buildEmptyCard('Belum ada data persentase');

    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      AppColors.error,
    ];

    return Container(
      height: 230,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                sections:
                    prodiPopularity.asMap().entries.map((entry) {
                      final i = entry.key;
                      final prodi = entry.value as Map<String, dynamic>;
                      final perc =
                          ((prodi['percentage'] as num?)?.toDouble() ?? 0.0);
                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: perc,
                        title: '${perc.toInt()}%',
                        radius: 30,
                        titleStyle: AppTextStyles.labelMd.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    prodiPopularity.asMap().entries.map((entry) {
                      final i = entry.key;
                      final prodi = entry.value as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[i % colors.length],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                prodi['name']?.toString() ?? '-',
                                style: AppTextStyles.labelMd.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Chart ───────────────────────────────────────────────────────

  Widget _buildCategoryChart(num academic, num nonAcademic) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                sections: [
                  if (academic > 0)
                    PieChartSectionData(
                      color: AppColors.primary,
                      value: academic.toDouble(),
                      title: '$academic',
                      radius: 30,
                      titleStyle: AppTextStyles.labelMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (nonAcademic > 0)
                    PieChartSectionData(
                      color: AppColors.warning,
                      value: nonAcademic.toDouble(),
                      title: '$nonAcademic',
                      radius: 30,
                      titleStyle: AppTextStyles.labelMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (academic <= 0 && nonAcademic <= 0)
                    PieChartSectionData(
                      color: AppColors.neutral300,
                      value: 1,
                      title: '',
                      radius: 30,
                    ),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Akademik',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral700,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Non-Akademik',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral700,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Issue Distribution ───────────────────────────────────────────────────

  Widget _buildIssueDistribution(List topIssues) {
    if (topIssues.isEmpty) {
      return _buildEmptyCard('Belum ada data distribusi masalah');
    }

    final maxVal = topIssues.fold<double>(0, (max, item) {
      final perc = ((item['percentage'] as num?)?.toDouble() ?? 0.0);
      return perc > max ? perc : max;
    });

    final colors = [
      AppColors.primary,
      const Color(0xFF8B5CF6),
      AppColors.warning,
      AppColors.success,
      AppColors.error,
    ];

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children:
            topIssues.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value as Map<String, dynamic>;
              final name = item['name']?.toString() ?? '-';
              final perc = ((item['percentage'] as num?)?.toDouble() ?? 0.0);
              final color = colors[i % colors.length];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == topIssues.length - 1 ? 0 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral800,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${perc.toStringAsFixed(1)}%',
                          style: AppTextStyles.bodySm.copyWith(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final fillWidth =
                            maxVal == 0 ? 0.0 : (perc / 100) * width;
                        return Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                height: 8,
                                width: fillWidth,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: AppRadius.radiusXs,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ─── Recommendations ──────────────────────────────────────────────────────

  Widget _buildRecommendations(List recommendations) {
    if (recommendations.isEmpty) {
      return _buildEmptyCard('Belum ada rekomendasi sistem');
    }

    return Column(
      children:
          recommendations.map((r) {
            final rec = r as Map<String, dynamic>;
            final isWarning = rec['type'] == 'warning';
            final color = isWarning ? AppColors.warning : AppColors.success;
            final bgColor =
                isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);
            final borderColor =
                isWarning ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Icon(
                      isWarning
                          ? Icons.warning_amber_rounded
                          : Icons.lightbulb_rounded,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['title']?.toString() ?? '',
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rec['description']?.toString() ?? '',
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 12,
                            color: AppColors.neutral700,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // ─── Empty Card ───────────────────────────────────────────────────────────

  Widget _buildEmptyCard(String message) {
    return BkuCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.neutral300),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySm.copyWith(
              fontSize: 13,
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
