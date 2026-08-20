import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';

class RecruitmentInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const RecruitmentInfoCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.primarySoft,
        borderRadius: BkuTheme.r12,
        border: Border.all(
          color: BkuTheme.primaryBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: BkuTheme.primary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: BkuTheme.textCardTitle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}