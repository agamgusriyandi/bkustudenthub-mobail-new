import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class IpkChartCard extends StatelessWidget {
  final double currentIpk;
  final int currentSemester;

  const IpkChartCard({
    super.key,
    required this.currentIpk,
    required this.currentSemester,
  });

  @override
  Widget build(BuildContext context) {
    final ipk = currentIpk > 0 ? currentIpk : 3.0;
    final semester = currentSemester > 0 ? currentSemester : 1;

    // Generate simulated dynamic GPA points leading to exact current IPK
    final List<FlSpot> spots = [];
    if (semester == 1) {
      spots.add(FlSpot(1, ipk));
    } else if (semester == 2) {
      spots.add(FlSpot(1, (ipk - 0.1).clamp(0.0, 4.0)));
      spots.add(FlSpot(2, ipk));
    } else if (semester == 3) {
      spots.add(FlSpot(1, (ipk - 0.15).clamp(0.0, 4.0)));
      spots.add(FlSpot(2, (ipk + 0.05).clamp(0.0, 4.0)));
      spots.add(FlSpot(3, ipk));
    } else {
      spots.add(FlSpot(1, (ipk - 0.2).clamp(0.0, 4.0)));
      spots.add(FlSpot(2, (ipk + 0.1).clamp(0.0, 4.0)));
      spots.add(FlSpot(3, (ipk - 0.05).clamp(0.0, 4.0)));
      for (int s = 4; s < semester; s++) {
        spots.add(FlSpot(s.toDouble(), (ipk + (s % 2 == 0 ? 0.02 : -0.02)).clamp(0.0, 4.0)));
      }
      spots.add(FlSpot(semester.toDouble(), ipk));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200),
      ),
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
                    'Perkembangan Akademik',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'IPK Terkini: ${ipk.toStringAsFixed(2)}',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: context.appColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  'Semester $semester',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => context.appColors.onSurface.withValues(alpha: 0.9),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          touchedSpot.y.toStringAsFixed(2),
                          TextStyle(
                            color: context.appColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 4.0 || value == 3.0 || value == 2.0 || value == 1.0) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 9,
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Sem ${value.toInt()}',
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 9,
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      interval: 1.0,
                    ),
                  ),
                ),
                minY: 1.0,
                maxY: 4.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 3,
                    color: context.appColors.primary,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: context.appColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
