import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

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

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderOnly: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF475569),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kalender Kegiatan',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(year, month - 1, 1);
                        _selectedDay = null;
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_months[month - 1]} $year',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(year, month + 1, 1);
                        _selectedDay = null;
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth = constraints.maxWidth / 7;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _days.map((d) {
                      return SizedBox(
                        width: columnWidth,
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
                    columnWidth,
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.appColors.outline.withValues(alpha: 0.1),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedDay == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Pilih tanggal untuk melihat rincian kegiatan',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (selectedDateEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Tidak ada kegiatan pada tanggal ini',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
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
    double columnWidth,
  ) {
    final cells = <Widget>[];

    for (int i = 0; i < startDay; i++) {
      cells.add(SizedBox(width: columnWidth, height: 38));
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
            width: columnWidth,
            height: 38,
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF1E293B)
                      : isSelected
                          ? const Color(0xFFF1F5F9)
                          : hasEvent
                              ? const Color(0xFFF8FAFC)
                              : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.5,
                        )
                      : hasEvent && !isToday
                          ? Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 0.8,
                            )
                          : null,
                ),
                child: Center(
                  child: Text(
                    '$d',
                    style: AppTextStyles.caption.copyWith(
                      color: isToday
                          ? Colors.white
                          : isSelected || hasEvent
                              ? const Color(0xFF0F172A)
                              : isPast
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                      fontWeight: isToday || isSelected || hasEvent
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: cells,
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEvent event) {
    final catLabel = _getCategoryLabel(event.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                catLabel,
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.title,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String? category) {
    switch (category?.toLowerCase()) {
      case 'kencana':
      case 'pkkmb':
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
