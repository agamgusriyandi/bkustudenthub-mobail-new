import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';

class OrmawaLpjPipelineScreen extends StatefulWidget {
  const OrmawaLpjPipelineScreen({super.key});

  @override
  State<OrmawaLpjPipelineScreen> createState() =>
      _OrmawaLpjPipelineScreenState();
}

class _OrmawaLpjPipelineScreenState extends State<OrmawaLpjPipelineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  static const List<String> _statusOptions = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak',
    'Selesai',
  ];

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

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('setuju')) return 'Disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'Ditolak';
    if (s.contains('selesai')) return 'Selesai';
    if (s.contains('menunggu') || s.contains('pending')) return 'Menunggu';
    return status;
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allLpjs = ormawaProvider.lpjs;

    final filteredLpjs = allLpjs.where((lpj) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          lpj.judul.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'Semua' ||
          _normalizeStatus(lpj.status) == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'Pipeline Lpj',
              subtitle: 'Antrian Review Lpj',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _buildPipelineStats(allLpjs),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: OrmawaListHeader(
                      title: 'ANTRIAN LPJ (${filteredLpjs.length})',
                      searchHint: 'Cari judul LPJ...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: _showFilterSheet,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (filteredLpjs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxxl,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 60,
                              color: AppColors.neutral400.withAlpha(80),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Tidak ada LPJ',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: context.appColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildPipelineItem(filteredLpjs[index], index),
                  childCount: filteredLpjs.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s150)),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStats(List<dynamic> lpjs) {
    final menunggu =
        lpjs.where((l) => _normalizeStatus(l.status) == 'Menunggu').length;
    final disetujui =
        lpjs.where((l) => _normalizeStatus(l.status) == 'Disetujui').length;
    final ditolak =
        lpjs.where((l) => _normalizeStatus(l.status) == 'Ditolak').length;
    final selesai =
        lpjs.where((l) => _normalizeStatus(l.status) == 'Selesai').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(8),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatMetric(
              'Menunggu',
              menunggu.toString(),
              AppColors.warning,
              Icons.schedule_rounded,
            ),
            _buildMetricDivider(),
            _buildStatMetric(
              'Disetujui',
              disetujui.toString(),
              AppColors.success,
              Icons.check_circle_outline_rounded,
            ),
            _buildMetricDivider(),
            _buildStatMetric(
              'Ditolak',
              ditolak.toString(),
              AppColors.error,
              Icons.cancel_outlined,
            ),
            _buildMetricDivider(),
            _buildStatMetric(
              'Selesai',
              selesai.toString(),
              AppColors.info,
              Icons.task_alt_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1.5,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: AppRadius.radiusXs,
      ),
    );
  }

  Widget _buildStatMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: AppSpacing.s10),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem(dynamic lpj, int index) {
    final statusColor = _getStatusColor(lpj.status);
    final normalizedStatus = _normalizeStatus(lpj.status);

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
      },
      child: BkuCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(
                    _getPipelineIcon(normalizedStatus),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lpj.judul,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (lpj.proposalTitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          lpj.proposalTitle!,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                BkuStatusBadge(
                  status: _mapStatusToBkuStatus(lpj.status),
                  customText: normalizedStatus,
                  showIcon: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(color: AppColors.neutral200, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: AppColors.neutral500,
                    ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(10),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: context.appColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Review',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPipelineIcon(String status) {
    switch (status) {
      case 'Disetujui':
      case 'Selesai':
        return Icons.check_circle_rounded;
      case 'Ditolak':
        return Icons.cancel_rounded;
      default:
        return Icons.folder_open_rounded;
    }
  }

  BkuStatus _mapStatusToBkuStatus(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('setuju') || s.contains('selesai') || s.contains('acc')) {
      return BkuStatus.success;
    } else if (s.contains('tolak') || s.contains('batal')) {
      return BkuStatus.error;
    } else if (s.contains('revisi')) {
      return BkuStatus.warning;
    }
    return BkuStatus.info;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
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
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStatus = status);
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.appColors.primary
                          : context.appColors.primary.withAlpha(10),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected
                            ? context.appColors.onPrimary
                            : context.appColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedStatus != 'Semua')
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: BkuButton.text(
                  text: 'Reset Filter',
                  onPressed: () {
                    setState(() => _selectedStatus = 'Semua');
                    context.pop();
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
