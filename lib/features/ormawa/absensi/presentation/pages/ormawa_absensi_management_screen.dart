import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
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

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = BkuTheme.borderSubtle;
    Color fg = BkuTheme.textBody;
    Color border = BkuTheme.border;

    if (s == 'aktif' || s == 'berlangsung' || s == 'ongoing') {
      bg = BkuTheme.emeraldSoft;
      fg = BkuTheme.emerald;
      border = BkuTheme.emeraldBorder;
    } else if (s == 'selesai' || s == 'completed') {
      bg = BkuTheme.skySoft;
      fg = BkuTheme.sky;
      border = BkuTheme.skyBorder;
    } else if (s == 'dibatalkan' || s == 'batal') {
      bg = BkuTheme.roseSoft;
      fg = BkuTheme.rose;
      border = BkuTheme.roseBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BkuTheme.r8,
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().fetchAbsensiManagement(),
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
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          borderRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Manajemen Presensi &',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Sesi Kehadiran Kegiatan',
                                          style: BkuTheme.textPageTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w900),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BkuTheme.r10,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_scanner_rounded, size: 14, color: Color(0xFF0F172A)),
                                        SizedBox(width: 5),
                                        Text(
                                          'Presensi Ormawa',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Buat barcode presensi QR Code, atur radius lokasi, dan pantau rekapitulasi kehadiran anggota.',
                                style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: BkuButton.outline(
                                      onPressed: () => provider.fetchAbsensiManagement(),
                                      icon: Icons.refresh_rounded,
                                      text: 'Refresh',
                                      height: 38,
                                      fontSize: 11,
                                      customRadius: BkuTheme.r10,
                                    ),
                                  ),
                                  if (canCreate) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: BkuButton.primary(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const CreateAbsensiScreen()),
                                        ).then((_) => provider.fetchAbsensiManagement()),
                                        icon: Icons.add_rounded,
                                        text: 'Buat Sesi Baru',
                                        height: 38,
                                        fontSize: 11,
                                        customRadius: BkuTheme.r10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
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
                                badgeColor: BkuTheme.sky,
                                subtitle: 'Semua event',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Sesi Aktif',
                                value: '$active',
                                badgeText: 'Live',
                                icon: Icons.play_circle_fill_rounded,
                                badgeColor: BkuTheme.emerald,
                                subtitle: 'Buka presensi',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Selesai',
                                value: '$completed',
                                badgeText: 'Arsip',
                                icon: Icons.check_circle_rounded,
                                badgeColor: BkuTheme.slate,
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
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: BkuEmptyState(
                              title: 'Tidak Ada Data Absensi',
                              message: 'Belum ada sesi presensi kegiatan yang sesuai kriteria.',
                              icon: Icons.event_busy_rounded,
                            ),
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

                              return BkuCard(
                                padding: const EdgeInsets.all(12),
                                borderRadius: 16,
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
                                            color: BkuTheme.primarySoft,
                                            borderRadius: BkuTheme.r10,
                                            border: Border.all(color: BkuTheme.primaryBorder),
                                          ),
                                          child: Icon(
                                            Icons.qr_code_scanner_rounded,
                                            color: BkuTheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nama,
                                                style: BkuTheme.textCardTitle.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                date != null ? DateFormat('dd MMM yyyy', 'id').format(date) : tanggal,
                                                style: BkuTheme.textCaption.copyWith(
                                                  fontSize: 10.5,
                                                  color: BkuTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStatusBadge(statusStr),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      decoration: const BoxDecoration(
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
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 13,
                                                color: BkuTheme.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                lokasi,
                                                style: BkuTheme.textCaption.copyWith(
                                                  fontSize: 10.5,
                                                  color: BkuTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '$jumlahHadir / $jumlahTotal Hadir',
                                            style: BkuTheme.textCaption.copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: BkuTheme.primaryDark,
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