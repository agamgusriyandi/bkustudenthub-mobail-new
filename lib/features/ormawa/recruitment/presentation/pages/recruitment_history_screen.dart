import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_history_card.dart';

class RecruitmentHistoryScreen extends StatelessWidget {
  const RecruitmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(title: 'Riwayat Keputusan'),
      body: Builder(
        builder: (context) {
          // Simulasi data riwayat
          final List<RecruitmentApplicant> history = [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.neutral300,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Belum ada riwayat',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Riwayat keputusan akan muncul di sini',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final applicant = history[index];
              return RecruitmentHistoryCard(applicant: applicant);
            },
          );
        },
      ),
    );
  }
}

