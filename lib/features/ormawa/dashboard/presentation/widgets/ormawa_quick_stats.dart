import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.75,
          children: const [
            BkuShimmer(
              width: double.infinity,
              height: 75,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 75,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 75,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
            BkuShimmer(
              width: double.infinity,
              height: 75,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final crossAxisCount = isTablet ? 4 : 2;
          final aspectRatio = isTablet ? 2.3 : 1.75;

          return GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspectRatio,
            children: [
              _StatusItem(
                label: 'Proposal',
                value: '${ormawa.activeProposalsCount} Proker',
                subValue: '${ormawa.approvalRate}% Approved',
                icon: Icons.description_rounded,
                color: AppColors.serviceSky,
                target: const OrmawaProposalScreen(),
              ),
              _StatusItem(
                label: 'Buku Kas',
                value: formattedKas,
                subValue: 'Pemasukan Bersih',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.serviceEmerald,
                target: const OrmawaFinanceScreen(),
              ),
              _StatusItem(
                label: 'Anggota',
                value: '${ormawa.totalMembers} Orang',
                subValue: 'Terverifikasi',
                icon: Icons.groups_rounded,
                color: AppColors.servicePurple,
                target: const OrmawaAnggotaScreen(),
              ),
              _StatusItem(
                label: 'Kegiatan',
                value: '${ormawa.upcomingAgendasCount} Agenda',
                subValue: 'Jadwal Dekat',
                icon: Icons.event_rounded,
                color: AppColors.serviceAmber,
                target: const OrmawaKalenderScreen(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;
  final Widget target;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      borderRadius: AppRadius.radius20,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.br2,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subValue,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: context.appColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
