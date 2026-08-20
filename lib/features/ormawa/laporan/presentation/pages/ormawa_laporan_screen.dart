import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_lpj.dart';
import 'package:go_router/go_router.dart';

class OrmawaLaporanScreen extends StatefulWidget {
  const OrmawaLaporanScreen({super.key});

  @override
  State<OrmawaLaporanScreen> createState() => _OrmawaLaporanScreenState();
}

class _OrmawaLaporanScreenState extends State<OrmawaLaporanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  final List<String> _statusOptions = [
    'Semua',
    'Diajukan',
    'Revisi',
    'Disetujui',
  ];

  @override
  void initState() {
    super.initState();
    final ormawaProvider = context.read<OrmawaProvider>();
    Future.microtask(() => ormawaProvider.refreshData());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final canCreateLPJ = ormawaProvider.hasPermission('ormawa.lpj.create, create_lpj');

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: OrmawaTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            const BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Laporan & LPJ',
              subtitle: 'Dokumentasi Kegiatan',
              expandedHeight: 125.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInAnimation(
                      delay: 0.1,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF94A3B8).withAlpha(20),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pusat Eksekutif &',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Laporan & Dokumentasi',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: OrmawaTheme.primarySoft,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: OrmawaTheme.primaryBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.assessment_rounded, size: 14, color: OrmawaTheme.primary),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Laporan Ormawa',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ringkasan eksekutif kegiatan, realisasi penggunaan dana anggaran, dan rekapitulasi kinerja ormawa.',
                              style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.read<OrmawaProvider>().refreshData(),
                                    icon: const Icon(Icons.refresh_rounded, size: 14),
                                    label: const Text('Refresh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: OrmawaTheme.textHeading,
                                      side: BorderSide(color: OrmawaTheme.border),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                if (canCreateLPJ) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showAddLaporan(context),
                                      icon: const Icon(Icons.add_rounded, size: 15),
                                      label: const Text('Buat LPJ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: OrmawaTheme.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSummaryGrid(),
                    const SizedBox(height: AppSpacing.xxl),
                    OrmawaListHeader(
                      title: 'Daftar Lpj Kegiatan',
                      searchHint: 'Cari judul laporan kegiatan...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: () => _showFilterSheet(),
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildLaporanList(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final lpjs = provider.lpjs;
        final totalLPJ = lpjs.length;
        final approvedLPJ =
            lpjs
                .where((e) => e.status == 'disetujui' || e.status == 'selesai')
                .length;
        final pendingLPJ =
            lpjs
                .where((e) => e.status == 'diajukan' || e.status == 'revisi')
                .length;
        final totalRealisasi = lpjs.fold<double>(
          0,
          (sum, item) => sum + item.realisasiAnggaran,
        );
        final totalSavings = lpjs.fold<double>(0, (sum, item) {
          final diff = item.totalAnggaran - item.realisasiAnggaran;
          return diff > 0 ? sum + diff : sum;
        });

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Laporan',
                    totalLPJ.toString(),
                    Icons.description_rounded,
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'LPJ Disetujui',
                    approvedLPJ.toString(),
                    Icons.verified_rounded,
                    context.appColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Diajukan & Revisi',
                    pendingLPJ.toString(),
                    Icons.pending_actions_rounded,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Realisasi Anggaran',
                    NumberFormat.compactCurrency(
                      locale: 'id',
                      symbol: 'Rp ',
                    ).format(totalRealisasi),
                    Icons.payments_rounded,
                    context.appColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatCard(
              'Sisa Saldo Efisiensi',
              NumberFormat.compactCurrency(
                locale: 'id',
                symbol: 'Rp ',
              ).format(totalSavings),
              Icons.savings_rounded,
              AppColors.success,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (isFullWidth) ...[
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.neutral900,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.padding6,
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Icon(icon, color: color, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    value,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.neutral900,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.neutral600;
      case 'diajukan':
        return context.appColors.info;
      case 'disetujui':
        return AppColors.success;
      case 'revisi':
        return AppColors.warning;
      case 'ditolak':
        return AppColors.error;
      case 'selesai':
        return context.appColors.info;
      default:
        return AppColors.neutral600;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'diajukan':
        return 'DIAJUKAN';
      case 'disetujui':
        return 'DISETUJUI';
      case 'revisi':
        return 'BUTUH REVISI';
      case 'ditolak':
        return 'DITOLAK';
      case 'selesai':
        return 'SELESAI';
      default:
        return status;
    }
  }

  Widget _buildEfficiencyRow(OrmawaLPJ report) {
    final diff = report.totalAnggaran - report.realisasiAnggaran;
    final pct =
        report.totalAnggaran > 0
            ? ((diff / report.totalAnggaran) * 100).round()
            : 0;

    final currencyFormatter = NumberFormat.compactCurrency(
      locale: 'id',
      symbol: 'Rp ',
    );

    if (diff > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.success,
              size: 14,
            ),
            const SizedBox(width: AppSpacing.s6),
            Flexible(
              child: Text(
                'HEMAT $pct% (+${currencyFormatter.format(diff)})',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSuccessContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (diff < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.dangerContainer,
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 14,
            ),
            const SizedBox(width: AppSpacing.s6),
            Flexible(
              child: Text(
                'OVER ${pct.abs()}% (-${currencyFormatter.format(diff.abs())})',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.labelSm.copyWith(
                   color: AppColors.onDangerContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gps_fixed_rounded, color: AppColors.neutral500, size: 14),
            const SizedBox(width: AppSpacing.s6),
            Flexible(
              child: Text(
                '100% EFISIEN',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: const Text(
              'Hapus Laporan LPJ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus data Laporan Pertanggungjawaban ini? Tindakan ini bersifat permanen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  try {
                    await context.read<OrmawaProvider>().deleteLPJ(id);
                    if (mounted) {
                      AppSnackbar.showError(
                        context,
                        'LPJ berhasil dihapus dari sistem',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      AppSnackbar.showError(context, 'Gagal menghapus LPJ: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 0,
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildLaporanList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final reports =
            provider.lpjs.where((lpj) {
              final matchesSearch = lpj.judul.toLowerCase().contains(
                _searchQuery,
              );
              final matchesFilter =
                  _filterStatus == 'Semua' ||
                  lpj.status.toLowerCase() == _filterStatus.toLowerCase();
              return matchesSearch && matchesFilter;
            }).toList();

        if (reports.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: AppColors.neutral500.withAlpha(50),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Belum ada laporan kegiatan',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final report = reports[index];
            final statusColor = _getStatusColor(report.status);

            return _buildLaporanCard(report, statusColor);
          },
        );
      },
    );
  }

  Widget _buildLaporanCard(OrmawaLPJ report, Color color) {
    Widget? tenggatWidget;
    if (report.tenggatLpj != null) {
      final tenggat = report.tenggatLpj!;
      final now = DateTime.now();
      final diffDays = (tenggat.difference(now).inHours / 24).ceil();
      final isLate = diffDays < 0;
      final isUrgent = diffDays >= 0 && diffDays <= 3;

      tenggatWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 13,
            color:
                isLate
                    ? AppColors.error
                    : (isUrgent ? AppColors.warning : AppColors.neutral600),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isLate
                ? 'Telat ${diffDays.abs()} hr'
                : (isUrgent ? 'Sisa $diffDays hr' : '$diffDays hr lagi'),
            style: AppTextStyles.labelSm.copyWith(
              color:
                  isLate
                       ? AppColors.onDangerContainer
                       : (isUrgent
                           ? AppColors.onWarningContainer
                          : AppColors.neutral600),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(10),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  _getStatusLabel(report.status),
                  style: AppTextStyles.labelSm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
              if (tenggatWidget != null) tenggatWidget,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            report.judul,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          if (report.proposalTitle != null &&
              report.proposalTitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s2),
            Text(
              report.proposalTitle!,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANGGARAN',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(report.totalAnggaran),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REALISASI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(report.realisasiAnggaran),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: OrmawaTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildEfficiencyRow(report)),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    Icons.visibility_outlined,
                    AppColors.info,
                    () => _showLaporanDetail(context, report),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildIconButton(
                    Icons.edit_outlined,
                    AppColors.warning,
                    () => _showEditLaporan(context, report),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildIconButton(
                    Icons.delete_outline_rounded,
                    AppColors.error,
                    () => _showDeleteConfirmation(report.id),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showLaporanDetail(BuildContext context, OrmawaLPJ report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (_, scrollController) {
              final double total = report.totalAnggaran;
              final double real = report.realisasiAnggaran;
              final int pct = total > 0 ? ((real / total) * 100).round() : 0;
              final double ratio =
                  total > 0 ? (real / total).clamp(0.0, 1.0) : 0.0;
              final diff = total - real;
              final isOver = real > total;

              return Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: AppRadius.radiusXs,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'DETAIL LAPORAN',
                      style: AppTextStyles.labelSm.copyWith(
                        color: OrmawaTheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      report.judul,
                      style: AppTextStyles.titleLg.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (report.proposalTitle != null &&
                        report.proposalTitle!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        report.proposalTitle!,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _buildDetailItem(
                      'Status',
                      _getStatusLabel(report.status),
                      Icons.info_outline_rounded,
                    ),
                    _buildDetailItem(
                      'Anggaran Terencana',
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(report.totalAnggaran),
                      Icons.account_balance_wallet_outlined,
                    ),
                    _buildDetailItem(
                      'Realisasi Anggaran',
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(report.realisasiAnggaran),
                      Icons.payments_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusXl,
                        border: Border.all(color: AppColors.neutral300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANALISIS PENYERAPAN ANGGARAN',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Penyerapan Anggaran',
                                style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.bold,
                                   color: AppColors.neutral800,
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color:
                                       isOver
                                           ? AppColors.onDangerContainer
                                           : AppColors.onSuccessContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: AppRadius.radiusMd,
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: AppColors.neutral300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOver ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Row(
                            children: [
                              Icon(
                                isOver
                                    ? Icons.warning_amber_rounded
                                    : Icons.lightbulb_outline_rounded,
                                size: 14,
                                color:
                                    isOver
                                        ? AppColors.error
                                        : AppColors.success,
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Expanded(
                                child: Text(
                                  isOver
                                      ? 'BENGKAK ${pct - 100}% DARI PAGU ANGGARAN'
                                      : 'EFISIEN / SISA: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(diff)} (${100 - pct}% Hemat)',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        isOver
                                            ? AppColors.onErrorContainer
                                            : AppColors.onSuccessContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'CATATAN & EVALUASI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(color: AppColors.neutral300),
                      ),
                      child: Text(
                        report.catatan.isEmpty
                            ? 'Tidak ada catatan evaluasi.'
                            : report.catatan,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (report.fileUrl != null &&
                        report.fileUrl!.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(report.fileUrl!);
                            try {
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } else {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackbar.showError(
                                  context,
                                  'Tidak dapat membuka file',
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.file_download_rounded,
                            color: context.appColors.onPrimary,
                          ),
                          label: Text(
                            'UNDUH DOKUMEN LPJ',
                            style: TextStyle(
                              color: context.appColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s20),
                    if (report.status == 'draft' ||
                        report.status == 'revisi') ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.pop();
                                  _showEditLaporan(context, report);
                                },

                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.warning,
                                ),
                                label: const Text(
                                  'EDIT LPJ',
                                  style: TextStyle(
                                    color: AppColors.neutral700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  context.pop();
                                  try {
                                    final provider =
                                        context.read<OrmawaProvider>();
                                    final payload = {
                                      'Judul': report.judul,
                                      'RealisasiAnggaran':
                                          report.realisasiAnggaran,
                                      'TotalAnggaran': report.totalAnggaran,
                                      'Catatan': report.catatan,
                                      'Status': 'diajukan',
                                    };
                                    await provider.updateLPJ(
                                      report.id,
                                      payload,
                                    );
                                    if (context.mounted) {
                                      AppSnackbar.showSuccess(
                                        context,
                                        'LPJ berhasil dikirim ke kampus',
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      AppSnackbar.showError(
                                        context,
                                        'Gagal mengirim LPJ: $e',
                                      );
                                    }
                                  }
                                },

                                icon: Icon(
                                  Icons.send_rounded,
                                  color: context.appColors.onPrimary,
                                ),
                                label: Text(
                                  'KIRIM LPJ',
                                  style: TextStyle(
                                    color: context.appColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.pop();
                            _showEditLaporan(context, report);
                          },

                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.warning,
                          ),
                          label: const Text(
                            'EDIT LAPORAN LPJ',
                            style: TextStyle(
                              color: AppColors.neutral700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: AppColors.neutral600, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditLaporan(BuildContext context, OrmawaLPJ report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrmawaEditLaporanScreen(report: report),
      ),
    );
  }

  void _showAddLaporan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrmawaCreateLaporanScreen(),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Filter Status',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _statusOptions.map((option) {
                        final isSelected = _filterStatus == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _filterStatus = option);
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? OrmawaTheme.primary : OrmawaTheme.primarySoft,
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              option,
                              style: AppTextStyles.labelSm.copyWith(
                                color: isSelected ? Colors.white : OrmawaTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (_filterStatus != 'Semua')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: TextButton(
                      onPressed: () {
                        setState(() => _filterStatus = 'Semua');
                        context.pop();
                      },
                      child: Text(
                        'Reset Filter',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
    );
  }
}

class OrmawaEditLaporanScreen extends StatefulWidget {
  final OrmawaLPJ report;
  const OrmawaEditLaporanScreen({super.key, required this.report});

  @override
  State<OrmawaEditLaporanScreen> createState() =>
      _OrmawaEditLaporanScreenState();
}

class _OrmawaEditLaporanScreenState extends State<OrmawaEditLaporanScreen> {
  late TextEditingController _judulController;
  late TextEditingController _realisasiController;
  late TextEditingController _totalAnggaranController;
  late TextEditingController _catatanController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.report.judul);
    _realisasiController = TextEditingController(
      text: _formatNumber(widget.report.realisasiAnggaran.toStringAsFixed(0)),
    );
    _totalAnggaranController = TextEditingController(
      text: _formatNumber(widget.report.totalAnggaran.toStringAsFixed(0)),
    );
    _catatanController = TextEditingController(text: widget.report.catatan);

    _totalAnggaranController.addListener(() => setState(() {}));
    _realisasiController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _judulController.dispose();
    _realisasiController.dispose();
    _totalAnggaranController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _updateLPJ(String status) async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Masukkan judul laporan terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<OrmawaProvider>();
      final payload = {
        'Judul': _judulController.text.trim(),
        'RealisasiAnggaran':
            double.tryParse(_realisasiController.text.replaceAll('.', '')) ??
            0.0,
        'TotalAnggaran':
            double.tryParse(
              _totalAnggaranController.text.replaceAll('.', ''),
            ) ??
            0.0,
        'Catatan': _catatanController.text,
        'Status': status,
      };

      await provider.updateLPJ(widget.report.id, payload);
      if (mounted) {
        context.pop();
        AppSnackbar.showSuccess(context, 'LPJ berhasil diperbarui');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memperbarui LPJ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Edit Laporan',
            subtitle: 'Documentation Hub',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Laporan Pertanggungjawaban',
                    style: AppTextStyles.titleLg.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (widget.report.proposalTitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Proposal: ${widget.report.proposalTitle}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  _buildInputField(
                    'JUDUL LAPORAN LPJ',
                    'Misal: LPJ Seminar Kepemimpinan Mahasiswa 2026...',
                    Icons.title_rounded,
                    controller: _judulController,
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _buildInputField(
                    'TOTAL ANGGARAN (PLANNED)',
                    'Contoh: 25000000',
                    Icons.account_balance_wallet_rounded,
                    controller: _totalAnggaranController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    prefixText: 'Rp ',
                  ),
                  if (_totalAnggaranController.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s6),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        'Format: ${currencyFormatter.format(double.tryParse(_totalAnggaranController.text.replaceAll('.', '')) ?? 0.0)}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onInfoContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s20),
                  _buildInputField(
                    'REALISASI ANGGARAN (ACTUAL)',
                    'Contoh: 24500000',
                    Icons.payments_rounded,
                    controller: _realisasiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    prefixText: 'Rp ',
                  ),
                  if (_realisasiController.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s6),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        'Format: ${currencyFormatter.format(double.tryParse(_realisasiController.text.replaceAll('.', '')) ?? 0.0)}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSuccessContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s20),
                  _buildInputField(
                    'CATATAN & EVALUASI',
                    'Tuliskan evaluasi dan catatan kegiatan...',
                    Icons.rate_review_rounded,
                    controller: _catatanController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  if (_isSubmitting)
                    const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
                  else if (widget.report.status == 'draft' ||
                      widget.report.status == 'revisi')
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () => _updateLPJ('draft'),

                              icon: const Icon(
                                Icons.drafts_rounded,
                                color: AppColors.neutral600,
                              ),
                              label: const Text(
                                'SIMPAN DRAFT',
                                style: TextStyle(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _updateLPJ('diajukan'),

                              icon: Icon(
                                Icons.send_rounded,
                                color: context.appColors.onPrimary,
                              ),
                              label: Text(
                                'KIRIM LAPORAN',
                                style: TextStyle(
                                  color: context.appColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateLPJ(widget.report.status),
                        icon: Icon(
                          Icons.save_rounded,
                          color: context.appColors.onPrimary,
                        ),
                        label: Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(
                            color: context.appColors.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > AppSpacing.s1 ? AppSpacing.md : 0),
                child: Icon(icon, color: AppColors.neutral500, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BkuTextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                    prefixText: prefixText,
                    prefixStyle: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.onSurface,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrmawaCreateLaporanScreen extends StatefulWidget {
  const OrmawaCreateLaporanScreen({super.key});

  @override
  State<OrmawaCreateLaporanScreen> createState() =>
      _OrmawaCreateLaporanScreenState();
}

class _OrmawaCreateLaporanScreenState extends State<OrmawaCreateLaporanScreen> {
  final _judulController = TextEditingController();
  final _totalAnggaranController = TextEditingController();
  final _realisasiController = TextEditingController();
  final _catatanController = TextEditingController();
  OrmawaProposal? _selectedProposal;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _totalAnggaranController.addListener(() => setState(() {}));
    _realisasiController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _judulController.dispose();
    _totalAnggaranController.dispose();
    _realisasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submitLPJ(String status) async {
    if (_selectedProposal == null) {
      AppSnackbar.showWarning(
        context,
        'Pilih proposal kegiatan terlebih dahulu',
      );
      return;
    }

    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Masukkan judul laporan terlebih dahulu');
      return;
    }

    if (_totalAnggaranController.text.isEmpty) {
      AppSnackbar.showError(context, 'Masukkan total anggaran');
      return;
    }

    if (_realisasiController.text.isEmpty) {
      AppSnackbar.showError(context, 'Masukkan realisasi anggaran');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<OrmawaProvider>();
      final payload = {
        'ProposalID': int.parse(_selectedProposal!.id),
        'Judul': _judulController.text.trim(),
        'TotalAnggaran':
            double.tryParse(
              _totalAnggaranController.text.replaceAll('.', ''),
            ) ??
            0.0,
        'RealisasiAnggaran':
            double.tryParse(_realisasiController.text.replaceAll('.', '')) ??
            0.0,
        'Catatan': _catatanController.text,
        'Status': status,
      };

      await provider.addLPJ(payload);
      if (mounted) {
        context.pop();
        AppSnackbar.showSuccess(context, 'LPJ berhasil diajukan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal mengajukan LPJ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Buat Laporan Baru',
            subtitle: 'Documentation Hub',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: OrmawaTheme.primarySoft,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          Icons.note_add_rounded,
                          color: OrmawaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: AppRadius.radiusXs,
                              ),
                              child: Text(
                                'NEW DOCUMENT',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: OrmawaTheme.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                            Text(
                              'LAPORAN KEGIATAN',
                              style: AppTextStyles.titleLg.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Unggah laporan pertanggungjawaban kegiatan resmi.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  _buildProposalSelector(),
                  if (_selectedProposal != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(10),
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.info.withAlpha(20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.info,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Anggaran Terencana (Pagu): ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_selectedProposal!.budget)}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onInfoContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildInputField(
                      'JUDUL LAPORAN LPJ',
                      'Misal: LPJ Seminar Kepemimpinan Mahasiswa 2026...',
                      Icons.title_rounded,
                      controller: _judulController,
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildInputField(
                      'TOTAL ANGGARAN (PLANNED)',
                      'Contoh: 25000000',
                      Icons.account_balance_wallet_rounded,
                      controller: _totalAnggaranController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      prefixText: 'Rp ',
                    ),
                    if (_totalAnggaranController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s6),
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: Text(
                          'Format: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(_totalAnggaranController.text.replaceAll('.', '')) ?? 0.0)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onInfoContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.s20),
                  _buildInputField(
                    'REALISASI ANGGARAN (ACTUAL)',
                    'Contoh: 24500000',
                    Icons.payments_rounded,
                    controller: _realisasiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    prefixText: 'Rp ',
                  ),
                  if (_realisasiController.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s6),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        'Format: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(_realisasiController.text.replaceAll('.', '')) ?? 0.0)}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSuccessContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s20),
                  _buildInputField(
                    'CATATAN & EVALUASI',
                    'Tuliskan evaluasi dan catatan kegiatan...',
                    Icons.rate_review_rounded,
                    controller: _catatanController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  if (_isSubmitting)
                    const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () => _submitLPJ('draft'),
                              icon: const Icon(
                                Icons.drafts_rounded,
                                color: AppColors.neutral600,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'SIMPAN DRAFT',
                                  style: TextStyle(
                                    color: AppColors.neutral700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _submitLPJ('diajukan'),
                              icon: Icon(
                                Icons.send_rounded,
                                color: context.appColors.onPrimary,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'KIRIM LAPORAN',
                                  style: TextStyle(
                                    color: context.appColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalSelector() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        
        final availableProposals = provider.proposals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PILIH KEGIATAN (PROPOSAL)',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: DropdownButtonHideUnderline(
                child: BkuDropdown<OrmawaProposal>(
                  isExpanded: true,
                  hint: 'Pilih proposal...',
                  disabledHint: Text(
                    'Belum ada proposal disetujui...',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  value: _selectedProposal,
                  items:
                      availableProposals.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.title,
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProposal = val;
                      if (val != null) {
                        _judulController.text = 'LPJ ${val.title}';
                        _totalAnggaranController.text = _formatNumber(
                          val.budget.toStringAsFixed(0),
                        );
                        _realisasiController.text = _formatNumber(
                          val.budget.toStringAsFixed(0),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > AppSpacing.s1 ? AppSpacing.md : 0),
                child: Icon(icon, color: AppColors.neutral500, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: BkuTextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                    prefixText: prefixText,
                    prefixStyle: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.onSurface,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatNumber(String value) {
  String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < cleaned.length; i++) {
    if (i > 0 && (cleaned.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(cleaned[i]);
  }
  return buffer.toString();
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < cleanedText.length; i++) {
      if (i > 0 && (cleanedText.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanedText[i]);
    }

    final newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}