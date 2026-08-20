import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/create_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/edit_lpj_screen.dart';

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

  Color _getStatusColor(String status) {
    final norm = _normalizeStatus(status);
    switch (norm) {
      case 'disetujui':
      case 'selesai':
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
    final norm = _normalizeStatus(status);
    switch (norm) {
      case 'disetujui':
      case 'selesai':
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
    final norm = _normalizeStatus(status);
    switch (norm) {
      case 'disetujui':
      case 'selesai':
        return BkuTheme.emeraldBorder;
      case 'ditolak':
        return BkuTheme.roseBorder;
      case 'revisi':
        return BkuTheme.amberBorder;
      default:
        return BkuTheme.skyBorder;
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  void _confirmDelete(BuildContext context, String lpjId, String title) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Berkas LPJ?',
      message: 'Apakah Anda yakin ingin menghapus laporan pertanggungjawaban "$title"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteLPJ(lpjId);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'LPJ berhasil dihapus');
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus LPJ: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final allLpjs = provider.lpjs;

    final totalCount = allLpjs.length;
    final approvedCount = allLpjs.where((l) {
      final s = _normalizeStatus(l.status);
      return s == 'disetujui' || s == 'selesai';
    }).length;
    final pendingCount = allLpjs.where((l) => _normalizeStatus(l.status) == 'menunggu').length;
    final revisiCount = allLpjs.where((l) => _normalizeStatus(l.status) == 'revisi' || _normalizeStatus(l.status) == 'ditolak').length;

    final totalRealisasi = allLpjs.fold<double>(0.0, (acc, curr) => acc + curr.realisasiAnggaran);
    final totalSavings = allLpjs.fold<double>(0.0, (acc, curr) {
      final diff = curr.totalAnggaran - curr.realisasiAnggaran;
      return diff > 0 ? acc + diff : acc;
    });

    final filteredLpjs = allLpjs.where((lpj) {
      final norm = _normalizeStatus(lpj.status);
      bool matchTab = true;
      if (_activeTab == 'diajukan') matchTab = (norm == 'menunggu');
      if (_activeTab == 'disetujui') matchTab = (norm == 'disetujui' || norm == 'selesai');
      if (_activeTab == 'revisi') matchTab = (norm == 'revisi' || norm == 'ditolak');

      final matchQuery = _searchQuery.isEmpty ||
          lpj.judul.toLowerCase().contains(_searchQuery) ||
          (lpj.proposalTitle != null && lpj.proposalTitle!.toLowerCase().contains(_searchQuery));

      return matchTab && matchQuery;
    }).toList();

    final canCreateLpj = provider.hasPermission('ormawa.lpj.create, create_lpj');
    final canEditLpj = provider.hasPermission('ormawa.lpj.update, edit_lpj');
    final canDeleteLpj = provider.hasPermission('ormawa.lpj.delete, delete_lpj');

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: BkuTheme.primary,
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
              subtitle: 'Pertanggungjawaban & Realisasi Anggaran',
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInAnimation(
                      delay: 0.1,
                      child: BkuCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
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
                                        'Manajemen Laporan &',
                                        style: BkuTheme.textBadge.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pertanggungjawaban LPJ',
                                        style: BkuTheme.textCardTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w900),
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
                                    borderRadius: BkuTheme.r8,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.assignment_turned_in_rounded, size: 14, color: Color(0xFF0F172A)),
                                      SizedBox(width: 5),
                                      Text(
                                        'LPJ Ormawa',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pelaporan realisasi anggaran kegiatan, verifikasi bukti transaksi pengeluaran, dan efisiensi pagu.',
                              style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: BkuButton.outline(
                                    onPressed: () => context.read<OrmawaProvider>().refreshData(),
                                    icon: Icons.refresh_rounded,
                                    text: 'Refresh',
                                    height: 36,
                                  ),
                                ),
                                if (canCreateLpj) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: BkuButton.primary(
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
                                      icon: Icons.add_rounded,
                                      text: 'Buat LPJ Baru',
                                      height: 36,
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
                            title: 'Total Berkas LPJ',
                            value: '$totalCount',
                            badgeText: 'Total',
                            icon: Icons.description_rounded,
                            badgeColor: BkuTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'LPJ Disetujui',
                            value: '$approvedCount',
                            badgeText: totalCount > 0 ? '${((approvedCount / totalCount) * 100).round()}%' : 'Telah Sah',
                            icon: Icons.check_circle_rounded,
                            badgeColor: BkuTheme.emerald,
                            progress: totalCount > 0 ? (approvedCount / totalCount) : 0.0,
                            progressColor: BkuTheme.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Menunggu Review',
                            value: '$pendingCount',
                            badgeText: 'Pending',
                            icon: Icons.hourglass_empty_rounded,
                            badgeColor: BkuTheme.sky,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Realisasi',
                            value: _formatCurrency(totalRealisasi),
                            badgeText: 'Pengeluaran',
                            icon: Icons.payments_rounded,
                            badgeColor: BkuTheme.rose,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OrmawaKpiCard(
                      title: 'Saldo Efisiensi Anggaran (Hemat)',
                      value: _formatCurrency(totalSavings),
                      badgeText: 'Efisiensi',
                      icon: Icons.savings_rounded,
                      badgeColor: BkuTheme.emerald,
                    ),
                    const SizedBox(height: 16),

                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua LPJ', count: totalCount),
                        OrmawaTabItem(key: 'diajukan', label: 'Menunggu Review', count: pendingCount),
                        OrmawaTabItem(key: 'revisi', label: 'Butuh Revisi', count: revisiCount),
                        OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: approvedCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),

                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul LPJ atau proposal terkait...',
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),

                    if (filteredLpjs.isEmpty)
                      BkuEmptyState(
                        title: 'Belum ada LPJ',
                        message: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Tidak ada laporan pertanggungjawaban yang sesuai dengan kriteria pencarian atau filter aktif.'
                            : 'Belum ada data laporan pertanggungjawaban (LPJ) kegiatan yang dibuat.',
                        buttonText: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Reset Filter & Cari Ulang'
                            : (canCreateLpj ? '+ Buat LPJ Baru' : null),
                        onButtonPressed: () async {
                          if (_searchQuery.isNotEmpty || _activeTab != 'all') {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _activeTab = 'all';
                            });
                          } else if (canCreateLpj) {
                            final prov = context.read<OrmawaProvider>();
                            final res = await context.push<bool>(AppRoutes.ormawaLpjCreate);
                            if (res == true && mounted) {
                              prov.refreshData();
                            }
                          }
                        },
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLpjs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final lpj = filteredLpjs[index];
                          final norm = _normalizeStatus(lpj.status);
                          final isLocked = norm == 'disetujui' || norm == 'selesai';
                          final diff = lpj.totalAnggaran - lpj.realisasiAnggaran;
                          final pct = lpj.totalAnggaran > 0 ? ((diff.abs() / lpj.totalAnggaran) * 100).round() : 0;
                          final statusColor = _getStatusColor(lpj.status);
                          final statusBg = _getStatusBg(lpj.status);
                          final statusBorder = _getStatusBorder(lpj.status);

                          return BkuCard(
                            onTap: () {
                              context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
                            },
                            padding: const EdgeInsets.all(14),
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: BkuTheme.borderSubtle,
                                              borderRadius: BkuTheme.r8,
                                              border: Border.all(color: BkuTheme.border),
                                            ),
                                            child: Text(
                                              '#LPJ-${lpj.id}',
                                              style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lpj.judul,
                                            style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w900),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (lpj.proposalTitle != null && lpj.proposalTitle!.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Icon(Icons.corporate_fare_rounded, size: 11, color: BkuTheme.textMuted),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    lpj.proposalTitle!,
                                                    style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                const SizedBox(height: 12),

                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: BkuTheme.borderSubtle,
                                    borderRadius: BkuTheme.r10,
                                    border: Border.all(color: BkuTheme.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pagu Usulan',
                                            style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _formatCurrency(lpj.totalAnggaran),
                                            style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Realisasi Dana',
                                            style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _formatCurrency(lpj.realisasiAnggaran),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: BkuTheme.emerald),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    if (diff > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.emeraldSoft,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.emeraldBorder),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.trending_down_rounded, size: 12, color: BkuTheme.emerald),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Hemat $pct% (+${_formatCurrency(diff)})',
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.emerald),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (diff < 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.roseSoft,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.roseBorder),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.trending_up_rounded, size: 12, color: BkuTheme.rose),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Over $pct% (-${_formatCurrency(diff.abs())})',
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.rose),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.borderSubtle,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.border),
                                        ),
                                        child: Text(
                                          '100% Sesuai Pagu',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    const Spacer(),

                                    InkWell(
                                      onTap: () => context.push(AppRoutes.ormawaLpjDetail, extra: lpj),
                                      borderRadius: BkuTheme.r8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BkuTheme.r8,
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.visibility_rounded, size: 12, color: Color(0xFF0F172A)),
                                            SizedBox(width: 4),
                                            Text('Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!isLocked && canEditLpj) ...[
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditLpjScreen(lpj: lpj),
                                            ),
                                          );
                                          if (context.mounted) {
                                            context.read<OrmawaProvider>().refreshData();
                                          }
                                        },
                                        borderRadius: BkuTheme.r8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BkuTheme.r8,
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit_rounded, size: 12, color: Color(0xFF0F172A)),
                                              SizedBox(width: 4),
                                              Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (!isLocked && canDeleteLpj) ...[
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => _confirmDelete(context, lpj.id, lpj.judul),
                                        borderRadius: BkuTheme.r8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: BkuTheme.roseSoft,
                                            borderRadius: BkuTheme.r8,
                                          ),
                                          child: const Icon(Icons.delete_outline_rounded, size: 14, color: BkuTheme.rose),
                                        ),
                                      ),
                                    ],
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