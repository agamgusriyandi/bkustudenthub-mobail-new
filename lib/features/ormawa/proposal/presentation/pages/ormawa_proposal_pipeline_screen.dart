import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_detail_screen.dart';

class OrmawaProposalPipelineScreen extends StatefulWidget {
  const OrmawaProposalPipelineScreen({super.key});

  @override
  State<OrmawaProposalPipelineScreen> createState() => _OrmawaProposalPipelineScreenState();
}

class _OrmawaProposalPipelineScreenState extends State<OrmawaProposalPipelineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'all';

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
    if (s.contains('disetujui') || s.contains('setuju')) return 'disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'ditolak';
    if (s.contains('revisi')) return 'revisi';
    return 'diajukan';
  }

  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'disetujui':
        return BkuTheme.emerald;
      case 'ditolak':
        return BkuTheme.rose;
      case 'revisi':
        return BkuTheme.amber;
      default:
        return BkuTheme.sky;
    }
  }

  Color _getStatusBg(String status) {
    switch (_normalizeStatus(status)) {
      case 'disetujui':
        return BkuTheme.emeraldSoft;
      case 'ditolak':
        return BkuTheme.roseSoft;
      case 'revisi':
        return BkuTheme.amberSoft;
      default:
        return BkuTheme.skySoft;
    }
  }

  Color _getStatusBorder(String status) {
    switch (_normalizeStatus(status)) {
      case 'disetujui':
        return BkuTheme.emeraldBorder;
      case 'ditolak':
        return BkuTheme.roseBorder;
      case 'revisi':
        return BkuTheme.amberBorder;
      default:
        return BkuTheme.skyBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allProposals = ormawaProvider.proposals;

    final diajukanCount = allProposals.where((p) => _normalizeStatus(p.status) == 'diajukan').length;
    final revisiCount = allProposals.where((p) => _normalizeStatus(p.status) == 'revisi').length;
    final disetujuiCount = allProposals.where((p) => _normalizeStatus(p.status) == 'disetujui').length;
    final ditolakCount = allProposals.where((p) => _normalizeStatus(p.status) == 'ditolak').length;

    final filteredProposals = allProposals.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _activeTab == 'all' || _normalizeStatus(p.status) == _activeTab;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: BkuTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            const BkuAppBar(
              title: 'Pipeline Proposal',
              subtitle: 'Antrian Review Berjenjang',
              variant: AppBarVariant.ormawa,
              expandedHeight: 125.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Diajukan',
                            value: '$diajukanCount',
                            badgeText: 'Review',
                            icon: Icons.hourglass_top_rounded,
                            badgeColor: BkuTheme.sky,
                            subtitle: 'Tahap telaah',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Revisi',
                            value: '$revisiCount',
                            badgeText: 'Perlu Cek',
                            icon: Icons.edit_document,
                            badgeColor: BkuTheme.amber,
                            subtitle: 'Catatan reviewer',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Disetujui',
                            value: '$disetujuiCount',
                            badgeText: 'Acc',
                            icon: Icons.check_circle_rounded,
                            badgeColor: BkuTheme.emerald,
                            subtitle: 'Siap cair / jalan',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Ditolak',
                            value: '$ditolakCount',
                            badgeText: 'Reject',
                            icon: Icons.cancel_rounded,
                            badgeColor: BkuTheme.rose,
                            subtitle: 'Tidak disetujui',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul atau kode proposal...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                    const SizedBox(height: 10),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: allProposals.length),
                        OrmawaTabItem(key: 'diajukan', label: 'Diajukan', count: diajukanCount),
                        OrmawaTabItem(key: 'revisi', label: 'Revisi', count: revisiCount),
                        OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: disetujuiCount),
                        OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: ditolakCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 14),
                    if (ormawaProvider.isLoading && allProposals.isEmpty)
                      const BkuShimmerList(itemCount: 3, itemHeight: 90)
                    else if (filteredProposals.isEmpty)
                      const BkuEmptyState(
                        title: 'Tidak Ada Proposal',
                        message: 'Tidak ada proposal kegiatan pada status ini.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProposals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final proposal = filteredProposals[index];
                          final statusColor = _getStatusColor(proposal.status);
                          final statusBg = _getStatusBg(proposal.status);
                          final statusBorder = _getStatusBorder(proposal.status);

                          return BkuCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrmawaProposalDetailScreen(proposal: proposal),
                                ),
                              );
                            },
                            padding: const EdgeInsets.all(14),
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: BkuTheme.primarySoft,
                                        borderRadius: BkuTheme.r10,
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        color: BkuTheme.primary,
                                        size: 19,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            proposal.title,
                                            style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            proposal.code,
                                            style: BkuTheme.textCaption.copyWith(
                                              fontSize: 11,
                                              color: BkuTheme.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BkuTheme.r8,
                                        border: Border.all(color: statusBorder),
                                      ),
                                      child: Text(
                                        proposal.status.toUpperCase(),
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: BkuTheme.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.payments_outlined,
                                            size: 13,
                                            color: BkuTheme.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(proposal.budget),
                                            style: BkuTheme.textBodyRegular.copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('dd MMM yyyy', 'id').format(proposal.date),
                                            style: BkuTheme.textCaption.copyWith(
                                              color: BkuTheme.textMuted,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 9,
                                            color: BkuTheme.primary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppSpacing.s120),
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