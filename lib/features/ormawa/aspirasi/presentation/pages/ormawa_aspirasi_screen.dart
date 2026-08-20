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
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_aspiration.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaAspirasiScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaAspirasiScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaAspirasiScreen> createState() => _OrmawaAspirasiScreenState();
}

class _OrmawaAspirasiScreenState extends State<OrmawaAspirasiScreen> {
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

  void _openDetailModal(BuildContext context, OrmawaAspiration item) {
    final tanggapanController = TextEditingController();
    String selectedStatus = 'selesai';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isSelesai = item.status == 'selesai';
          final isDitolak = item.status == 'ditolak';

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: OrmawaTheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.forum_rounded, color: OrmawaTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.judul.isEmpty ? 'Detail Aspirasi' : item.judul,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'Aspirasi Masuk Mahasiswa',
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
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusBadge(item.status),
                              if (item.createdAt != null)
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm', 'id').format(item.createdAt!),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.judul.isEmpty ? 'Tanpa Judul' : item.judul,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.isi,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
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
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.attachment_rounded, size: 14, color: Color(0xFF475569)),
                                    SizedBox(width: 6),
                                    Text('Lihat Berkas Lampiran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (isSelesai || isDitolak) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelesai ? const Color(0xFFECFDF5) : const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelesai ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelesai ? Icons.verified_rounded : Icons.cancel_rounded,
                                        size: 16,
                                        color: isSelesai ? const Color(0xFF047857) : const Color(0xFFBE123C),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isSelesai ? 'Tanggapan Resmi Pengurus' : 'Catatan Penolakan Aspirasi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isSelesai ? const Color(0xFF047857) : const Color(0xFFBE123C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.tanggapan != null && item.tanggapan!.isNotEmpty
                                        ? item.tanggapan!
                                        : 'Aspirasi telah ditindaklanjuti secara resmi oleh pengurus ormawa.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isSelesai ? const Color(0xFF065F46) : const Color(0xFF9F1239),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (context.read<OrmawaProvider>().hasPermission('ormawa.aspiration.update, ormawa.aspirations.update, respond_aspirations, ormawa.organisasi.manage')) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'KEPUTUSAN STATUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedStatus,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'selesai',
                                      child: Text(
                                        'Selesai / Diterima & Ditindaklanjuti',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ditolak',
                                      child: Text(
                                        'Ditolak / Di luar Wewenang',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFBE123C)),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedStatus = val);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'BERIKAN TANGGAPAN / SOLUSI RESMI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: tanggapanController,
                              maxLines: 4,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Tuliskan tanggapan atau tindak lanjut resmi dari pengurus organisasi...',
                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: OrmawaTheme.primary, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        if (tanggapanController.text.trim().isEmpty) {
                                          AppSnackbar.showWarning(context, 'Tuliskan tanggapan terlebih dahulu');
                                          return;
                                        }

                                        setDialogState(() => isSubmitting = true);
                                        try {
                                          await context.read<OrmawaProvider>().respondToAspiration(
                                            item.id,
                                            {
                                              'Status': selectedStatus,
                                              'Tanggapan': tanggapanController.text.trim(),
                                            },
                                          );
                                          if (context.mounted) {
                                            Navigator.pop(dialogCtx);
                                            AppSnackbar.showSuccess(context, 'Tanggapan resmi berhasil dikirim!');
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            AppSnackbar.showError(context, 'Gagal mengirim tanggapan: $e');
                                          }
                                        } finally {
                                          setDialogState(() => isSubmitting = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OrmawaTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: isSubmitting
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.send_rounded, size: 14),
                                label: Text(
                                  isSubmitting ? 'Mengirim...' : 'Kirim Tanggapan Resmi',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFEFF6FF);
    Color text = const Color(0xFF1D4ED8);
    String label = 'Menunggu';

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Selesai';
        break;
      case 'diproses':
      case 'proses':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        label = 'Diproses';
        break;
      case 'ditolak':
        bg = const Color(0xFFFFE4E6);
        text = const Color(0xFFBE123C);
        label = 'Ditolak';
        break;
      default:
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final aspirations = ormawaProvider.aspirations;

    final totalCount = aspirations.length;
    final answeredCount = aspirations.where((a) => a.status == 'selesai').length;
    final pendingCount = aspirations.where((a) => a.status == 'pending' || a.status == 'menunggu').length;
    final rejectedCount = aspirations.where((a) => a.status == 'ditolak').length;

    final filteredList = aspirations.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.judul.toLowerCase().contains(_searchQuery) ||
          item.isi.toLowerCase().contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_activeTab == 'all') return true;
      if (_activeTab == 'pending') return item.status == 'pending' || item.status == 'menunggu';
      return item.status == _activeTab;
    }).toList();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Aspirasi Mahasiswa',
              subtitle: 'Kanal Suara & Tanggapan',
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
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Aspirasi',
                            value: '$totalCount',
                            badgeText: 'Semua Masuk',
                            icon: Icons.forum_outlined,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Sudah Ditanggapi',
                            value: '$answeredCount',
                            badgeText: 'Selesai',
                            icon: Icons.check_circle_outline_rounded,
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
                            title: 'Menunggu Respon',
                            value: '$pendingCount',
                            badgeText: 'Pending',
                            icon: Icons.schedule_rounded,
                            badgeColor: const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Aspirasi Ditolak',
                            value: '$rejectedCount',
                            badgeText: 'Ditolak',
                            icon: Icons.cancel_outlined,
                            badgeColor: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: totalCount),
                        OrmawaTabItem(key: 'pending', label: 'Menunggu', count: pendingCount),
                        OrmawaTabItem(key: 'selesai', label: 'Selesai', count: answeredCount),
                        OrmawaTabItem(key: 'ditolak', label: 'Ditolak', count: rejectedCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari judul aspirasi atau isi pesan...',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),
                    if (filteredList.isEmpty)
                      OrmawaEmptyCard(
                        title: 'Belum ada aspirasi',
                        description: _searchQuery.isNotEmpty || _activeTab != 'semua'
                            ? 'Tidak ada aspirasi mahasiswa yang cocok dengan filter pencarian atau status aktif.'
                            : 'Belum ada pesan aspirasi atau masukan dari mahasiswa untuk organisasi ini.',
                        icon: Icons.forum_outlined,
                        actionLabel: _searchQuery.isNotEmpty || _activeTab != 'semua'
                            ? 'Reset Filter & Cari Ulang'
                            : null,
                        actionIcon: Icons.refresh_rounded,
                        onAction: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _activeTab = 'semua';
                          });
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

                          return OrmawaCard(
                            onTap: () => _openDetailModal(context, item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatusBadge(item.status),
                                    if (item.createdAt != null)
                                      Text(
                                        DateFormat('dd MMM yyyy', 'id')
                                            .format(item.createdAt!),
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
                                  item.judul.isEmpty ? 'Tanpa Judul' : item.judul,
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
                                          Icons.person_outline_rounded,
                                          size: 13,
                                          color: OrmawaTheme.textMuted,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          item.mahasiswaName.isNotEmpty
                                              ? item.mahasiswaName
                                              : 'Mahasiswa',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: OrmawaTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _openDetailModal(context, item),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: OrmawaTheme.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Tanggapi',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
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