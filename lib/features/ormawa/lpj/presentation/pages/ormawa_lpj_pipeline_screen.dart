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
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_detail_screen.dart';

class OrmawaLpjPipelineScreen extends StatefulWidget {
  const OrmawaLpjPipelineScreen({super.key});

  @override
  State<OrmawaLpjPipelineScreen> createState() => _OrmawaLpjPipelineScreenState();
}

class _OrmawaLpjPipelineScreenState extends State<OrmawaLpjPipelineScreen> {
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
    if (s.contains('disetujui') || s.contains('selesai') || s.contains('acc')) return 'disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'ditolak';
    if (s.contains('revisi')) return 'revisi';
    return 'menunggu';
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
    final allLpj = ormawaProvider.lpjs;

    final menungguCount = allLpj.where((l) => _normalizeStatus(l.status) == 'menunggu').length;
    final revisiCount = allLpj.where((l) => _normalizeStatus(l.status) == 'revisi').length;
    final disetujuiCount = allLpj.where((l) => _normalizeStatus(l.status) == 'disetujui').length;
    final ditolakCount = allLpj.where((l) => _normalizeStatus(l.status) == 'ditolak').length;

    final filteredLpj = allLpj.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.judul.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _activeTab == 'all' || _normalizeStatus(l.status) == _activeTab;
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
              title: 'Pipeline LPJ',
              subtitle: 'Antrian Verifikasi Berjenjang',
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
                            title: 'Menunggu',
                            value: '$menungguCount',
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
                            subtitle: 'Catatan penguji',
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
                            subtitle: 'LPJ diterima',
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
                      hintText: 'Cari kegiatan LPJ...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                    const SizedBox(height: 10),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: allLpj.length),
                        OrmawaTabItem(key: 'menunggu', label: 'Menunggu', count: menungguCount),
                        OrmawaTabItem(key: 'revisi', label: 'Revisi', count: revisiCount),
                        OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: disetujuiCount),
                        OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: ditolakCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 14),
                    if (ormawaProvider.isLoading && allLpj.isEmpty)
                      const BkuShimmerList(itemCount: 3, itemHeight: 90)
                    else if (filteredLpj.isEmpty)
                      const OrmawaEmptyCard(
                        title: 'Tidak Ada LPJ',
                        description: 'Tidak ada laporan pertanggungjawaban pada status ini.',
                        icon: Icons.assignment_outlined,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLpj.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lpj = filteredLpj[index];
                          return OrmawaCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrmawaLpjDetailScreen(lpj: lpj),
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
                                            lpj.judul,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: OrmawaTheme.textHeading,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (lpj.proposalTitle != null && lpj.proposalTitle!.isNotEmpty) ...[
                                            SizedBox(height: 2),
                                            Text(
                                              lpj.proposalTitle!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: OrmawaTheme.textMuted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    OrmawaBadge(
                                      text: lpj.status.toUpperCase(),
                                      variant: _getBadgeVariant(lpj.status),
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
                                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(lpj.realisasiAnggaran),
                                            style: TextStyle(
                                              color: OrmawaTheme.textHeading,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (lpj.createdAt != null)
                                        Row(
                                          children: [
                                            Text(
                                              DateFormat('dd MMM yyyy', 'id').format(lpj.createdAt!),
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