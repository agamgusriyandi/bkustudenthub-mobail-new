import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/proposal_pdf_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/edit_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaProposalScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaProposalScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaProposalScreen> createState() => _OrmawaProposalScreenState();
}

class _OrmawaProposalScreenState extends State<OrmawaProposalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'all';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData([bool isManual = false]) async {
    if (!mounted) return;
    if (isManual) setState(() => _isRefreshing = true);
    try {
      await context.read<OrmawaProvider>().refreshData();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
        return OrmawaBadgeVariant.success;
      case 'ditolak':
        return OrmawaBadgeVariant.danger;
      case 'revisi':
        return OrmawaBadgeVariant.warning;
      default:
        return OrmawaBadgeVariant.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui_prodi':
        return 'Disetujui Prodi';
      case 'disetujui_fakultas':
        return 'Acc Fakultas';
      case 'disetujui_univ':
        return 'Acc Univ';
      case 'revisi':
        return 'Butuh Revisi';
      case 'diajukan':
        return 'Diajukan';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status.toUpperCase();
    }
  }

  void _confirmDelete(OrmawaProposal p) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Proposal Usulan?',
      message: 'Apakah Anda yakin ingin membatalkan/menghapus usulan "${p.title}"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteProposal(p.id);
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Proposal berhasil dihapus');
            _loadData(true);
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus proposal: $e');
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
    final allProposals = provider.proposals;

    final canCreateProposal = provider.hasPermission('ormawa.proposals.create, create_proposal');
    final canEditProposal = provider.hasPermission('ormawa.proposals.update, edit_proposal');
    final canDeleteProposal = provider.hasPermission('ormawa.proposals.delete, delete_proposal');

    final totalCount = allProposals.length;
    final diajukanCount = allProposals.where((p) => p.status.toLowerCase() == 'diajukan').length;
    final revisiCount = allProposals.where((p) => p.status.toLowerCase() == 'revisi').length;
    final disetujuiCount = allProposals.where((p) {
      final s = p.status.toLowerCase();
      return s == 'disetujui' || s == 'disetujui_prodi' || s == 'disetujui_fakultas' || s == 'disetujui_univ' || s == 'selesai';
    }).length;
    final ditolakCount = allProposals.where((p) => p.status.toLowerCase() == 'ditolak').length;
    final totalAnggaran = allProposals.fold<double>(0.0, (sum, p) => sum + p.budget);

    List<OrmawaProposal> filtered = allProposals;
    if (_activeTab != 'all') {
      filtered = filtered.where((p) {
        final s = p.status.toLowerCase();
        if (_activeTab == 'diajukan') return s == 'diajukan';
        if (_activeTab == 'revisi') return s == 'revisi';
        if (_activeTab == 'disetujui') {
          return s == 'disetujui' || s == 'disetujui_prodi' || s == 'disetujui_fakultas' || s == 'disetujui_univ' || s == 'selesai';
        }
        if (_activeTab == 'ditolak') return s == 'ditolak';
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final title = p.title.toLowerCase();
        final pj = (p.pjKegiatan ?? '').toLowerCase();
        final bentuk = (p.bentukKegiatan ?? '').toLowerCase();
        final id = p.id.toLowerCase();
        return title.contains(_searchQuery) || pj.contains(_searchQuery) || bentuk.contains(_searchQuery) || id.contains(_searchQuery);
      }).toList();
    }

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => _loadData(true),
        color: OrmawaTheme.primary,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Proposal & Kegiatan',
              subtitle: 'Manajemen Usulan Ormawa',
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            if (provider.isLoading && allProposals.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

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
                                          'Manajemen Usulan &',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Proposal Kegiatan',
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
                                        Icon(Icons.description_rounded, size: 14, color: OrmawaTheme.primary),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Proposal Ormawa',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Pengajuan naskah KAK/TOR, estimasi alokasi dana pagu, dan monitoring verifikasi persetujuan berjenjang.',
                                style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _loadData(true),
                                      icon: _isRefreshing
                                          ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: OrmawaTheme.primary))
                                          : const Icon(Icons.refresh_rounded, size: 14),
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
                                  if (canCreateProposal) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => context.push(AppRoutes.ormawaProposalCreate),
                                        icon: const Icon(Icons.add_rounded, size: 15),
                                        label: const Text('Tambah Usulan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                              title: 'Total Usulan',
                              value: '$totalCount',
                              badgeText: 'Semua Usulan',
                              icon: Icons.description_rounded,
                              badgeColor: OrmawaTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Menunggu Review',
                              value: '$diajukanCount',
                              badgeText: 'Antrean Review',
                              icon: Icons.schedule_rounded,
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
                              title: 'Butuh Revisi',
                              value: '$revisiCount',
                              badgeText: 'Perlu Revisi',
                              icon: Icons.error_outline_rounded,
                              badgeColor: const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Disetujui / Selesai',
                              value: '$disetujuiCount',
                              badgeText: totalCount > 0 ? '${((disetujuiCount / totalCount) * 100).round()}%' : 'ACC Tuntas',
                              icon: Icons.check_circle_rounded,
                              badgeColor: const Color(0xFF059669),
                              progress: totalCount > 0 ? (disetujuiCount / totalCount) : 0.0,
                              progressColor: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF16A34A)),
                                SizedBox(width: 8),
                                Text('Total Anggaran Usulan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                              ],
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(totalAnggaran)}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      OrmawaFilterTabs(
                        tabs: [
                          OrmawaTabItem(key: 'all', label: 'Semua Usulan', count: totalCount),
                          OrmawaTabItem(key: 'diajukan', label: 'Diajukan', count: diajukanCount),
                          OrmawaTabItem(key: 'revisi', label: 'Butuh Revisi', count: revisiCount),
                          OrmawaTabItem(key: 'disetujui', label: 'Disetujui', count: disetujuiCount),
                          OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: ditolakCount),
                        ],
                        activeKey: _activeTab,
                        onTabChanged: (val) => setState(() => _activeTab = val),
                      ),
                      const SizedBox(height: 12),

                      OrmawaSearchBar(
                        controller: _searchController,
                        hintText: 'Cari judul usulan, PJ, atau kategori...',
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DAFTAR PROPOSAL (${filtered.length})',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                          ),
                          if (_activeTab != 'all' || _searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTab = 'all';
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Reset Filter', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filtered.isEmpty)
                        OrmawaEmptyCard(
                          title: 'Belum Ada Usulan Proposal',
                          description: _searchQuery.isNotEmpty || _activeTab != 'all'
                              ? 'Tidak ada usulan proposal yang cocok dengan kriteria pencarian atau filter status aktif.'
                              : 'Belum ada data usulan proposal kegiatan yang dibuat untuk organisasi ini.',
                          icon: Icons.assignment_outlined,
                          actionLabel: _searchQuery.isNotEmpty || _activeTab != 'all'
                              ? 'Reset Filter & Cari Ulang'
                              : (canCreateProposal ? '+ Buat Usulan Baru' : null),
                          actionIcon: _searchQuery.isNotEmpty || _activeTab != 'all'
                              ? Icons.refresh_rounded
                              : Icons.add_rounded,
                          isPrimaryAction: _searchQuery.isEmpty && _activeTab == 'all',
                          onAction: () {
                            if (_searchQuery.isNotEmpty || _activeTab != 'all') {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _activeTab = 'all';
                              });
                            } else if (canCreateProposal) {
                              context.push(AppRoutes.ormawaProposalCreate);
                            }
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final proposal = filtered[idx];
                            return _buildProposalCard(
                              context,
                              proposal,
                              canEdit: canEditProposal,
                              canDelete: canDeleteProposal,
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

  Widget _buildProposalCard(
    BuildContext context,
    OrmawaProposal p, {
    required bool canEdit,
    required bool canDelete,
  }) {
    final statusText = _getStatusText(p.status);
    final badgeVariant = _getBadgeVariant(p.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.code,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
              OrmawaBadge(
                text: statusText,
                variant: badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            p.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_rounded, size: 13, color: Color(0xFF16A34A)),
                const SizedBox(width: 5),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(p.budget)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                ),
                if (p.jadwalPelaksanaan != null && p.jadwalPelaksanaan!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.event_note_rounded, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.jadwalPelaksanaan!,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.push(AppRoutes.ormawaProposalDetail, extra: p),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_rounded, size: 12, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text('Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ],
                    ),
                  ),
                ),
                if (canEdit)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProposalScreen(proposal: p),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                InkWell(
                  onTap: () {
                    ProposalPdfService.showPdfActionSheet(
                      context,
                      p,
                      ormawaName: context.read<OrmawaProvider>().orgName,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Color(0xFFDC2626)),
                  ),
                ),
                if (canDelete)
                  InkWell(
                    onTap: () => _confirmDelete(p),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFE11D48)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}