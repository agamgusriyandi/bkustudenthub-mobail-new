import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

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
    final ipk = currentIpk > 0 ? currentIpk : 0.0;
    final semester = currentSemester > 0 ? currentSemester : 1;

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

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: 20,
      borderOnly: true,
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
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IPK Terkini: ${ipk.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFDBEAFE),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Semester $semester',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          'IPK ${touchedSpot.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value == 4.0 || value == 3.0 || value == 2.0 || value == 1.0) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
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
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
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
                    barWidth: 2.8,
                    color: const Color(0xFF2563EB),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF2563EB),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3B82F6).withValues(alpha: 0.22),
                          const Color(0xFF3B82F6).withValues(alpha: 0.0),
                        ],
                      ),
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
