import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:go_router/go_router.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().loadAcademicData();
      context.read<OrganizationProvider>().loadOrganizationData();
    });
  }

  List<CampusEventSchedule> _getEventsForDay(
    DateTime day,
    List<CampusEventSchedule> allEvents,
    Set<String> myOrgNames,
  ) {
    return allEvents.where((event) {
      if (!isSameDay(event.tanggal, day)) return false;

      if (event.kategori.toLowerCase() == 'organisasi') {
        if (myOrgNames.isEmpty) return false;
        final title = event.judul.toLowerCase();
        final desc = event.deskripsi.toLowerCase();
        final loc = event.lokasi.toLowerCase();
        final matches = myOrgNames.any((org) =>
            title.contains(org) || desc.contains(org) || loc.contains(org));
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime dt) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    String dayName = days[dt.weekday - 1];
    String monthName = months[dt.month - 1];
    String dayNum = dt.day.toString().padLeft(2, '0');
    return '$dayName, $dayNum $monthName';
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kencana':
      case 'pkkmb':
        return AppColors.primary;
      case 'beasiswa':
        return AppColors.success;
      case 'konseling':
        return Colors.indigo;
      case 'organisasi':
        return Colors.amber.shade800;
      case 'kesehatan':
        return const Color(0xFFE11D48);
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryLabel(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'kencana':
      case 'pkkmb':
        return 'PKKMB';
      case 'beasiswa':
        return 'Beasiswa';
      case 'konseling':
        return 'Konseling';
      case 'organisasi':
        return 'Organisasi';
      case 'kesehatan':
        return 'Kesehatan';
      default:
        return kategori.toUpperCase();
    }
  }

  void _showEventDetail(BuildContext context, CampusEventSchedule event) {
    final catColor = _getCategoryColor(event.kategori);
    final catLabel = _getCategoryLabel(event.kategori);

    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          catLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: catColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.judul,
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow(
              Icons.access_time_rounded,
              'Waktu Pelaksanaan',
              _formatDate(event.tanggal),
            ),
            if (event.lokasi.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(
                Icons.location_on_outlined,
                'Lokasi',
                event.lokasi,
              ),
            ],
            if (event.deskripsi.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(
                Icons.notes_rounded,
                'Deskripsi',
                event.deskripsi,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: BkuButton(
                onPressed: () => context.pop(),
                text: 'Tutup',
                variant: BkuButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final orgProvider = context.watch<OrganizationProvider>();

    final Set<String> myOrgNames = orgProvider.organizationHistory
        .where((o) {
          final s = o.statusVerifikasi.toLowerCase();
          return s.contains('setuju') ||
              s.contains('valid') ||
              s.contains('aktif') ||
              s == 'approved';
        })
        .map((o) => o.namaOrganisasi.toLowerCase().trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    final selectedEvents = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      academic.campusEvents,
      myOrgNames,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BkuStaticAppBar(
        title: 'Kalender Kegiatan',
        variant: AppBarVariant.student,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: TableCalendar<CampusEventSchedule>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) =>
                  _getEventsForDay(day, academic.campusEvents, myOrgNames),
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Bulan',
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 1,
                markerSize: 5,
                markerMargin: const EdgeInsets.only(top: 2),
                markerDecoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: context.appColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                weekendTextStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                titleTextStyle: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF475569),
                  size: 24,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF475569),
                  size: 24,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda Kegiatan',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_selectedDay ?? _focusedDay),
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${selectedEvents.length} Kegiatan',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 40,
                          color: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tidak ada kegiatan di tanggal ini',
                          style: AppTextStyles.bodySm.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pilih tanggal dengan titik untuk melihat agenda',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: selectedEvents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      final catColor = _getCategoryColor(event.kategori);
                      final catLabel = _getCategoryLabel(event.kategori);

                      return InkWell(
                        onTap: () => _showEventDetail(context, event),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
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
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      catLabel,
                                      style: AppTextStyles.caption.copyWith(
                                        color: catColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.judul,
                                style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (event.lokasi.isNotEmpty ||
                                  event.deskripsi.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  event.lokasi.isNotEmpty
                                      ? event.lokasi
                                      : event.deskripsi,
                                  style: AppTextStyles.caption.copyWith(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
