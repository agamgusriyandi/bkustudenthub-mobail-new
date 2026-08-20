import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';

class RecruitmentApplicantCard extends StatelessWidget {
  final RecruitmentApplicant applicant;
  final VoidCallback onReview;

  const RecruitmentApplicantCard({
    super.key,
    required this.applicant,
    required this.onReview,
  });

  BkuStatus _mapStatusToBkuStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        return BkuStatus.success;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        return BkuStatus.error;
      case 'pending':
      case 'menunggu':
      default:
        return BkuStatus.warning;
    }
  }

  String _mapStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        return 'Diterima';
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      case 'menunggu':
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      onTap: onReview,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(color: BkuTheme.primaryBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              applicant.name.isNotEmpty ? applicant.name.substring(0, 1).toUpperCase() : 'P',
              style: TextStyle(
                color: BkuTheme.primary,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BkuStatusBadge(
                status: _mapStatusToBkuStatus(applicant.status),
                customText: _mapStatusText(applicant.status),
                showIcon: false,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: BkuTheme.amber,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    applicant.ipk.toStringAsFixed(2),
                    style: BkuTheme.textCaption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BkuTheme.textHeading,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
