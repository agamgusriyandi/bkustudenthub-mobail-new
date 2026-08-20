import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/create_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/edit_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/ormawa_pengumuman_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaPengumumanScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaPengumumanScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaPengumumanScreen> createState() => _OrmawaPengumumanScreenState();
}

class _OrmawaPengumumanScreenState extends State<OrmawaPengumumanScreen> {
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

  Future<void> _handleRefresh() async {
    await context.read<OrmawaProvider>().refreshData();
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'umum':
        return BkuTheme.textBody;
      case 'kegiatan':
        return BkuTheme.primary;
      case 'penting':
        return BkuTheme.rose;
      case 'prestasi':
        return BkuTheme.amber;
      default:
        return BkuTheme.textBody;
    }
  }

  Color _getCategoryBgColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'umum':
        return BkuTheme.borderSubtle;
      case 'kegiatan':
        return BkuTheme.primarySoft;
      case 'penting':
        return BkuTheme.roseSoft;
      case 'prestasi':
        return BkuTheme.amberSoft;
      default:
        return BkuTheme.borderSubtle;
    }
  }

  String _getCategoryLabel(String cat) {
    switch (cat.toLowerCase()) {
      case 'umum':
        return 'Umum';
      case 'kegiatan':
        return 'Kegiatan';
      case 'penting':
        return 'Penting';
      case 'prestasi':
        return 'Prestasi';
      default:
        return cat.toUpperCase();
    }
  }

  void _openDetailModal(BuildContext context, OrmawaAnnouncement item) {
    final catColor = _getCategoryColor(item.kategori);
    final catBg = _getCategoryBgColor(item.kategori);
    final displayDate = item.tanggalMulai ?? item.createdAt;

    BkuBottomSheet.show(
      context: context,
      title: 'Detail Siaran Pengumuman',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BkuCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catBg,
                        borderRadius: BkuTheme.r20,
                        border: Border.all(color: catColor.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getCategoryLabel(item.kategori),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (displayDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: BkuTheme.textPlaceholder,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy', 'id').format(displayDate),
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: BkuTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.judul,
                  style: BkuTheme.textSectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.isi,
                  style: BkuTheme.textBodyRegular.copyWith(
                    fontSize: 12.5,
                    color: BkuTheme.textBody,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (item.lampiranUrl != null && item.lampiranUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final uri = Uri.parse(item.lampiranUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BkuTheme.r12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file_rounded, color: BkuTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buka Berkas Lampiran',
                        style: BkuTheme.textCardTitle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BkuTheme.primary,
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded, color: BkuTheme.primary, size: 16),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BkuButton.outline(
                  onPressed: () => Navigator.pop(context),
                  text: 'Tutup',
                  height: 42,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BkuButton.primary(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPengumumanScreen(announcement: item),
                      ),
                    );
                  },
                  icon: Icons.edit_rounded,
                  text: 'Edit Siaran',
                  height: 42,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, OrmawaAnnouncement item) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Pengumuman?',
      message: 'Apakah Anda yakin ingin menghapus siaran "${item.judul}"? Tindakan ini bersifat permanen.',
      primaryButtonText: 'Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteAnnouncement(item.id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Pengumuman berhasil dihapus');
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus pengumuman: $e');
          }
        }
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final announcements = ormawaProvider.announcements;

    final totalSiaran = announcements.length;
    final totalPenting = announcements.where((p) => p.kategori == 'penting').length;
    final totalKegiatan = announcements.where((p) => p.kategori == 'kegiatan').length;
    final totalPrestasi = announcements.where((p) => p.kategori == 'prestasi').length;

    final filteredList = announcements.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.judul.toLowerCase().contains(_searchQuery) ||
          item.isi.toLowerCase().contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_activeTab == 'all') return true;
      return item.kategori == _activeTab;
    }).toList();

    final canCreate = ormawaProvider.hasPermission('ormawa.announcements.create, create_announcements, create_announcement');
    final canEdit = ormawaProvider.hasPermission('ormawa.announcements.update, edit_announcements, edit_announcement');
    final canDelete = ormawaProvider.hasPermission('ormawa.announcements.delete, delete_announcements, delete_announcement');

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: BkuTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Siaran & Pengumuman',
              subtitle: 'Pusat Informasi & Publikasi',
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
                    FadeInAnimation(
                      delay: 0.1,
                      child: BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
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
                                        'Pusat Publikasi &',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Siaran Pengumuman',
                                        style: BkuTheme.textSectionTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w900),
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
                                      Icon(Icons.campaign_rounded, size: 14, color: Color(0xFF0F172A)),
                                      SizedBox(width: 5),
                                      Text(
                                        'Warta Ormawa',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Penyampaian maklumat resmi, surat edaran, dan kabar penting ke seluruh anggota dan mahasiswa.',
                              style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: BkuButton.outline(
                                    onPressed: _handleRefresh,
                                    icon: Icons.refresh_rounded,
                                    text: 'Refresh',
                                    height: 38,
                                    fontSize: 11,
                                    customRadius: BkuTheme.r12,
                                  ),
                                ),
                                if (canCreate) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: BkuButton.primary(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const CreatePengumumanScreen()),
                                        );
                                      },
                                      icon: Icons.add_rounded,
                                      text: 'Buat Siaran',
                                      height: 38,
                                      fontSize: 11,
                                      customRadius: BkuTheme.r12,
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
                            title: 'Total Siaran',
                            value: '$totalSiaran',
                            badgeText: 'Semua Terbit',
                            icon: Icons.campaign_rounded,
                            badgeColor: BkuTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Penting & Urgen',
                            value: '$totalPenting',
                            badgeText: 'Prioritas',
                            icon: Icons.priority_high_rounded,
                            badgeColor: BkuTheme.rose,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Info Kegiatan',
                            value: '$totalKegiatan',
                            badgeText: 'Agenda Proker',
                            icon: Icons.event_rounded,
                            badgeColor: BkuTheme.sky,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Kabar Prestasi',
                            value: '$totalPrestasi',
                            badgeText: 'Apresiasi',
                            icon: Icons.emoji_events_rounded,
                            badgeColor: BkuTheme.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: totalSiaran),
                        OrmawaTabItem(key: 'umum', label: 'Umum', count: announcements.where((p) => p.kategori == 'umum').length),
                        OrmawaTabItem(key: 'kegiatan', label: 'Kegiatan', count: totalKegiatan),
                        OrmawaTabItem(key: 'penting', label: 'Penting', count: totalPenting),
                        OrmawaTabItem(key: 'prestasi', label: 'Prestasi', count: totalPrestasi),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul siaran atau isi informasi...',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),
                    if (filteredList.isEmpty)
                      BkuEmptyState(
                        title: 'Belum Ada Pengumuman',
                        message: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Tidak ada siaran atau pengumuman yang sesuai kriteria pencarian atau filter aktif.'
                            : 'Belum ada siaran pengumuman yang dipublikasikan untuk organisasi ini.',
                        icon: Icons.campaign_outlined,
                        buttonText: _searchQuery.isNotEmpty || _activeTab != 'all'
                            ? 'Reset Filter & Cari Ulang'
                            : (canCreate ? 'Buat Pengumuman Baru' : null),
                        onButtonPressed: () async {
                          if (_searchQuery.isNotEmpty || _activeTab != 'all') {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _activeTab = 'all';
                            });
                          } else if (canCreate) {
                            final prov = context.read<OrmawaProvider>();
                            final res = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePengumumanScreen()),
                            );
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
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final catColor = _getCategoryColor(item.kategori);
                          final catBg = _getCategoryBgColor(item.kategori);
                          final displayDate = item.tanggalMulai ?? item.createdAt;

                          return BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            borderRadius: 16,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrmawaPengumumanDetailScreen(announcement: item),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catBg,
                                        borderRadius: BkuTheme.r8,
                                      ),
                                      child: Text(
                                        _getCategoryLabel(item.kategori),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: catColor,
                                        ),
                                      ),
                                    ),
                                    if (displayDate != null)
                                      Text(
                                        DateFormat('dd MMM yyyy', 'id').format(displayDate),
                                        style: BkuTheme.textCaption.copyWith(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: BkuTheme.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.judul,
                                  style: BkuTheme.textCardTitle.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.isi,
                                  style: BkuTheme.textCaption.copyWith(
                                    fontSize: 11.5,
                                    color: BkuTheme.textBody,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_circle_outlined,
                                          size: 13,
                                          color: BkuTheme.textPlaceholder,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.targetAudiens.isNotEmpty
                                              ? item.targetAudiens
                                              : 'Publik Kampus',
                                          style: BkuTheme.textCaption.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: BkuTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _openDetailModal(context, item),
                                          borderRadius: BkuTheme.r8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: BkuTheme.borderSubtle,
                                              borderRadius: BkuTheme.r8,
                                              border: Border.all(
                                                color: BkuTheme.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.visibility_outlined,
                                              size: 15,
                                              color: BkuTheme.sky,
                                            ),
                                          ),
                                        ),
                                        if (canEdit) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => EditPengumumanScreen(
                                                    announcement: item,
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius: BkuTheme.r8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: BkuTheme.borderSubtle,
                                                borderRadius: BkuTheme.r8,
                                                border: Border.all(
                                                  color: BkuTheme.border,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 15,
                                                color: BkuTheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (canDelete) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => _confirmDelete(context, item),
                                            borderRadius: BkuTheme.r8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: BkuTheme.roseSoft,
                                                borderRadius: BkuTheme.r8,
                                                border: Border.all(
                                                  color: BkuTheme.roseBorder,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 15,
                                                color: BkuTheme.rose,
                                              ),
                                            ),
                                          ),
                                        ],
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