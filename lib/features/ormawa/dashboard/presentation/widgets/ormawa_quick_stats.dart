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
import 'package:bkuhub_mobile/features/ormawa/pagu/presentation/pages/ormawa_pagu_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_kalender_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/aspirasi/presentation/pages/ormawa_aspirasi_screen.dart';

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

    final canViewProposals = ormawa.hasPermission('ormawa.proposals.view, view_proposal');
    final canViewFinance = ormawa.hasPermission('ormawa.finance.view, view_finance');

    final formattedKas = NumberFormat.compactCurrency(
      symbol: 'Rp ',
      locale: 'id_ID',
      decimalDigits: 1,
    ).format(ormawa.balance);

    Widget card1;
    Widget card2;
    Widget card3;
    Widget card4;

    if (canViewFinance && !canViewProposals) {
      card1 = OrmawaKpiCard(
        title: 'Buku Kas',
        value: formattedKas,
        badgeText: 'Saldo',
        icon: Icons.account_balance_wallet_rounded,
        badgeColor: const Color(0xFF059669),
        subtitle: 'Saldo kas bersih',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaFinanceScreen()),
        ),
      );

      card2 = OrmawaKpiCard(
        title: 'Pagu Anggaran',
        value: ormawa.financialSetting != null ? 'Rp ${NumberFormat.compact(locale: "id_ID").format(ormawa.financialSetting!.budgetLimit)}' : 'Aktif',
        badgeText: 'Pagu',
        icon: Icons.savings_rounded,
        badgeColor: const Color(0xFF0284C7),
        subtitle: 'Alokasi dana',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaPaguScreen()),
        ),
      );

      card3 = OrmawaKpiCard(
        title: 'LPJ Keuangan',
        value: '${ormawa.lpjs.length}',
        badgeText: 'Laporan',
        icon: Icons.description_rounded,
        badgeColor: const Color(0xFFE11D48),
        subtitle: 'Pertanggungjawaban',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaLpjScreen()),
        ),
      );

      card4 = OrmawaKpiCard(
        title: 'Agenda Terdekat',
        value: '${ormawa.upcomingAgendasCount}',
        badgeText: 'Jadwal',
        icon: Icons.event_rounded,
        badgeColor: const Color(0xFF6366F1),
        subtitle: 'Kegiatan proker',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaKalenderScreen()),
        ),
      );
    } else if (canViewProposals && !canViewFinance) {
      card1 = OrmawaKpiCard(
        title: 'Proposal Proker',
        value: '${ormawa.activeProposalsCount}',
        badgeText: '${ormawa.approvalRate}% Acc',
        icon: Icons.description_rounded,
        badgeColor: const Color(0xFF0284C7),
        subtitle: 'Pengajuan aktif',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaProposalScreen()),
        ),
      );

      card2 = OrmawaKpiCard(
        title: 'LPJ Kegiatan',
        value: '${ormawa.lpjs.length}',
        badgeText: 'Laporan',
        icon: Icons.assignment_turned_in_rounded,
        badgeColor: const Color(0xFFE11D48),
        subtitle: 'Pertanggungjawaban',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaLpjScreen()),
        ),
      );

      card3 = OrmawaKpiCard(
        title: 'Total Anggota',
        value: '${ormawa.totalMembers}',
        badgeText: 'Anggota',
        icon: Icons.groups_rounded,
        badgeColor: const Color(0xFF9333EA),
        subtitle: 'Terverifikasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaAnggotaScreen()),
        ),
      );

      card4 = OrmawaKpiCard(
        title: 'Agenda Kegiatan',
        value: '${ormawa.upcomingAgendasCount}',
        badgeText: 'Jadwal',
        icon: Icons.event_rounded,
        badgeColor: const Color(0xFF6366F1),
        subtitle: 'Agenda terdekat',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaKalenderScreen()),
        ),
      );
    } else if (canViewProposals && canViewFinance) {
      card1 = OrmawaKpiCard(
        title: 'Proposal Proker',
        value: '${ormawa.activeProposalsCount}',
        badgeText: '${ormawa.approvalRate}% Acc',
        icon: Icons.description_rounded,
        badgeColor: const Color(0xFF0284C7),
        subtitle: 'Pengajuan aktif',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaProposalScreen()),
        ),
      );

      card2 = OrmawaKpiCard(
        title: 'Buku Kas',
        value: formattedKas,
        badgeText: 'Saldo',
        icon: Icons.account_balance_wallet_rounded,
        badgeColor: const Color(0xFF059669),
        subtitle: 'Saldo kas bersih',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaFinanceScreen()),
        ),
      );

      card3 = OrmawaKpiCard(
        title: 'Total Anggota',
        value: '${ormawa.totalMembers}',
        badgeText: 'Anggota',
        icon: Icons.groups_rounded,
        badgeColor: const Color(0xFF9333EA),
        subtitle: 'Terverifikasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaAnggotaScreen()),
        ),
      );

      card4 = OrmawaKpiCard(
        title: 'Agenda Kegiatan',
        value: '${ormawa.upcomingAgendasCount}',
        badgeText: 'Jadwal',
        icon: Icons.event_rounded,
        badgeColor: const Color(0xFF6366F1),
        subtitle: 'Agenda terdekat',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaKalenderScreen()),
        ),
      );
    } else {
      card1 = OrmawaKpiCard(
        title: 'Sesi Presensi',
        value: '${ormawa.absensiManagementList.length}',
        badgeText: 'QR Code',
        icon: Icons.qr_code_scanner_rounded,
        badgeColor: const Color(0xFF0D9488),
        subtitle: 'Presensi kegiatan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaAbsensiScreen()),
        ),
      );

      card2 = OrmawaKpiCard(
        title: 'Agenda Kegiatan',
        value: '${ormawa.upcomingAgendasCount}',
        badgeText: 'Jadwal',
        icon: Icons.event_rounded,
        badgeColor: const Color(0xFF6366F1),
        subtitle: 'Agenda terdekat',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaKalenderScreen()),
        ),
      );

      card3 = OrmawaKpiCard(
        title: 'Aspirasi Masuk',
        value: '${ormawa.aspirations.length}',
        badgeText: 'Suara',
        icon: Icons.chat_bubble_outline_rounded,
        badgeColor: const Color(0xFFF43F5E),
        subtitle: 'Kotak aspirasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrmawaAspirasiScreen()),
        ),
      );

      card4 = OrmawaKpiCard(
        title: 'Poin Organisasi',
        value: '${ormawa.gamifikasiPoin}',
        badgeText: 'Poin',
        icon: Icons.emoji_events_rounded,
        badgeColor: const Color(0xFF7C3AED),
        subtitle: 'Peringkat #${ormawa.gamifikasiPeringkat}',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 8),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 8),
              Expanded(child: card4),
            ],
          ),
        ],
      ),
    );
  }
}
