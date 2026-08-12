import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_detail_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';

class OrmawaProposalList extends StatelessWidget {
  const OrmawaProposalList({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();
    final proposals = ormawa.proposals;

    if (ormawa.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: BkuShimmerList(itemCount: 2, itemHeight: 120),
      );
    }

    if (proposals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Text(
            'Belum ada proposal terbaru',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: proposals.length > 3 ? 3 : proposals.length,
      itemBuilder: (context, index) {
        final proposal = proposals[index];
        final statusLower = proposal.status.toLowerCase();

        Color statusColor;
        IconData statusIcon;
        List<Color> gradientColors;
        BkuStatus mappedStatus;

        if (statusLower.contains('disetujui') || statusLower == 'selesai') {
          statusColor = AppColors.success; // Emerald green
          statusIcon = Icons.check_circle_rounded;
          gradientColors = [AppColors.successContainer, AppColors.successContainer];
          mappedStatus = BkuStatus.success;
        } else if (statusLower.contains('tolak') || statusLower == 'batal') {
          statusColor = AppColors.error; // Red
          statusIcon = Icons.cancel_rounded;
          gradientColors = [AppColors.dangerContainer, AppColors.dangerContainer];
          mappedStatus = BkuStatus.error;
        } else if (statusLower.contains('revisi')) {
          statusColor = AppColors.warning; // Amber
          statusIcon = Icons.edit_document;
          gradientColors = [AppColors.warningContainer, AppColors.warningContainer];
          mappedStatus = BkuStatus.warning;
        } else {
          statusColor = AppColors.info; // Blue
          statusIcon = Icons.file_present_rounded;
          gradientColors = [AppColors.infoContainer, AppColors.infoContainer];
          mappedStatus = BkuStatus.info;
        }

        return FadeInAnimation(
          delay: 0.9 + (index * 0.1),
          child: BkuCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            borderRadius: 24.0,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proposal.title,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.neutral800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              proposal.code,
                              style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BkuStatusBadge(
                        status: mappedStatus,
                        customText: proposal.status,
                        showIcon: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: context.appColors.outline,
                          ),
                          const SizedBox(width: AppSpacing.s6),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                              'id',
                            ).format(proposal.date),
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.outline,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrmawaProposalDetailScreen(
                                    proposal: proposal,
                                  ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Lihat Detail',
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: context.appColors.primary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
