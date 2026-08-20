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
                            subtitle: 'Catatan penguji',
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
                            subtitle: 'LPJ diterima',
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
                      const BkuEmptyState(
                        title: 'Tidak Ada LPJ',
                        message: 'Tidak ada laporan pertanggungjawaban pada status ini.',
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
                          final statusColor = _getStatusColor(lpj.status);
                          final statusBg = _getStatusBg(lpj.status);
                          final statusBorder = _getStatusBorder(lpj.status);

                          return BkuCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrmawaLpjDetailScreen(lpj: lpj),
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
                                            lpj.judul,
                                            style: BkuTheme.textCardTitle.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (lpj.proposalTitle != null && lpj.proposalTitle!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              lpj.proposalTitle!,
                                              style: BkuTheme.textCaption.copyWith(
                                                fontSize: 11,
                                                color: BkuTheme.textMuted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
                                        lpj.status.toUpperCase(),
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
                                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(lpj.realisasiAnggaran),
                                            style: BkuTheme.textBodyRegular.copyWith(
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