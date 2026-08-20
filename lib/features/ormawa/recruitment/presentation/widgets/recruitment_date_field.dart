import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
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
          style: BkuTheme.textCaption.copyWith(
            fontWeight: FontWeight.w700,
            color: BkuTheme.textHeading,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BkuTheme.r12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: BkuTheme.border,
              ),
              borderRadius: BkuTheme.r12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: BkuTheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy', 'id_ID').format(date!)
                      : 'Pilih Tanggal',
                  style: BkuTheme.textBodyRegular.copyWith(
                    color: date != null
                        ? BkuTheme.textHeading
                        : BkuTheme.textPlaceholder,
                    fontWeight: date != null ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
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