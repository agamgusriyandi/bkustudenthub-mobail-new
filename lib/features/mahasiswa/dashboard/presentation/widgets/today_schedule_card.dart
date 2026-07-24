import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/pages/student_calendar_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class TodayScheduleCard extends StatelessWidget {
  const TodayScheduleCard({super.key});

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

  void _navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentCalendarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final events = student.campusEvents;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter events for today or future
    final upcomingEvents =
        events.where((e) {
          final evDate = DateTime(
            e.tanggal.year,
            e.tanggal.month,
            e.tanggal.day,
          );
          return evDate.isAfter(today) || evDate.isAtSameMomentAs(today);
        }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalender Kegiatan',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(now),
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _navigateToCalendar(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.neutral800,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lihat Jadwal',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (student.isLoading && upcomingEvents.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkuShimmer.text(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
                  BkuShimmer.text(width: double.infinity, height: 60),
                ],
              ),
            ),
          ] else if (upcomingEvents.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline.withAlpha(100),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada kegiatan terdekat',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semua agenda saat ini sudah terlaksana dengan baik.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...upcomingEvents.take(2).map((event) {
              final isToday =
                  event.tanggal.year == now.year &&
                  event.tanggal.month == now.month &&
                  event.tanggal.day == now.day;
              return _buildScheduleItem(context, event, isOngoing: isToday);
            }),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    CampusEventSchedule event, {
    bool isOngoing = false,
  }) {
    final statusColor =
        isOngoing ? AppColors.success : Theme.of(context).colorScheme.outline;
    String timeStr =
        '${event.tanggal.hour.toString().padLeft(2, '0')}:${event.tanggal.minute.toString().padLeft(2, '0')}';
    if (timeStr == '00:00') {
      timeStr = 'Full Day';
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isOngoing ? statusColor.withAlpha(8) : Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color:
              isOngoing
                  ? statusColor.withAlpha(40)
                  : AppColors.neutral200.withAlpha(150),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isOngoing
                    ? statusColor.withAlpha(10)
                    : Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEventDetail(context, event),
        borderRadius: AppRadius.radiusXl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isOngoing
                          ? statusColor
                          : Theme.of(context).colorScheme.outline.withAlpha(50),
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOngoing
                              ? 'HARI INI • $timeStr'
                              : _formatDate(event.tanggal),
                          style: AppTextStyles.labelSm.copyWith(
                            color:
                                isOngoing
                                    ? statusColor
                                    : Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        if (isOngoing) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              'SEDANG BERJALAN',
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.judul,
                      style: AppTextStyles.labelMd.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withAlpha(150),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.kategori,
                            style: AppTextStyles.labelSm.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.outline.withAlpha(100),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context, CampusEventSchedule event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: const Icon(
                        Icons.event_note_rounded,
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Kegiatan',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          Text(
                            event.judul,
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailInfo(
                  Icons.category_rounded,
                  'Kategori',
                  event.kategori,
                ),
                _buildDetailInfo(
                  Icons.timer_rounded,
                  'Waktu Pelaksanaan',
                  _formatDate(event.tanggal),
                ),
                if (event.lokasi.isNotEmpty)
                  _buildDetailInfo(
                    Icons.location_on_rounded,
                    'Lokasi',
                    event.lokasi,
                  ),
                if (event.deskripsi.isNotEmpty)
                  _buildDetailInfo(
                    Icons.description_rounded,
                    'Deskripsi',
                    event.deskripsi,
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BkuButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Tutup',
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline.withAlpha(150)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
