import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_section_header.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';

class MentorHandbookChart extends StatelessWidget {
  final MentorDashboardData dashboard;

  const MentorHandbookChart({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.warning.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: context.appColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dokumen Handbook', style: AppTextStyles.labelSm),
                    const SizedBox(height: 2),
                    Text(
                      '${dashboard.pendingHandbooks} Menunggu Persetujuan',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const BkuSectionHeader(
          title: 'Evaluasi Mahasiswa',
        ),
        const SizedBox(height: AppSpacing.md),
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: (dashboard.passedStudents + dashboard.remedialStudents + dashboard.pendingScoring) == 0
                          ? [
                              PieChartSectionData(
                                color: AppColors.neutral200,
                                value: 1,
                                title: '',
                                radius: 20,
                              ),
                            ]
                          : [
                              PieChartSectionData(
                                color: context.appColors.success,
                                value: dashboard.passedStudents.toDouble(),
                                title: '',
                                radius: 20,
                              ),
                              PieChartSectionData(
                                color: context.appColors.error,
                                value: dashboard.remedialStudents.toDouble(),
                                title: '',
                                radius: 20,
                              ),
                              PieChartSectionData(
                                color: AppColors.neutral300,
                                value: dashboard.pendingScoring.toDouble(),
                                title: '',
                                radius: 20,
                              ),
                            ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        context.appColors.success,
                        'Lulus (${dashboard.passedStudents})',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        context.appColors.error,
                        'Remedial (${dashboard.remedialStudents})',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        AppColors.neutral300,
                        'Belum (${dashboard.pendingScoring})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}
