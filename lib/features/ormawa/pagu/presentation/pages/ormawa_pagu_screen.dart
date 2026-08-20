import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_financial_setting.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

String _formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

String _formatDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';
  try {
    final d = DateTime.parse(dateStr).toLocal();
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);
  } catch (_) {
    return dateStr;
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Selamat Pagi';
  if (hour < 15) return 'Selamat Siang';
  if (hour < 18) return 'Selamat Sore';
  return 'Selamat Malam';
}

class OrmawaPaguScreen extends StatefulWidget {
  const OrmawaPaguScreen({super.key});

  @override
  State<OrmawaPaguScreen> createState() => _OrmawaPaguScreenState();
}

class _OrmawaPaguScreenState extends State<OrmawaPaguScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchFinancialSettings();
    });
  }

  void _openConfigModal(BuildContext context, OrmawaFinancialSetting setting) {
    BkuBottomSheet.show(
      context: context,
      title: 'Konfigurasi Pagu Anggaran',
      child: _PaguConfigSheet(setting: setting),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        final setting = provider.financialSetting;
        final auditLogs = provider.auditLogs;
        final isLoading = provider.isLoadingPagu;

        final isOrmawaUser = AuthService().currentRole == UserRole.ormawa || AuthService().currentRole == UserRole.student;
        final canManageFinance = !isOrmawaUser && (
          provider.hasPermission('ormawa.organisasi.manage') ||
          provider.hasPermission('ormawa.pagu.update') ||
          provider.hasPermission('ormawa.pagu.manage') ||
          provider.hasPermission('superadmin.dashboard.view') ||
          provider.hasPermission('kemahasiswaan.manage')
        );

        final limit = setting?.budgetLimit ?? 0.0;
        final used = setting?.usedBudget ?? 0.0;
        final pending = setting?.pendingBudget ?? 0.0;
        final remaining = setting?.remainingBudget ?? 0.0;

        final usedPct = limit > 0 ? (used / limit * 100).clamp(0.0, 100.0) : 0.0;
        final pendingPct = limit > 0 ? (pending / limit * 100).clamp(0.0, 100.0) : 0.0;
        final remainingPct = limit > 0 ? (100.0 - usedPct - pendingPct).clamp(0.0, 100.0) : 0.0;

        final orgName = setting?.name.isNotEmpty == true ? setting!.name : provider.orgName;

        return Scaffold(
          backgroundColor: BkuTheme.scaffoldBg,
          body: RefreshIndicator(
            onRefresh: () => provider.fetchFinancialSettings(),
            color: BkuTheme.primary,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              slivers: [
                const BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Pagu Anggaran',
                  subtitle: 'Sentralisasi Plafon Dana Kampus',
                  expandedHeight: 115.0,
                  showBackButton: true,
                  isExpandable: false,
                ),

                if (isLoading && setting == null)
                  const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 100),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeroBanner(context, orgName, setting, canManageFinance, provider),
                        const SizedBox(height: 14),

                        if (provider.allFinancialSettings.length > 1) ...[
                          _buildOrmawaSelector(context, provider, setting),
                          const SizedBox(height: 14),
                        ],

                        _buildStatsGrid(context, setting, limit, used, pending, remaining, usedPct, pendingPct, remainingPct),
                        const SizedBox(height: 14),

                        _buildAbsorptionCard(context, setting, limit, used, pending, remaining, usedPct, pendingPct, remainingPct),
                        const SizedBox(height: 14),

                        _buildAuditLogsCard(context, auditLogs),
                        const SizedBox(height: 14),

                        _buildSopCard(context),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrmawaSelector(
    BuildContext context,
    OrmawaProvider provider,
    OrmawaFinancialSetting? current,
  ) {
    return BkuCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      onTap: () => _openOrmawaPicker(context, provider),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              borderRadius: BkuTheme.r10,
            ),
            child: Icon(Icons.swap_horiz_rounded, size: 20, color: BkuTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Organisasi Mahasiswa',
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: BkuTheme.textHeading,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  current?.name ?? 'Pilih ORMAWA',
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: BkuTheme.r8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ganti',
                  style: BkuTheme.textCaption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: BkuTheme.textBody,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: BkuTheme.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openOrmawaPicker(BuildContext context, OrmawaProvider provider) {
    BkuBottomSheet.show(
      context: context,
      title: 'Daftar Organisasi Mahasiswa',
      child: _OrmawaPickerSheet(provider: provider),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    String orgName,
    OrmawaFinancialSetting? setting,
    bool canManageFinance,
    OrmawaProvider provider,
  ) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Text(
                    'Sentralisasi Pagu Anggaran',
                    style: BkuTheme.textBadge.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textHeading,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canManageFinance && setting != null) ...[
                    BkuButton.primary(
                      onPressed: () => _openConfigModal(context, setting),
                      icon: Icons.tune_rounded,
                      text: 'Konfigurasi',
                      height: 28,
                      fontSize: 10.5,
                      fullWidth: false,
                      customRadius: BkuTheme.r8,
                    ),
                    const SizedBox(width: 6),
                  ],
                  IconButton(
                    onPressed: () => provider.fetchFinancialSettings(),
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: BkuTheme.textMuted),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    tooltip: 'Perbarui Data',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, size: 20, color: BkuTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_getGreeting()}, ',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
                          ),
                          TextSpan(
                            text: orgName,
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: BkuTheme.textHeading),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pusat kendali pagu anggaran resmi. Pantau alokasi plafon tahunan, serapan dana proposal, dan kuota tersedia secara real-time.',
                      style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    OrmawaFinancialSetting? setting,
    double limit,
    double used,
    double pending,
    double remaining,
    double usedPct,
    double pendingPct,
    double remainingPct,
  ) {
    final year = setting?.fiscalYear ?? DateTime.now().year.toString();
    final isActive = setting?.active ?? true;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Total Pagu Anggaran',
                value: _formatCurrency(limit),
                icon: Icons.account_balance_wallet_rounded,
                badgeColor: BkuTheme.sky,
                subtitle: 'Periode Tahun $year',
                badgeText: isActive ? 'Pagu Aktif' : 'Nonaktif',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Dana Terpakai',
                value: _formatCurrency(used),
                icon: Icons.trending_up_rounded,
                badgeColor: BkuTheme.rose,
                subtitle: 'Proposal & kegiatan disetujui',
                badgeText: '${usedPct.round()}% Serapan',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Dalam Pengajuan',
                value: _formatCurrency(pending),
                icon: Icons.hourglass_top_rounded,
                badgeColor: BkuTheme.amber,
                subtitle: 'Menunggu review/approval',
                badgeText: '${pendingPct.round()}% Kuota',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Sisa Pagu Tersedia',
                value: _formatCurrency(remaining),
                icon: Icons.savings_rounded,
                badgeColor: BkuTheme.emerald,
                subtitle: 'Dapat diajukan proposal baru',
                badgeText: '${remainingPct.round()}% Tersedia',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAbsorptionCard(
    BuildContext context,
    OrmawaFinancialSetting? setting,
    double limit,
    double used,
    double pending,
    double remaining,
    double usedPct,
    double pendingPct,
    double remainingPct,
  ) {
    final year = setting?.fiscalYear ?? DateTime.now().year.toString();
    final isActive = setting?.active ?? true;
    final enforce = setting?.enforceLimit ?? true;

    final totalProcessedPct = (usedPct + pendingPct).round();

    return BkuCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, size: 18, color: BkuTheme.textBody),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status Penyerapan Dana',
                  style: BkuTheme.textSectionTitle.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? BkuTheme.emeraldSoft : BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r8,
                ),
                child: Text(
                  isActive ? 'Pagu Aktif' : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? BkuTheme.emerald : BkuTheme.textMuted,
                  ),
                ),
              ),
              if (enforce) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BkuTheme.indigoSoft,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Text(
                    'Enforced',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: BkuTheme.indigo,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Rincian alokasi kuota anggaran dan realisasi pengajuan proposal tahun fiskal $year.',
            style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Penyerapan Anggaran',
                style: BkuTheme.textCaption.copyWith(fontSize: 10.5, fontWeight: FontWeight.bold, color: BkuTheme.textBody),
              ),
              Text(
                '$totalProcessedPct% Terpakai & Diproses',
                style: BkuTheme.textCardTitle.copyWith(fontSize: 10.5, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (limit > 0)
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BkuTheme.borderSubtle,
                borderRadius: BkuTheme.r8,
                border: Border.all(color: BkuTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  if (usedPct > 0)
                    Flexible(
                      flex: (usedPct * 10).toInt(),
                      child: Container(color: BkuTheme.rose),
                    ),
                  if (pendingPct > 0)
                    Flexible(
                      flex: (pendingPct * 10).toInt(),
                      child: Container(color: BkuTheme.amber),
                    ),
                  if (remainingPct > 0)
                    Flexible(
                      flex: (remainingPct * 10).toInt(),
                      child: Container(color: BkuTheme.emerald),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BkuTheme.amberSoft,
                borderRadius: BkuTheme.r10,
                border: Border.all(color: BkuTheme.amberBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: BkuTheme.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pagu anggaran belum dialokasikan oleh bagian Kemahasiswaan untuk organisasi ini.',
                      style: TextStyle(fontSize: 10, color: BkuTheme.amber, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                  decoration: BoxDecoration(
                    color: BkuTheme.roseSoft,
                    borderRadius: BkuTheme.r10,
                    border: Border.all(color: BkuTheme.roseBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dana Terpakai',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.rose,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(used),
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Disetujui',
                        style: BkuTheme.textCaption.copyWith(fontSize: 8, color: BkuTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                  decoration: BoxDecoration(
                    color: BkuTheme.amberSoft,
                    borderRadius: BkuTheme.r10,
                    border: Border.all(color: BkuTheme.amberBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengajuan',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.amber,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(pending),
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Review',
                        style: BkuTheme.textCaption.copyWith(fontSize: 8, color: BkuTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                  decoration: BoxDecoration(
                    color: BkuTheme.emeraldSoft,
                    borderRadius: BkuTheme.r10,
                    border: Border.all(color: BkuTheme.emeraldBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sisa Kuota',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.emerald,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(remaining),
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tersedia',
                        style: BkuTheme.textCaption.copyWith(fontSize: 8, color: BkuTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsCard(BuildContext context, List<OrmawaFinancialAuditLog> auditLogs) {
    return BkuCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: BkuTheme.textBody),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Riwayat Penyesuaian Pagu',
                  style: BkuTheme.textSectionTitle.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r8,
                ),
                child: Text(
                  '${auditLogs.length} Riwayat',
                  style: BkuTheme.textCaption.copyWith(fontSize: 8.5, fontWeight: FontWeight.bold, color: BkuTheme.textBody),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Log catatan resmi seluruh alokasi dan penyesuaian nominal pagu anggaran.',
            style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
          ),
          const SizedBox(height: 12),

          if (auditLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: BkuTheme.borderSubtle,
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 28, color: BkuTheme.textPlaceholder),
                  const SizedBox(height: 6),
                  Text(
                    'Belum ada catatan riwayat perubahan pagu',
                    style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auditLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = auditLogs[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: BkuTheme.skySoft,
                              borderRadius: BkuTheme.r8,
                              border: Border.all(color: BkuTheme.skyBorder, width: 0.8),
                            ),
                            child: Text(
                              'Tahun ${log.periode}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          Text(
                            _formatDateTime(log.createdAt),
                            style: BkuTheme.textCaption.copyWith(fontSize: 9, color: BkuTheme.textPlaceholder, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alokasi Pagu Baru:',
                            style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatCurrency(log.newValue),
                            style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 12, color: BkuTheme.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.user,
                              style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.textBody),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (log.reason.trim().isNotEmpty && log.reason.trim() != '-') ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '• ${log.reason}',
                                style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSopCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r18,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              borderRadius: BkuTheme.r10,
              border: Border.all(color: BkuTheme.primaryBorder),
            ),
            child: Icon(Icons.info_outline_rounded, size: 18, color: BkuTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketentuan & SOP Pagu Anggaran ORMAWA',
                  style: BkuTheme.textSectionTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pagu anggaran adalah batas maksimal plafon dana kampus yang dapat diajukan oleh organisasi mahasiswa dalam satu periode tahun anggaran. Pengajuan proposal kegiatan dengan sumber dana Pagu Kampus akan otomatis memotong kuota pagu setelah disetujui. Apabila memerlukan penambahan pagu atau penyesuaian kegiatan strategis, silakan mengajukan permohonan resmi kepada Bagian Kemahasiswaan Universitas.',
                  style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaguConfigSheet extends StatefulWidget {
  final OrmawaFinancialSetting setting;

  const _PaguConfigSheet({required this.setting});

  @override
  State<_PaguConfigSheet> createState() => _PaguConfigSheetState();
}

class _PaguConfigSheetState extends State<_PaguConfigSheet> {
  late TextEditingController _budgetController;
  late TextEditingController _yearController;
  late bool _active;
  late bool _enforceLimit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: NumberFormat.decimalPattern('id_ID').format(widget.setting.budgetLimit.toInt()),
    );
    _yearController = TextEditingController(
      text: widget.setting.fiscalYear,
    );
    _active = widget.setting.active;
    _enforceLimit = widget.setting.enforceLimit;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  double get _currentLimit => double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

  void _onBudgetChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      _budgetController.value = const TextEditingValue(text: '0');
      setState(() {});
      return;
    }
    final numVal = int.tryParse(clean) ?? 0;
    final formatted = NumberFormat.decimalPattern('id_ID').format(numVal);
    _budgetController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  void _handleSubmit() {
    final newBudget = _currentLimit;
    final oldBudget = widget.setting.budgetLimit;

    if (newBudget > oldBudget) {
      BkuDialog.show(
        context: context,
        type: BkuDialogType.warning,
        title: 'Konfirmasi Penyesuaian Pagu',
        message: 'Anda akan menaikkan alokasi pagu dari ${_formatCurrency(oldBudget)} menjadi ${_formatCurrency(newBudget)}. Lanjutkan simpan?',
        primaryButtonText: 'Ya, Simpan',
        secondaryButtonText: 'Batal',
        onPrimaryPressed: () {
          Navigator.pop(context);
          _doSave();
        },
        onSecondaryPressed: () => Navigator.pop(context),
      );
    } else {
      _doSave();
    }
  }

  Future<void> _doSave() async {
    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'ormawa_id': widget.setting.ormawaId,
        'budget_limit': _currentLimit,
        'periode': _yearController.text.trim(),
        'is_active': _active,
        'enforce_limit': _enforceLimit,
      };

      await context.read<OrmawaProvider>().updateFinancialSetting(payload);
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.showSuccess(context, 'Pengaturan pagu anggaran berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final used = widget.setting.usedBudget;
    final pending = widget.setting.pendingBudget;
    final simulatedRemaining = (_currentLimit - used - pending).clamp(0.0, double.infinity);
    final isYearLocked = widget.setting.budgetLimit > 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BkuTextField(
            controller: _budgetController,
            label: 'Total Pagu Anggaran (IDR)',
            keyboardType: TextInputType.number,
            onChanged: _onBudgetChanged,
            prefixIcon: Container(
              width: 36,
              alignment: Alignment.center,
              child: const Text('Rp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Alokasi Pagu Baru:', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                    Text(_formatCurrency(_currentLimit), style: BkuTheme.textCardTitle.copyWith(fontSize: 11, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Realisasi Terpakai (Disetujui):', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                    Text(_formatCurrency(used), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: BkuTheme.rose)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Antrean Menunggu Review:', style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted)),
                    Text(_formatCurrency(pending), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: BkuTheme.amber)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sisa Kuota Tersedia:', style: BkuTheme.textCardTitle.copyWith(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    Text(_formatCurrency(simulatedRemaining), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: BkuTheme.emerald)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          BkuTextField(
            controller: _yearController,
            label: 'Periode Tahun (Fiscal Year)',
            readOnly: isYearLocked,
            keyboardType: TextInputType.number,
            prefixIcon: Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: isYearLocked ? BkuTheme.textPlaceholder : BkuTheme.textMuted,
            ),
          ),
          if (isYearLocked) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 12, color: BkuTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tahun fiskal terkunci untuk konsistensi data anggaran tahun berjalan.',
                    style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pagu Aktif', style: BkuTheme.textCardTitle.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Izinkan pengajuan proposal berbasis pagu', style: BkuTheme.textCaption.copyWith(fontSize: 9, color: BkuTheme.textMuted)),
                  ],
                ),
                Switch(
                  value: _active,
                  onChanged: (val) => setState(() => _active = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: BkuTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tegakkan Batas (Enforce)', style: BkuTheme.textCardTitle.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Tolak otomatis proposal melebihi sisa pagu', style: BkuTheme.textCaption.copyWith(fontSize: 9, color: BkuTheme.textMuted)),
                  ],
                ),
                Switch(
                  value: _enforceLimit,
                  onChanged: (val) => setState(() => _enforceLimit = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: BkuTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          BkuButton.primary(
            onPressed: _isSubmitting ? null : _handleSubmit,
            isLoading: _isSubmitting,
            icon: Icons.save_rounded,
            text: 'Simpan Perubahan Pagu',
            height: 46,
          ),
        ],
      ),
    );
  }
}

class _OrmawaPickerSheet extends StatefulWidget {
  final OrmawaProvider provider;

  const _OrmawaPickerSheet({required this.provider});

  @override
  State<_OrmawaPickerSheet> createState() => _OrmawaPickerSheetState();
}

class _OrmawaPickerSheetState extends State<_OrmawaPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.provider.allFinancialSettings;
    final current = widget.provider.financialSetting;

    final filtered = all.where((o) {
      if (_searchTerm.isEmpty) return true;
      final q = _searchTerm.toLowerCase();
      final n = o.name.toLowerCase();
      final c = o.code.toLowerCase();
      return n.contains(q) || c.contains(q);
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BkuTextField(
            controller: _searchController,
            hint: 'Cari nama atau kode ORMAWA...',
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: BkuTheme.textPlaceholder),
            onChanged: (val) => setState(() => _searchTerm = val),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Text(
                        'Tidak ada organisasi mahasiswa yang cocok.',
                        style: TextStyle(fontSize: 12, color: BkuTheme.textPlaceholder),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final isSelected = current?.ormawaId == item.ormawaId;

                      final limit = item.budgetLimit;
                      final used = item.usedBudget;
                      final pending = item.pendingBudget;
                      final rem = item.remainingBudget;

                      final usedPct = limit > 0 ? (used / limit * 100).clamp(0.0, 100.0) : 0.0;
                      final pendingPct = limit > 0 ? (pending / limit * 100).clamp(0.0, 100.0) : 0.0;
                      final remPct = limit > 0 ? (100.0 - usedPct - pendingPct).clamp(0.0, 100.0) : 0.0;

                      return InkWell(
                        onTap: () {
                          widget.provider.selectFinancialOrmawa(item);
                          Navigator.pop(context);
                        },
                        borderRadius: BkuTheme.r12,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? BkuTheme.primarySoft : BkuTheme.cardSurface,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(
                              color: isSelected ? BkuTheme.primary : BkuTheme.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected ? BkuTheme.primary : BkuTheme.borderSubtle,
                                      borderRadius: BkuTheme.r8,
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.code.isNotEmpty
                                            ? item.code.substring(0, item.code.length >= 2 ? 2 : 1).toUpperCase()
                                            : 'OM',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? Colors.white : BkuTheme.textBody,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: BkuTheme.textCardTitle.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? BkuTheme.primaryDark : BkuTheme.textHeading,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Kode: ${item.code.isNotEmpty ? item.code : '-'}',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(limit),
                                        style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                                      ),
                                      Text('Pagu Tahunan', style: BkuTheme.textCaption.copyWith(fontSize: 8.5, color: BkuTheme.textPlaceholder)),
                                    ],
                                  ),
                                ],
                              ),
                              if (limit > 0) ...[
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.borderSubtle,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: Row(
                                    children: [
                                      if (usedPct > 0)
                                        Flexible(
                                          flex: (usedPct * 10).toInt(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: BkuTheme.rose,
                                              borderRadius: BorderRadius.horizontal(
                                                left: const Radius.circular(3),
                                                right: (pendingPct == 0 && remPct == 0) ? const Radius.circular(3) : Radius.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (pendingPct > 0)
                                        Flexible(
                                          flex: (pendingPct * 10).toInt(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: BkuTheme.amber,
                                              borderRadius: (usedPct == 0 && remPct == 0)
                                                  ? const BorderRadius.all(Radius.circular(3))
                                                  : BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                      if (remPct > 0)
                                        Flexible(
                                          flex: (remPct * 10).toInt(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: BkuTheme.emerald,
                                              borderRadius: BorderRadius.horizontal(
                                                left: (usedPct == 0 && pendingPct == 0) ? const Radius.circular(3) : Radius.zero,
                                                right: const Radius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pakai: ${_formatCurrency(used)}', style: TextStyle(fontSize: 8.5, color: BkuTheme.rose, fontWeight: FontWeight.bold)),
                                    Text('Review: ${_formatCurrency(pending)}', style: TextStyle(fontSize: 8.5, color: BkuTheme.amber, fontWeight: FontWeight.bold)),
                                    Text('Sisa: ${_formatCurrency(rem)}', style: TextStyle(fontSize: 8.5, color: BkuTheme.emerald, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
