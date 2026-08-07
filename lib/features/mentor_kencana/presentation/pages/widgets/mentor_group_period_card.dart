import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';

class MentorGroupPeriodCard extends StatelessWidget {
  final MentorDashboardData dashboard;

  const MentorGroupPeriodCard({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final raw = dashboard.rawData;
    final group = raw['group'] as Map<String, dynamic>?;
    final period = group?['period'] as Map<String, dynamic>?;

    // Calculate progress
    final studentCount = dashboard.totalMentees;
    final evaluatedCount = dashboard.passedStudents + dashboard.remedialStudents;
    final progressPercent =
        studentCount > 0 ? (evaluatedCount / studentCount).clamp(0.0, 1.0) : 0.0;

    // Formatting dates
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '-';
      try {
        final date = DateTime.parse(dateStr);
        return '${date.day}-${date.month}-${date.year}';
      } catch (_) {
        return dateStr;
      }
    }

    final groupName = group?['name']?.toString() ?? '-';
    final groupCode = group?['code']?.toString() ?? '-';
    final scope = group?['scope_type']?.toString() ?? '-';
    final periodName = period?['name']?.toString() ?? '-';
    final startDateStr = formatDate(period?['start_date']?.toString());
    final endDateStr = formatDate(period?['end_date']?.toString());
    final passGrade = period?['passing_grade']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: AppRadius.radiusXl,
            ),
            child: Text(
              scope,
              style: AppTextStyles.labelSm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            groupName,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kode: $groupCode',
            style: AppTextStyles.labelMd.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              _buildModernPill(Icons.event, periodName),
              _buildModernPill(Icons.calendar_today, '$startDateStr - $endDateStr'),
              _buildModernPill(Icons.grade, 'Lulus: $passGrade'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kemajuan Evaluasi',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
                    ),
                    Text(
                      '$evaluatedCount dari $studentCount',
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(context.appColors.success),
                  borderRadius: AppRadius.radiusSm,
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
