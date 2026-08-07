import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

class OrmawaProposalScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaProposalScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaProposalScreen> createState() => _OrmawaProposalScreenState();
}

class _OrmawaProposalScreenState extends State<OrmawaProposalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  final List<String> _statusOptions = [
    'Semua',
    'Diajukan',
    'Diproses',
    'Disetujui',
    'Ditolak',
  ];

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

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allProposals = ormawaProvider.proposals;

    final filteredProposals =
        allProposals.where((p) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.code.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus =
              _selectedStatus == 'Semua' ||
              _normalizeStatus(p.status) == _selectedStatus;
          return matchesSearch && matchesStatus;
        }).toList();

    final canCreateProposal = ormawaProvider.hasPermission('create_proposal');

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      floatingActionButton:
          canCreateProposal
              ? Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s100),
                child: FadeInAnimation(
                  delay: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.br28,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(70),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        context.push(AppRoutes.ormawaCreateProposal);
                      },
                      backgroundColor: context.appColors.primary,
                      elevation: 0,
                      highlightElevation: 0,
                      icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
                      label: Text(
                        'Buat Proposal',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'MANAJEMEN PROPOSAL',
              subtitle: 'PROPOSAL & SURAT',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _buildProposalStats(ormawaProvider),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: OrmawaListHeader(
                      title: 'DAFTAR PROPOSAL (${filteredProposals.length})',
                      searchHint: 'Cari proposal...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: () => _showFilterSheet(),
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
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
                              Icons.search_off_rounded,
                              size: 60,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withAlpha(50),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Proposal tidak ditemukan',
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
                      _buildProposalItem(filteredProposals[index], index),
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

  Widget _buildProposalStats(OrmawaProvider provider) {
    final proposals = provider.proposals;
    final diajukan =
        proposals.where((p) => p.status.toLowerCase() == 'diajukan').length;
    final disetujui =
        proposals
            .where(
              (p) =>
                  p.status.toLowerCase() == 'disetujui' ||
                  p.status.toLowerCase() == 'disetujui_fakultas',
            )
            .length;
    final ditolak =
        proposals.where((p) => p.status.toLowerCase() == 'ditolak').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: FadeInAnimation(
        delay: 0.3,
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
                'Semua',
                proposals.length.toString(),
                AppColors.info,
                Icons.all_inbox_rounded,
              ),
              _buildMetricDivider(),
              _buildStatMetric(
                'Proses',
                diajukan.toString(),
                AppColors.warning,
                Icons.hourglass_empty_rounded,
              ),
              _buildMetricDivider(),
              _buildStatMetric(
                'Selesai',
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

  Widget _buildProposalItem(OrmawaProposal proposal, int index) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id');

    Color statusColor;
    String displayStatus = proposal.status.toTitleCase();

    switch (proposal.status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        statusColor = AppColors.success;
        if (proposal.status.toLowerCase() == 'disetujui_fakultas') {
          displayStatus = 'Acc Fakultas';
        }
        if (proposal.status.toLowerCase() == 'disetujui_univ') {
          displayStatus = 'Acc Univ';
        }
        if (proposal.status.toLowerCase() == 'selesai') {
          displayStatus = 'Selesai';
        }
        break;
      case 'ditolak':
        statusColor = AppColors.error;
        displayStatus = 'Ditolak';
        break;
      case 'revisi':
        statusColor = AppColors.warning;
        displayStatus = 'Revisi';
        break;
      case 'proses':
      case 'diajukan':
        statusColor = AppColors.info;
        displayStatus = 'Menunggu';
        break;
      default:
        statusColor = AppColors.info;
    }

    return FadeInAnimation(
      delay: 0.1 * (index % 5),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(12),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                    color: context.appColors.primary.withAlpha(10),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: context.appColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.title,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${proposal.code} • ${dateFormatter.format(proposal.date)}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
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
                    displayStatus,
                    style: AppTextStyles.labelSm.copyWith(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Divider(color: AppColors.neutral200, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANGGARAN',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(proposal.budget),
                      style: AppTextStyles.bodyLg.copyWith(
                        color: context.appColors.success,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(
                      Icons.visibility_outlined,
                      AppColors.info,
                      () {
                        context.push(AppRoutes.ormawaProposalDetail, extra: proposal);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildActionButton(Icons.edit_outlined, context.appColors.info, () {
                      context.push(AppRoutes.ormawaCreateProposal, extra: proposal);
                    }),
                    const SizedBox(width: AppSpacing.sm),
                    _buildActionButton(
                      Icons.delete_outline_rounded,
                      AppColors.error,
                      () {
                        _showDeleteConfirmation(context, proposal);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, OrmawaProposal proposal) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => CustomDialog(
            title: 'Hapus Proposal?',
            content:
                'Apakah Anda yakin ingin menghapus proposal "${proposal.title}"? Tindakan ini tidak dapat dibatalkan.',
            cancelText: 'Batal',
            confirmText: 'Hapus',
            isDestructive: true,
            onCancel: () => Navigator.pop(dialogCtx),
            onConfirm: () async {
              final provider = Provider.of<OrmawaProvider>(
                context,
                listen: false,
              );
              await provider.deleteProposal(proposal.id);
              if (context.mounted) {
                Navigator.pop(dialogCtx);
                AppSnackbar.showError(context, 'Proposal berhasil dihapus');
              }
            },
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
                      _statusOptions.map((status) {
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
                              color:
                                  isSelected
                                      ? context.appColors.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(10),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              status,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isSelected
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
