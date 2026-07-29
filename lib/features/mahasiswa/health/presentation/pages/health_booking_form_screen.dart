import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_booking.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';

import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import '../../../../../core/error/error_handler.dart';

class HealthBookingFormScreen extends StatefulWidget {
  final HealthWorker worker;
  final String? rescheduleBookingId;

  const HealthBookingFormScreen({
    super.key,
    required this.worker,
    this.rescheduleBookingId,
  });

  @override
  State<HealthBookingFormScreen> createState() =>
      _HealthBookingFormScreenState();
}

class _HealthBookingFormScreenState extends State<HealthBookingFormScreen> {
  HealthSchedule? _selectedSchedule;
  final _complaintCtrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;
  String _selectedDayFilter = 'Semua Hari';
  String _selectedServiceFilter = 'Semua Layanan';

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isReschedule = widget.rescheduleBookingId != null;

    final today = DateTime.now().subtract(const Duration(minutes: 5));
    final schedules =
        student.healthSchedules.where((s) {
          if (s.tenagaKesId != widget.worker.id) return false;

          DateTime slotEnd = s.tanggal;
          try {
            final timeParts = s.jamSelesai.split(':');
            if (timeParts.length >= 2) {
              final hours = int.parse(timeParts[0]);
              final minutes = int.parse(timeParts[1]);
              slotEnd = DateTime(
                s.tanggal.year,
                s.tanggal.month,
                s.tanggal.day,
                hours,
                minutes,
              );
            } else {
              slotEnd = DateTime(
                s.tanggal.year,
                s.tanggal.month,
                s.tanggal.day,
                23,
                59,
              );
            }
          } catch (e) {
            slotEnd = DateTime(
              s.tanggal.year,
              s.tanggal.month,
              s.tanggal.day,
              23,
              59,
            );
          }

          return slotEnd.isAfter(today);
        }).toList();

    final Set<String> serviceSet = {'Semua Layanan'};
    for (final s in schedules) {
      if (s.tipeLayanan.isNotEmpty) {
        serviceSet.add(s.tipeLayanan);
      }
    }
    final serviceFilters = serviceSet.toList();
    if (!serviceFilters.contains(_selectedServiceFilter)) {
      _selectedServiceFilter = 'Semua Layanan';
    }

