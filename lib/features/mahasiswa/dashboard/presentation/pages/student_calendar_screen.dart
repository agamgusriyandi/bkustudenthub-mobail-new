import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
// // import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';

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
      context.read<StudentProvider>().refreshCampusEvents();
    });
  }

  List<CampusEventSchedule> _getEventsForDay(
    DateTime day,
    List<CampusEventSchedule> allEvents,
  ) {
    return allEvents.where((event) {
      return isSameDay(event.tanggal, day);
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

  void _showEventDetail(BuildContext context, CampusEventSchedule event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_available_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.judul,
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withAlpha(30),
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Text(
                              event.kategori.toUpperCase(),
                              style: AppTextStyles.labelSm.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(event.tanggal),
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (event.lokasi.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.lokasi,
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.deskripsi,
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: BkuButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Tutup',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final selectedEvents = _getEventsForDay(
          _selectedDay ?? _focusedDay,
          provider.campusEvents,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const BkuStaticAppBar(
            title: 'Jadwal',
            variant: AppBarVariant.student,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar<CampusEventSchedule>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader:
                    (day) => _getEventsForDay(day, provider.campusEvents),
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.twoWeeks: '2 Weeks',
                  CalendarFormat.week: 'Week',
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
                  outsideDaysVisible: true,
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: AppColors.neutral800,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.neutral800,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: false,
                  titleTextStyle: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.neutral600,
                    size: 20,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.neutral600,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Kelas',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(_selectedDay ?? _focusedDay),
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    selectedEvents.isEmpty
                        ? Center(
                          child: Text(
                            'Tidak ada kelas di tanggal ini',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.sm,
                          ),
                          itemCount: selectedEvents.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = selectedEvents[index];
                            IconData iconData = Icons.event_note_rounded;
                            Color iconColor = AppColors.neutral800;
                            if (event.kategori.toLowerCase() == 'konseling') {
                              iconData = Icons.health_and_safety_rounded;
                              iconColor = Colors.teal;
                            } else if (event.kategori.toLowerCase() ==
                                'beasiswa') {
                              iconData = Icons.school_rounded;
                              iconColor = AppColors.warning;
                            } else if (event.kategori.toLowerCase() ==
                                    'pkkmb' ||
                                event.kategori.toLowerCase() == 'kencana') {
                              iconData = Icons.emoji_events_rounded;
                              iconColor = Colors.amber;
                            }

                            return InkWell(
                              onTap: () => _showEventDetail(context, event),
                              borderRadius: AppRadius.radiusXl,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadius.radiusXl,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withAlpha(20),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(6),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: iconColor.withAlpha(20),
                                        borderRadius: AppRadius.radiusLg,
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: iconColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.judul,
                                            style: AppTextStyles.labelMd
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.neutral900,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category_rounded,
                                                size: 14,
                                                color: AppColors.neutral500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                event.kategori.toUpperCase(),
                                                style: AppTextStyles.labelSm
                                                    .copyWith(
                                                      color:
                                                          AppColors.neutral600,
                                                      fontSize: 10,
                                                      letterSpacing: 0.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.neutral400,
                                    ),
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
      },
    );
  }
}
