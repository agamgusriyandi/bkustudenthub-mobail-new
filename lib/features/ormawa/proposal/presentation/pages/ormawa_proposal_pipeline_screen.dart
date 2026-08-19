import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
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

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (_normalizeStatus(status)) {
      case 'disetujui':
        return OrmawaBadgeVariant.success;
      case 'ditolak':
        return OrmawaBadgeVariant.danger;
      case 'revisi':
        return OrmawaBadgeVariant.warning;
      default:
        return OrmawaBadgeVariant.info;
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
                            badgeColor: OrmawaTheme.statusInfoText,
                            subtitle: 'Tahap telaah',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Revisi',
                            value: '$revisiCount',
                            badgeText: 'Perlu Cek',
                            icon: Icons.edit_document,
                            badgeColor: OrmawaTheme.statusWarningText,
                            subtitle: 'Catatan reviewer',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Disetujui',
                            value: '$disetujuiCount',
                            badgeText: 'Acc',
                            icon: Icons.check_circle_rounded,
                            badgeColor: OrmawaTheme.statusSuccessText,
                            subtitle: 'Siap cair / jalan',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Ditolak',
                            value: '$ditolakCount',
                            badgeText: 'Reject',
                            icon: Icons.cancel_rounded,
                            badgeColor: OrmawaTheme.statusDangerText,
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
                      const OrmawaEmptyCard(
                        title: 'Tidak Ada Proposal',
                        description: 'Tidak ada proposal kegiatan pada status ini.',
                        icon: Icons.assignment_outlined,
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
                          return OrmawaCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrmawaProposalDetailScreen(proposal: proposal),
                                ),
                              );
                            },
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
                                        color: OrmawaTheme.primarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        color: OrmawaTheme.primary,
                                        size: 19,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            proposal.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: OrmawaTheme.textHeading,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            proposal.code,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: OrmawaTheme.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OrmawaBadge(
                                      text: proposal.status.toUpperCase(),
                                      variant: _getBadgeVariant(proposal.status),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Color(0xFFF1F5F9),
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
                                            color: OrmawaTheme.textMuted,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(proposal.budget),
                                            style: TextStyle(
                                              color: OrmawaTheme.textHeading,
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
                                            style: TextStyle(
                                              color: OrmawaTheme.textMuted,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 9,
                                            color: OrmawaTheme.primary,
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
