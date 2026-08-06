import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:intl/intl.dart';


class RecruitmentDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const RecruitmentDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : 'Pilih Tanggal',
                  style: AppTextStyles.bodyMd.copyWith(
                    color:
                        date != null
                            ? AppColors.neutral900
                            : AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

