import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';

class RecruitmentApplicantCard extends StatelessWidget {
  final RecruitmentApplicant applicant;
  final VoidCallback onReview;

  const RecruitmentApplicantCard({
    super.key,
    required this.applicant,
    required this.onReview,
  });

  Widget _buildStatusBadge(String status) {
    final String statusText;
    final Color badgeColor;
    final Color textColor;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        statusText = 'Diterima';
        badgeColor = AppColors.success.withAlpha(20);
        textColor = AppColors.onSuccessContainer;
        break;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        statusText = 'Ditolak';
        badgeColor = AppColors.error.withAlpha(20);
        textColor = AppColors.onDangerContainer;
        break;
      case 'pending':
      case 'menunggu':
      default:
        statusText = 'Menunggu';
        badgeColor = AppColors.warning.withAlpha(20);
        textColor = AppColors.onWarningContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelSm.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: context.appColors.outline.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onReview,
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.appColors.primary,
                        context.appColors.primary.withAlpha(150),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    applicant.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.titleSm.copyWith(
                      color: context.appColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${applicant.nim} • ${applicant.prodi}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(applicant.status),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          applicant.ipk.toStringAsFixed(2),
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

