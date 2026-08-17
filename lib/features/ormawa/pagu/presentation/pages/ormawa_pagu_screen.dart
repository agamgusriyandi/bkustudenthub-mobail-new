import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaguConfigSheet(setting: setting),
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
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchFinancialSettings(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.primary.withAlpha(50)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openOrmawaPicker(context, provider),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.appColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.swap_horiz_rounded, size: 20, color: context.appColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PILIH ORGANISASI MAHASISWA',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current?.name ?? 'Pilih ORMAWA',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
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
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ganti',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOrmawaPicker(BuildContext context, OrmawaProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrmawaPickerSheet(provider: provider),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    String orgName,
    OrmawaFinancialSetting? setting,
    bool canManageFinance,
    OrmawaProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text(
                  'SENTRALISASI PAGU ANGGARAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canManageFinance && setting != null) ...[
                    ElevatedButton.icon(
                      onPressed: () => _openConfigModal(context, setting),
                      icon: const Icon(Icons.tune_rounded, size: 13),
                      label: const Text('Konfigurasi', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  IconButton(
                    onPressed: () => provider.fetchFinancialSettings(),
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    tooltip: 'Perbarui Data',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, size: 20, color: context.appColors.primary),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          TextSpan(
                            text: orgName,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.appColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Pusat kendali pagu anggaran resmi. Pantau alokasi plafon tahunan, serapan dana proposal, dan kuota tersedia secara real-time.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.35),
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
              child: _buildStatCard(
                title: 'Total Pagu Anggaran',
                value: _formatCurrency(limit),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: context.appColors.primary,
                iconBg: context.appColors.primary.withAlpha(18),
                subtitle: 'Periode Tahun $year',
                badgeText: isActive ? 'Pagu Aktif' : 'Nonaktif',
                badgeBg: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                badgeColor: isActive ? const Color(0xFF047857) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Dana Terpakai',
                value: _formatCurrency(used),
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFE11D48),
                iconBg: const Color(0xFFFFF1F2),
                subtitle: 'Proposal & kegiatan disetujui',
                badgeText: '${usedPct.round()}% Serapan',
                badgeBg: const Color(0xFFFFF1F2),
                badgeColor: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Dalam Pengajuan',
                value: _formatCurrency(pending),
                icon: Icons.hourglass_top_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                subtitle: 'Menunggu review/approval',
                badgeText: '${pendingPct.round()}% Kuota',
                badgeBg: const Color(0xFFFEF3C7),
                badgeColor: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Sisa Pagu Tersedia',
                value: _formatCurrency(remaining),
                icon: Icons.savings_rounded,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFECFDF5),
                subtitle: 'Dapat diajukan proposal baru',
                badgeText: '${remainingPct.round()}% Tersedia',
                badgeBg: const Color(0xFFECFDF5),
                badgeColor: const Color(0xFF047857),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'STATUS PENYERAPAN DANA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Pagu Aktif' : 'Nonaktif',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF047857) : const Color(0xFF64748B)),
                ),
              ),
              if (enforce) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Enforced',
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Rincian alokasi kuota anggaran dan realisasi pengajuan proposal tahun fiskal $year.',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tingkat Penyerapan Anggaran',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              Text(
                '$totalProcessedPct% Terpakai & Diproses',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: context.appColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (limit > 0)
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  if (usedPct > 0)
                    Flexible(
                      flex: (usedPct * 10).toInt(),
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (pendingPct > 0)
                    Flexible(
                      flex: (pendingPct * 10).toInt(),
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (remainingPct > 0)
                    Flexible(
                      flex: (remainingPct * 10).toInt(),
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pagu anggaran belum dialokasikan oleh bagian Kemahasiswaan untuk organisasi ini.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFFEF4444)),
                          SizedBox(width: 4),
                          Text('DANA TERPAKAI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF9F1239))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(used),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Proposal disetujui', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFFF59E0B)),
                          SizedBox(width: 4),
                          Text('DALAM PENGAJUAN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF92400E))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(pending),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Menunggu review', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text('SISA KUOTA', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF065F46))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(remaining),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Siap diajukan', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'RIWAYAT PENYESUAIAN PAGU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${auditLogs.length} Riwayat',
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Log catatan resmi seluruh alokasi dan penyesuaian nominal pagu anggaran.',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          if (auditLogs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Column(
                children: [
                  Icon(Icons.history_edu_rounded, size: 36, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 6),
                  Text(
                    'Belum ada catatan riwayat perubahan pagu',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Setiap perubahan alokasi oleh kemahasiswaan akan tercatat di sini.',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
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
              itemBuilder: (ctx, i) {
                final log = auditLogs[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: context.appColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Tahun ${log.periode}',
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: context.appColors.primary),
                            ),
                          ),
                          Text(
                            _formatDateTime(log.createdAt),
                            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Alokasi Pagu Baru:',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatCurrency(log.newValue),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            log.user,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '• ${log.reason}',
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(Icons.info_outline_rounded, size: 18, color: context.appColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketentuan & SOP Pagu Anggaran ORMAWA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  'Pagu anggaran adalah batas maksimal plafon dana kampus yang dapat diajukan oleh organisasi mahasiswa dalam satu periode tahun anggaran. Pengajuan proposal kegiatan dengan sumber dana Pagu Kampus akan otomatis memotong kuota pagu setelah disetujui. Apabila memerlukan penambahan pagu atau penyesuaian kegiatan strategis, silakan mengajukan permohonan resmi kepada Bagian Kemahasiswaan Universitas.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.4),
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
      text: widget.setting.budgetLimit.toInt().toString(),
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded, size: 20, color: context.appColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konfigurasi Pagu Anggaran',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'PENYESUAIAN KUOTA PLAFON DANA KAMPUS',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pagu Anggaran (IDR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 36,
                          alignment: Alignment.center,
                          child: Text('Rp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: context.appColors.primary)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Alokasi Pagu Baru:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              Text(_formatCurrency(_currentLimit), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Realisasi Terpakai (Disetujui):', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              Text(_formatCurrency(used), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Antrean Menunggu Review:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              Text(_formatCurrency(pending), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            ],
                          ),
                          const Divider(height: 12, color: Color(0xFFCBD5E1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sisa Kuota Tersedia:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text(_formatCurrency(simulatedRemaining), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Periode Tahun (Fiscal Year)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pagu Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text('Izinkan pengajuan proposal berbasis pagu', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            ],
                          ),
                          Switch(
                            value: _active,
                            onChanged: (val) => setState(() => _active = val),
                            activeThumbColor: Colors.white,
                            activeTrackColor: context.appColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tegakkan Batas (Enforce)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Text('Tolak otomatis proposal melebihi sisa pagu', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            ],
                          ),
                          Switch(
                            value: _enforceLimit,
                            onChanged: (val) => setState(() => _enforceLimit = val),
                            activeThumbColor: Colors.white,
                            activeTrackColor: context.appColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded, size: 16),
                        label: const Text('Simpan Perubahan Pagu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.groups_rounded, size: 18, color: context.appColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Organisasi Mahasiswa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${filtered.length} / ${all.length} Organisasi',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchTerm = val),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode ORMAWA...',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.appColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'Tidak ada organisasi mahasiswa yang cocok.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? context.appColors.primary.withAlpha(12) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? context.appColors.primary : const Color(0xFFE2E8F0),
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
                                      color: isSelected ? context.appColors.primary : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.code.isNotEmpty
                                            ? item.code.substring(0, item.code.length >= 2 ? 2 : 1).toUpperCase()
                                            : 'OM',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? Colors.white : const Color(0xFF475569),
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
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? context.appColors.primary : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Kode: ${item.code.isNotEmpty ? item.code : '-'}',
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(limit),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                      ),
                                      const Text('Pagu Tahunan', style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ],
                              ),
                              if (limit > 0) ...[
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    children: [
                                      if (usedPct > 0)
                                        Flexible(
                                          flex: (usedPct * 10).toInt(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF43F5E),
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
                                              color: const Color(0xFFF59E0B),
                                              borderRadius: (usedPct == 0 && remPct == 0)
                                                  ? BorderRadius.circular(3)
                                                  : BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                      if (remPct > 0)
                                        Flexible(
                                          flex: (remPct * 10).toInt(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981),
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
                                    Text('Pakai: ${_formatCurrency(used)}', style: const TextStyle(fontSize: 8.5, color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
                                    Text('Review: ${_formatCurrency(pending)}', style: const TextStyle(fontSize: 8.5, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                                    Text('Sisa: ${_formatCurrency(rem)}', style: const TextStyle(fontSize: 8.5, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
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

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}

