import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_calendar_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';

class OrmawaKalenderScreen extends StatefulWidget {
  const OrmawaKalenderScreen({super.key});

  @override
  State<OrmawaKalenderScreen> createState() => _OrmawaKalenderScreenState();
}

class _OrmawaKalenderScreenState extends State<OrmawaKalenderScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _activeTab = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
      final ormawaProvider = context.read<OrmawaProvider>();
      await ormawaProvider.refreshData();
      final ormawaId = ormawaProvider.ormawaId;
      if (ormawaId != null && mounted) {
        await context.read<OrmawaCalendarProvider>().fetchAgendas(ormawaId);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _formatRp(double? val) {
    if (val == null || val == 0.0) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('dd MMM yyyy', 'id').format(start);
    if (isSameDay(start, end)) return startStr;
    final endStr = DateFormat('dd MMM yyyy', 'id').format(end);
    return '$startStr s/d $endStr';
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return const Color(0xFFFEF3C7);
      case 'selesai':
      case 'terlaksana':
        return const Color(0xFFD1FAE5);
      case 'dibatalkan':
      case 'batal':
        return const Color(0xFFFFE4E6);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return const Color(0xFFB45309);
      case 'selesai':
      case 'terlaksana':
        return const Color(0xFF047857);
      case 'dibatalkan':
      case 'batal':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return 'Berlangsung';
      case 'selesai':
      case 'terlaksana':
        return 'Selesai';
      case 'dibatalkan':
      case 'batal':
        return 'Dibatalkan';
      default:
        return 'Terjadwal';
    }
  }

  List<dynamic> _getEventsForDay(
    DateTime day,
    List<OrmawaAgenda> agendas,
    List<OrmawaProposal> proposals,
    List<OrmawaAnnouncement> announcements,
  ) {
    final List<dynamic> events = [];

    for (final a in agendas) {
      final start = DateTime(a.date.year, a.date.month, a.date.day);
      final end = DateTime(a.endDate.year, a.endDate.month, a.endDate.day, 23, 59, 59);
      final target = DateTime(day.year, day.month, day.day);
      if (target.isAfter(start.subtract(const Duration(seconds: 1))) &&
          target.isBefore(end.add(const Duration(seconds: 1)))) {
        events.add(a);
      }
    }

    for (final p in proposals) {
      final pDate = p.date;
      if (isSameDay(pDate, day)) {
        events.add(p);
      }
    }

    for (final ann in announcements) {
      final annDate = ann.tanggalMulai ?? ann.createdAt;
      if (annDate != null && isSameDay(annDate, day)) {
        events.add(ann);
      }
    }

    return events;
  }

  void _confirmDelete(BuildContext context, OrmawaAgenda agenda) {
    BkuDialog.show(
      context: context,
      title: 'Batalkan Kegiatan?',
      message: 'Apakah Anda yakin ingin membatalkan/menghapus jadwal kegiatan "${agenda.title}"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus Kegiatan',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteAgenda(agenda.id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Kegiatan berhasil dibatalkan/dihapus');
            _loadData(true);
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus kegiatan: $e');
          }
        }
      },
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final allAgendas = provider.agendas;
    final allProposals = provider.proposals;
    final allAnnouncements = provider.announcements;

    final totalEvents = allAgendas.length;
    final activeEvents = allAgendas.where((e) => e.status.toLowerCase() == 'berlangsung').length;
    final upcomingEvents = allAgendas.where((e) =>
        e.status.toLowerCase() == 'terjadwal' ||
        e.status.toLowerCase() == 'planned' ||
        e.status.toLowerCase() == 'dijadwalkan' ||
        e.status.toLowerCase() == 'persiapan').length;
    final completedEvents = allAgendas.where((e) =>
        e.status.toLowerCase() == 'selesai' || e.status.toLowerCase() == 'terlaksana').length;
    final cancelledEvents = allAgendas.where((e) =>
        e.status.toLowerCase() == 'dibatalkan' || e.status.toLowerCase() == 'batal').length;

    List<OrmawaAgenda> filteredAgendas = allAgendas;

    if (_activeTab != 'all') {
      filteredAgendas = filteredAgendas.where((a) {
        final s = a.status.toLowerCase();
        if (_activeTab == 'berlangsung') return s == 'berlangsung';
        if (_activeTab == 'terjadwal') return s == 'terjadwal' || s == 'planned' || s == 'dijadwalkan' || s == 'persiapan';
        if (_activeTab == 'selesai') return s == 'selesai' || s == 'terlaksana';
        if (_activeTab == 'dibatalkan') return s == 'dibatalkan' || s == 'batal';
        return true;
      }).toList();
    }

    if (_selectedDay != null) {
      filteredAgendas = filteredAgendas.where((a) {
        final start = DateTime(a.date.year, a.date.month, a.date.day);
        final end = DateTime(a.endDate.year, a.endDate.month, a.endDate.day, 23, 59, 59);
        final target = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        return target.isAfter(start.subtract(const Duration(seconds: 1))) &&
            target.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredAgendas = filteredAgendas.where((a) {
        return a.title.toLowerCase().contains(_searchQuery) ||
            a.location.toLowerCase().contains(_searchQuery) ||
            (a.pjKegiatan?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    final selectedDayItems = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, allAgendas, allProposals, allAnnouncements)
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => _loadData(true),
        color: const Color(0xFF2563EB),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Jadwal & Agenda',
              subtitle: 'Kalender Kegiatan',
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),

            if (provider.isLoading && allAgendas.isEmpty)
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
                      SizedBox(height: 14),

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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Manajemen Jadwal &',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Agenda Kegiatan',
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
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.event_note_rounded, size: 14, color: Color(0xFF2563EB)),
                                        SizedBox(width: 5),
                                        Text(
                                          'Kalender Ormawa',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Kalender operasional, sinkronisasi timeline kegiatan, dan pemantauan program kerja organisasi mahasiswa.',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _loadData(true),
                                      icon: _isRefreshing
                                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))
                                          : const Icon(Icons.refresh_rounded, size: 14),
                                      label: const Text('Refresh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0F172A),
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.push(AppRoutes.ormawaJadwalCreate),
                                      icon: const Icon(Icons.add_rounded, size: 15),
                                      label: const Text('Tambah Kegiatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
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
                              title: 'Total Kegiatan',
                              value: '$totalEvents',
                              badgeText: 'Semua Agenda',
                              icon: Icons.calendar_month_rounded,
                              badgeColor: OrmawaTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Sedang Berlangsung',
                              value: '$activeEvents',
                              badgeText: 'Live Active',
                              icon: Icons.schedule_rounded,
                              badgeColor: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Terjadwal (Upcoming)',
                              value: '$upcomingEvents',
                              badgeText: 'Akan Datang',
                              icon: Icons.event_available_rounded,
                              badgeColor: const Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Selesai Terlaksana',
                              value: '$completedEvents',
                              badgeText: 'Tuntas',
                              icon: Icons.check_circle_rounded,
                              badgeColor: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      FadeInAnimation(
                        delay: 0.25,
                        child: Container(
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
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF2563EB)),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Kalender Agenda', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                            Text('Pilih tanggal untuk melihat jadwal khusus', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (_selectedDay != null)
                                      InkWell(
                                        onTap: () => setState(() => _selectedDay = null),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFFECDD3)),
                                          ),
                                          child: const Text('Reset Filter', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),

                              TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Bulan',
                                },
                                availableGestures: AvailableGestures.horizontalSwipe,
                                selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
                                eventLoader: (day) => _getEventsForDay(day, allAgendas, allProposals, allAnnouncements),
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    if (_selectedDay != null && isSameDay(_selectedDay, selectedDay)) {
                                      _selectedDay = null;
                                    } else {
                                      _selectedDay = selectedDay;
                                    }
                                    _focusedDay = focusedDay;
                                  });
                                },
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                  leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B), size: 20),
                                  rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
                                ),
                                calendarStyle: const CalendarStyle(
                                  outsideDaysVisible: false,
                                  defaultTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  weekendTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                                  selectedDecoration: BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  todayDecoration: BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  markerDecoration: BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  markerSize: 5,
                                  markersMaxCount: 1,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedDay != null
                                                ? DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDay!)
                                                : 'Pilih tanggal pada kalender',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          ),
                                          if (_selectedDay != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${selectedDayItems.length} Agenda',
                                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      if (_selectedDay != null) ...[
                                        if (selectedDayItems.isNotEmpty)
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: selectedDayItems.length,
                                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                                            itemBuilder: (context, idx) {
                                              final item = selectedDayItems[idx];
                                              String typeLabel = 'Kegiatan';
                                              Color typeColor = const Color(0xFF2563EB);
                                              Color typeBg = const Color(0xFFEFF6FF);
                                              String title = '';
                                              String loc = '';
                                              String statusStr = '';

                                              if (item is OrmawaAgenda) {
                                                typeLabel = 'Kegiatan';
                                                title = item.title;
                                                loc = item.location;
                                                statusStr = _getStatusLabel(item.status);
                                              } else if (item is OrmawaProposal) {
                                                typeLabel = 'Proposal';
                                                typeColor = const Color(0xFFD97706);
                                                typeBg = const Color(0xFFFEF3C7);
                                                title = item.title;
                                                statusStr = item.status;
                                              } else if (item is OrmawaAnnouncement) {
                                                typeLabel = 'Pengumuman';
                                                typeColor = const Color(0xFF059669);
                                                typeBg = const Color(0xFFD1FAE5);
                                                title = item.judul;
                                              }

                                              return InkWell(
                                                onTap: item is OrmawaAgenda
                                                    ? () => context.push(AppRoutes.ormawaAgendaDetail, extra: item)
                                                    : null,
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: typeBg,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          typeLabel,
                                                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: typeColor),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              title,
                                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            if (loc.isNotEmpty) ...[
                                                              const SizedBox(height: 2),
                                                              Row(
                                                                children: [
                                                                  const Icon(Icons.location_on_rounded, size: 10, color: Color(0xFF94A3B8)),
                                                                  const SizedBox(width: 2),
                                                                  Expanded(
                                                                    child: Text(
                                                                      loc,
                                                                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      if (statusStr.isNotEmpty)
                                                        Text(
                                                          statusStr,
                                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusTextColor(statusStr)),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: Text('Tidak ada agenda pada tanggal ini.', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                            ),
                                          )
                                      ] else
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: Text('Klik tanggal pada kalender untuk melihat agenda khusus.', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      OrmawaFilterTabs(
                        tabs: [
                          OrmawaTabItem(key: 'all', label: 'Semua Agenda', count: totalEvents),
                          OrmawaTabItem(key: 'berlangsung', label: 'Berlangsung', count: activeEvents),
                          OrmawaTabItem(key: 'terjadwal', label: 'Terjadwal', count: upcomingEvents),
                          OrmawaTabItem(key: 'selesai', label: 'Selesai', count: completedEvents),
                          OrmawaTabItem(key: 'dibatalkan', label: 'Dibatalkan', count: cancelledEvents),
                        ],
                        activeKey: _activeTab,
                        onTabChanged: (val) => setState(() => _activeTab = val),
                      ),
                      const SizedBox(height: 12),
                      OrmawaSearchBar(
                        controller: _searchController,
                        hintText: 'Cari judul, lokasi, atau PJ kegiatan...',
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DAFTAR JADWAL KEGIATAN (${filteredAgendas.length})',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5),
                          ),
                          if (_selectedDay != null || _activeTab != 'all' || _searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDay = null;
                                  _activeTab = 'all';
                                  _searchController.clear();
                                });
                              },
                              child: const Text('Reset Semua Filter', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filteredAgendas.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.event_busy_rounded, size: 40, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 10),
                              Text('Belum Ada Jadwal Kegiatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              SizedBox(height: 4),
                              Text('Tidak ada agenda kegiatan yang cocok dengan filter aktif.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredAgendas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final agenda = filteredAgendas[idx];
                            return _buildAgendaCard(context, agenda);
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

  Widget _buildAgendaCard(BuildContext context, OrmawaAgenda agenda) {
    final statusLabel = _getStatusLabel(agenda.status);
    final statusBg = _getStatusBgColor(agenda.status);
    final statusColor = _getStatusTextColor(agenda.status);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  agenda.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  agenda.location.isNotEmpty ? agenda.location : 'Lokasi belum ditentukan',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (agenda.pjKegiatan != null && agenda.pjKegiatan!.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    agenda.pjKegiatan!,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.event_rounded, size: 12, color: Color(0xFF2563EB)),
              const SizedBox(width: 4),
              Text(
                _formatDateRange(agenda.date, agenda.endDate),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const Spacer(),
              if (agenda.estimasiDana != null && agenda.estimasiDana! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _formatRp(agenda.estimasiDana),
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontFamily: 'monospace'),
                  ),
                ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => context.push(AppRoutes.ormawaAgendaDetail, extra: agenda),
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
                      Icon(Icons.visibility_rounded, size: 13, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text('Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => context.push(AppRoutes.ormawaJadwalEdit, extra: agenda),
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
                      Icon(Icons.edit_rounded, size: 13, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _confirmDelete(context, agenda),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFE11D48)),
                      SizedBox(width: 4),
                      Text('Batal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
