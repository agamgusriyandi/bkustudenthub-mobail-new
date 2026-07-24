import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class OrmawaQuickStats extends StatelessWidget {
  const OrmawaQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();

    if (ormawa.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: const BkuShimmer(
          width: double.infinity,
          height: 180,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.description_rounded,
                  title: 'Proposal Aktif',
                  value: ormawa.activeProposalsCount.toString(),
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.info.withAlpha(15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.people_rounded,
                  title: 'Total Anggota',
                  value: ormawa.totalMembers.toString(),
                  iconColor: Colors.purple,
                  iconBgColor: Colors.purple.withAlpha(15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.checklist_rounded,
                  title: 'Approval Rate',
                  value: '${ormawa.approvalRate}%',
                  iconColor: Colors.teal,
                  iconBgColor: Colors.teal.withAlpha(15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.event_rounded,
                  title: 'Agenda Dekat',
                  value: ormawa.upcomingAgendasCount.toString(),
                  iconColor: Colors.indigo,
                  iconBgColor: Colors.indigo.withAlpha(15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Kas Organisasi',
            value: NumberFormat.compactCurrency(
              symbol: 'Rp',
              locale: 'id_ID',
              decimalDigits: 1,
            ).format(ormawa.balance),
            iconColor: AppColors.success,
            iconBgColor: AppColors.success.withAlpha(15),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
    bool isFullWidth = false,
  }) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isFullWidth ? 22 : 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
