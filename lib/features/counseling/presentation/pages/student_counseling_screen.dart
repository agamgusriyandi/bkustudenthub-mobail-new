import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class StudentCounselingScreen extends StatefulWidget {
  const StudentCounselingScreen({super.key});

  @override
  State<StudentCounselingScreen> createState() =>
      _StudentCounselingScreenState();
}

class _StudentCounselingScreenState extends State<StudentCounselingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<StudentCounselingProvider>();
      p.loadPsychologists();
      p.loadMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().background,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'BKU Care',
            subtitle: 'Konseling & Kesehatan Mental',
            variant: AppBarVariant.student,
            showBackButton: true,
            expandedHeight: 130,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  SizedBox(height: AppSpacing.xl),
                  _buildUrgentCard(),
                  SizedBox(height: AppSpacing.xxl),
                  _buildSectionHeader('Menu Layanan'),
                  SizedBox(height: AppSpacing.lg),
                  _buildServiceGrid(context),
                  SizedBox(height: AppSpacing.xxl),
                  _buildSectionHeader('Jadwal Saya'),
                  SizedBox(height: AppSpacing.lg),
                  _buildMyAppointments(),
                  SizedBox(height: AppSpacing.xxl),
                  _buildSectionHeader('Psikolog Tersedia'),
                  SizedBox(height: AppSpacing.lg),
                  _buildPsychologistList(context),
                  SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final name = context.watch<ProfileProvider>().name;
    final firstName = name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $firstName 👋',
          style: AppTextStyles.titleLg.copyWith(
            color: context.watch<ThemeProvider>().primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'Apa yang kamu rasakan hari ini? Kami di sini untuk mendengarkan.',
          style: AppTextStyles.bodyMd.copyWith(
            color: context.watch<ThemeProvider>().outline,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentCard() {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: context.appColors.error.withAlpha(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().colorError,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emergency_rounded, color: context.appColors.onPrimary, size: 24),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh bantuan segera?',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: context.watch<ThemeProvider>().colorError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Klik untuk hubungi hotline darurat 24/7',
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.watch<ThemeProvider>().colorError,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: context.watch<ThemeProvider>().colorError,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        color: context.watch<ThemeProvider>().primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildServiceCard(
          context,
          'Booking Sesi',
          Icons.event_available_rounded,
          context.watch<ThemeProvider>().info,
          AppRoutes.counselingBooking,
        ),
        _buildServiceCard(
          context,
          'Riwayat Saya',
          Icons.history_rounded,
          context.watch<ThemeProvider>().warning,
          null,
          onTap: () => _showMyBookings(context),
        ),
        _buildServiceCard(
          context,
          'Rekam Medis',
          Icons.medical_information_rounded,
          context.appColors.info,
          null,
          onTap: () => _showMedicalRecord(context),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String? route, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? (route != null ? () => context.push(route) : null),
      child: BkuCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAppointments() {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        if (provider.myBookingsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: BkuShimmerList(itemCount: 3, itemHeight: 120),
          );
        }
        final bookings = provider.myBookings;
        if (bookings.isEmpty) {
          return BkuCard(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                'Belum ada jadwal konseling',
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.watch<ThemeProvider>().outline,
                ),
              ),
            ),
          );
        }

        // Tampilkan booking terbaru yang aktif
        final active = bookings.firstWhere(
          (b) => b['status'] == 'Menunggu' || b['status'] == 'Dikonfirmasi',
          orElse: () => bookings.first,
        );

        final psikolog = active['psychologist'] as Map<String, dynamic>?;
        final psikologName = psikolog?['name']?.toString() ?? '-';
        final displayDate = active['display_date']?.toString() ?? '-';
        final start = active['start']?.toString() ?? '-';
        final status = active['status']?.toString() ?? '-';
        final topic = active['topic']?.toString() ?? '-';

        Color statusColor = context.watch<ThemeProvider>().primary;
        if (status.toLowerCase() == 'menunggu') {
          statusColor = context.watch<ThemeProvider>().warning;
        }
        if (status.toLowerCase() == 'selesai') {
          statusColor = context.watch<ThemeProvider>().success;
        }
        if (status.toLowerCase() == 'ditolak' ||
            status.toLowerCase() == 'dibatalkan') {
          statusColor = context.watch<ThemeProvider>().colorError;
        }

        return BkuCard(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Column(
                  children: [
                    Text(
                      displayDate.split(' ').first,
                      style: AppTextStyles.titleMd.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      displayDate.split(' ').skip(1).join(' '),
                      style: AppTextStyles.labelSm.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$psikologName • $start WIB',
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.watch<ThemeProvider>().outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelMd.copyWith(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPsychologistList(BuildContext context) {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        if (provider.psychologistsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: BkuShimmerList(itemCount: 4, itemHeight: 120),
          );
        }
        if (provider.psychologistsError != null) {
          return Center(
            child: Text(
              provider.psychologistsError!,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.watch<ThemeProvider>().colorError,
              ),
            ),
          );
        }
        final psychologists = provider.psychologists;
        if (psychologists.isEmpty) {
          return BkuCard(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                'Belum ada psikolog tersedia',
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.watch<ThemeProvider>().outline,
                ),
              ),
            ),
          );
        }
        return Column(
          children:
              psychologists
                  .map((p) => _buildPsychologistCard(context, p))
                  .toList(),
        );
      },
    );
  }

  Widget _buildPsychologistCard(BuildContext context, Map<String, dynamic> p) {
    final name = p['name']?.toString() ?? '-';
    final spec = p['specialization']?.toString() ?? '-';
    final id = p['id']?.toString() ?? '';
    final isActive = p['is_active'] == true;

    return BkuCard(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.neutral200,
                child: Icon(
                  Icons.person_rounded,
                  color: context.watch<ThemeProvider>().outline,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? context.watch<ThemeProvider>().success
                            : AppColors.neutral500,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral300, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  spec,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.watch<ThemeProvider>().outline,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  isActive ? 'Tersedia' : 'Tidak Tersedia',
                  style: AppTextStyles.labelMd.copyWith(
                    color:
                        isActive
                            ? context.watch<ThemeProvider>().success
                            : AppColors.neutral500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          BkuButton(
            text: 'Book',
            onPressed:
                isActive
                    ? () => context.push(
                      '${AppRoutes.counselingBooking}?psikolog_id=$id',
                    )
                    : null,
            width: 80,
            height: 36,
          ),
        ],
      ),
    );
  }

  void _showMyBookings(BuildContext context) {
    final provider = context.read<StudentCounselingProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MyBookingsSheet(provider: provider),
    );
  }

  void _showMedicalRecord(BuildContext context) {
    final provider = context.read<StudentCounselingProvider>();
    provider.loadMyMedicalRecord();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedicalRecordSheet(provider: provider),
    );
  }
}

