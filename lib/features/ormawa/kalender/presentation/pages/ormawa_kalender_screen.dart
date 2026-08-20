import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
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
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
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
    try {
      final startStr = DateFormat('dd MMM yyyy', 'id_ID').format(start);
      if (isSameDay(start, end)) return startStr;
      final endStr = DateFormat('dd MMM yyyy', 'id_ID').format(end);
      return '$startStr s/d $endStr';
    } catch (_) {
      return '${start.day}/${start.month}/${start.year}';
    }
  }

  String _formatSelectedDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal pada kalender';
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      try {
        return DateFormat('EEEE, dd MMMM yyyy').format(date);
      } catch (_) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return BkuTheme.amberSoft;
      case 'selesai':
      case 'terlaksana':
        return BkuTheme.emeraldSoft;
      case 'dibatalkan':
      case 'batal':
        return BkuTheme.roseSoft;
      default:
        return BkuTheme.skySoft;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return BkuTheme.amber;
      case 'selesai':
      case 'terlaksana':
        return BkuTheme.emerald;
      case 'dibatalkan':
      case 'batal':
        return BkuTheme.rose;
      default:
        return BkuTheme.sky;
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

    final canCreateEvent = provider.hasPermission('ormawa.events.create, create_calendar');
    final canEditEvent = provider.hasPermission('ormawa.events.update, edit_calendar');
    final canDeleteEvent = provider.hasPermission('ormawa.events.delete, delete_calendar');

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => _loadData(true),
        color: BkuTheme.primary,
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
                      const SizedBox(height: 14),

                      FadeInAnimation(
                        delay: 0.1,
                        child: BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          borderRadius: 16,
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
                                          style: BkuTheme.textCaption.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: BkuTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Agenda Kegiatan',
                                          style: BkuTheme.textCardTitle.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: BkuTheme.primarySoft,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(color: BkuTheme.primaryBorder),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.event_note_rounded, size: 14, color: BkuTheme.primary),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Kalender Ormawa',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w900,
                                            color: BkuTheme.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Kalender operasional, sinkronisasi timeline kegiatan, dan pemantauan program kerja organisasi mahasiswa.',
                                style: BkuTheme.textCaption.copyWith(
                                  fontSize: 11,
                                  color: BkuTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: BkuButton.outline(
                                      onPressed: () => _loadData(true),
                                      icon: Icons.refresh_rounded,
                                      text: _isRefreshing ? 'Memuat...' : 'Refresh',
                                      height: 38,
                                      fontSize: 11,
                                      customRadius: BkuTheme.r10,
                                    ),
                                  ),
                                  if (canCreateEvent) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: BkuButton.primary(
                                        onPressed: () => context.push(AppRoutes.ormawaJadwalCreate),
                                        icon: Icons.add_rounded,
                                        text: 'Tambah Kegiatan',
                                        height: 38,
                                        fontSize: 11,
                                        customRadius: BkuTheme.r10,
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
                              title: 'Total Kegiatan',
                              value: '$totalEvents',
                              badgeText: 'Semua Agenda',
                              icon: Icons.calendar_month_rounded,
                              badgeColor: BkuTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Sedang Berlangsung',
                              value: '$activeEvents',
                              badgeText: 'Live Active',
                              icon: Icons.schedule_rounded,
                              badgeColor: BkuTheme.amber,
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
                              badgeColor: BkuTheme.sky,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Selesai Terlaksana',
                              value: '$completedEvents',
                              badgeText: 'Tuntas',
                              icon: Icons.check_circle_rounded,
                              badgeColor: BkuTheme.emerald,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      FadeInAnimation(
                        delay: 0.25,
                        child: BkuCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month_rounded, size: 18, color: BkuTheme.primary),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kalender Agenda',
                                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w900),
                                            ),
                                            Text(
                                              'Pilih tanggal untuk melihat jadwal khusus',
                                              style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (_selectedDay != null)
                                      InkWell(
                                        onTap: () => setState(() => _selectedDay = null),
                                        borderRadius: BkuTheme.r8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: BkuTheme.roseSoft,
                                            borderRadius: BkuTheme.r8,
                                            border: Border.all(color: BkuTheme.roseBorder),
                                          ),
                                          child: const Text(
                                            'Reset Filter',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: BkuTheme.rose,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              TableCalendar(
                                locale: 'id_ID',
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
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  defaultTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  weekendTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                                  selectedDecoration: BoxDecoration(
                                    color: BkuTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  todayDecoration: BoxDecoration(
                                    color: BkuTheme.primarySoft,
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  markerDecoration: BoxDecoration(
                                    color: BkuTheme.primary,
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
                                    color: BkuTheme.borderSubtle,
                                    borderRadius: BkuTheme.r12,
                                    border: Border.all(color: BkuTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatSelectedDate(_selectedDay),
                                            style: BkuTheme.textCardTitle.copyWith(fontSize: 11, fontWeight: FontWeight.w900),
                                          ),
                                          if (_selectedDay != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: BkuTheme.skySoft,
                                                borderRadius: BkuTheme.r8,
                                              ),
                                              child: Text(
                                                '${selectedDayItems.length} Agenda',
                                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.sky),
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
                                              Color typeColor = BkuTheme.sky;
                                              Color typeBg = BkuTheme.skySoft;
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
                                                typeColor = BkuTheme.amber;
                                                typeBg = BkuTheme.amberSoft;
                                                title = item.title;
                                                statusStr = item.status;
                                              } else if (item is OrmawaAnnouncement) {
                                                typeLabel = 'Pengumuman';
                                                typeColor = BkuTheme.emerald;
                                                typeBg = BkuTheme.emeraldSoft;
                                                title = item.judul;
                                              }

                                              return InkWell(
                                                onTap: item is OrmawaAgenda
                                                    ? () => context.push(AppRoutes.ormawaAgendaDetail, extra: item)
                                                    : null,
                                                borderRadius: BkuTheme.r10,
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BkuTheme.r10,
                                                    border: Border.all(color: BkuTheme.border),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: typeBg,
                                                          borderRadius: BkuTheme.r8,
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
                                                              style: BkuTheme.textCardTitle.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            if (loc.isNotEmpty) ...[
                                                              const SizedBox(height: 2),
                                                              Row(
                                                                children: [
                                                                  const Icon(Icons.location_on_rounded, size: 10, color: BkuTheme.textPlaceholder),
                                                                  const SizedBox(width: 2),
                                                                  Expanded(
                                                                    child: Text(
                                                                      loc,
                                                                      style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
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
                                              child: Text('Tidak ada agenda pada tanggal ini.', style: TextStyle(fontSize: 10, color: BkuTheme.textPlaceholder)),
                                            ),
                                          )
                                      ] else
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: Text('Klik tanggal pada kalender untuk melihat agenda khusus.', style: TextStyle(fontSize: 10, color: BkuTheme.textPlaceholder)),
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
                            style: BkuTheme.textBadge.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: BkuTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
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
                              child: const Text('Reset Semua Filter', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filteredAgendas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: BkuEmptyState(
                            title: 'Belum Ada Jadwal Kegiatan',
                            message: 'Tidak ada agenda kegiatan yang cocok dengan filter aktif.',
                            icon: Icons.event_busy_rounded,
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
                            return _buildAgendaCard(
                              context,
                              agenda,
                              canEdit: canEditEvent,
                              canDelete: canDeleteEvent,
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

  Widget _buildAgendaCard(
    BuildContext context,
    OrmawaAgenda agenda, {
    required bool canEdit,
    required bool canDelete,
  }) {
    final statusLabel = _getStatusLabel(agenda.status);
    final statusBg = _getStatusBgColor(agenda.status);
    final statusColor = _getStatusTextColor(agenda.status);

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 14,
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
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BkuTheme.r8,
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
              const Icon(Icons.location_on_outlined, size: 12, color: BkuTheme.textPlaceholder),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  agenda.location.isNotEmpty ? agenda.location : 'Lokasi belum ditentukan',
                  style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (agenda.pjKegiatan != null && agenda.pjKegiatan!.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.person_outline_rounded, size: 12, color: BkuTheme.textPlaceholder),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    agenda.pjKegiatan!,
                    style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
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
              Icon(Icons.event_rounded, size: 12, color: BkuTheme.primary),
              const SizedBox(width: 4),
              Text(
                _formatDateRange(agenda.date, agenda.endDate),
                style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.textBody),
              ),
              const Spacer(),
              if (agenda.estimasiDana != null && agenda.estimasiDana! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Text(
                    _formatRp(agenda.estimasiDana),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textHeading,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BkuButton.outline(
                onPressed: () => context.push(AppRoutes.ormawaAgendaDetail, extra: agenda),
                icon: Icons.visibility_rounded,
                text: 'Detail',
                height: 28,
                fontSize: 10,
                customRadius: BkuTheme.r8,
              ),
              if (canEdit) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => context.push(AppRoutes.ormawaJadwalEdit, extra: agenda),
                  borderRadius: BkuTheme.r8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: BkuTheme.amberSoft,
                      borderRadius: BkuTheme.r8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 13, color: BkuTheme.amber),
                        SizedBox(width: 4),
                        Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.amber)),
                      ],
                    ),
                  ),
                ),
              ],
              if (canDelete) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _confirmDelete(context, agenda),
                  borderRadius: BkuTheme.r8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: BkuTheme.roseSoft,
                      borderRadius: BkuTheme.r8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 13, color: BkuTheme.rose),
                        SizedBox(width: 4),
                        Text('Batal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.rose)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}