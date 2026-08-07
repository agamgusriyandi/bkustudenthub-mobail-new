import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';

class RecruitmentHistoryCard extends StatelessWidget {
  final RecruitmentApplicant applicant;

  const RecruitmentHistoryCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final isAccepted =
        applicant.status == 'aktif' || applicant.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color:
              isAccepted
                  ? AppColors.success.withAlpha(50)
                  : AppColors.error.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isAccepted
                    ? AppColors.success.withAlpha(20)
                    : AppColors.error.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isAccepted
                          ? [AppColors.success, context.appColors.success]
                          : [AppColors.error, context.appColors.error],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isAccepted ? AppColors.success : AppColors.error)
                        .withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                applicant.name.substring(0, 1),
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: (isAccepted ? AppColors.success : AppColors.error)
                    .withAlpha(20),
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: (isAccepted ? AppColors.success : AppColors.error)
                      .withAlpha(50),
                ),
              ),
              child: Text(
                isAccepted ? 'Diterima' : 'Ditolak',
                style: AppTextStyles.labelSm.copyWith(
                  color:
                      isAccepted
                          ? AppColors.onSuccessContainer
                          : AppColors.onDangerContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal Detail Applicant