    final filteredSchedules =
        schedules.where((s) {
          if (_selectedDayFilter != 'Semua Hari') {
            final dayName = DateFormat('EEEE', 'id').format(s.tanggal);
            if (dayName.toLowerCase() != _selectedDayFilter.toLowerCase()) {
              return false;
            }
          }
          if (_selectedServiceFilter != 'Semua Layanan') {
            if (s.tipeLayanan.toLowerCase() !=
                _selectedServiceFilter.toLowerCase()) {
              return false;
            }
          }
          return true;
        }).toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await student.refreshHealthData();
        },
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: isReschedule ? 'Reschedule Klinik' : 'Booking Klinik',
              subtitle: 'FORMULIR PENJADWALAN MEDIS',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReschedule)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: themeProvider.warning.withAlpha(20),
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(
                            color: themeProvider.warning.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: themeProvider.warning,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Anda sedang melakukan penjadwalan ulang (Reschedule) untuk janji temu klinik.',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: themeProvider.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Brief Dokter
                    _buildHealthWorkerBrief(widget.worker),
                    const SizedBox(height: AppSpacing.xxl),

                    // Pilih Slot
                    _buildSectionHeader('Pilih Slot Jadwal'),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(15),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: Text(
                              'Slot abu-abu = penuh. Tarik ke bawah untuk refresh jadwal.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.neutral700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral50,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDayFilter,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                ),
                                items:
                                    [
                                          'Semua Hari',
                                          'Senin',
                                          'Selasa',
                                          'Rabu',
                                          'Kamis',
                                          'Jumat',
                                          'Sabtu',
                                          'Minggu',
                                        ]
                                        .map(
                                          (day) => DropdownMenuItem(
                                            value: day,
                                            child: Text(
                                              day,
                                              style: AppTextStyles.labelMd
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedDayFilter = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral50,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedServiceFilter,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                ),
                                items:
                                    serviceFilters
                                        .map(
                                          (service) => DropdownMenuItem(
                                            value: service,
                                            child: Text(
                                              service,
                                              style: AppTextStyles.labelMd
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedServiceFilter = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (filteredSchedules.isEmpty)
                      _buildEmptySlots()
                    else
                      _buildSlotList(filteredSchedules),

                    if (!isReschedule) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionHeader('Keluhan Utama'),
                      const SizedBox(height: AppSpacing.md),
                      _buildComplaintField(),
                    ],

                    const SizedBox(height: AppSpacing.xxxl),
                    _buildConfirmButton(student),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthWorkerBrief(HealthWorker worker) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusXl,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.nama,
                  style: AppTextStyles.titleSm.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  worker.spesialisasi,
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      worker.lokasi.isNotEmpty
                          ? worker.lokasi
                          : 'Klinik Kampus',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLg.copyWith(
        fontWeight: FontWeight.w900,

        fontSize: 16,
      ),
    );
  }

  Widget _buildEmptySlots() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tidak ada jadwal praktek tersedia',
              style: AppTextStyles.labelMd.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList(List<HealthSchedule> schedules) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 5,
        radius: const Radius.circular(AppRadius.radius3),
        thumbColor: AppColors.neutral400,
        trackColor: AppColors.neutral200.withAlpha(50),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(right: AppSpacing.md),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final slot = schedules[index];

            final isSelected = _selectedSchedule?.id == slot.id;
            final formattedDate = DateFormat(
              'EEEE, dd MMM yyyy',
              'id',
            ).format(slot.tanggal);
            final start = slot.jamMulai;
            final end = slot.jamSelesai;
            final lokasi = slot.lokasi;

            final sisaKuota = slot.sisaKuota;

            final isFull = sisaKuota <= 0;

            return GestureDetector(
              onTap:
                  isFull
                      ? null
                      : () => setState(
                        () => _selectedSchedule = isSelected ? null : slot,
                      ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color:
                      isFull
                          ? Colors.grey.withAlpha(10)
                          : isSelected
                          ? Theme.of(context).colorScheme.primary
                          : context.appColors.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color:
                        isFull
                            ? Colors.grey.withAlpha(30)
                            : isSelected
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.neutral300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(40),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            isFull
                                ? Colors.grey.withAlpha(20)
                                : isSelected
                                ? Colors.white.withAlpha(30)
                                : AppColors.neutral100,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        isFull ? Icons.block_rounded : Icons.schedule_rounded,
                        color:
                            isFull
                                ? Colors.grey
                                : isSelected
                                ? context.appColors.onPrimary
                                : AppColors.neutral700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color:
                                  isFull
                                      ? Colors.grey
                                      : isSelected
                                      ? context.appColors.onPrimary
                                      : AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            'Pukul $start - $end WIB',
                            style: AppTextStyles.labelSm.copyWith(
                              color:
                                  isFull
                                      ? Colors.grey
                                      : isSelected
                                      ? Colors.white70
                                      : Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.white.withAlpha(30)
                                          : Colors.teal.withAlpha(15),
                                  borderRadius: AppRadius.radiusXs,
                                ),
                                child: Text(
                                  lokasi.isNotEmpty ? lokasi : 'Klinik Kampus',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        isSelected ? context.appColors.onPrimary : Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintField() {
    return TextField(
      controller: _complaintCtrl,
      maxLines: 4,
      style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText:
            'Tuliskan gejala atau keluhan yang Anda rasakan secara detail...',
        hintStyle: AppTextStyles.labelMd.copyWith(
          color: Theme.of(context).colorScheme.outline.withAlpha(100),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: AppColors.neutral100.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusXl,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.xl),
      ),
    );
  }

  Widget _buildConfirmButton(StudentProvider student) {
    final isReschedule = widget.rescheduleBookingId != null;
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 44,
        child: BkuButton(
          onPressed:
              (_selectedSchedule == null || _isSubmitting)
                  ? null
                  : () => _submit(student),
          text: isReschedule ? 'Konfirmasi Reschedule' : 'Lanjutkan Booking',
          variant: BkuButtonVariant.success,
          height: 44,
        ),
      ),
    );
  }

  Future<void> _submit(StudentProvider student) async {
    if (_selectedSchedule == null) return;

    final themeProvider = context.read<ThemeProvider>();
    final isReschedule = widget.rescheduleBookingId != null;
    if (!isReschedule && _complaintCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan isi keluhan terlebih dahulu'),
          backgroundColor: themeProvider.colorError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    bool success = false;
    String? errorMsg;

    try {
      if (isReschedule) {
        await student.rescheduleHealthBooking(
          widget.rescheduleBookingId!,
          _selectedSchedule!.id,
        );
      } else {
        await student.createHealthBooking(
          _selectedSchedule!.id,
          _complaintCtrl.text.trim(),
        );
      }
      success = true;
    } catch (e) {
      success = false;
      errorMsg = ErrorHandler.getMessage(e);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      BkuLoadingDialog.hide(context);

      if (success) {
        AppSnackbar.showSuccess(
          context,
          isReschedule ? 'Reschedule Berhasil!' : 'Booking Berhasil!',
        );
        Navigator.pop(context);
      } else {
        AppSnackbar.showError(
          context,
          errorMsg ?? 'Gagal membuat permintaan. Coba lagi.',
        );
      }
    }
  }
}
