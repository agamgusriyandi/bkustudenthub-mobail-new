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
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/proposal_pdf_service.dart';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
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
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
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
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
        return BkuTheme.emeraldBorder;
      case 'ditolak':
        return BkuTheme.roseBorder;
      case 'revisi':
        return BkuTheme.amberBorder;
      default:
        return BkuTheme.skyBorder;
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
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => _loadData(true),
        color: BkuTheme.primary,
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
                                          'Manajemen Usulan &',
                                          style: BkuTheme.textBadge.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Proposal Kegiatan',
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
                                        Icon(Icons.description_rounded, size: 14, color: Color(0xFF0F172A)),
                                        SizedBox(width: 5),
                                        Text(
                                          'Proposal Ormawa',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Pengajuan naskah KAK/TOR, estimasi alokasi dana pagu, dan monitoring verifikasi persetujuan berjenjang.',
                                style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: BkuButton.outline(
                                      onPressed: () => _loadData(true),
                                      icon: Icons.refresh_rounded,
                                      text: 'Refresh',
                                      height: 36,
                                      isLoading: _isRefreshing,
                                    ),
                                  ),
                                  if (canCreateProposal) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: BkuButton.primary(
                                        onPressed: () => context.push(AppRoutes.ormawaProposalCreate),
                                        icon: Icons.add_rounded,
                                        text: 'Tambah Usulan',
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
                              title: 'Total Usulan',
                              value: '$totalCount',
                              badgeText: 'Semua Usulan',
                              icon: Icons.description_rounded,
                              badgeColor: BkuTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Menunggu Review',
                              value: '$diajukanCount',
                              badgeText: 'Antrean Review',
                              icon: Icons.schedule_rounded,
                              badgeColor: BkuTheme.sky,
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
                              badgeColor: BkuTheme.amber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Disetujui / Selesai',
                              value: '$disetujuiCount',
                              badgeText: totalCount > 0 ? '${((disetujuiCount / totalCount) * 100).round()}%' : 'ACC Tuntas',
                              icon: Icons.check_circle_rounded,
                              badgeColor: BkuTheme.emerald,
                              progress: totalCount > 0 ? (disetujuiCount / totalCount) : 0.0,
                              progressColor: BkuTheme.emerald,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: BkuTheme.emeraldSoft,
                          borderRadius: BkuTheme.r12,
                          border: Border.all(color: BkuTheme.emeraldBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, size: 16, color: BkuTheme.emerald),
                                const SizedBox(width: 8),
                                Text('Total Anggaran Usulan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: BkuTheme.emerald)),
                              ],
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(totalAnggaran)}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: BkuTheme.emerald),
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
                            style: BkuTheme.textBadge.copyWith(fontSize: 11.5, color: BkuTheme.textMuted, letterSpacing: 0.5),
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
                              child: const Text('Reset Filter', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filtered.isEmpty)
                        BkuEmptyState(
                          title: 'Belum Ada Usulan Proposal',
                          message: _searchQuery.isNotEmpty || _activeTab != 'all'
                              ? 'Tidak ada usulan proposal yang cocok dengan kriteria pencarian atau filter status aktif.'
                              : 'Belum ada data usulan proposal kegiatan yang dibuat untuk organisasi ini.',
                          buttonText: _searchQuery.isNotEmpty || _activeTab != 'all'
                              ? 'Reset Filter & Cari Ulang'
                              : (canCreateProposal ? '+ Buat Usulan Baru' : null),
                          onButtonPressed: () {
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
    final statusColor = _getStatusColor(p.status);
    final statusBg = _getStatusBg(p.status);
    final statusBorder = _getStatusBorder(p.status);

    return BkuCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r8,
                ),
                child: Text(
                  p.code,
                  style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
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
                  statusText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            p.title,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: BkuTheme.r8,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_rounded, size: 13, color: BkuTheme.emerald),
                const SizedBox(width: 5),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(p.budget)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.emerald),
                ),
                if (p.jadwalPelaksanaan != null && p.jadwalPelaksanaan!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.event_note_rounded, size: 13, color: BkuTheme.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.jadwalPelaksanaan!,
                      style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
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
                  borderRadius: BkuTheme.r8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    borderRadius: BkuTheme.r8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                InkWell(
                  onTap: () {
                    ProposalPdfService.showPdfActionSheet(
                      context,
                      p,
                      ormawaName: context.read<OrmawaProvider>().orgName,
                    );
                  },
                  borderRadius: BkuTheme.r8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BkuTheme.borderSubtle,
                      borderRadius: BkuTheme.r8,
                      border: Border.all(color: BkuTheme.border),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: BkuTheme.rose),
                  ),
                ),
                if (canDelete)
                  InkWell(
                    onTap: () => _confirmDelete(p),
                    borderRadius: BkuTheme.r8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BkuTheme.roseSoft,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 13, color: BkuTheme.rose),
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