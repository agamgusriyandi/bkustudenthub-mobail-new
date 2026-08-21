import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final orgProvider = context.watch<OrganizationProvider>();
    final events = academic.campusEvents;

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingEvents = events.where((e) {
      final isDeadline = e.judul.toLowerCase().startsWith('deadline') ||
          e.kategori.toLowerCase() == 'beasiswa';
      if (isDeadline) return false;

      if (e.kategori.toLowerCase() == 'organisasi') {
        if (myOrgNames.isEmpty) return false;
        final eventTitle = e.judul.toLowerCase();
        final eventDesc = e.deskripsi.toLowerCase();
        final eventLocation = e.lokasi.toLowerCase();
        final matchesMyOrg = myOrgNames.any((String orgName) =>
            eventTitle.contains(orgName) ||
            eventDesc.contains(orgName) ||
            eventLocation.contains(orgName));
        if (!matchesMyOrg) return false;
      }

      final evDate = DateTime(
        e.tanggal.year,
        e.tanggal.month,
        e.tanggal.day,
      );
      return evDate.isAfter(today) || evDate.isAtSameMomentAs(today);
    }).toList();

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderOnly: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalender Kegiatan',
                    style: AppTextStyles.caption.copyWith(
                      color: context.appColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(now),
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _navigateToCalendar(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 13,
                        color: AppColors.neutral800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lihat Jadwal',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral800,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (academic.isLoading && upcomingEvents.isEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BkuShimmer.text(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                ),
                BkuShimmer.text(width: double.infinity, height: 50),
              ],
            ),
          ] else if (upcomingEvents.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 36,
                      color: context.appColors.outline.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada kegiatan terdekat',
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.appColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Semua agenda saat ini sudah terlaksana dengan baik.',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    CampusEventSchedule event, {
    bool isOngoing = false,
  }) {
    final categoryColor = _getCategoryColor(event.kategori);
    final categoryLabel = _getCategoryLabel(event.kategori);
    String timeStr =
        '${event.tanggal.hour.toString().padLeft(2, '0')}:${event.tanggal.minute.toString().padLeft(2, '0')}';
    if (timeStr == '00:00') {
      timeStr = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOngoing
              ? AppColors.primary.withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () => _showEventDetail(context, event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  isOngoing
                      ? (timeStr.isNotEmpty ? 'Hari Ini • $timeStr' : 'Hari Ini')
                      : _formatDate(event.tanggal),
                  style: AppTextStyles.caption.copyWith(
                    color: isOngoing
                        ? AppColors.primary
                        : context.appColors.onSurfaceVariant,
                    fontWeight: isOngoing ? FontWeight.bold : FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.judul,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.outline.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
            if (event.lokasi.isNotEmpty || event.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.lokasi.isNotEmpty ? event.lokasi : event.deskripsi,
                style: AppTextStyles.caption.copyWith(
                  color: context.appColors.onSurfaceVariant,
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
  }

  void _showEventDetail(BuildContext context, CampusEventSchedule event) {
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Kegiatan',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.judul,
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.w800,
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
            _buildDetailInfo(
              Icons.category_outlined,
              'Kategori',
              event.kategori.toUpperCase(),
            ),
            _buildDetailInfo(
              Icons.access_time_rounded,
              'Waktu Pelaksanaan',
              _formatDate(event.tanggal),
            ),
            if (event.lokasi.isNotEmpty)
              _buildDetailInfo(
                Icons.location_on_outlined,
                'Lokasi',
                event.lokasi,
              ),
            if (event.deskripsi.isNotEmpty)
              _buildDetailInfo(
                Icons.notes_rounded,
                'Deskripsi',
                event.deskripsi,
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: BkuButton(
                onPressed: () => Navigator.pop(context),
                text: 'Tutup',
                variant: BkuButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline.withAlpha(150)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  value,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
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
