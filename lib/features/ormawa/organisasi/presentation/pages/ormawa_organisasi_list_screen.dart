import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/create_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/edit_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/ormawa_organisasi_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaOrganisasiListScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaOrganisasiListScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaOrganisasiListScreen> createState() => _OrmawaOrganisasiListScreenState();
}

class _OrmawaOrganisasiListScreenState extends State<OrmawaOrganisasiListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchOrganisasi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrmawaOrganisasi> _getFiltered(List<OrmawaOrganisasi> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((o) {
      return o.nama.toLowerCase().contains(_searchQuery) ||
          o.deskripsi.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _confirmDelete(OrmawaOrganisasi org) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Organisasi',
      message: 'Apakah Anda yakin ingin menghapus\n${org.nama}?',
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteOrganisasi(org.id.toString());
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Organisasi berhasil dihapus');
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filtered = _getFiltered(provider.organisasiList);
        final total = provider.organisasiList.length;
        final aktif = provider.organisasiList.where((o) => o.status.toLowerCase() == 'aktif').length;
        final nonaktif = total - aktif;
        final canCreate = provider.hasPermission('ormawa.organisasi.create, ormawa.organisasi.manage, manage_organisasi, faculty_ormawa.create');

        return Scaffold(
          backgroundColor: OrmawaTheme.scaffoldBg,
          body: RefreshIndicator(
            onRefresh: () => provider.fetchOrganisasi(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Manajemen Organisasi',
                  subtitle: 'Database Organisasi Mahasiswa',
                  expandedHeight: 120.0,
                  showBackButton: widget.showBackButton,
                  isExpandable: false,
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 12,
                      ),
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
                                              'Direktori Institusi &',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Organisasi Mahasiswa',
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
                                            Icon(Icons.apartment_rounded, size: 14, color: OrmawaTheme.primary),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Database Ormawa',
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Pusat data kelembagaan ormawa, unit kegiatan mahasiswa (UKM), dan himpunan mahasiswa jurusan.',
                                    style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => provider.fetchOrganisasi(),
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
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const CreateOrganisasiScreen()),
                                              );
                                            },
                                            icon: const Icon(Icons.add_rounded, size: 15),
                                            label: const Text('Tambah Ormawa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                                  title: 'Total Ormawa',
                                  value: '$total',
                                  badgeText: 'Terdaftar',
                                  icon: Icons.business_rounded,
                                  badgeColor: OrmawaTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Status Aktif',
                                  value: '$aktif',
                                  badgeText: 'Operasional',
                                  icon: Icons.check_circle_rounded,
                                  badgeColor: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Status Nonaktif',
                                  value: '$nonaktif',
                                  badgeText: 'Vakum',
                                  icon: Icons.pause_circle_rounded,
                                  badgeColor: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OrmawaKpiCard(
                                  title: 'Hasil Pencarian',
                                  value: '${filtered.length}',
                                  badgeText: 'Tersaring',
                                  icon: Icons.filter_alt_rounded,
                                  badgeColor: const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OrmawaSearchBar(
                            controller: _searchController,
                            hintText: 'Cari organisasi, bidang, atau deskripsi...',
                            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                          ),
                          const SizedBox(height: 14),
                          if (filtered.isEmpty)
                            const OrmawaEmptyCard(
                              title: 'Belum Ada Organisasi',
                              description: 'Tidak ada data organisasi yang sesuai dengan kata kunci pencarian.',
                              icon: Icons.business_outlined,
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final org = filtered[index];
                                return _buildOrganisasiCard(org, provider);
                              },
                            ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrganisasiCard(OrmawaOrganisasi org, OrmawaProvider provider) {
    final isAktif = org.status.toLowerCase() == 'aktif';

    return OrmawaCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrmawaOrganisasiDetailScreen(organisasi: org)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: OrmawaTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OrmawaTheme.primary.withAlpha(30)),
            ),
            child: Icon(
              Icons.business_rounded,
              color: OrmawaTheme.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        org.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: OrmawaTheme.textHeading,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: OrmawaTheme.textPlaceholder),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 16, color: Color(0xFF0284C7)),
                              SizedBox(width: 8),
                              Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditOrganisasiScreen(organisasi: org)),
                          );
                        } else if (val == 'delete') {
                          _confirmDelete(org);
                        }
                      },
                    ),
                  ],
                ),
                if (org.deskripsi.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    org.deskripsi,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: OrmawaTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAktif
                            ? OrmawaTheme.statusSuccessBg
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        org.status.toUpperCase(),
                        style: TextStyle(
                          color: isAktif ? OrmawaTheme.statusSuccessText : OrmawaTheme.textMuted,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (org.tahunBerdiri != null && org.tahunBerdiri!.isNotEmpty) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: OrmawaTheme.primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Berdiri ${org.tahunBerdiri}',
                          style: TextStyle(
                            color: OrmawaTheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}