// ─── My Bookings Sheet ────────────────────────────────────────────────────────

class _MyBookingsSheet extends StatelessWidget {
  final StudentCounselingProvider provider;
  const _MyBookingsSheet({required this.provider});

  void _handleCancelBooking(BuildContext context, String bookingId) {
    BkuDialog.show(
      context: context,
      title: 'Batalkan Booking?',
      message: 'Apakah Anda yakin ingin membatalkan jadwal konseling ini?',
      primaryButtonText: 'Ya, Batalkan',
      type: BkuDialogType.error,
      onPrimaryPressed: () async {
        Navigator.pop(context);
        BkuLoadingDialog.show(context);
              final success = await context
                  .read<StudentCounselingProvider>()
                  .cancelBooking(bookingId);
              if (context.mounted) {
                BkuLoadingDialog.hide(context);
                BkuDialog.show(
                  context: context,
                  title: success ? 'Berhasil' : 'Gagal',
                  message:
                      success
                          ? 'Booking berhasil dibatalkan'
                          : 'Gagal membatalkan booking',
                  primaryButtonText: 'Tutup',
                  type: success ? BkuDialogType.success : BkuDialogType.error,
                  onPrimaryPressed: () => context.pop(),
                );
              }
            },
          );
  }

  void _handleReschedule(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RescheduleSheet(provider: provider, booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.neutral500.withAlpha(50),
              borderRadius: AppRadius.radiusMd,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Riwayat Booking',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ChangeNotifierProvider.value(
              value: provider,
              child: Consumer<StudentCounselingProvider>(
                builder: (context, p, _) {
                  if (p.myBookingsLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                    );
                  }
                  if (p.myBookings.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada booking',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: context.watch<ThemeProvider>().outline,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: p.myBookings.length,
                    itemBuilder: (context, i) {
                      final b = p.myBookings[i];
                      final psikolog =
                          b['psychologist'] as Map<String, dynamic>?;
                      final status = b['status']?.toString() ?? '-';
                      final mode = b['mode']?.toString() ?? 'Tatap Muka';
                      final linkMeeting = b['link_meeting']?.toString() ?? '';
                      final isOnline = mode == 'Online';
                      final isDikonfirmasi = status == 'Dikonfirmasi';

                      Color statusColor =
                          context.watch<ThemeProvider>().primary;
                      if (status.toLowerCase() == 'menunggu') {
                        statusColor = context.watch<ThemeProvider>().warning;
                      }
                      if (status.toLowerCase() == 'selesai') {
                        statusColor = context.watch<ThemeProvider>().success;
                      }
                      if (status.toLowerCase() == 'ditolak' ||
                          status.toLowerCase() == 'dibatalkan') {
                        statusColor = context.watch<ThemeProvider>().colorError;
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(color: statusColor.withAlpha(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b['topic']?.toString() ?? '-',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${psikolog?['name'] ?? '-'} • ${b['display_date'] ?? '-'}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              context
                                                  .watch<ThemeProvider>()
                                                  .outline,
                                        ),
                                      ),
                                      Text(
                                        '${b['start'] ?? '-'} - ${b['end'] ?? '-'}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              context
                                                  .watch<ThemeProvider>()
                                                  .outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(15),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    status,
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            // Badge mode
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isOnline
                                            ? context
                                                .watch<ThemeProvider>()
                                                .info
                                                .withAlpha(20)
                                            : context.appColors.info.withAlpha(20),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOnline
                                            ? Icons.videocam_rounded
                                            : Icons.location_on_rounded,
                                        size: 11,
                                        color:
                                            isOnline
                                                ? context
                                                    .watch<ThemeProvider>()
                                                    .info
                                                : context.appColors.info,
                                      ),
                                      SizedBox(width: AppSpacing.xs),
                                      Text(
                                        mode,
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isOnline
                                                  ? context
                                                      .watch<ThemeProvider>()
                                                      .info
                                                  : context.appColors.info,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Link meeting — tampil kalau Online + Dikonfirmasi + ada link
                            if (isOnline &&
                                isDikonfirmasi &&
                                linkMeeting.isNotEmpty) ...[
                              SizedBox(height: AppSpacing.s10),
                              GestureDetector(
                                onTap: () async {
                                  final uri = Uri.parse(linkMeeting);
                                  try {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.inAppBrowserView,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      AppSnackbar.showError(
                                        context,
                                        'Gagal membuka link meeting',
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context
                                        .watch<ThemeProvider>()
                                        .info
                                        .withAlpha(10),
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color: context
                                          .watch<ThemeProvider>()
                                          .info
                                          .withAlpha(40),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.videocam_rounded,
                                        color:
                                            context.watch<ThemeProvider>().info,
                                        size: 18,
                                      ),
                                      SizedBox(width: AppSpacing.s10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Link Meeting Tersedia',
                                              style: AppTextStyles.labelMd
                                                  .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        context
                                                            .watch<
                                                              ThemeProvider
                                                            >()
                                                            .info,
                                                  ),
                                            ),
                                            Text(
                                              linkMeeting,
                                              style: AppTextStyles.labelMd
                                                  .copyWith(
                                                    fontSize: 10,
                                                    color: context
                                                        .watch<ThemeProvider>()
                                                        .info
                                                        .withAlpha(180),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        color:
                                            context.watch<ThemeProvider>().info,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            // Actions (Reschedule & Cancel)
                            if (status == 'Menunggu' ||
                                status == 'Dikonfirmasi') ...[
                              const Divider(height: 24, thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  BkuButton(
                                    text: 'Batalkan Sesi',
                                    variant: BkuButtonVariant.outline,
                                    onPressed:
                                        () => _handleCancelBooking(
                                          context,
                                          b['id'].toString(),
                                        ),
                                    width: 120,
                                    height: 36,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  BkuButton(
                                    text: 'Reschedule',
                                    onPressed:
                                        () => _handleReschedule(context, b),
                                    width: 120,
                                    height: 36,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reschedule Sheet ────────────────────────────────────────────────────────

class _RescheduleSheet extends StatefulWidget {
  final StudentCounselingProvider provider;
  final Map<String, dynamic> booking;

  const _RescheduleSheet({required this.provider, required this.booking});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Parse current date and times if possible to pre-populate
    try {
      final rawDate = widget.booking['tanggal'] ?? widget.booking['date'];
      if (rawDate != null) {
        _selectedDate = DateTime.parse(rawDate.toString());
      }
    } catch (_) {}

    try {
      final startStr = widget.booking['start']?.toString() ?? '';
      if (startStr.contains(':')) {
        final parts = startStr.split(':');
        _startTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}

    try {
      final endStr = widget.booking['end']?.toString() ?? '';
      if (endStr.contains(':')) {
        final parts = endStr.split(':');
        _endTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate != null && _selectedDate!.isAfter(now)
              ? _selectedDate!
              : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.watch<ThemeProvider>().primary,
              onPrimary: context.appColors.onPrimary,
              onSurface: context.watch<ThemeProvider>().onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Auto end time = start time + 1 hour if not set
        if (_endTime == null) {
          int endHour = picked.hour + 1;
          if (endHour > 23) endHour = 23;
          _endTime = TimeOfDay(hour: endHour, minute: picked.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '-';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _startTime == null) {
      AppSnackbar.showWarning(
        context,
        'Pilih tanggal dan jam mulai rescheduling',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final startStr = _formatTimeOfDay(_startTime);
    final endStr = _formatTimeOfDay(_endTime);
    final bookingId = widget.booking['id'].toString();

    final success = await widget.provider.rescheduleBooking(
      bookingId: bookingId,
      date: formattedDate,
      start: startStr,
      end: endStr,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.pop(); // Close Reschedule Sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Berhasil menjadwalkan ulang! Menunggu konfirmasi ulang dari psikolog.',
            ),
            backgroundColor: context.watch<ThemeProvider>().success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        AppSnackbar.showError(
          context,
          widget.provider.rescheduleError ??
              'Gagal melakukan reschedule. Coba lagi.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final psikolog = widget.booking['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? '-';
    final topic = widget.booking['topic']?.toString() ?? '-';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
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
          SizedBox(height: AppSpacing.s20),
          Text(
            'Reschedule Konseling',
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w900,
              color: context.watch<ThemeProvider>().primary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Untuk sesi dengan $psikologName\nTopik: $topic',
            style: AppTextStyles.bodyMd.copyWith(
              color: context.watch<ThemeProvider>().outline,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          // Date Field
          _buildPickerField(
            label: 'Tanggal Baru',
            value:
                _selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('dd MMMM yyyy').format(_selectedDate!),
            icon: Icons.calendar_today_rounded,
            onTap: _selectDate,
          ),
          SizedBox(height: AppSpacing.lg),
          // Start & End Time Fields
          Row(
            children: [
              Expanded(
                child: _buildPickerField(
                  label: 'Jam Mulai',
                  value:
                      _startTime == null
                          ? 'Pilih Jam'
                          : _formatTimeOfDay(_startTime),
                  icon: Icons.access_time_rounded,
                  onTap: _selectStartTime,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildPickerField(
                  label: 'Jam Selesai',
                  value:
                      _endTime == null
                          ? 'Pilih Jam'
                          : _formatTimeOfDay(_endTime),
                  icon: Icons.access_time_rounded,
                  onTap: _selectEndTime,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().warning.withAlpha(10),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: context.watch<ThemeProvider>().warning.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.watch<ThemeProvider>().warning,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Setelah reschedule dikirim, status booking akan kembali ke Menunggu dan psikolog perlu menyetujui jadwal baru.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.watch<ThemeProvider>().warning,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          BkuButton(
            text: 'Kirim Reschedule',
            onPressed: _submit,
            isLoading: _isSubmitting,
            height: 55,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSpacing.s6),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusLg,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().background,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: context.watch<ThemeProvider>().outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: context.watch<ThemeProvider>().outline,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMd.copyWith(
                      color:
                          value.startsWith('Pilih')
                              ? context
                                  .watch<ThemeProvider>()
                                  .outline
                                  .withAlpha(150)
                              : context.watch<ThemeProvider>().onSurface,
                      fontWeight:
                          value.startsWith('Pilih')
                              ? FontWeight.normal
                              : FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Medical Record Sheet ─────────────────────────────────────────────────────

class _MedicalRecordSheet extends StatelessWidget {
  final StudentCounselingProvider provider;
  const _MedicalRecordSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.neutral500.withAlpha(50),
              borderRadius: AppRadius.radiusMd,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Rekam Medis Saya',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ChangeNotifierProvider.value(
              value: provider,
              child: Consumer<StudentCounselingProvider>(
                builder: (context, p, _) {
                  if (p.medicalRecordLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                    );
                  }
                  final records = p.myMedicalRecord['records'] as List? ?? [];
                  final summary =
                      p.myMedicalRecord['summary'] as Map<String, dynamic>? ??
                      {};
                  if (records.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada catatan sesi',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: context.watch<ThemeProvider>().outline,
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    children: [
                      // Summary card
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        margin: EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context
                              .watch<ThemeProvider>()
                              .primary
                              .withAlpha(10),
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(
                            color: context
                                .watch<ThemeProvider>()
                                .primary
                                .withAlpha(30),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.summarize_rounded,
                              color: context.watch<ThemeProvider>().primary,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ${summary['total_records'] ?? 0} catatan',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Status terkini: ${summary['latest_status'] ?? '-'}',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color:
                                        context.watch<ThemeProvider>().outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ...records.map((r) {
                        final rec = r as Map<String, dynamic>;
                        return Container(
                           margin: EdgeInsets.only(bottom: AppSpacing.md),
                           padding: EdgeInsets.all(AppSpacing.lg),
                           decoration: BoxDecoration(
                             color: context.appColors.surface,
                             borderRadius: AppRadius.radiusLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rec['display_date']?.toString() ?? '-',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color:
                                          context
                                              .watch<ThemeProvider>()
                                              .outline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    rec['type']?.toString() ?? '-',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color:
                                          context
                                              .watch<ThemeProvider>()
                                              .primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.sm),
                              if ((rec['complaint']?.toString() ?? '')
                                  .isNotEmpty)
                                Text(
                                  'Keluhan: ${rec['complaint']}',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color:
                                        context
                                            .watch<ThemeProvider>()
                                            .onSurfaceVariant,
                                  ),
                                ),
                              if ((rec['recommendation']?.toString() ?? '')
                                  .isNotEmpty) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Rekomendasi: ${rec['recommendation']}',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color:
                                        context.watch<ThemeProvider>().outline,
                                  ),
                                ),
                              ],
                              SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  _buildChip(
                                    'Mood: ${rec['mood'] ?? '-'}',
                                    context.watch<ThemeProvider>().info,
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  _buildChip(
                                    rec['status']?.toString() ?? '-',
                                    context.watch<ThemeProvider>().success,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
