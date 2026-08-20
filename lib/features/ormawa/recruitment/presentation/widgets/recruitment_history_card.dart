import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';

class RecruitmentHistoryCard extends StatelessWidget {
  final RecruitmentApplicant applicant;

  const RecruitmentHistoryCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final isAccepted =
        applicant.status == 'aktif' || applicant.status == 'accepted';

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAccepted ? BkuTheme.emeraldSoft : BkuTheme.roseSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAccepted ? BkuTheme.emeraldBorder : BkuTheme.roseBorder,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              applicant.name.isNotEmpty ? applicant.name.substring(0, 1).toUpperCase() : 'P',
              style: TextStyle(
                color: isAccepted ? BkuTheme.emerald : BkuTheme.rose,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant.name,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${applicant.nim} • ${applicant.prodi}',
                  style: BkuTheme.textCaption.copyWith(
                    color: BkuTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          BkuStatusBadge(
            status: isAccepted ? BkuStatus.success : BkuStatus.error,
            customText: isAccepted ? 'Diterima' : 'Ditolak',
            showIcon: false,
          ),
        ],
      ),
    );
  }
}