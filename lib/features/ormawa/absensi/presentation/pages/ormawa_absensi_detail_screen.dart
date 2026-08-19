import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/edit_absensi_screen.dart';

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

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return const Color(0xFFFEF3C7);
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return const Color(0xFFD1FAE5);
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return const Color(0xFFFFE4E6);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return const Color(0xFFB45309);
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return const Color(0xFF047857);
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF1D4ED8);
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

  void _showDynamicQrModal(BuildContext context) {
    final nama = (widget.absensiData['Nama'] ?? widget.absensiData['nama'] ?? 'Sesi Kegiatan').toString();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _DetailDynamicQrDialog(
        agendaId: widget.absensiId,
        agendaTitle: nama,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;
    final provider = context.watch<OrmawaProvider>();

    final matchingAgenda = provider.agendas.where((a) => a.id.toString() == widget.absensiId.toString()).firstOrNull;

    final nama = matchingAgenda?.title ?? (widget.absensiData['Nama'] ?? widget.absensiData['nama'] ?? widget.absensiData['Judul'] ?? 'Detail Sesi').toString();
    final deskripsi = matchingAgenda?.description ?? (widget.absensiData['Deskripsi'] ?? widget.absensiData['deskripsi'] ?? '').toString();
    final lokasi = (matchingAgenda != null && matchingAgenda.location.isNotEmpty) ? matchingAgenda.location : (widget.absensiData['Lokasi'] ?? widget.absensiData['lokasi'] ?? 'Kampus Utama').toString();
    final status = matchingAgenda?.status ?? (widget.absensiData['Status'] ?? widget.absensiData['status'] ?? 'terjadwal').toString();
    final date = matchingAgenda?.date ?? (widget.absensiData['Tanggal'] != null ? DateTime.tryParse(widget.absensiData['Tanggal'].toString()) : null);
    final waktuMulai = matchingAgenda != null ? DateFormat('HH:mm').format(matchingAgenda.date) : (widget.absensiData['WaktuMulai'] ?? widget.absensiData['waktu_mulai'] ?? '-').toString();
    final waktuSelesai = matchingAgenda != null ? DateFormat('HH:mm').format(matchingAgenda.endDate) : (widget.absensiData['WaktuSelesai'] ?? widget.absensiData['waktu_selesai'] ?? '-').toString();

    final attendanceList = provider.attendanceList;
    final attendedCount = attendanceList.where((a) => a.status.toLowerCase() == 'hadir').length;
    final absentCount = attendanceList.where((a) => a.status.toLowerCase() == 'tidak_hadir' || a.status.toLowerCase() == 'alpa').length;
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail Presensi',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(15),
                          blurRadius: 12,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor),
                              ),
                            ),
                            Text(
                              'ID #${widget.absensiId}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(lokasi, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
                        primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Waktu Sesi',
                        _formatSessionTime(waktuMulai, waktuSelesai),
                        Icons.schedule_rounded,
                        primaryColor,
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
                        const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Rasio Kehadiran',
                        '$attendanceRate%',
                        Icons.percent_rounded,
                        const Color(0xFFD97706),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (deskripsi.isNotEmpty && deskripsi != '-') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF94A3B8).withAlpha(15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KETERANGAN KEGIATAN', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            deskripsi,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(15),
                          blurRadius: 12,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rekapitulasi Peserta', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                Text('$totalAttendance peserta terdaftar pada sesi ini', style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('$attendedCount Hadir', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: primaryColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Cari nama atau NIM peserta...',
                              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (provider.isLoading && attendanceList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
                          )
                        else if (filteredList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text('Belum ada data presensi peserta pada sesi ini.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
                                    backgroundColor: isHadir ? const Color(0xFFD1FAE5) : primaryColor.withAlpha(20),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isHadir ? const Color(0xFF047857) : primaryColor,
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
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'NIM: ${item.nim ?? item.mahasiswaId}',
                                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHadir ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isHadir ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      isHadir ? 'Hadir' : 'Belum Hadir',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: isHadir ? const Color(0xFF047857) : const Color(0xFF64748B),
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
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isHadir ? const Color(0xFFFFE4E6) : const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isHadir ? const Color(0xFFFECDD3) : const Color(0xFFA7F3D0)),
                                      ),
                                      child: Icon(
                                        isHadir ? Icons.close_rounded : Icons.check_rounded,
                                        size: 15,
                                        color: isHadir ? const Color(0xFFBE123C) : const Color(0xFF047857),
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showDynamicQrModal(context),
                      icon: const Icon(Icons.qr_code_rounded, size: 16),
                      label: const Text('Buka QR Presensi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Hapus Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE11D48),
                            side: const BorderSide(color: Color(0xFFFECDD3)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
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
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Edit Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF94A3B8).withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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

class _DetailDynamicQrDialogState extends State<_DetailDynamicQrDialog> with SingleTickerProviderStateMixin {
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
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                color: primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.qr_code_scanner_rounded, size: 28, color: primaryColor),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pemindaian QR Presensi Kegiatan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.agendaTitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(25),
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
                              colors: [Colors.transparent, primaryColor, primaryColor.withAlpha(200), primaryColor, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withAlpha(160),
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
                    Icon(Icons.access_time_rounded, size: 12, color: primaryColor),
                    const SizedBox(width: 4),
                    const Text('Token Otomatis Diperbarui:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ],
                ),
                Text('$_countdown s', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryColor, fontFamily: 'monospace')),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _countdown / 45,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'QR Code berganti otomatis setiap 45 detik untuk mencegah kecurangan absensi.',
              style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF334155),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tutup Panel QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
