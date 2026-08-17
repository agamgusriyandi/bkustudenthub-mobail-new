import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
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
        child: BkuShimmerList(itemCount: 2, itemHeight: 90),
      );
    }

    if (proposals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            'Belum ada proposal terbaru',
            style: TextStyle(
              fontSize: 11,
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
          statusColor = AppColors.success;
          statusIcon = Icons.check_circle_rounded;
          gradientColors = [AppColors.successContainer, AppColors.successContainer];
          mappedStatus = BkuStatus.success;
        } else if (statusLower.contains('tolak') || statusLower == 'batal') {
          statusColor = AppColors.error;
          statusIcon = Icons.cancel_rounded;
          gradientColors = [AppColors.dangerContainer, AppColors.dangerContainer];
          mappedStatus = BkuStatus.error;
        } else if (statusLower.contains('revisi')) {
          statusColor = AppColors.warning;
          statusIcon = Icons.edit_document;
          gradientColors = [AppColors.warningContainer, AppColors.warningContainer];
          mappedStatus = BkuStatus.warning;
        } else {
          statusColor = AppColors.info;
          statusIcon = Icons.file_present_rounded;
          gradientColors = [AppColors.infoContainer, AppColors.infoContainer];
          mappedStatus = BkuStatus.info;
        }

        return BkuCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          borderRadius: AppRadius.lg,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: context.appColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          proposal.code,
                          style: TextStyle(
                            fontSize: 10,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: context.appColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                          'id',
                        ).format(proposal.date),
                        style: TextStyle(
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
                          style: const TextStyle(
                            color: AppColors.neutral800,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.neutral800,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
