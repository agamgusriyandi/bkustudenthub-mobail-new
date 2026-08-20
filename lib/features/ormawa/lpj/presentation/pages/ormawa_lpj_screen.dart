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
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
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

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    final norm = _normalizeStatus(status);
    switch (norm) {
      case 'disetujui':
      case 'selesai':
        return OrmawaBadgeVariant.success;
      case 'ditolak':
        return OrmawaBadgeVariant.danger;
      case 'revisi':
        return OrmawaBadgeVariant.warning;
      default:
        return OrmawaBadgeVariant.info;
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
      backgroundColor: OrmawaTheme.scaffoldBg,
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
                                        'Manajemen Laporan &',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Pertanggungjawaban LPJ',
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
                                      Icon(Icons.assignment_turned_in_rounded, size: 14, color: OrmawaTheme.primary),
                                      const SizedBox(width: 5),
                                      Text(
                                        'LPJ Ormawa',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pelaporan realisasi anggaran kegiatan, verifikasi bukti transaksi pengeluaran, dan efisiensi pagu.',
                              style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.read<OrmawaProvider>().refreshData(),
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
                                if (canCreateLpj) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
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
                                      icon: const Icon(Icons.add_rounded, size: 15),
                                      label: const Text('Buat LPJ Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                            title: 'Total Berkas LPJ',
                            value: '$totalCount',
                            badgeText: 'Total',
                            icon: Icons.description_rounded,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'LPJ Disetujui',
                            value: '$approvedCount',
                            badgeText: totalCount > 0 ? '${((approvedCount / totalCount) * 100).round()}%' : 'Telah Sah',
                            icon: Icons.check_circle_rounded,
                            badgeColor: const Color(0xFF10B981),
                            progress: totalCount > 0 ? (approvedCount / totalCount) : 0.0,
                            progressColor: const Color(0xFF10B981),
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
                            badgeColor: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Realisasi',
                            value: _formatCurrency(totalRealisasi),
                            badgeText: 'Pengeluaran',
                            icon: Icons.payments_rounded,
                            badgeColor: const Color(0xFFE11D48),
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
                      badgeColor: const Color(0xFF10B981),
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
                      OrmawaEmptyCard(
                        title: 'Belum ada LPJ',
                        description: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Tidak ada laporan pertanggungjawaban yang sesuai dengan kriteria pencarian atau filter aktif.'
                            : 'Belum ada data laporan pertanggungjawaban (LPJ) kegiatan yang dibuat.',
                        icon: Icons.folder_open_rounded,
                        actionLabel: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Reset Filter & Cari Ulang'
                            : (canCreateLpj ? '+ Buat LPJ Baru' : null),
                        actionIcon: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? Icons.refresh_rounded
                            : Icons.add_rounded,
                        isPrimaryAction: _searchQuery.isEmpty && _activeTab == 'all',
                        onAction: () async {
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

                          return OrmawaCard(
                            onTap: () {
                              context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
                            },
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
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: Text(
                                              '#LPJ-${lpj.id}',
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569), fontFamily: 'monospace'),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lpj.judul,
                                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (lpj.proposalTitle != null && lpj.proposalTitle!.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                const Icon(Icons.corporate_fare_rounded, size: 11, color: Color(0xFF64748B)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    lpj.proposalTitle!,
                                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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
                                    OrmawaBadge(
                                      text: lpj.status.toUpperCase(),
                                      variant: _getBadgeVariant(lpj.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'PAGU USULAN',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _formatCurrency(lpj.totalAnggaran),
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'REALISASI DANA',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _formatCurrency(lpj.realisasiAnggaran),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
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
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFBBF7D0)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.trending_down_rounded, size: 12, color: Color(0xFF16A34A)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Hemat $pct% (+${_formatCurrency(diff)})',
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (diff < 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFFECDD3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFFE11D48)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Over $pct% (-${_formatCurrency(diff.abs())})',
                                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: const Text(
                                          '100% Sesuai Pagu',
                                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                        ),
                                      ),
                                    const Spacer(),

                                    InkWell(
                                      onTap: () => context.push(AppRoutes.ormawaLpjDetail, extra: lpj),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: OrmawaTheme.primarySoft,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.visibility_rounded, size: 12, color: OrmawaTheme.primary),
                                            const SizedBox(width: 4),
                                            Text('Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: OrmawaTheme.primaryDark)),
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
                                         borderRadius: BorderRadius.circular(8),
                                         child: Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                           decoration: BoxDecoration(
                                             color: const Color(0xFFFEF3C7),
                                             borderRadius: BorderRadius.circular(8),
                                           ),
                                           child: const Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Icon(Icons.edit_rounded, size: 12, color: Color(0xFFD97706)),
                                               SizedBox(width: 4),
                                               Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                             ],
                                           ),
                                         ),
                                       ),
                                     ],
                                     if (!isLocked && canDeleteLpj) ...[
                                       const SizedBox(width: 6),
                                       InkWell(
                                         onTap: () => _confirmDelete(context, lpj.id, lpj.judul),
                                         borderRadius: BorderRadius.circular(8),
                                         child: Container(
                                           padding: const EdgeInsets.all(4),
                                           decoration: BoxDecoration(
                                             color: const Color(0xFFFFF1F2),
                                             borderRadius: BorderRadius.circular(8),
                                           ),
                                           child: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFE11D48)),
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