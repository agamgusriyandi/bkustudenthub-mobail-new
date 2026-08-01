import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrmawaProposalPipelineScreen extends StatefulWidget {
  const OrmawaProposalPipelineScreen({super.key});

  @override
  State<OrmawaProposalPipelineScreen> createState() =>
      _OrmawaProposalPipelineScreenState();
}

class _OrmawaProposalPipelineScreenState
    extends State<OrmawaProposalPipelineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  static const List<String> _statusOptions = [
    'Semua',
    'Diajukan',
    'Diproses',
    'Disetujui',
    'Ditolak',
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

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('setuju')) return 'Disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'Ditolak';
    if (s.contains('diajukan') || s.contains('proses')) return 'Diproses';
    return 'Diajukan';
  }

  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'Disetujui':
        return AppColors.success;
      case 'Ditolak':
        return AppColors.error;
      case 'Diproses':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allProposals = ormawaProvider.proposals;

    final filteredProposals = allProposals.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'Semua' ||
          _normalizeStatus(p.status) == _selectedStatus;
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
              title: 'PIPELINE PROPOSAL',
              subtitle: 'ANTRIAN REVIEW PROPOSAL',
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
                  _buildPipelineStats(allProposals),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: OrmawaListHeader(
                      title: 'ANTRIAN PROPOSAL (${filteredProposals.length})',
                      searchHint: 'Cari proposal...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: _showFilterSheet,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (filteredProposals.isEmpty)
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
                              'Tidak ada proposal',
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
                      _buildPipelineItem(filteredProposals[index], index),
                  childCount: filteredProposals.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s150)),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStats(List<OrmawaProposal> proposals) {
    final diajukan =
        proposals.where((p) => _normalizeStatus(p.status) == 'Diajukan').length;
    final diproses =
        proposals.where((p) => _normalizeStatus(p.status) == 'Diproses').length;
    final disetujui =
        proposals.where((p) => _normalizeStatus(p.status) == 'Disetujui').length;
    final ditolak =
        proposals.where((p) => _normalizeStatus(p.status) == 'Ditolak').length;

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
              'Diajukan',
              diajukan.toString(),
              AppColors.info,
              Icons.send_rounded,
            ),
            _buildMetricDivider(),
            _buildStatMetric(
              'Diproses',
              diproses.toString(),
              AppColors.warning,
              Icons.autorenew_rounded,
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

  Widget _buildPipelineItem(OrmawaProposal proposal, int index) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id');

    final statusColor = _getStatusColor(proposal.status);
    final normalizedStatus = _normalizeStatus(proposal.status);

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.ormawaProposalDetail, extra: proposal);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                        proposal.title,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${proposal.code} \u2022 ${dateFormatter.format(proposal.date).toUpperCase()}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    normalizedStatus.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
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
                Text(
                  'Anggaran: ${currencyFormatter.format(proposal.budget)}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
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
        return Icons.check_circle_rounded;
      case 'Ditolak':
        return Icons.cancel_rounded;
      case 'Diproses':
        return Icons.autorenew_rounded;
      default:
        return Icons.send_rounded;
    }
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
                    Navigator.pop(context);
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
                child: TextButton(
                  onPressed: () {
                    setState(() => _selectedStatus = 'Semua');
                    Navigator.pop(context);
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
