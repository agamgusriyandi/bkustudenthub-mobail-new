import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/create_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_detail_screen.dart';

class OrmawaAbsensiManagementScreen extends StatefulWidget {
  const OrmawaAbsensiManagementScreen({super.key});

  @override
  State<OrmawaAbsensiManagementScreen> createState() => _OrmawaAbsensiManagementScreenState();
}

class _OrmawaAbsensiManagementScreenState extends State<OrmawaAbsensiManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().fetchAbsensiManagement();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'berlangsung':
      case 'ongoing':
        return OrmawaBadgeVariant.success;
      case 'selesai':
      case 'completed':
        return OrmawaBadgeVariant.info;
      case 'dibatalkan':
      case 'batal':
        return OrmawaBadgeVariant.danger;
      default:
        return OrmawaBadgeVariant.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().fetchAbsensiManagement(),
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
              variant: AppBarVariant.ormawa,
              title: 'Manajemen Absensi',
              subtitle: 'Kehadiran Kegiatan',
              expandedHeight: 125.0,
              showBackButton: true,
              isExpandable: false,
            ),
            Consumer<OrmawaProvider>(
              builder: (context, provider, _) {
                final list = provider.absensiManagementList;
                final total = list.length;
                final active = list.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'aktif').length;
                final completed = list.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'selesai').length;

                final filteredList = list.where((item) {
                  final nama = (item['Nama'] ?? item['nama'] ?? item['Judul'] ?? '').toString();
                  final status = (item['Status'] ?? item['status'] ?? '').toString().toLowerCase();
                  final matchesSearch = nama.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesFilter = _activeTab == 'all' || status == _activeTab;
                  return matchesSearch && matchesFilter;
                }).toList();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Total Sesi',
                                value: '$total',
                                badgeText: 'Total',
                                icon: Icons.event_rounded,
                                badgeColor: OrmawaTheme.statusInfoText,
                                subtitle: 'Semua event',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Sesi Aktif',
                                value: '$active',
                                badgeText: 'Live',
                                icon: Icons.play_circle_fill_rounded,
                                badgeColor: OrmawaTheme.statusSuccessText,
                                subtitle: 'Buka presensi',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Selesai',
                                value: '$completed',
                                badgeText: 'Arsip',
                                icon: Icons.check_circle_rounded,
                                badgeColor: OrmawaTheme.textMuted,
                                subtitle: 'Telah ditutup',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OrmawaSearchBar(
                          controller: _searchController,
                          hintText: 'Cari kegiatan absensi...',
                          onChanged: (v) => setState(() => _searchQuery = v),
                          onClear: () => setState(() => _searchQuery = ''),
                        ),
                        const SizedBox(height: 10),
                        OrmawaFilterTabs(
                          tabs: [
                            OrmawaTabItem(key: 'all', label: 'Semua', count: total),
                            OrmawaTabItem(key: 'aktif', label: 'Aktif', count: active),
                            OrmawaTabItem(key: 'selesai', label: 'Selesai', count: completed),
                          ],
                          activeKey: _activeTab,
                          onTabChanged: (val) => setState(() => _activeTab = val),
                        ),
                        const SizedBox(height: 14),
                        if (provider.isLoading && list.isEmpty)
                          const BkuShimmerList(itemCount: 3, itemHeight: 90)
                        else if (filteredList.isEmpty)
                          const OrmawaEmptyCard(
                            title: 'Tidak Ada Data Absensi',
                            description: 'Belum ada sesi presensi kegiatan yang sesuai kriteria.',
                            icon: Icons.event_busy_rounded,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final nama = (item['Nama'] ?? item['nama'] ?? item['Judul'] ?? '').toString();
                              final tanggal = (item['Tanggal'] ?? item['tanggal'] ?? '').toString();
                              final lokasi = (item['Lokasi'] ?? item['lokasi'] ?? '-').toString();
                              final jumlahHadir = item['JumlahHadir'] ?? item['jumlah_hadir'] ?? 0;
                              final jumlahTotal = item['JumlahTotal'] ?? item['jumlah_total'] ?? 0;
                              final id = (item['ID'] ?? item['id'] ?? '').toString();
                              final statusStr = (item['Status'] ?? item['status'] ?? 'Terjadwal').toString();

                              DateTime? date;
                              try {
                                date = DateTime.parse(tanggal);
                              } catch (_) {}

                              return OrmawaCard(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrmawaAbsensiManagementDetailScreen(absensiId: id, absensiData: item),
                                  ),
                                ).then((_) => provider.fetchAbsensiManagement()),
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
                                            Icons.qr_code_scanner_rounded,
                                            color: OrmawaTheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nama,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: OrmawaTheme.textHeading,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                date != null ? DateFormat('dd MMM yyyy', 'id').format(date) : tanggal,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: OrmawaTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        OrmawaBadge(
                                          text: statusStr.toUpperCase(),
                                          variant: _getBadgeVariant(statusStr),
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
                                                Icons.location_on_outlined,
                                                size: 13,
                                                color: OrmawaTheme.textMuted,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                lokasi,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: OrmawaTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '$jumlahHadir / $jumlahTotal Hadir',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: OrmawaTheme.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppSpacing.s100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission('edit_attendance')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateAbsensiScreen()),
            ).then((_) => provider.fetchAbsensiManagement()),
            backgroundColor: OrmawaTheme.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Buat Absensi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
