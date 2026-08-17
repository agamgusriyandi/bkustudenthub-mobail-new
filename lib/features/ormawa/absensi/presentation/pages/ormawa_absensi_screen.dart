import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/create_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_qr_scan_screen.dart';

class OrmawaAbsensiScreen extends StatefulWidget {
  final bool showBackButton;

  const OrmawaAbsensiScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaAbsensiScreen> createState() => _OrmawaAbsensiScreenState();
}

class _OrmawaAbsensiScreenState extends State<OrmawaAbsensiScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchAttController = TextEditingController();
  String _searchQuery = '';
  String _searchAttQuery = '';
  String _activeTab = 'all';
  bool _isRefreshing = false;
  OrmawaAgenda? _selectedAgenda;
  Timer? _attendancePollTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    _searchAttController.addListener(() {
      setState(() => _searchAttQuery = _searchAttController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAttController.dispose();
    _attendancePollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      final prov = context.read<OrmawaProvider>();
      await prov.refreshData();
      if (_selectedAgenda != null && mounted) {
        await prov.fetchAttendance(_selectedAgenda!.id);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _selectAgenda(OrmawaAgenda agenda) {
    setState(() {
      if (_selectedAgenda?.id == agenda.id) {
        _selectedAgenda = null;
        _attendancePollTimer?.cancel();
      } else {
        _selectedAgenda = agenda;
        context.read<OrmawaProvider>().fetchAttendance(agenda.id);
        _attendancePollTimer?.cancel();
        _attendancePollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (mounted && _selectedAgenda != null) {
            context.read<OrmawaProvider>().fetchAttendance(_selectedAgenda!.id);
          }
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id').format(date);
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
        return 'Berlangsung';
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return 'Selesai';
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Terjadwal';
    }
  }

  void _showDynamicQrModal(BuildContext context, OrmawaAgenda agenda) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _DynamicQrDialog(agenda: agenda),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;
    final primaryGradient = themeProvider.primaryGradient;

    if (provider.isLoading && provider.agendas.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'Sistem Presensi',
              subtitle: 'Absensi Kegiatan',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2.5, color: primaryColor),
                    const SizedBox(height: 12),
                    const Text('Memuat data presensi kegiatan...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final allAgendas = provider.agendas;
    final totalSessions = allAgendas.length;
    final ongoingCount = allAgendas.where((e) => e.status.toLowerCase() == 'berlangsung' || e.status.toLowerCase() == 'ongoing').length;
    final plannedCount = allAgendas.where((e) => e.status.toLowerCase() == 'terjadwal' || e.status.toLowerCase() == 'planned').length;
    final completedCount = allAgendas.where((e) => e.status.toLowerCase() == 'selesai' || e.status.toLowerCase() == 'terlaksana' || e.status.toLowerCase() == 'completed').length;

    final attendanceList = provider.attendanceList;
    final attendedCount = attendanceList.where((a) => a.status.toLowerCase() == 'hadir').length;
    final absentCount = attendanceList.where((a) => a.status.toLowerCase() == 'tidak_hadir' || a.status.toLowerCase() == 'alpa').length;
    final totalAttendance = attendanceList.length;
    final attendanceRate = totalAttendance > 0 ? ((attendedCount / totalAttendance) * 100).round() : 0;

    final filteredAgendas = allAgendas.where((agenda) {
      final statusKey = agenda.status.toLowerCase();
      bool matchTab = true;
      if (_activeTab == 'berlangsung') matchTab = (statusKey == 'berlangsung' || statusKey == 'ongoing');
      if (_activeTab == 'terjadwal') matchTab = (statusKey == 'terjadwal' || statusKey == 'planned');
      if (_activeTab == 'selesai') matchTab = (statusKey == 'selesai' || statusKey == 'terlaksana' || statusKey == 'completed');

      final matchQuery = _searchQuery.isEmpty ||
          agenda.title.toLowerCase().contains(_searchQuery) ||
          agenda.location.toLowerCase().contains(_searchQuery) ||
          (agenda.pjKegiatan != null && agenda.pjKegiatan!.toLowerCase().contains(_searchQuery));

      return matchTab && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Sistem Presensi',
            subtitle: 'Absensi Kegiatan',
            variant: AppBarVariant.ormawa,
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
                                color: primaryColor.withAlpha(18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: primaryColor.withAlpha(45)),
                              ),
                              child: Text('Presensi Realtime', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: _isRefreshing ? null : _loadData,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _isRefreshing
                                            ? SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: primaryColor,
                                                ),
                                              )
                                            : Icon(Icons.refresh_rounded, size: 13, color: primaryColor),
                                        const SizedBox(width: 4),
                                        const Text('Refresh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                      ],
                                    ),
                                  ),
                                ),
                                if (provider.hasPermission('submit_attendance')) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CreateAbsensiScreen()),
                                      ).then((_) => _loadData());
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_rounded, size: 13, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Tambah Sesi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sistem Presensi & Absensi Kegiatan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kelola kehadiran anggota ormawa, pantau rasio partisipasi, dan generate QR Code instan.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildKpiCard(
                        '$totalSessions',
                        'Total Sesi Kegiatan',
                        'Semua Sesi',
                        Icons.calendar_month_rounded,
                        primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildKpiCard(
                        _selectedAgenda != null ? '$totalAttendance' : '${provider.members.length}',
                        _selectedAgenda != null ? 'Peserta Terdaftar' : 'Total Anggota',
                        _selectedAgenda != null ? 'Sesi Terpilih' : 'Anggota Aktif',
                        Icons.people_alt_rounded,
                        const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildKpiCard(
                        _selectedAgenda != null ? '$attendedCount / $absentCount' : '— / —',
                        'Hadir / Tidak Hadir',
                        'Presensi',
                        Icons.check_circle_rounded,
                        const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      _buildKpiCard(
                        _selectedAgenda != null ? '$attendanceRate%' : '0%',
                        'Rasio Kehadiran',
                        'Persentase',
                        Icons.percent_rounded,
                        const Color(0xFFD97706),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_selectedAgenda != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(40),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
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
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('SESI AKTIF TERPILIH', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                              ),
                              InkWell(
                                onTap: () => setState(() => _selectedAgenda = null),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.close_rounded, size: 12, color: Colors.white),
                                      SizedBox(width: 3),
                                      Text('Tutup Sesi', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedAgenda!.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _selectedAgenda!.location.isNotEmpty ? _selectedAgenda!.location : 'Kampus Utama',
                                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showDynamicQrModal(context, _selectedAgenda!),
                                  icon: const Icon(Icons.qr_code_rounded, size: 15),
                                  label: const Text('Buka QR Presensi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final selectedId = _selectedAgenda!.id;
                                    final selectedTitle = _selectedAgenda!.title;
                                    final ormawaProv = context.read<OrmawaProvider>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrmawaQrScanScreen(
                                          eventId: selectedId,
                                          eventTitle: selectedTitle,
                                        ),
                                      ),
                                    ).then((_) {
                                      ormawaProv.fetchAttendance(selectedId);
                                    });
                                  },
                                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 15),
                                  label: const Text('Scan QR Peserta', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

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
                                  const Text('Rekapitulasi Kehadiran', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
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
                              controller: _searchAttController,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Cari nama atau NIM peserta...',
                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
                                suffixIcon: _searchAttQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                                        onPressed: () => _searchAttController.clear(),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                              ),
                            ),
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          _buildAttendanceParticipantList(provider, _selectedAgenda!.id, primaryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabPill('all', 'Semua Sesi', totalSessions, primaryColor),
                        const SizedBox(width: 6),
                        _buildTabPill('berlangsung', 'Berlangsung', ongoingCount, primaryColor),
                        const SizedBox(width: 6),
                        _buildTabPill('terjadwal', 'Terjadwal', plannedCount, primaryColor),
                        const SizedBox(width: 6),
                        _buildTabPill('selesai', 'Selesai', completedCount, primaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Cari judul kegiatan atau lokasi...',
                        hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (filteredAgendas.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.event_busy_rounded, size: 42, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 8),
                          Text('Belum ada sesi kegiatan', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          SizedBox(height: 4),
                          Text('Tidak ada agenda yang cocok dengan filter.', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAgendas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final agenda = filteredAgendas[index];
                        final isSelected = _selectedAgenda?.id == agenda.id;

                        final statusBg = _getStatusBgColor(agenda.status);
                        final statusText = _getStatusTextColor(agenda.status);
                        final statusLabel = _getStatusLabel(agenda.status);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? primaryColor.withAlpha(15) : const Color(0xFF94A3B8).withAlpha(15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(statusLabel, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: statusText)),
                                    ),
                                    Text(
                                      '${_formatDate(agenda.date)}, ${DateFormat('HH:mm').format(agenda.date)} WIB',
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  agenda.title,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        agenda.location.isNotEmpty ? agenda.location : 'Kampus Utama',
                                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18, color: Color(0xFFF1F5F9)),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _selectAgenda(agenda),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isSelected ? Colors.white : primaryColor,
                                          backgroundColor: isSelected ? primaryColor : primaryColor.withAlpha(18),
                                          side: BorderSide(color: isSelected ? primaryColor : primaryColor.withAlpha(50)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          isSelected ? 'Sesi Aktif' : 'Pilih Sesi',
                                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () => _showDynamicQrModal(context, agenda),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.qr_code_rounded, size: 14, color: primaryColor),
                                            const SizedBox(width: 4),
                                            const Text('QR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OrmawaAbsensiManagementDetailScreen(
                                              absensiId: agenda.id,
                                              absensiData: {
                                                'id': agenda.id,
                                                'Nama': agenda.title,
                                                'Lokasi': agenda.location,
                                                'Tanggal': agenda.date.toIso8601String(),
                                                'WaktuMulai': DateFormat('HH:mm').format(agenda.date),
                                                'WaktuSelesai': DateFormat('HH:mm').format(agenda.endDate),
                                                'Status': agenda.status,
                                                'Deskripsi': agenda.description,
                                              },
                                            ),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildAttendanceParticipantList(OrmawaProvider provider, String eventId, Color primaryColor) {
    if (provider.isLoading && provider.attendanceList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
      );
    }

    final list = provider.attendanceList;
    final filtered = list.where((item) {
      if (_searchAttQuery.isEmpty) return true;
      final name = (item.mahasiswaName ?? '').toLowerCase();
      final nim = (item.nim ?? '').toLowerCase();
      return name.contains(_searchAttQuery) || nim.contains(_searchAttQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Belum ada data presensi peserta pada sesi ini.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, idx) {
        final item = filtered[idx];
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
                  await provider.submitAttendance(eventId, item.mahasiswaId, targetStatus);
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
    );
  }

  Widget _buildKpiCard(String value, String title, String subtitle, IconData icon, Color color) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(subtitle, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
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

  Widget _buildTabPill(String tabId, String label, int count, Color primaryColor) {
    final isActive = _activeTab == tabId;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabId),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? primaryColor : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withAlpha(50) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicQrDialog extends StatefulWidget {
  final OrmawaAgenda agenda;

  const _DynamicQrDialog({required this.agenda});

  @override
  State<_DynamicQrDialog> createState() => _DynamicQrDialogState();
}

class _DynamicQrDialogState extends State<_DynamicQrDialog> with SingleTickerProviderStateMixin {
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
    _qrPayload = 'https://stag.bkustudenthub.com/student/presensi?eventId=${widget.agenda.id}&token=$token&t=$nowMs';
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
              widget.agenda.title,
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
