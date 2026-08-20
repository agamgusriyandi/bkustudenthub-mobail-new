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
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
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

                final canCreate = provider.hasPermission('ormawa.attendance.create, ormawa.attendance.manage, create_attendance, edit_attendance, ormawa.events.create, ormawa.events.manage');

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInAnimation(
                          delay: 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF94A3B8).withAlpha(20),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Manajemen Presensi &',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Sesi Kehadiran Kegiatan',
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: OrmawaTheme.primarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: OrmawaTheme.primaryBorder),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.qr_code_scanner_rounded, size: 14, color: OrmawaTheme.primary),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Presensi Ormawa',
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Buat barcode presensi QR Code, atur radius lokasi, dan pantau rekapitulasi kehadiran anggota.',
                                  style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => provider.fetchAbsensiManagement(),
                                        icon: const Icon(Icons.refresh_rounded, size: 14),
                                        label: const Text('Refresh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: OrmawaTheme.textHeading,
                                          side: BorderSide(color: OrmawaTheme.border),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                    if (canCreate) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const CreateAbsensiScreen()),
                                          ).then((_) => provider.fetchAbsensiManagement()),
                                          icon: const Icon(Icons.add_rounded, size: 15),
                                          label: const Text('Buat Sesi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: OrmawaTheme.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}