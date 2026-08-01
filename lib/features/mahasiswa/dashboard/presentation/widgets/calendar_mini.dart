import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

class CalendarEvent {
  final String title;
  final DateTime date;
  final String? category;

  CalendarEvent({
    required this.title,
    required this.date,
    this.category,
  });
}

class CalendarMini extends StatefulWidget {
  final List<CalendarEvent> events;

  const CalendarMini({super.key, this.events = const []});

  @override
  State<CalendarMini> createState() => _CalendarMiniState();
}

class _CalendarMiniState extends State<CalendarMini> {
  late DateTime _currentDate;
  int? _selectedDay;

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final today = DateTime.now();

    final firstDayOfMonth = DateTime(year, month, 1).weekday;
    final startDay = firstDayOfMonth - 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final viewedEvents = widget.events.where((e) {
      return e.date.month == month && e.date.year == year;
    }).toList();

    final eventDates = viewedEvents.map((e) => e.date.day).toSet();

    final selectedDateEvents = _selectedDay != null
        ? viewedEvents.where((e) => e.date.day == _selectedDay).toList()
        : [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: context.appColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kalender Kegiatan',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(year, month - 1, 1);
                        _selectedDay = null;
                      });
                    },
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: context.appColors.onSurfaceVariant,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${_months[month - 1]} $year',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(year, month + 1, 1);
                        _selectedDay = null;
                      });
                    },
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: context.appColors.onSurfaceVariant,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _days.map((d) {
              return SizedBox(
                width: 36,
                child: Text(
                  d,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(
            context,
            startDay,
            daysInMonth,
            today,
            eventDates,
            year,
            month,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.appColors.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDay != null
                      ? 'Kegiatan $_selectedDay ${_months[month - 1]}'
                      : 'Kegiatan ${_months[month - 1]}',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedDay == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: context.appColors.onSurfaceVariant.withOpacity(0.4),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Klik tanggal yang memiliki titik',
                            style: AppTextStyles.caption.copyWith(
                              color: context.appColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (selectedDateEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            color: context.appColors.onSurfaceVariant.withOpacity(0.4),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada kegiatan',
                            style: AppTextStyles.caption.copyWith(
                              color: context.appColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...selectedDateEvents.map((e) => _buildEventItem(context, e)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    int startDay,
    int daysInMonth,
    DateTime today,
    Set<int> eventDates,
    int year,
    int month,
  ) {
    final cells = <Widget>[];

    for (int i = 0; i < startDay; i++) {
      cells.add(const SizedBox(height: 36));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final isToday = d == today.day && month == today.month && year == today.year;
      final hasEvent = eventDates.contains(d);
      final isPast = d < today.day && month == today.month && year == today.year;
      final isSelected = _selectedDay == d;

      cells.add(
        GestureDetector(
          onTap: hasEvent ? () => setState(() => _selectedDay = d) : null,
          child: SizedBox(
            height: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.appColors.primary.withOpacity(0.2)
                        : isToday
                            ? context.appColors.primary
                            : null,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: context.appColors.primary.withOpacity(0.4),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$d',
                      style: AppTextStyles.caption.copyWith(
                        color: isToday
                            ? context.appColors.surface
                            : isPast
                                ? context.appColors.onSurfaceVariant.withOpacity(0.4)
                                : context.appColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (hasEvent)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isToday || isSelected
                          ? context.appColors.primary
                          : context.appColors.primary.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: cells,
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getCategoryColor(event.category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getCategoryLabel(event.category),
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'kencana':
        return context.appColors.primary;
      case 'beasiswa':
        return const Color(0xFF16A34A);
      case 'konseling':
        return const Color(0xFF7C3AED);
      case 'kampus':
        return const Color(0xFF0284C7);
      case 'organisasi':
        return const Color(0xFFF59E0B);
      case 'kesehatan':
        return const Color(0xFFDC2626);
      default:
        return context.appColors.onSurfaceVariant;
    }
  }

  String _getCategoryLabel(String? category) {
    switch (category) {
      case 'kencana':
        return 'PKKMB';
      case 'beasiswa':
        return 'Beasiswa';
      case 'konseling':
        return 'Konseling';
      case 'kampus':
        return 'Kampus';
      case 'organisasi':
        return 'Organisasi';
      case 'kesehatan':
        return 'Kesehatan';
      default:
        return category ?? '';
    }
  }
}
