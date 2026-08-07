import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_booking.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'health_booking_form_screen.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:go_router/go_router.dart';

class KlinikBookingScreen extends StatefulWidget {
  const KlinikBookingScreen({super.key});

  @override
  State<KlinikBookingScreen> createState() => _KlinikBookingScreenState();
}

class _KlinikBookingScreenState extends State<KlinikBookingScreen> {
  @override
  Widget build(BuildContext context) {
    final student = context.watch<ProfileProvider>();
    final health = context.watch<HealthViewModel>();
    final activeBookings =
        health.healthBookings
            .where((b) => b.status != 'Dibatalkan' && b.status != 'Ditolak')
            .toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await health.refreshHealthData();
        },
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Booking Klinik',
              subtitle: 'Jadwal & Antrian Medis',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    if (student.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                      )
                    else ...[
                      // SECTION 1: JADWAL KLINIK SAYA
                      FadeInAnimation(
                        delay: 0.1,
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: context.appColors.primary,
                                borderRadius: AppRadius.radiusXs,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            Text(
                              'Jadwal Klinik Saya',
                              style: AppTextStyles.titleLg.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.neutral800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (activeBookings.isEmpty)
                        FadeInAnimation(
                          delay: 0.2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxl,
                              horizontal: AppSpacing.xl,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              borderRadius: AppRadius.radiusXl,
                              border: Border.all(color: AppColors.neutral200),
                              boxShadow: [
                                BoxShadow(
                                  color: context.appColors.onSurface.withAlpha(2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 32,
                                    color:
                                        context.appColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Belum Ada Janji Temu Aktif',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color:
                                        context.appColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s6),
                                Text(
                                  'Jadwal pemeriksaan atau konsultasi dokter yang Anda pesan akan muncul di sini.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        context.appColors.outline,
                                    fontSize: 11,
                                    height: 1.4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...List.generate(
                          activeBookings.length,
                          (index) => FadeInAnimation(
                            delay: 0.2 + (index * 0.05),
                            child: _buildBookingCard(
                              context,
                              student,
                              activeBookings[index],
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xxl),

                      // SECTION 2: TENAGA KESEHATAN TERSEDIA
                      FadeInAnimation(
                        delay: 0.3,
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: context.appColors.primary,
                                borderRadius: AppRadius.radiusXs,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            Text(
                              'Tenaga Kesehatan Tersedia',
                              style: AppTextStyles.titleLg.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.neutral800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (health.healthWorkers.isEmpty)
                        FadeInAnimation(
                          delay: 0.4,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: Text(
                                'Tidak ada tenaga kesehatan yang aktif',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(
                          health.healthWorkers.length,
                          (index) => FadeInAnimation(
                            delay: 0.4 + (index * 0.05),
                            child: _buildHealthWorkerCard(
                              context,
                              student,
                              health.healthWorkers[index],
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    ProfileProvider student,
    HealthBooking booking,
  ) {
    final schedule = booking.jadwal;
    if (schedule == null) return const SizedBox.shrink();

    final dateStr = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id',
    ).format(schedule.tanggal);
    final isApproved =
        booking.status == 'Disetujui' || booking.status == 'Dikonfirmasi';
    final isCompleted = booking.status == 'Selesai';

    final themeProvider = context.watch<ThemeProvider>();
    Color statusColor = themeProvider.warning;
    if (isApproved || isCompleted) {
      statusColor = themeProvider.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBookingDetailModal(context, student, booking),
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Text(
                        booking.status,
                        style: AppTextStyles.labelSm.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Antrean #${booking.id}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.neutral400,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.tenagaKes?.nama ?? 'Tenaga Kesehatan',
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral800,
                      ),
                    ),
                    Text(
                      schedule.tenagaKes?.spesialisasi ?? 'Dokter Umum',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildCardInfoRow(Icons.calendar_today_rounded, dateStr),
                _buildCardInfoRow(
                  Icons.access_time_rounded,
                  '${schedule.jamMulai} - ${schedule.jamSelesai} WIB',
                ),
                _buildCardInfoRow(
                  Icons.location_on_rounded,
                  schedule.lokasi.isNotEmpty
                      ? schedule.lokasi
                      : 'Klinik Kampus',
                ),
                _buildCardInfoRow(
                  Icons.medical_services_rounded,
                  'Keluhan: ${booking.keluhan}',
                ),
                if (booking.alasanPenolakan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Catatan Review: ${booking.alasanPenolakan}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: themeProvider.colorError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!isCompleted) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed:
                              () => _confirmCancelBooking(
                                context,
                                student,
                                booking,
                              ),
                          text: 'Batalkan',
                          variant: BkuButtonVariant.outline,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BkuButton(
                          onPressed: () {
                            final schedule = booking.jadwal;
                            if (schedule != null &&
                                schedule.tenagaKes != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HealthBookingFormScreen(
                                        worker: schedule.tenagaKes!,
                                        rescheduleBookingId:
                                            booking.id.toString(),
                                      ),
                                ),
                              ).then((_) {
  if (context.mounted) {
    context.read<HealthViewModel>().refreshHealthData();
  }
});
                            }
                          },
                          text: 'Jadwal Ulang',
                          variant: BkuButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthWorkerCard(
    BuildContext context,
    ProfileProvider student,
    HealthWorker worker,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    color: AppColors.neutral800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (worker.spesialisasi.contains('Gizi')
                            ? AppColors.warning
                            : context.appColors.success)
                        .withAlpha(15),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    worker.spesialisasi,
                    style: AppTextStyles.labelSm.copyWith(
                      color:
                          worker.spesialisasi.contains('Gizi')
                              ? AppColors.warning
                              : context.appColors.success,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: context.appColors.outline,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        worker.lokasi.isNotEmpty
                            ? worker.lokasi
                            : 'Klinik Kampus',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          BkuButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HealthBookingFormScreen(worker: worker),
                  ),
                ).then((_) {
  if (context.mounted) {
    context.read<HealthViewModel>().refreshHealthData();
  }
}),
            text: 'Booking',
            width: 95,
            height: 40,
            fullWidth: false,
            variant: BkuButtonVariant.success,
          ),
        ],
      ),
    );
  }

  void _showBookingDetailModal(
    BuildContext context,
    ProfileProvider student,
    HealthBooking booking,
  ) {
    final schedule = booking.jadwal;
    final dateStr =
        schedule != null
            ? DateFormat('EEEE, dd MMMM yyyy', 'id').format(schedule.tanggal)
            : '-';
    final isApproved =
        booking.status == 'Disetujui' || booking.status == 'Dikonfirmasi';
    final isCompleted = booking.status == 'Selesai';
    final isCancelled =
        booking.status == 'Dibatalkan' || booking.status == 'Ditolak';

    Color statusColor = AppColors.warning;
    if (isApproved || isCompleted) {
      statusColor = AppColors.success;
    } else if (isCancelled) {
      statusColor = AppColors.error;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: SingleChildScrollView(
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
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Janji Temu',
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Antrean #${booking.id}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          booking.status,
                          style: AppTextStyles.labelSm.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  const Divider(color: AppColors.neutral200),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'TENAGA KESEHATAN',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    schedule?.tenagaKes?.nama ?? 'Tenaga Kesehatan',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    schedule?.tenagaKes?.spesialisasi ?? 'Pemeriksaan Umum',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'WAKTU & LOKASI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCardInfoRow(Icons.calendar_today_rounded, dateStr),
                  _buildCardInfoRow(
                    Icons.access_time_rounded,
                    '${schedule?.jamMulai ?? "-"} - ${schedule?.jamSelesai ?? "-"} WIB',
                  ),
                  _buildCardInfoRow(
                    Icons.location_on_rounded,
                    (schedule?.lokasi.isNotEmpty ?? false)
                        ? schedule!.lokasi
                        : 'Klinik Kampus Universitas Bakti Kencana',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'KELUHAN MAHASISWA',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusLg,
                    ),
                    child: Text(
                      booking.keluhan.isEmpty ? '-' : booking.keluhan,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (booking.alasanPenolakan.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'CATATAN REVIEW',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: Text(
                        booking.alasanPenolakan,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (!isCompleted && !isCancelled) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: BkuButton(
                            onPressed: () {
                              Navigator.pop(modalContext);
                              _confirmCancelBooking(context, student, booking);
                            },
                            text: 'Batalkan Janji',
                            variant: BkuButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: BkuButton(
                            onPressed: () {
                              Navigator.pop(modalContext);
                              if (schedule != null &&
                                  schedule.tenagaKes != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => HealthBookingFormScreen(
                                          worker: schedule.tenagaKes!,
                                          rescheduleBookingId:
                                              booking.id.toString(),
                                        ),
                                  ),
                                ).then((_) {
  if (context.mounted) {
    context.read<HealthViewModel>().refreshHealthData();
  }
});
                              }
                            },
                            text: 'Jadwal Ulang',
                            variant: BkuButtonVariant.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildCardInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.appColors.outline),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancelBooking(
    BuildContext context,
    ProfileProvider student,
    HealthBooking booking,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Batalkan Janji Temu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin membatalkan janji temu klinik ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close confirm dialog
                  BkuLoadingDialog.show(context);
                  try {
                    await context.read<HealthViewModel>().cancelHealthBooking(booking.id.toString());
                    if (context.mounted) {
                      BkuLoadingDialog.hide(context);
                      showDialog(
                        context: context,
                        builder:
                            (context) => CustomDialog(
                              title: 'Berhasil',
                              content: 'Janji temu berhasil dibatalkan',
                              cancelText: '',
                              confirmText: 'Tutup',
                              onCancel: () {},
                              onConfirm: () => context.pop(),
                            ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      BkuLoadingDialog.hide(context);
                      showDialog(
                        context: context,
                        builder:
                            (context) => CustomDialog(
                              title: 'Gagal',
                              content: ErrorHandler.getMessage(e),
                              cancelText: '',
                              confirmText: 'Tutup',
                              isDestructive: true,
                              onCancel: () {},
                              onConfirm: () => context.pop(),
                            ),
                      );
                    }
                  }
                },

                child: const Text(
                  'Ya, Batalkan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
