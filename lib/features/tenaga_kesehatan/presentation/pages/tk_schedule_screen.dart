import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_schedule_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class TkScheduleScreen extends StatefulWidget {
  final bool showBackButton;

  const TkScheduleScreen({super.key, this.showBackButton = true});

  @override
  State<TkScheduleScreen> createState() => _TkScheduleScreenState();
}

class _TkScheduleScreenState extends State<TkScheduleScreen> {
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkScheduleProvider>().loadSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Jadwal Praktik',
        showBackButton: true,
        onBack: () {
          final mainState =
              context.findAncestorStateOfType<TkMainScreenState>();
          if (mainState != null) {
            mainState.setSelectedIndex(0);
          } else if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/tenagakes?tab=0');
          }
        },
        variant: AppBarVariant.nakes,
      ),
      body: Consumer<TkScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 4, itemHeight: 120),
            );
          }

          if (provider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      size: 48,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Jadwal Praktik',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Buat jadwal praktik Anda untuk menerima pendaftaran pasien.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  BkuButton(
                    onPressed: () => context.push('/tk/add-schedule'),
                    text: 'Buat Jadwal Baru',
                    icon: Icons.add_rounded,
                  ),
                ],
              ),
            );
          }

          // Group schedules by date
          final groupedSchedules = _groupSchedulesByDate(provider.schedules);
          final groupedEntries = groupedSchedules.entries.toList();
          final totalPages = (groupedEntries.length / _itemsPerPage).ceil();
          final safePage = _currentPage.clamp(1, totalPages > 0 ? totalPages : 1);
          final startIndex = (safePage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, groupedEntries.length);
          final pagedEntries = groupedEntries.sublist(startIndex, endIndex);

          return RefreshIndicator(
            onRefresh: () => provider.loadSchedules(),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 170,
              ),
              itemCount: pagedEntries.length + (totalPages > 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (totalPages > 1 && index == 0) {
                  return _buildTopPagination(totalPages);
                }

                final entryIndex = totalPages > 1 ? index - 1 : index;
                final entry = pagedEntries[entryIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        entry.key,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (schedule) => _buildScheduleCard(schedule),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withAlpha(70),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/tk/add-schedule'),
          backgroundColor: const Color(0xFF16A34A),
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Buat Jadwal Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Schedule>> _groupSchedulesByDate(List<Schedule> schedules) {
    final grouped = <String, List<Schedule>>{};
    for (final schedule in schedules) {
      final dateKey = _formatDate(schedule.tanggal);
      grouped.putIfAbsent(dateKey, () => []).add(schedule);
    }
    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final scheduleDate = DateTime(date.year, date.month, date.day);

    if (scheduleDate == today) {
      return 'Hari Ini';
    } else if (scheduleDate == tomorrow) {
      return 'Besok';
    } else {
      const months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Widget _buildScheduleCard(Schedule schedule) {
    IconData serviceIcon;
    Color iconBg;
    Color iconColor;

    final lowerService = schedule.tipeLayanan.toLowerCase();
    if (lowerService.contains('gigi')) {
      serviceIcon = Icons.medical_information_rounded;
      iconBg = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
    } else if (lowerService.contains('konsultasi') || lowerService.contains('spesialis')) {
      serviceIcon = Icons.health_and_safety_rounded;
      iconBg = const Color(0xFFF3E8FF);
      iconColor = const Color(0xFF9333EA);
    } else if (lowerService.contains('darurat') || lowerService.contains('gawat')) {
      serviceIcon = Icons.volunteer_activism_rounded;
      iconBg = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
    } else {
      serviceIcon = Icons.medical_services_rounded;
      iconBg = const Color(0xFFECFDF5);
      iconColor = const Color(0xFF059669);
    }

    final bool isAvailable = schedule.hasKuota;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(serviceIcon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.tipeLayanan,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule.waktuFormat,
                          style: AppTextStyles.labelSm.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAvailable ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable
                          ? 'Sisa: ${schedule.availableSlots}'
                          : 'Penuh',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  schedule.lokasi,
                  style: AppTextStyles.labelSm.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Kuota: ${schedule.kuota}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _confirmDeleteSchedule(schedule),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (schedule.catatan != null && schedule.catatan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.catatan!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: const Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSchedule(Schedule schedule) async {
    if (schedule.availableSlots < schedule.kuota) {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Tidak Bisa Dihapus',
              content:
                  'Jadwal ini tidak dapat dihapus karena sudah ada pasien yang mendaftar (kuota sudah terpakai).',
              cancelText: '',
              confirmText: 'Mengerti',
              onCancel: () => Navigator.pop(context),
              onConfirm: () => Navigator.pop(context),
            ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomDialog(
            title: 'Hapus Jadwal',
            content: 'Yakin ingin menghapus jadwal ini?',
            cancelText: 'Batal',
            confirmText: 'Hapus',
            isDestructive: true,
            onCancel: () => Navigator.pop(context, false),
            onConfirm: () => Navigator.pop(context, true),
          ),
    );
    if (result == true && mounted) {
      try {
        await context.read<TkScheduleProvider>().deleteSchedule(
          schedule.id,
        );
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => CustomDialog(
                  title: 'Berhasil',
                  content: 'Jadwal berhasil dihapus',
                  cancelText: '',
                  confirmText: 'Tutup',
                  isSuccess: true,
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () => Navigator.pop(context),
                ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => CustomDialog(
                  title: 'Gagal Menghapus',
                  content:
                      'Jadwal ini tidak dapat dihapus karena sudah ada pasien yang mendaftar atau terjadi kesalahan sistem.\n\nDetail: ${e.toString().replaceAll('Exception: ', '')}',
                  cancelText: '',
                  confirmText: 'Tutup',
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () => Navigator.pop(context),
                ),
          );
        }
      }
    }
  }

  Widget _buildTopPagination(int totalPages) {
    final bool canPrev = _currentPage > 1;
    final bool canNext = _currentPage < totalPages;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: canPrev ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: canPrev ? () => setState(() => _currentPage--) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sebelumnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          Material(
            color: canNext ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: canNext ? () => setState(() => _currentPage++) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
