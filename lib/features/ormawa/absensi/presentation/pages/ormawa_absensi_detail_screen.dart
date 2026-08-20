import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/edit_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';

class OrmawaAbsensiManagementDetailScreen extends StatefulWidget {
  final String absensiId;
  final Map<String, dynamic> absensiData;

  const OrmawaAbsensiManagementDetailScreen({
    super.key,
    required this.absensiId,
    required this.absensiData,
  });

  @override
  State<OrmawaAbsensiManagementDetailScreen> createState() =>
      _OrmawaAbsensiManagementDetailScreenState();
}

class _OrmawaAbsensiManagementDetailScreenState
    extends State<OrmawaAbsensiManagementDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _pollTimer;
  bool _isMutatingStatus = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchAttendance(widget.absensiId);
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<OrmawaProvider>().fetchAttendance(widget.absensiId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  bool _isEventAttendanceActive(OrmawaAgenda? agenda, DateTime? date, String status) {
    final s = status.toLowerCase();
    if (s == 'selesai' || s == 'terlaksana' || s == 'completed' || s == 'dibatalkan' || s == 'batal' || s == 'cancelled') {
      return false;
    }
    if (s == 'berlangsung' || s == 'ongoing') {
      return true;
    }

    final startDate = agenda?.date ?? date;
    final endDate = agenda?.endDate ?? startDate;

    if (startDate == null) return false;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final startDay = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
    final endDay = DateTime(endDate!.year, endDate.month, endDate.day, 23, 59, 59);

    return (todayStart.isAtSameMomentAs(startDay) || todayStart.isAfter(startDay)) &&
        (todayStart.isAtSameMomentAs(endDay) || todayStart.isBefore(endDay));
  }

  Future<void> _handleStartEventNow() async {
    setState(() => _isMutatingStatus = true);
    try {
      final provider = context.read<OrmawaProvider>();
      await provider.updateAgenda(widget.absensiId, {
        'Status': 'berlangsung',
        'status': 'berlangsung',
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Status kegiatan diubah menjadi Berlangsung');
        await provider.refreshData();
        setState(() => _isMutatingStatus = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMutatingStatus = false);
        AppSnackbar.showError(context, 'Gagal mengubah status kegiatan: $e');
      }
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return BkuTheme.amberSoft;
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return BkuTheme.emeraldSoft;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return BkuTheme.roseSoft;
      case 'direncanakan':
      case 'planned':
      case 'diajukan':
        return BkuTheme.borderSubtle;
      default:
        return BkuTheme.borderSubtle;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return BkuTheme.amber;
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return BkuTheme.emerald;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return BkuTheme.rose;
      case 'direncanakan':
      case 'planned':
      case 'diajukan':
        return BkuTheme.textBody;
      default:
        return BkuTheme.textBody;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return 'Sedang Berlangsung (Ongoing)';
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return 'Selesai Terlaksana';
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return 'Dibatalkan';
      case 'direncanakan':
      case 'planned':
      case 'diajukan':
        return 'Direncanakan';
      default:
        return 'Terjadwal';
    }
  }

  String _formatSessionTime(String mulai, String selesai) {
    if ((mulai == '00:00' || mulai == '-') && (selesai == '00:00' || selesai == '-' || selesai == '02:00')) {
      return 'Sepanjang Hari (Fleksibel)';
    }
    return '$mulai - $selesai WIB';
  }

  void _confirmDelete(BuildContext context) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Sesi Kegiatan?',
      message: 'Sesi absensi ini beserta seluruh log kehadiran peserta akan dihapus secara permanen.',
      primaryButtonText: 'Hapus Sesi',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteAgenda(widget.absensiId);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Sesi absensi berhasil dihapus');
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus sesi: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  void _showDynamicQrModal(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _DetailDynamicQrDialog(
        agendaId: widget.absensiId,
        agendaTitle: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();

    final matchingAgenda = provider.agendas.where((a) => a.id.toString() == widget.absensiId.toString()).firstOrNull;

    final nama = matchingAgenda?.title ?? (widget.absensiData['Nama'] ?? widget.absensiData['nama'] ?? widget.absensiData['Judul'] ?? 'Detail Sesi').toString();
    final deskripsi = matchingAgenda?.description ?? (widget.absensiData['Deskripsi'] ?? widget.absensiData['deskripsi'] ?? '').toString();
    final lokasi = (matchingAgenda != null && matchingAgenda.location.isNotEmpty) ? matchingAgenda.location : (widget.absensiData['Lokasi'] ?? widget.absensiData['lokasi'] ?? 'Kampus Utama').toString();
    final status = matchingAgenda?.status ?? (widget.absensiData['Status'] ?? widget.absensiData['status'] ?? 'terjadwal').toString();
    final date = matchingAgenda?.date ?? (widget.absensiData['Tanggal'] != null ? DateTime.tryParse(widget.absensiData['Tanggal'].toString()) : null);
    final waktuMulai = matchingAgenda != null ? DateFormat('HH:mm').format(matchingAgenda.date) : (widget.absensiData['WaktuMulai'] ?? widget.absensiData['waktu_mulai'] ?? '-').toString();
    final waktuSelesai = matchingAgenda != null ? DateFormat('HH:mm').format(matchingAgenda.endDate) : (widget.absensiData['WaktuSelesai'] ?? widget.absensiData['waktu_selesai'] ?? '-').toString();

    final isProposal = widget.absensiId.startsWith('prop-');
    final isAttendanceActive = _isEventAttendanceActive(matchingAgenda, date, status);
    final canManageAttendance = provider.hasPermission('ormawa.attendance.manage') || provider.hasPermission('ormawa.events.update') || provider.hasPermission('ormawa.events.manage');

    final attendanceList = provider.attendanceList;
    final attendedCount = attendanceList.where((a) => a.status.toLowerCase() == 'hadir').length;
    final absentCount = attendanceList.where((a) => a.status.toLowerCase() == 'tidak_hadir' || a.status.toLowerCase() == 'alpa' || a.status.toLowerCase() == 'belum_absen').length;
    final totalAttendance = attendanceList.length;
    final attendanceRate = totalAttendance > 0 ? ((attendedCount / totalAttendance) * 100).round() : 0;

    final filteredList = attendanceList.where((item) {
      if (_searchQuery.isEmpty) return true;
      final name = (item.mahasiswaName ?? '').toLowerCase();
      final nim = (item.nim ?? '').toLowerCase();
      return name.contains(_searchQuery) || nim.contains(_searchQuery);
    }).toList();

    final statusBg = _getStatusBgColor(status);
    final statusColor = _getStatusTextColor(status);
    final statusLabel = _getStatusLabel(status);

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail Presensi',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: isProposal ? BkuTheme.borderSubtle : BkuTheme.skySoft,
                                    borderRadius: BkuTheme.r8,
                                    border: Border.all(color: isProposal ? BkuTheme.border : BkuTheme.skyBorder),
                                  ),
                                  child: Text(
                                    isProposal ? 'Proposal' : 'Kegiatan Mandiri',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: isProposal ? BkuTheme.textBody : BkuTheme.sky,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'ID #${widget.absensiId}',
                              style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.textPlaceholder),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          style: BkuTheme.textPageTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w900, height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: BkuTheme.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(lokasi, style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildMetricCard(
                        'Tanggal Pelaksanaan',
                        date != null ? DateFormat('dd MMMM yyyy', 'id').format(date) : '—',
                        Icons.calendar_today_rounded,
                        BkuTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Waktu Sesi',
                        _formatSessionTime(waktuMulai, waktuSelesai),
                        Icons.schedule_rounded,
                        BkuTheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMetricCard(
                        'Kehadiran (Hadir/Alpa)',
                        '$attendedCount / $absentCount Peserta',
                        Icons.check_circle_rounded,
                        BkuTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Rasio Kehadiran',
                        '$attendanceRate%',
                        Icons.percent_rounded,
                        BkuTheme.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (deskripsi.isNotEmpty && deskripsi != '-') ...[
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      borderRadius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keterangan Kegiatan', style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.w900, color: BkuTheme.textMuted, letterSpacing: 0.3)),
                          const SizedBox(height: 8),
                          Text(
                            deskripsi,
                            style: BkuTheme.textBodyRegular.copyWith(fontSize: 11.5, color: BkuTheme.textBody, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rekapitulasi Peserta', style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w900)),
                                Text('$totalAttendance peserta terdaftar pada sesi ini', style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Text('$attendedCount Hadir', style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        BkuTextField(
                          controller: _searchController,
                          hint: 'Cari nama atau NIM peserta...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 16, color: BkuTheme.textPlaceholder),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 14, color: BkuTheme.textPlaceholder),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),

                        if (provider.isLoading && attendanceList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E))),
                          )
                        else if (filteredList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text('Belum ada data presensi peserta pada sesi ini.', style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textPlaceholder)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = filteredList[idx];
                              final isHadir = item.status.toLowerCase() == 'hadir';
                              final initial = (item.mahasiswaName != null && item.mahasiswaName!.isNotEmpty)
                                  ? item.mahasiswaName!.substring(0, 1).toUpperCase()
                                  : 'M';

                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isHadir ? BkuTheme.emeraldSoft : BkuTheme.primarySoft,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isHadir ? BkuTheme.emerald : BkuTheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.mahasiswaName ?? 'Mahasiswa #${item.mahasiswaId}',
                                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'NIM: ${item.nim ?? item.mahasiswaId}',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHadir ? BkuTheme.emeraldSoft : BkuTheme.borderSubtle,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(color: isHadir ? BkuTheme.emeraldBorder : BkuTheme.border),
                                    ),
                                    child: Text(
                                      isHadir ? 'Hadir' : 'Belum Hadir',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: isHadir ? BkuTheme.emerald : BkuTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  InkWell(
                                    onTap: () async {
                                      final targetStatus = isHadir ? 'tidak_hadir' : 'hadir';
                                      try {
                                        await provider.submitAttendance(widget.absensiId, item.mahasiswaId, targetStatus);
                                      } catch (e) {
                                        if (context.mounted) {
                                          final msg = ErrorHandler.getMessage(e);
                                          AppSnackbar.showError(context, 'Gagal mencatat presensi: $msg');
                                        }
                                      }
                                    },
                                    borderRadius: BkuTheme.r8,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isHadir ? BkuTheme.roseSoft : BkuTheme.emeraldSoft,
                                        borderRadius: BkuTheme.r8,
                                        border: Border.all(color: isHadir ? BkuTheme.roseBorder : BkuTheme.emeraldBorder),
                                      ),
                                      child: Icon(
                                        isHadir ? Icons.close_rounded : Icons.check_rounded,
                                        size: 15,
                                        color: isHadir ? BkuTheme.rose : BkuTheme.emerald,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isAttendanceActive) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BkuTheme.amberSoft,
                        borderRadius: BkuTheme.r12,
                        border: Border.all(color: BkuTheme.amberBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.event_busy_rounded, size: 18, color: BkuTheme.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sesi presensi belum dibuka. Pemindaian QR hanya aktif saat kegiatan berstatus Berlangsung atau pada hari tanggal kegiatan (${date != null ? DateFormat('d MMM yyyy', 'id').format(date) : '-'}).',
                                  style: TextStyle(fontSize: 10.5, color: BkuTheme.amber.withAlpha(220), height: 1.35),
                                ),
                              ),
                            ],
                          ),
                          if (canManageAttendance && status.toLowerCase() != 'selesai' && status.toLowerCase() != 'dibatalkan') ...[
                            const SizedBox(height: 10),
                            BkuButton.primary(
                              onPressed: _isMutatingStatus ? null : _handleStartEventNow,
                              isLoading: _isMutatingStatus,
                              icon: Icons.play_arrow_rounded,
                              text: 'Mulai Kegiatan Sekarang',
                              height: 38,
                              fontSize: 11,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: BkuButton.primary(
                            onPressed: () => _showDynamicQrModal(context, nama),
                            icon: Icons.qr_code_rounded,
                            text: 'Buka QR Presensi',
                            height: 44,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BkuButton.outline(
                            onPressed: () {
                              final ormawaProv = context.read<OrmawaProvider>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrmawaQrScanScreen(
                                    eventId: widget.absensiId,
                                    eventTitle: nama,
                                  ),
                                ),
                              ).then((_) {
                                ormawaProv.fetchAttendance(widget.absensiId);
                              });
                            },
                            icon: Icons.qr_code_scanner_rounded,
                            text: 'Scan QR Peserta',
                            height: 44,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: BkuButton.dangerOutline(
                          onPressed: () => _confirmDelete(context),
                          icon: Icons.delete_outline_rounded,
                          text: 'Hapus Sesi',
                          height: 40,
                          fontSize: 11,
                          customRadius: BkuTheme.r10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BkuButton.outline(
                          onPressed: () async {
                            final currentData = {
                              'id': widget.absensiId,
                              'Nama': nama,
                              'Judul': nama,
                              'Deskripsi': deskripsi,
                              'Lokasi': lokasi,
                              'Status': status,
                              'Tanggal': (date ?? DateTime.now()).toIso8601String(),
                              'TanggalMulai': (matchingAgenda?.date ?? date ?? DateTime.now()).toIso8601String(),
                              'TanggalSelesai': (matchingAgenda?.endDate ?? DateTime.now()).toIso8601String(),
                              'WaktuMulai': waktuMulai,
                              'WaktuSelesai': waktuSelesai,
                              'landasan_kegiatan': matchingAgenda?.landasanKegiatan ?? widget.absensiData['landasan_kegiatan'],
                              'bentuk_kegiatan': matchingAgenda?.bentukKegiatan ?? widget.absensiData['bentuk_kegiatan'],
                              'mitra': matchingAgenda?.mitra ?? widget.absensiData['mitra'],
                              'latar_belakang': matchingAgenda?.latarBelakang ?? widget.absensiData['latar_belakang'],
                              'tujuan_kegiatan': matchingAgenda?.tujuanKegiatan ?? widget.absensiData['tujuan_kegiatan'],
                              'jadwal_pelaksanaan': matchingAgenda?.jadwalPelaksanaan ?? widget.absensiData['jadwal_pelaksanaan'],
                              'sasaran_kegiatan': matchingAgenda?.sasaranKegiatan ?? widget.absensiData['sasaran_kegiatan'],
                              'indikator_keberhasilan': matchingAgenda?.indikatorKeberhasilan ?? widget.absensiData['indikator_keberhasilan'],
                              'sumber_dana': matchingAgenda?.sumberDana ?? widget.absensiData['sumber_dana'],
                              'estimasi_dana': matchingAgenda?.estimasiDana ?? widget.absensiData['estimasi_dana'],
                              'pj_kegiatan': matchingAgenda?.pjKegiatan ?? widget.absensiData['pj_kegiatan'],
                            };
                            final ormProvider = context.read<OrmawaProvider>();
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAbsensiScreen(absensiId: widget.absensiId, absensiData: currentData),
                              ),
                            );
                            if (res == true && mounted) {
                              await ormProvider.refreshData();
                              await ormProvider.fetchAttendance(widget.absensiId);
                            }
                          },
                          icon: Icons.edit_rounded,
                          text: 'Edit Sesi',
                          height: 40,
                          fontSize: 11,
                          customRadius: BkuTheme.r10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: BkuCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: BkuTheme.textBadge.copyWith(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailDynamicQrDialog extends StatefulWidget {
  final String agendaId;
  final String agendaTitle;

  const _DetailDynamicQrDialog({
    required this.agendaId,
    required this.agendaTitle,
  });

  @override
  State<_DetailDynamicQrDialog> createState() => _DetailDynamicQrDialogState();
}

class _DetailDynamicQrDialogState extends State<_DetailDynamicQrDialog>
    with SingleTickerProviderStateMixin {
  int _countdown = 45;
  Timer? _timer;
  late AnimationController _laserController;
  String _qrPayload = '';

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _generatePayload();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown <= 1) {
          _countdown = 45;
          _generatePayload();
        } else {
          _countdown--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _laserController.dispose();
    super.dispose();
  }

  void _generatePayload() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final token = (nowMs ~/ 1000).toString();
    _qrPayload = '${ApiGate.webUrl}/student/presensi?eventId=${widget.agendaId}&token=$token&t=$nowMs';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: BkuTheme.r24,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BkuTheme.primarySoft,
                borderRadius: BkuTheme.r12,
              ),
              child: Icon(Icons.qr_code_scanner_rounded, size: 28, color: BkuTheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Pemindaian QR Presensi Kegiatan',
              style: BkuTheme.textCardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.agendaTitle,
              style: BkuTheme.textCaption.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BkuTheme.r16,
                border: Border.all(color: BkuTheme.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: BkuTheme.primary.withAlpha(25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: QrImageView(
                      data: _qrPayload,
                      version: QrVersions.auto,
                      size: 190.0,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1E293B)),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1E293B)),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _laserController,
                    builder: (context, child) {
                      return Positioned(
                        top: 10 + (_laserController.value * 190),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, BkuTheme.primary, BkuTheme.primary.withAlpha(200), BkuTheme.primary, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BkuTheme.primary.withAlpha(160),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: BkuTheme.primary),
                    const SizedBox(width: 4),
                    Text('Token Otomatis Diperbarui:', style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.textMuted)),
                  ],
                ),
                Text('$_countdown s', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontFamily: 'monospace')),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BkuTheme.r8,
              child: LinearProgressIndicator(
                value: _countdown / 45,
                backgroundColor: BkuTheme.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(BkuTheme.primary),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR Code berganti otomatis setiap 45 detik untuk mencegah kecurangan absensi.',
              style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textPlaceholder),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            BkuButton.outline(
              onPressed: () => Navigator.pop(context),
              text: 'Tutup Panel QR',
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}