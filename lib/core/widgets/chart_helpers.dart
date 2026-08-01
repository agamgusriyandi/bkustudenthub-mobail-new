import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPoint {
  final String label;
  final double value;
  const ChartPoint({required this.label, required this.value});
}

class ChartSlice {
  final String label;
  final double value;
  final Color color;
  const ChartSlice({required this.label, required this.value, required this.color});
}

class ChartBar {
  final String label;
  final double value;
  final Color color;
  const ChartBar({required this.label, required this.value, required this.color});
}


class ChartHelpers {
  ChartHelpers._();

  static Widget buildLineChart(
    BuildContext context, {
    required List<ChartPoint> points,
    Color? lineColor,
    double height = 200,
    String yAxisSuffix = '',
  }) {
    if (points.isEmpty) return SizedBox(height: height);
    final color = lineColor ?? context.appColors.info;
    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value));
    }
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final ceiling = maxY == 0 ? 1.0 : maxY * 1.2;
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: ceiling,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appColors.outlineVariant.withAlpha(80),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      points[i].label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: context.appColors.surface,
                  strokeWidth: 2,
                  strokeColor: color,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withAlpha(50), color.withAlpha(0)],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched
                  .map(
                    (s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}$yAxisSuffix',
                      TextStyle(
                        color: context.appColors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildPieChart(
    BuildContext context, {
    required List<ChartSlice> slices,
    double height = 180,
    double radius = 60,
    List<Color>? fallbackPalette,
  }) {
    if (slices.isEmpty) return SizedBox(height: height);
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return SizedBox(height: height);
    final palette = fallbackPalette ??
        [
          context.appColors.primary,
          context.appColors.secondary,
          context.appColors.success,
          context.appColors.warning,
          context.appColors.info,
          context.appColors.error,
        ];
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < slices.length; i++) {
      final s = slices[i];
      final color = s.color != _transparent
          ? s.color
          : palette[i % palette.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: s.value,
          title: '${(s.value / total * 100).toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: context.appColors.surface,
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 36,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < slices.length; i++)
              _legendItem(context, slices[i], palette[i % palette.length]),
          ],
        ),
      ],
    );
  }

  static Widget buildBarChart(
    BuildContext context, {
    required List<ChartBar> bars,
    Color? color,
    double height = 200,
    String yAxisSuffix = '',
  }) {
    if (bars.isEmpty) return SizedBox(height: height);
    final maxV = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final ceiling = maxV == 0 ? 1.0 : maxV * 1.25;
    final baseColor = color ?? context.appColors.info;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: ceiling,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${bars[groupIndex].label}\n${rod.toY.toStringAsFixed(0)}$yAxisSuffix',
                  TextStyle(
                    color: context.appColors.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= bars.length) {
                    return const SizedBox.shrink();
                  }
                  final lbl = bars[i].label;
                  final abbrev = lbl.length > 8
                      ? '${lbl.substring(0, 8)}…'
                      : lbl;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      abbrev,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appColors.outlineVariant.withAlpha(80),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < bars.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: bars[i].value,
                    color: bars[i].color != _transparent
                        ? bars[i].color
                        : baseColor,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.radius6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static Widget _legendItem(
    BuildContext context,
    ChartSlice s,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s6),
        Text(
          '${s.label} (${s.value.toInt()})',
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static const Color _transparent = Color(0x00000000);
}
