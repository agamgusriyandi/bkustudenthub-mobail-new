import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
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
        child: OrmawaEmptyCard(
          title: 'Belum Ada Proposal',
          description: 'Belum ada pengajuan proposal kegiatan terbaru.',
          icon: Icons.assignment_outlined,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: proposals.length > 3 ? 3 : proposals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          final statusLower = proposal.status.toLowerCase();

          Color badgeBg = OrmawaTheme.statusInfoBg;
          Color badgeText = OrmawaTheme.statusInfoText;

          if (statusLower.contains('disetujui') || statusLower == 'selesai') {
            badgeBg = OrmawaTheme.statusSuccessBg;
            badgeText = OrmawaTheme.statusSuccessText;
          } else if (statusLower.contains('tolak') || statusLower == 'batal') {
            badgeBg = OrmawaTheme.statusDangerBg;
            badgeText = OrmawaTheme.statusDangerText;
          } else if (statusLower.contains('revisi')) {
            badgeBg = OrmawaTheme.statusWarningBg;
            badgeText = OrmawaTheme.statusWarningText;
          }

          return OrmawaCard(
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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF2563EB),
                        size: 19,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proposal.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: OrmawaTheme.textHeading,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            proposal.code,
                            style: TextStyle(
                              fontSize: 11,
                              color: OrmawaTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        proposal.status,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (proposal.date.hour != 0 || proposal.date.minute != 0)
                              ? DateFormat('dd MMM yyyy, HH:mm', 'id').format(proposal.date)
                              : DateFormat('dd MMM yyyy', 'id').format(proposal.date),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (proposal.budget > 0)
                      Text(
                        _formatRp(proposal.budget),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF64748B),
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