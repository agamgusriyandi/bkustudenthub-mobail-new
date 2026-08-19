import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/create_lpj_screen.dart';

class OrmawaLpjScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaLpjScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaLpjScreen> createState() => _OrmawaLpjScreenState();
}

class _OrmawaLpjScreenState extends State<OrmawaLpjScreen> {
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

  String _normalizeStatus(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('setuju') || s.contains('acc')) return 'disetujui';
    if (s.contains('selesai')) return 'selesai';
    if (s.contains('tolak') || s.contains('batal')) return 'ditolak';
    if (s.contains('revisi')) return 'revisi';
    return 'menunggu';
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
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

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final allLpjs = provider.lpjs;

    final totalCount = allLpjs.length;
    final approvedCount = allLpjs
        .where((l) =>
            _normalizeStatus(l.status) == 'disetujui' ||
            _normalizeStatus(l.status) == 'selesai')
        .length;
    final pendingCount = allLpjs
        .where((l) => _normalizeStatus(l.status) == 'menunggu')
        .length;
    final rejectedCount = allLpjs
        .where((l) => _normalizeStatus(l.status) == 'ditolak')
        .length;
    final revisionCount = allLpjs
        .where((l) => _normalizeStatus(l.status) == 'revisi')
        .length;

    final filteredLpjs = allLpjs.where((lpj) {
      final norm = _normalizeStatus(lpj.status);
      bool matchTab = true;
      if (_activeTab == 'menunggu') matchTab = (norm == 'menunggu');
      if (_activeTab == 'disetujui') matchTab = (norm == 'disetujui' || norm == 'selesai');
      if (_activeTab == 'revisi') matchTab = (norm == 'revisi');
      if (_activeTab == 'ditolak') matchTab = (norm == 'ditolak');

      final matchQuery = _searchQuery.isEmpty ||
          lpj.judul.toLowerCase().contains(_searchQuery) ||
          (lpj.proposalTitle != null && lpj.proposalTitle!.toLowerCase().contains(_searchQuery));

      return matchTab && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      floatingActionButton: provider.hasPermission('create_lpj')
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s100),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final ormawaProv = context.read<OrmawaProvider>();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateLpjScreen(),
                    ),
                  );
                  ormawaProv.refreshData();
                },
                backgroundColor: OrmawaTheme.primary,
                elevation: 4,
                highlightElevation: 2,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Buat LPJ',
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
              variant: AppBarVariant.ormawa,
              title: 'Laporan LPJ',
              subtitle: 'Pertanggungjawaban Kegiatan',
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
                            title: 'Total Laporan LPJ',
                            value: '$totalCount',
                            badgeText: 'Semua',
                            icon: Icons.description_rounded,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Menunggu Review',
                            value: '$pendingCount',
                            badgeText: 'Pending',
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
                            title: 'LPJ Disetujui',
                            value: '$approvedCount',
                            badgeText: 'Disetujui',
                            icon: Icons.check_circle_rounded,
                            badgeColor: const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Perlu Revisi / Tolak',
                            value: '${revisionCount + rejectedCount}',
                            badgeText: 'Perhatian',
                            icon: Icons.info_outline_rounded,
                            badgeColor: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: totalCount),
                        OrmawaTabItem(key: 'menunggu', label: 'Menunggu', count: pendingCount),
                        OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: approvedCount),
                        OrmawaTabItem(key: 'revisi', label: 'Revisi', count: revisionCount),
                        OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: rejectedCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul LPJ atau kegiatan...',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),
                    if (filteredLpjs.isEmpty)
                      const OrmawaEmptyCard(
                        title: 'Belum ada LPJ',
                        description: 'Tidak ada laporan pertanggungjawaban yang sesuai.',
                        icon: Icons.folder_open_rounded,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLpjs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lpj = filteredLpjs[index];
                          final norm = _normalizeStatus(lpj.status);
                          final statusBg = _getStatusBgColor(norm);
                          final statusText = _getStatusTextColor(norm);

                          return OrmawaCard(
                            onTap: () {
                              context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
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
                                        lpj.status,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: statusText,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: OrmawaTheme.textPlaceholder,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  lpj.judul,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: OrmawaTheme.textHeading,
                                    height: 1.3,
                                  ),
                                ),
                                if (lpj.proposalTitle != null && lpj.proposalTitle!.isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    lpj.proposalTitle!,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: OrmawaTheme.textMuted,
                                    ),
                                  ),
                                ],
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
                                          'REALISASI ANGGARAN',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: OrmawaTheme.textPlaceholder,
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(lpj.realisasiAnggaran),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'TOTAL PENGAJUAN',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: OrmawaTheme.textPlaceholder,
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(lpj.totalAnggaran),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: OrmawaTheme.textBody,
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
