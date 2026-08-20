import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/create_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/edit_pengumuman_screen.dart';
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
        return const Color(0xFF475569);
      case 'kegiatan':
        return OrmawaTheme.primary;
      case 'penting':
        return const Color(0xFFE11D48);
      case 'prestasi':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getCategoryBgColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'umum':
        return const Color(0xFFF1F5F9);
      case 'kegiatan':
        return OrmawaTheme.primarySoft;
      case 'penting':
        return const Color(0xFFFFE4E6);
      case 'prestasi':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF1F5F9);
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: OrmawaTheme.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: OrmawaTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Siaran Pengumuman',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Pusat Informasi Ormawa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
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
                                    borderRadius: BorderRadius.circular(20),
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
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy', 'id').format(displayDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.judul,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.isi,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF334155),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.lampiranUrl != null && item.lampiranUrl!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(item.lampiranUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: OrmawaTheme.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: OrmawaTheme.primary.withAlpha(40)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.attach_file_rounded, color: OrmawaTheme.primary, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Buka Berkas Lampiran',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: OrmawaTheme.primary,
                                    ),
                                  ),
                                ),
                                Icon(Icons.open_in_new_rounded, color: OrmawaTheme.primary, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPengumumanScreen(announcement: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrmawaTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text(
                          'Edit Siaran',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, OrmawaAnnouncement item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFE11D48), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hapus Pengumuman?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus siaran "${item.judul}"? Tindakan ini bersifat permanen.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
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
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                                        'Pusat Publikasi &',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Siaran Pengumuman',
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
                                      Icon(Icons.campaign_rounded, size: 14, color: OrmawaTheme.primary),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Warta Ormawa',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: OrmawaTheme.primaryDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Penyampaian maklumat resmi, surat edaran, dan kabar penting ke seluruh anggota dan mahasiswa.',
                              style: TextStyle(fontSize: 10.5, color: OrmawaTheme.textMuted, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _handleRefresh,
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
                                          MaterialPageRoute(builder: (_) => const CreatePengumumanScreen()),
                                        );
                                      },
                                      icon: const Icon(Icons.add_rounded, size: 15),
                                      label: const Text('Buat Pengumuman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                            title: 'Total Siaran',
                            value: '$totalSiaran',
                            badgeText: 'Semua Terbit',
                            icon: Icons.campaign_rounded,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Penting & Urgen',
                            value: '$totalPenting',
                            badgeText: 'Prioritas',
                            icon: Icons.priority_high_rounded,
                            badgeColor: const Color(0xFFE11D48),
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
                            badgeColor: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Kabar Prestasi',
                            value: '$totalPrestasi',
                            badgeText: 'Apresiasi',
                            icon: Icons.emoji_events_rounded,
                            badgeColor: const Color(0xFFD97706),
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
                      OrmawaEmptyCard(
                        title: 'Belum ada pengumuman',
                        description: _searchQuery.isNotEmpty || _activeTab != 'semua'
                            ? 'Tidak ada siaran atau pengumuman yang sesuai kriteria pencarian atau filter aktif.'
                            : 'Belum ada siaran pengumuman yang dipublikasikan untuk organisasi ini.',
                        icon: Icons.campaign_outlined,
                        actionLabel: _searchQuery.isNotEmpty || _activeTab != 'semua'
                            ? 'Reset Filter & Cari Ulang'
                            : (canCreate ? '+ Buat Pengumuman Baru' : null),
                        actionIcon: _searchQuery.isNotEmpty || _activeTab != 'semua'
                            ? Icons.refresh_rounded
                            : Icons.add_rounded,
                        isPrimaryAction: _searchQuery.isEmpty && _activeTab == 'semua',
                        onAction: () async {
                          if (_searchQuery.isNotEmpty || _activeTab != 'semua') {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _activeTab = 'semua';
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

                          return OrmawaCard(
                            onTap: () => _openDetailModal(context, item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catBg,
                                        borderRadius: BorderRadius.circular(6),
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
                                        DateFormat('dd MMM yyyy', 'id')
                                            .format(displayDate),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: OrmawaTheme.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item.judul,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: OrmawaTheme.textHeading,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item.isi,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: OrmawaTheme.textBody,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_circle_outlined,
                                          size: 13,
                                          color: OrmawaTheme.textMuted,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          item.targetAudiens.isNotEmpty
                                              ? item.targetAudiens
                                              : 'Publik Kampus',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: OrmawaTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              _openDetailModal(context, item),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: OrmawaTheme.border,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.visibility_outlined,
                                              size: 15,
                                              color: Color(0xFF0284C7),
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
                                                  builder: (_) =>
                                                      EditPengumumanScreen(
                                                    announcement: item,
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: OrmawaTheme.border,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 15,
                                                color: OrmawaTheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (canDelete) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () =>
                                                _confirmDelete(context, item),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: OrmawaTheme.border,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 15,
                                                color: Color(0xFFE11D48),
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