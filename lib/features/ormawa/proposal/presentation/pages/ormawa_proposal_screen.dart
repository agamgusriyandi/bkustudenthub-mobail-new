import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaProposalScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaProposalScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaProposalScreen> createState() => _OrmawaProposalScreenState();
}

class _OrmawaProposalScreenState extends State<OrmawaProposalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('setuju')) return 'disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'ditolak';
    if (s.contains('revisi')) return 'revisi';
    if (s.contains('diajukan')) return 'diajukan';
    if (s.contains('proses')) return 'proses';
    return 'diajukan';
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return OrmawaTheme.statusSuccessBg;
      case 'ditolak':
        return OrmawaTheme.statusDangerBg;
      case 'revisi':
        return OrmawaTheme.statusWarningBg;
      default:
        return OrmawaTheme.statusInfoBg;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'disetujui_fakultas':
      case 'disetujui_univ':
      case 'selesai':
        return OrmawaTheme.statusSuccessText;
      case 'ditolak':
        return OrmawaTheme.statusDangerText;
      case 'revisi':
        return OrmawaTheme.statusWarningText;
      default:
        return OrmawaTheme.statusInfoText;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return 'Disetujui';
      case 'disetujui_fakultas':
        return 'Acc Fakultas';
      case 'disetujui_univ':
        return 'Acc Univ';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'revisi':
        return 'Revisi';
      case 'proses':
        return 'Diproses';
      default:
        return 'Diajukan';
    }
  }

  void _showDeleteConfirmation(BuildContext context, OrmawaProposal proposal) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Proposal?',
      message:
          'Apakah Anda yakin ingin menghapus proposal "${proposal.title}"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        final provider = context.read<OrmawaProvider>();
        await provider.deleteProposal(proposal.id);
        if (context.mounted) {
          Navigator.pop(context);
          AppSnackbar.showSuccess(context, 'Proposal berhasil dihapus');
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allProposals = ormawaProvider.proposals;

    final totalCount = allProposals.length;
    final diajukanCount =
        allProposals.where((p) => _normalizeStatus(p.status) == 'diajukan' || _normalizeStatus(p.status) == 'proses').length;
    final disetujuiCount =
        allProposals.where((p) => _normalizeStatus(p.status) == 'disetujui').length;
    final ditolakCount =
        allProposals.where((p) => _normalizeStatus(p.status) == 'ditolak').length;
    final revisiCount =
        allProposals.where((p) => _normalizeStatus(p.status) == 'revisi').length;

    final filteredProposals = allProposals.where((p) {
      final norm = _normalizeStatus(p.status);
      bool matchTab = true;
      if (_activeTab == 'diajukan') matchTab = (norm == 'diajukan' || norm == 'proses');
      if (_activeTab == 'disetujui') matchTab = (norm == 'disetujui');
      if (_activeTab == 'ditolak') matchTab = (norm == 'ditolak');
      if (_activeTab == 'revisi') matchTab = (norm == 'revisi');

      final matchQuery = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery) ||
          p.code.toLowerCase().contains(_searchQuery);

      return matchTab && matchQuery;
    }).toList();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id');

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      floatingActionButton: ormawaProvider.hasPermission('create_proposal')
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s100),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.push(AppRoutes.ormawaCreateProposal);
                },
                backgroundColor: OrmawaTheme.primary,
                elevation: 4,
                highlightElevation: 2,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Buat Proposal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
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
              title: 'Manajemen Proposal',
              subtitle: 'Proposal & Surat',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Proposal',
                            value: '$totalCount',
                            badgeText: 'Semua',
                            icon: Icons.all_inbox_rounded,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Menunggu Review',
                            value: '$diajukanCount',
                            badgeText: 'Proses',
                            icon: Icons.hourglass_empty_rounded,
                            badgeColor: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Proposal Disetujui',
                            value: '$disetujuiCount',
                            badgeText: 'Disetujui',
                            icon: Icons.check_circle_rounded,
                            badgeColor: const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Proposal Ditolak',
                            value: '$ditolakCount',
                            badgeText: 'Ditolak',
                            icon: Icons.cancel_rounded,
                            badgeColor: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: totalCount),
                        OrmawaTabItem(key: 'diajukan', label: 'Diajukan', count: diajukanCount),
                        OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: disetujuiCount),
                        OrmawaTabItem(key: 'revisi', label: 'Revisi', count: revisiCount),
                        OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: ditolakCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul proposal atau nomor...',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),
                    if (filteredProposals.isEmpty)
                      const OrmawaEmptyCard(
                        title: 'Belum ada proposal',
                        description: 'Tidak ada proposal yang sesuai dengan filter.',
                        icon: Icons.description_outlined,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProposals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final proposal = filteredProposals[index];
                          final statusBg = _getStatusBgColor(proposal.status);
                          final statusText = _getStatusTextColor(proposal.status);
                          final statusLabel = _getStatusLabel(proposal.status);

                          return OrmawaCard(
                            onTap: () {
                              context.push(
                                AppRoutes.ormawaProposalDetail,
                                extra: proposal,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: statusText,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      dateFormatter.format(proposal.date),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: OrmawaTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  proposal.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: OrmawaTheme.textHeading,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  proposal.code,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: OrmawaTheme.textMuted,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Divider(
                                  height: 18,
                                  color: OrmawaTheme.borderSubtle,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ANGGARAN PENGAJUAN',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: OrmawaTheme.textPlaceholder,
                                          ),
                                        ),
                                        Text(
                                          currencyFormatter.format(proposal.budget),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            context.push(
                                              AppRoutes.ormawaProposalDetail,
                                              extra: proposal,
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: OrmawaTheme.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.visibility_outlined,
                                              size: 15,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () {
                                            context.push(
                                              AppRoutes.ormawaCreateProposal,
                                              extra: proposal,
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: OrmawaTheme.border,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 15,
                                              color: OrmawaTheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () {
                                            _showDeleteConfirmation(
                                              context,
                                              proposal,
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: OrmawaTheme.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 15,
                                              color: Color(0xFFE11D48),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppSpacing.s140),
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
