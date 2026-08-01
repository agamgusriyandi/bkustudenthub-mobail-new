import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/create_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrmawaAbsensiManagementScreen extends StatefulWidget {
  const OrmawaAbsensiManagementScreen({super.key});

  @override
  State<OrmawaAbsensiManagementScreen> createState() => _OrmawaAbsensiManagementScreenState();
}

class _OrmawaAbsensiManagementScreenState extends State<OrmawaAbsensiManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.success;
      case 'selesai':
        return AppColors.info;
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().fetchAbsensiManagement(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'MANAJEMEN ABSENSI',
              subtitle: 'KEHADIRAN KEGIATAN',
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSearchAndFilter(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _buildAbsensiList(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s100)),
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
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Buat Absensi',
              style: TextStyle(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        final list = provider.absensiManagementList;
        final total = list.length;
        final active = list.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'aktif').length;
        final completed = list.where((a) => (a['Status'] ?? a['status'] ?? '').toString().toLowerCase() == 'selesai').length;

        return Row(
          children: [
            _buildStatCard('Total', total.toString(), AppColors.info, Icons.event_rounded),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Aktif', active.toString(), AppColors.success, Icons.play_circle_rounded),
            const SizedBox(width: AppSpacing.md),
            _buildStatCard('Selesai', completed.toString(), AppColors.neutral600, Icons.check_circle_rounded),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.padding6,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama kegiatan...',
                hintStyle: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                prefixIcon: Icon(Icons.search_rounded, color: context.appColors.primary, size: 24),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        InkWell(
          onTap: _showFilterBottomSheet,
          borderRadius: AppRadius.radiusLg,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Icon(Icons.filter_list_rounded, color: context.appColors.primary),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      backgroundColor: context.appColors.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: AppRadius.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Filter Status',
                    style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold, color: context.appColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Semua', 'Aktif', 'Selesai', 'Dibatalkan'].map((filter) {
                      final isSelected = _selectedStatusFilter == filter;
                      return ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? context.appColors.onPrimary : context.appColors.primary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatusFilter = filter);
                            setModalState(() {});
                          }
                        },
                        selectedColor: context.appColors.primary,
                        backgroundColor: AppColors.neutral200,
                        side: BorderSide.none,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAbsensiList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.absensiManagementList.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: const [
                  BkuShimmer(width: double.infinity, height: 120, borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20))),
                  SizedBox(height: AppSpacing.s20),
                  BkuShimmerList(itemCount: 3, itemHeight: 100),
                ],
              ),
            ),
          );
        }

        final filteredList = provider.absensiManagementList.where((item) {
          final nama = (item['Nama'] ?? item['nama'] ?? '').toString();
          final status = (item['Status'] ?? item['status'] ?? '').toString();
          final matchesSearch = nama.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesFilter = _selectedStatusFilter == 'Semua' || status.toLowerCase() == _selectedStatusFilter.toLowerCase();
          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredList.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_rounded, size: 48, color: AppColors.neutral500.withAlpha(50)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _searchQuery.isEmpty && _selectedStatusFilter == 'Semua'
                          ? 'Belum ada data absensi'
                          : 'Data tidak ditemukan',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredList[index];
                final nama = (item['Nama'] ?? item['nama'] ?? '').toString();
                final status = (item['Status'] ?? item['status'] ?? '').toString();
                final tanggal = (item['Tanggal'] ?? item['tanggal'] ?? '').toString();
                final lokasi = (item['Lokasi'] ?? item['lokasi'] ?? '-').toString();
                final jumlahHadir = item['JumlahHadir'] ?? item['jumlah_hadir'] ?? 0;
                final jumlahTotal = item['JumlahTotal'] ?? item['jumlah_total'] ?? 0;
                final id = (item['ID'] ?? item['id'] ?? '').toString();
                final statusColor = _getStatusColor(status);

                DateTime? date;
                try {
                  date = DateTime.parse(tanggal);
                } catch (_) {}

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrmawaAbsensiManagementDetailScreen(absensiId: id, absensiData: item),
                    ),
                  ).then((_) => provider.fetchAbsensiManagement()),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusXl,
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(nama, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(15),
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.neutral500),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              date != null ? DateFormat('dd MMMM yyyy', 'id').format(date) : tanggal,
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Icon(Icons.location_on_rounded, size: 14, color: AppColors.neutral500),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                lokasi,
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(Icons.people_rounded, size: 14, color: AppColors.neutral500),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$jumlahHadir / $jumlahTotal hadir',
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filteredList.length,
            ),
          ),
        );
      },
    );
  }
}
