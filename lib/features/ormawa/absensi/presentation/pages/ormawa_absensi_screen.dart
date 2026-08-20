import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
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
  bool _isMutatingStatus = false;
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
        _searchAttController.clear();
      } else {
        _selectedAgenda = agenda;
        _searchAttController.clear();
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

  bool _isEventAttendanceActive(OrmawaAgenda agenda) {
    final s = agenda.status.toLowerCase();
    if (s == 'selesai' || s == 'terlaksana' || s == 'completed' || s == 'dibatalkan' || s == 'batal' || s == 'cancelled') {
      return false;
    }
    if (s == 'berlangsung' || s == 'ongoing') {
      return true;
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final startDay = DateTime(agenda.date.year, agenda.date.month, agenda.date.day, 0, 0, 0);
    final endDay = DateTime(agenda.endDate.year, agenda.endDate.month, agenda.endDate.day, 23, 59, 59);

    return (todayStart.isAtSameMomentAs(startDay) || todayStart.isAfter(startDay)) &&
        (todayStart.isAtSameMomentAs(endDay) || todayStart.isBefore(endDay));
  }

  Future<void> _handleStartEventNow(OrmawaAgenda agenda) async {
    setState(() => _isMutatingStatus = true);
    try {
      final provider = context.read<OrmawaProvider>();
      await provider.updateAgenda(agenda.id, {
        'Status': 'berlangsung',
        'status': 'berlangsung',
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Status kegiatan diubah menjadi Berlangsung');
        OrmawaAgenda updated = agenda;
        for (final a in provider.agendas) {
          if (a.id == agenda.id) {
            updated = a;
            break;
          }
        }
        setState(() {
          _selectedAgenda = updated;
          _isMutatingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMutatingStatus = false);
        AppSnackbar.showError(context, 'Gagal mengubah status kegiatan: $e');
      }
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final isSame = start.year == end.year && start.month == end.month && start.day == end.day;
    if (isSame) {
      return DateFormat('EEEE, d MMMM yyyy', 'id').format(start);
    }
    return '${DateFormat('d MMM yyyy', 'id').format(start)} s/d ${DateFormat('d MMM yyyy', 'id').format(end)}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startStr = DateFormat('HH:mm').format(start);
    final endStr = DateFormat('HH:mm').format(end);
    if (startStr == endStr || (start.hour == 0 && start.minute == 0 && end.hour == 0 && end.minute == 0)) {
      return '';
    }
    return '$startStr - $endStr WIB';
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
        return 'Berlangsung';
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return 'Selesai';
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

    if (provider.isLoading && provider.agendas.isEmpty) {
      return Scaffold(
        backgroundColor: BkuTheme.scaffoldBg,
        body: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'Sistem Presensi',
              subtitle: 'Absensi Kegiatan',
              variant: AppBarVariant.ormawa,
              expandedHeight: 125.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0F766E)),
                    const SizedBox(height: 12),
                    Text('Memuat data presensi kegiatan...', style: TextStyle(fontSize: 12, color: BkuTheme.textMuted)),
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
    final plannedCount = allAgendas.where((e) => e.status.toLowerCase() == 'terjadwal').length;
    final direncanakanCount = allAgendas.where((e) {
      final s = e.status.toLowerCase();
      return s == 'direncanakan' || s == 'planned' || s == 'diajukan';
    }).length;
    final completedCount = allAgendas.where((e) => e.status.toLowerCase() == 'selesai' || e.status.toLowerCase() == 'terlaksana' || e.status.toLowerCase() == 'completed').length;

    final attendanceList = provider.attendanceList;
    final attendedCount = attendanceList.where((a) => a.status.toLowerCase() == 'hadir').length;
    final absentCount = attendanceList.where((a) => a.status.toLowerCase() == 'tidak_hadir' || a.status.toLowerCase() == 'alpa' || a.status.toLowerCase() == 'belum_absen').length;
    final totalAttendance = attendanceList.length;
    final attendanceRate = totalAttendance > 0 ? ((attendedCount / totalAttendance) * 100).round() : 0;

    final filteredAgendas = allAgendas.where((agenda) {
      final statusKey = agenda.status.toLowerCase();
      bool matchTab = true;
      if (_activeTab == 'berlangsung') matchTab = (statusKey == 'berlangsung' || statusKey == 'ongoing');
      if (_activeTab == 'terjadwal') matchTab = (statusKey == 'terjadwal');
      if (_activeTab == 'direncanakan') matchTab = (statusKey == 'direncanakan' || statusKey == 'planned' || statusKey == 'diajukan');
      if (_activeTab == 'selesai') matchTab = (statusKey == 'selesai' || statusKey == 'terlaksana' || statusKey == 'completed');

      final matchQuery = _searchQuery.isEmpty ||
          agenda.title.toLowerCase().contains(_searchQuery) ||
          agenda.location.toLowerCase().contains(_searchQuery) ||
          (agenda.pjKegiatan != null && agenda.pjKegiatan!.toLowerCase().contains(_searchQuery));

      return matchTab && matchQuery;
    }).toList();

    final canCreateEvent = provider.hasPermission('ormawa.events.create') || provider.hasPermission('submit_attendance');
    final canManageAttendance = provider.hasPermission('ormawa.attendance.manage') || provider.hasPermission('ormawa.events.update') || provider.hasPermission('ormawa.events.manage');

    OrmawaAgenda? selected;
    if (_selectedAgenda != null) {
      for (final a in provider.agendas) {
        if (a.id == _selectedAgenda!.id) {
          selected = a;
          break;
        }
      }
      selected ??= _selectedAgenda;
    }
    final liveSelectedAgenda = selected;

    final isAttendanceActive = liveSelectedAgenda != null ? _isEventAttendanceActive(liveSelectedAgenda) : false;

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Sistem Presensi',
            subtitle: 'Absensi Kegiatan',
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: widget.showBackButton,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Text('Presensi Realtime', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            ),
                            Row(
                              children: [
                                BkuButton.outline(
                                  onPressed: _isRefreshing ? null : _loadData,
                                  icon: Icons.refresh_rounded,
                                  text: 'Refresh',
                                  height: 32,
                                  fontSize: 10.5,
                                  fullWidth: false,
                                  customRadius: BkuTheme.r8,
                                ),
                                if (canCreateEvent) ...[
                                  const SizedBox(width: 6),
                                  BkuButton.primary(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CreateAbsensiScreen()),
                                      ).then((_) => _loadData());
                                    },
                                    icon: Icons.add_rounded,
                                    text: 'Tambah Sesi',
                                    height: 32,
                                    fontSize: 10.5,
                                    fullWidth: false,
                                    customRadius: BkuTheme.r8,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sistem Presensi & Absensi Kegiatan',
                          style: BkuTheme.textPageTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola kehadiran anggota ormawa, pantau rasio partisipasi, dan generate QR Code instan.',
                          style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Total Sesi Kegiatan',
                          value: '$totalSessions',
                          badgeText: 'Semua Sesi',
                          icon: Icons.calendar_month_rounded,
                          badgeColor: BkuTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: liveSelectedAgenda != null ? 'Peserta Terdaftar' : 'Total Anggota',
                          value: liveSelectedAgenda != null ? '$totalAttendance' : '${provider.members.length}',
                          badgeText: liveSelectedAgenda != null ? 'Sesi Terpilih' : 'Anggota Aktif',
                          icon: Icons.people_alt_rounded,
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
                          title: 'Hadir / Tidak Hadir',
                          value: liveSelectedAgenda != null ? '$attendedCount / $absentCount' : '— / —',
                          badgeText: 'Presensi',
                          icon: Icons.check_circle_rounded,
                          badgeColor: BkuTheme.emerald,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OrmawaKpiCard(
                          title: 'Rasio Kehadiran',
                          value: liveSelectedAgenda != null ? '$attendanceRate%' : '0%',
                          badgeText: 'Persentase',
                          icon: Icons.percent_rounded,
                          badgeColor: BkuTheme.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (liveSelectedAgenda == null) ...[
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      borderRadius: 18,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: BkuTheme.primarySoft,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(color: BkuTheme.primaryBorder),
                            ),
                            child: Icon(Icons.qr_code_scanner_rounded, size: 22, color: BkuTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Belum Ada Sesi Terpilih',
                                  style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Pilih salah satu sesi kegiatan dari daftar di bawah untuk membuka QR Code Presensi dan mengelola kehadiran peserta.',
                                  style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isAttendanceActive ? BkuTheme.emeraldSoft : BkuTheme.amberSoft,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(color: isAttendanceActive ? BkuTheme.emeraldBorder : BkuTheme.amberBorder),
                                    ),
                                    child: Text(
                                      isAttendanceActive ? 'Sesi Presensi Aktif' : 'Sesi Belum Dibuka',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: isAttendanceActive ? BkuTheme.emerald : BkuTheme.amber,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: liveSelectedAgenda.id.startsWith('prop-') ? BkuTheme.borderSubtle : BkuTheme.skySoft,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(color: liveSelectedAgenda.id.startsWith('prop-') ? BkuTheme.border : BkuTheme.skyBorder),
                                    ),
                                    child: Text(
                                      liveSelectedAgenda.id.startsWith('prop-') ? 'Proposal' : 'Kegiatan Mandiri',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: liveSelectedAgenda.id.startsWith('prop-') ? BkuTheme.textBody : BkuTheme.sky,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => setState(() => _selectedAgenda = null),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: BkuTheme.borderSubtle,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.close_rounded, size: 12, color: BkuTheme.textBody),
                                      const SizedBox(width: 3),
                                      Text('Tutup', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.textBody)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            liveSelectedAgenda.title,
                            style: BkuTheme.textPageTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: BkuTheme.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  liveSelectedAgenda.location.isNotEmpty ? liveSelectedAgenda.location : 'Kampus Utama',
                                  style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: BkuTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateRange(liveSelectedAgenda.date, liveSelectedAgenda.endDate),
                                style: BkuTheme.textCaption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: BkuTheme.textBody),
                              ),
                              if (_formatTimeRange(liveSelectedAgenda.date, liveSelectedAgenda.endDate).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.access_time_rounded, size: 12, color: BkuTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimeRange(liveSelectedAgenda.date, liveSelectedAgenda.endDate),
                                  style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),

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
                                          'Sesi presensi belum dibuka. Pemindaian QR hanya aktif saat kegiatan berstatus Berlangsung atau pada hari tanggal kegiatan (${DateFormat('d MMM yyyy', 'id').format(liveSelectedAgenda.date)}).',
                                          style: TextStyle(fontSize: 10.5, color: BkuTheme.amber.withAlpha(220), height: 1.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (canManageAttendance && liveSelectedAgenda.status.toLowerCase() != 'selesai' && liveSelectedAgenda.status.toLowerCase() != 'dibatalkan') ...[
                                    const SizedBox(height: 10),
                                    BkuButton.primary(
                                      onPressed: _isMutatingStatus ? null : () => _handleStartEventNow(liveSelectedAgenda),
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
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: BkuButton.primary(
                                    onPressed: () => _showDynamicQrModal(context, liveSelectedAgenda),
                                    icon: Icons.qr_code_rounded,
                                    text: 'Buka QR Presensi',
                                    height: 40,
                                    fontSize: 11,
                                    customRadius: BkuTheme.r10,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: BkuButton.outline(
                                    onPressed: () {
                                      final selectedId = liveSelectedAgenda.id;
                                      final selectedTitle = liveSelectedAgenda.title;
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
                                    icon: Icons.qr_code_scanner_rounded,
                                    text: 'Scan QR Peserta',
                                    height: 40,
                                    fontSize: 11,
                                    customRadius: BkuTheme.r10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

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
                                  Text('Rekapitulasi Kehadiran', style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w900)),
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
                            controller: _searchAttController,
                            hint: 'Cari nama atau NIM peserta...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 16, color: BkuTheme.textPlaceholder),
                            suffixIcon: _searchAttQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 14, color: BkuTheme.textPlaceholder),
                                    onPressed: () => _searchAttController.clear(),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),

                          _buildAttendanceParticipantList(provider, liveSelectedAgenda.id),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  OrmawaFilterTabs(
                    tabs: [
                      OrmawaTabItem(key: 'all', label: 'Semua', count: totalSessions),
                      OrmawaTabItem(key: 'terjadwal', label: 'Terjadwal', count: plannedCount),
                      OrmawaTabItem(key: 'direncanakan', label: 'Direncanakan', count: direncanakanCount),
                      OrmawaTabItem(key: 'berlangsung', label: 'Berlangsung', count: ongoingCount),
                      OrmawaTabItem(key: 'selesai', label: 'Selesai', count: completedCount),
                    ],
                    activeKey: _activeTab,
                    onTabChanged: (val) => setState(() => _activeTab = val),
                  ),
                  const SizedBox(height: 12),

                  OrmawaSearchBar(
                    controller: _searchController,
                    hintText: 'Cari judul kegiatan atau lokasi...',
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 14),

                  if (filteredAgendas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: BkuEmptyState(
                        title: 'Belum ada sesi kegiatan',
                        message: 'Tidak ada agenda yang cocok dengan filter.',
                        icon: Icons.event_busy_rounded,
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
                        final isSelected = liveSelectedAgenda?.id == agenda.id;
                        final isProp = agenda.id.startsWith('prop-');

                        final statusBg = _getStatusBgColor(agenda.status);
                        final statusText = _getStatusTextColor(agenda.status);
                        final statusLabel = _getStatusLabel(agenda.status);

                        return BkuCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: isProp ? BkuTheme.borderSubtle : BkuTheme.skySoft,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: isProp ? BkuTheme.border : BkuTheme.skyBorder),
                                        ),
                                        child: Text(
                                          isProp ? 'Proposal' : 'Kegiatan Mandiri',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: isProp ? BkuTheme.textBody : BkuTheme.sky,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BkuTheme.r8,
                                        ),
                                        child: Text(statusLabel, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: statusText)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('d MMM yyyy', 'id').format(agenda.date),
                                    style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                agenda.title,
                                style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w900, height: 1.3),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: BkuTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      agenda.location.isNotEmpty ? agenda.location : 'Kampus Utama',
                                      style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (_formatTimeRange(agenda.date, agenda.endDate).isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 12, color: BkuTheme.textPlaceholder),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimeRange(agenda.date, agenda.endDate),
                                      style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: isSelected
                                        ? BkuButton.primary(
                                            onPressed: () => _selectAgenda(agenda),
                                            text: 'Sesi Aktif',
                                            height: 34,
                                            fontSize: 10.5,
                                            customRadius: BkuTheme.r8,
                                          )
                                        : BkuButton.outline(
                                            onPressed: () => _selectAgenda(agenda),
                                            text: 'Pilih Sesi',
                                            height: 34,
                                            fontSize: 10.5,
                                            customRadius: BkuTheme.r8,
                                          ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _showDynamicQrModal(context, agenda),
                                    borderRadius: BkuTheme.r8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.borderSubtle,
                                        borderRadius: BkuTheme.r8,
                                        border: Border.all(color: BkuTheme.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.qr_code_rounded, size: 14, color: BkuTheme.primary),
                                          const SizedBox(width: 4),
                                          Text('QR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.textBody)),
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
                                    borderRadius: BkuTheme.r8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.borderSubtle,
                                        borderRadius: BkuTheme.r8,
                                        border: Border.all(color: BkuTheme.border),
                                      ),
                                      child: const Icon(Icons.chevron_right_rounded, size: 16, color: BkuTheme.textMuted),
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
    );
  }

  Widget _buildAttendanceParticipantList(OrmawaProvider provider, String eventId) {
    if (provider.isLoading && provider.attendanceList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E))),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Belum ada data presensi peserta pada sesi ini.', style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textPlaceholder)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                  await provider.submitAttendance(eventId, item.mahasiswaId, targetStatus);
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
    _qrPayload = '${ApiGate.webUrl}/student/presensi?eventId=${widget.agenda.id}&token=$token&t=$nowMs';
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
              widget.agenda.title,
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