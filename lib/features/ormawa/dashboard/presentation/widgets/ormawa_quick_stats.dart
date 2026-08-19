import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/finance/presentation/pages/ormawa_finance_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_kalender_screen.dart';

class OrmawaQuickStats extends StatelessWidget {
  const OrmawaQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();

    if (ormawa.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: const [
            BkuShimmer(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
          ],
        ),
      );
    }

    final formattedKas = NumberFormat.compactCurrency(
      symbol: 'Rp ',
      locale: 'id_ID',
      decimalDigits: 1,
    ).format(ormawa.balance);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OrmawaKpiCard(
                  title: 'Proposal Proker',
                  value: '${ormawa.activeProposalsCount}',
                  badgeText: '${ormawa.approvalRate}% Acc',
                  icon: Icons.description_rounded,
                  badgeColor: const Color(0xFF0284C7),
                  subtitle: 'Pengajuan aktif',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaProposalScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OrmawaKpiCard(
                  title: 'Buku Kas',
                  value: formattedKas,
                  badgeText: 'Saldo',
                  icon: Icons.account_balance_wallet_rounded,
                  badgeColor: const Color(0xFF059669),
                  subtitle: 'Saldo kas bersih',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaFinanceScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OrmawaKpiCard(
                  title: 'Total Anggota',
                  value: '${ormawa.totalMembers}',
                  badgeText: 'Anggota',
                  icon: Icons.groups_rounded,
                  badgeColor: const Color(0xFF9333EA),
                  subtitle: 'Terverifikasi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaAnggotaScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OrmawaKpiCard(
                  title: 'Agenda Kegiatan',
                  value: '${ormawa.upcomingAgendasCount}',
                  badgeText: 'Jadwal',
                  icon: Icons.event_rounded,
                  badgeColor: const Color(0xFFD97706),
                  subtitle: 'Agenda terdekat',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaKalenderScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
