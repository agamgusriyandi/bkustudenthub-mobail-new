import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/create_lpj_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class OrmawaLpjScreen extends StatefulWidget {
  const OrmawaLpjScreen({super.key});

  @override
  State<OrmawaLpjScreen> createState() => _OrmawaLpjScreenState();
}

class _OrmawaLpjScreenState extends State<OrmawaLpjScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      case 'menunggu':
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.neutral500;
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Lpj',
              subtitle: 'Laporan Pertanggungjawaban',
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: AppSpacing.xl),
                    OrmawaListHeader(
                      title: 'Daftar Lpj',
                      searchHint: 'Cari judul LPJ...',
                      searchController: _searchController,
                      onRefresh: () =>
                          context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: _showFilterSheet,
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _buildLpjList(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s100)),
          ],
        ),
      ),
      floatingActionButton: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission('create_lpj')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCreateLpj(),
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Buat LPJ',
              style: TextStyle(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        final lpjs = provider.lpjs;
        final total = lpjs.length;
        final approved = lpjs
            .where((l) =>
                l.status.toLowerCase().contains('disetujui') ||
                l.status.toLowerCase() == 'selesai')
            .length;
        final pending = lpjs
            .where((l) =>
                l.status.toLowerCase().contains('menunggu') ||
                l.status.toLowerCase() == 'pending')
            .length;

        return Row(
          children: [
            _buildStatCard('Total', total.toString(), AppColors.info),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Disetujui', approved.toString(), AppColors.success),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Pending', pending.toString(), AppColors.warning),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.padding6,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(
                label == 'Total'
                    ? Icons.description_rounded
                    : label == 'Disetujui'
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLpjList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        final filteredLpjs = provider.lpjs.where((lpj) {
          final matchesSearch =
              lpj.judul.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus = _selectedStatusFilter == 'Semua' ||
              lpj.status.toLowerCase() ==
                  _selectedStatusFilter.toLowerCase();
          return matchesSearch && matchesStatus;
        }).toList();

        if (filteredLpjs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined, size: 48, color: AppColors.neutral500.withAlpha(50)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _searchQuery.isEmpty && _selectedStatusFilter == 'Semua'
                          ? 'Belum ada LPJ'
                          : 'LPJ tidak ditemukan',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lpj = filteredLpjs[index];
                final statusColor = _getStatusColor(lpj.status);
                return GestureDetector(
                  onTap: () => _showLpjDetail(lpj),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                            Expanded(
                              child: Text(
                                lpj.judul,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(15),
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Text(
                                lpj.status,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (lpj.proposalTitle != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            lpj.proposalTitle!,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                size: 14, color: AppColors.neutral500),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _formatCurrency(lpj.realisasiAnggaran),
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' / ${_formatCurrency(lpj.totalAnggaran)}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filteredLpjs.length,
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Status',
                  style: AppTextStyles.titleLg
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Selesai']
                    .map((s) => GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedStatusFilter = s);
                            setState(() {});
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _selectedStatusFilter == s
                                  ? context.appColors.primary
                                  : AppColors.neutral100,
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              s,
                              style: AppTextStyles.labelSm.copyWith(
                                color: _selectedStatusFilter == s
                                    ? context.appColors.onPrimary
                                    : AppColors.neutral700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateLpj() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLpjScreen(),
      ),
    ).then((_) {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  void _showLpjDetail(dynamic lpj) {
    context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
  }
}
