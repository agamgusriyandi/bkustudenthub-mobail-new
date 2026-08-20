import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_detail_screen.dart';

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
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: BkuEmptyState(
          title: 'Belum Ada Proposal',
          message: 'Belum ada pengajuan proposal kegiatan terbaru.',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: proposals.length > 5 ? 5 : proposals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          final statusLower = proposal.status.toLowerCase();

          BkuStatus badgeStatus = BkuStatus.info;
          if (statusLower.contains('disetujui') || statusLower == 'selesai') {
            badgeStatus = BkuStatus.success;
          } else if (statusLower.contains('tolak') || statusLower == 'batal') {
            badgeStatus = BkuStatus.error;
          } else if (statusLower.contains('revisi')) {
            badgeStatus = BkuStatus.warning;
          }

          return BkuCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrmawaProposalDetailScreen(
                    proposal: proposal,
                  ),
                ),
              );
            },
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: BkuTheme.primarySoft,
                        borderRadius: BkuTheme.r10,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: BkuTheme.primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proposal.title,
                            style: BkuTheme.textCardTitle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            proposal.code,
                            style: BkuTheme.textCaption.copyWith(
                              color: BkuTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BkuStatusBadge(
                      status: badgeStatus,
                      customText: proposal.status,
                      showIcon: false,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: BkuTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (proposal.date.hour != 0 || proposal.date.minute != 0)
                              ? DateFormat('dd MMM yyyy, HH:mm', 'id').format(proposal.date)
                              : DateFormat('dd MMM yyyy', 'id').format(proposal.date),
                          style: BkuTheme.textCaption.copyWith(
                            color: BkuTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (proposal.budget > 0)
                      Text(
                        _formatRp(proposal.budget),
                        style: TextStyle(
                          color: BkuTheme.emerald,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Text(
                            'Lihat Detail',
                            style: BkuTheme.textCaption.copyWith(
                              color: BkuTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: BkuTheme.textMuted,
                            size: 9,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatRp(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}