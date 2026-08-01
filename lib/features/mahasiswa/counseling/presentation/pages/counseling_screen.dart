import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/counseling_session.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/psychologist_list_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CounselingScreen extends StatefulWidget {
  const CounselingScreen({super.key});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  int _selectedTabIndex = 0;
  int _currentBookingPage = 1;
  static const int _bookingPerPage = 10;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAllData();
      context.read<StudentCounselingProvider>().loadPsychologists();
      context.read<StudentCounselingProvider>().loadMyReferrals();
      context.read<StudentCounselingProvider>().loadMyBookings();
      context.read<StudentCounselingProvider>().loadMyMedicalRecord();
    });

    // Start periodic polling for real-time booking status updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<StudentCounselingProvider>().loadMyBookings(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        color: AppColors.neutral800,
        onRefresh: () async {
          await Future.wait([
            context.read<StudentProvider>().loadAllData(),
            context.read<StudentCounselingProvider>().loadPsychologists(),
            context.read<StudentCounselingProvider>().loadMyReferrals(),
            context.read<StudentCounselingProvider>().loadMyBookings(),
            context.read<StudentCounselingProvider>().loadMyMedicalRecord(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Layanan Konseling',
              subtitle: 'CARE & SUPPORT',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
              actions: [
                IconButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const PsychologistListScreen(
                                autoFocusSearch: true,
                              ),
                        ),
                      ),
                          icon: Icon(Icons.search_rounded, color: context.appColors.onPrimary),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      const FadeInAnimation(
                        delay: 0.2,
                        child: _CounselingBanner(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeInAnimation(
                        delay: 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Psikolog Aktif',
                                  style: AppTextStyles.titleLg.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const PsychologistListScreen(),
                                        ),
                                      ),
                                  child: Text(
                                    'Lihat Semua',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.neutral800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Consumer<StudentCounselingProvider>(
                              builder: (context, counselingProvider, _) {
                                if (counselingProvider.psychologistsLoading) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Row(
                                      children: List.generate(
                                        2,
                                        (index) => const Padding(
                                          padding: EdgeInsets.only(right: AppSpacing.lg),
                                          child: BkuShimmer(
                                            width: 160,
                                            height: 220,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(AppRadius.radius20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final psychologists =
                                    counselingProvider.psychologists;
                                if (psychologists.isEmpty) {
                                  return const SizedBox(
                                    height: 80,
                                    child: Center(
                                      child: Text(
                                        'Belum ada psikolog tersedia',
                                        style: TextStyle(
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox(
                                  height: 235,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    physics: const ClampingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    ),
                                    itemCount: psychologists.length,
                                    itemBuilder:
                                        (context, index) => FadeInAnimation(
                                          delay: 0.4 + (index * 0.1),
                                          child: _buildPsychologistCardFromMap(
                                            context,
                                            psychologists[index],
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      FadeInAnimation(
                        delay: 0.5,
                        child:
                            student.isLoading
                                ? const BkuShimmer(
                                  width: double.infinity,
                                  height: 180,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.xl),
                                  ),
                                )
                                : _buildDashboardSection(),
                      ),
                      FadeInAnimation(
                        delay: 0.6,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => _selectedTabIndex = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedTabIndex == 0
                                              ? context.appColors.surface
                                              : Colors.transparent,
                                      borderRadius: AppRadius.radiusMd,
                                      boxShadow:
                                          _selectedTabIndex == 0
                                              ? [
                                                BoxShadow(
                                                  color: context.appColors.onSurface.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Text(
                                      'Sesi Konseling',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight:
                                            _selectedTabIndex == 0
                                                ? FontWeight.w900
                                                : FontWeight.bold,
                                        fontSize: 12,
                                        color:
                                            _selectedTabIndex == 0
                                                ? AppColors.neutral800
                                                : AppColors.neutral500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => _selectedTabIndex = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedTabIndex == 1
                                              ? context.appColors.surface
                                              : Colors.transparent,
                                      borderRadius: AppRadius.radiusMd,
                                      boxShadow:
                                          _selectedTabIndex == 1
                                              ? [
                                                BoxShadow(
                                                  color: context.appColors.onSurface.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Text(
                                      'Surat Rujukan',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight:
                                            _selectedTabIndex == 1
                                                ? FontWeight.w900
                                                : FontWeight.bold,
                                        fontSize: 12,
                                        color:
                                            _selectedTabIndex == 1
                                                ? AppColors.neutral800
                                                : AppColors.neutral500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          setState(() => _selectedTabIndex = 2),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedTabIndex == 2
                                              ? context.appColors.surface
                                              : Colors.transparent,
                                      borderRadius: AppRadius.radiusMd,
                                      boxShadow:
                                          _selectedTabIndex == 2
                                              ? [
                                                BoxShadow(
                                                  color: context.appColors.onSurface.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Text(
                                      'Rekam Medis',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight:
                                            _selectedTabIndex == 2
                                                ? FontWeight.w900
                                                : FontWeight.bold,
                                        fontSize: 12,
                                        color:
                                            _selectedTabIndex == 2
                                                ? AppColors.neutral800
                                                : AppColors.neutral500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (_selectedTabIndex == 0) ...[
                        Consumer<StudentCounselingProvider>(
                          builder: (context, provider, _) {
                            if (provider.myBookingsLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                child: BkuShimmerList(
                                  itemCount: 2,
                                  itemHeight: 140,
                                ),
                              );
                            }
                            if (provider.myBookings.isEmpty) {
                              return FadeInAnimation(
                                delay: 0.7,
                                child: _buildEmptyState(),
                              );
                            }

                            final totalBookings = provider.myBookings.length;
                            final totalPages = (totalBookings / _bookingPerPage).ceil();
                            final validPage = _currentBookingPage.clamp(1, totalPages > 0 ? totalPages : 1);
                            final startIndex = (validPage - 1) * _bookingPerPage;
                            final endIndex = (startIndex + _bookingPerPage < totalBookings)
                                ? startIndex + _bookingPerPage
                                : totalBookings;
                            final paginatedBookings = provider.myBookings.sublist(startIndex, endIndex);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(paginatedBookings.length, (
                                  index,
                                ) {
                                  final booking = paginatedBookings[index];
                                  return FadeInAnimation(
                                    delay: 0.1 + (index * 0.05),
                                    child: _buildRealSessionCard(
                                      context,
                                      booking,
                                    ),
                                  );
                                }),
                                if (totalPages > 1) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                    color: context.appColors.background,
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: AppColors.neutral300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          onPressed:
                                              validPage > 1
                                                  ? () {
                                                    setState(() {
                                                      _currentBookingPage =
                                                          validPage - 1;
                                                    });
                                                  }
                                                  : null,
                                          icon: const Icon(
                                            Icons.chevron_left_rounded,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Sebelumnya',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Halaman $validPage dari $totalPages',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral700,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed:
                                              validPage < totalPages
                                                  ? () {
                                                    setState(() {
                                                      _currentBookingPage =
                                                          validPage + 1;
                                                    });
                                                  }
                                                  : null,
                                          icon: const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Selanjutnya',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          iconAlignment: IconAlignment.end,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ] else if (_selectedTabIndex == 1) ...[
                        Consumer<StudentCounselingProvider>(
                          builder: (context, provider, _) {
                            if (provider.myReferralsLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                child: BkuShimmerList(
                                  itemCount: 2,
                                  itemHeight: 120,
                                ),
                              );
                            }
                            if (provider.myReferrals.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xxxl,
                                  ),
                                  child: Text(
                                    'Belum ada surat rujukan',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: AppColors.neutral500,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(
                                  provider.myReferrals.length,
                                  (index) => FadeInAnimation(
                                    delay: 0.2 + (index * 0.1),
                                    child: _buildReferralCard(
                                      context,
                                      provider.myReferrals[index],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        Consumer<StudentCounselingProvider>(
                          builder: (context, provider, _) {
                            if (provider.medicalRecordLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                child: BkuShimmerList(
                                  itemCount: 2,
                                  itemHeight: 140,
                                ),
                              );
                            }
                            final records =
                                (provider.myMedicalRecord['records'] as List?)
                                        ?.cast<Map<String, dynamic>>() ??
                                    const [];
                            if (records.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xxxl,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.medical_information_outlined,
                                        size: 64,
                                        color: context.appColors.outline
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        'Belum ada rekam medis',
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.neutral500,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(
                                  records.length,
                                  (index) => FadeInAnimation(
                                    delay: 0.2 + (index * 0.1),
                                    child: _buildMedicalRecordCard(
                                      context,
                                      records[index],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: AppSpacing.s120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.myBookings;
        final total = bookings.length.toString();
        final pending =
            bookings
                .where(
                  (s) =>
                      s['status'] == 'Menunggu' ||
                      s['status'] == 'Dikonfirmasi',
                )
                .length
                .toString();
        final completed =
            bookings.where((s) => s['status'] == 'Selesai').length.toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Layanan',
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w900,
                color: context.appColors.outline,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BkuCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        'TOTAL SESI',
                        total,
                        Icons.history_rounded,
                        AppColors.info,
                      ),
                      _buildMiniStat(
                        'MENUNGGU',
                        pending,
                        Icons.pending_actions_rounded,
                        AppColors.neutral500,
                      ),
                      _buildMiniStat(
                        'SELESAI',
                        completed,
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.neutral800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildFacultyMapping(StudentProvider student) {
    final list = student.facultyProgress;
    if (list.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progres Sesi per Fakultas (Top 3)',
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFacultyBar('Fakultas Farmasi', 0.85, '452 Mhs'),
          const SizedBox(height: AppSpacing.md),
          _buildFacultyBar('Fakultas Keperawatan', 0.65, '312 Mhs'),
          const SizedBox(height: AppSpacing.md),
          _buildFacultyBar('Fakultas Kesehatan', 0.45, '220 Mhs'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progres Sesi per Fakultas (Top 3)',
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(list.length, (index) {
          final item = list[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == list.length - AppSpacing.s1 ? 0 : AppSpacing.md),
            child: _buildFacultyBar(
              item.name,
              item.ratio,
              '${item.count} Sesi',
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFacultyBar(String name, double progress, String detail) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            Text(
              detail,
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                AppThemeColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutral800),
          ),
        ),
      ],
    );
  }

  Widget _buildRealSessionCard(BuildContext context, dynamic map) {
    final session = map as Map<String, dynamic>;
    final psikolog = session['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? '-';
    final topic = session['topic']?.toString() ?? '-';
    final start = session['start']?.toString() ?? '-';
    final end = session['end']?.toString() ?? '';
    final timeStr = end.isNotEmpty ? '$start - $end' : start;
    final statusStr = session['status']?.toString() ?? 'Menunggu';
    final displayDate = session['display_date']?.toString() ?? '-';

    DateTime? parsedDate;
    if (session['date'] != null) {
      try {
        parsedDate = DateTime.parse(session['date'].toString());
      } catch (_) { /* Silenced: non-critical parse fallback */ }
    }
    final indonesianDays = {
      DateTime.monday: 'Senin',
      DateTime.tuesday: 'Selasa',
      DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis',
      DateTime.friday: 'Jumat',
      DateTime.saturday: 'Sabtu',
      DateTime.sunday: 'Minggu',
    };
    final dayName =
        parsedDate != null ? indonesianDays[parsedDate.weekday] ?? '' : '';
    final fullDateStr =
        dayName.isNotEmpty ? '$dayName, $displayDate' : displayDate;

    Color statusColor;
    Color statusBg;
    Color statusBorder;
    IconData cardIcon;
    Color iconBgColor;
    Color iconColor;

    switch (statusStr.toLowerCase()) {
      case 'dikonfirmasi':
        statusColor = context.appColors.info;
        statusBg = context.appColors.infoContainer;
        statusBorder = context.appColors.info;
        cardIcon = Icons.event_available_rounded;
        iconBgColor = context.appColors.infoContainer;
        iconColor = context.appColors.primary;
        break;
      case 'selesai':
        statusColor = context.appColors.success;
        statusBg = context.appColors.successContainer;
        statusBorder = context.appColors.success;
        cardIcon = Icons.task_alt_rounded;
        iconBgColor = context.appColors.successContainer;
        iconColor = context.appColors.success;
        break;
      case 'ditolak':
      case 'dibatalkan':
        statusColor = context.appColors.error;
        statusBg = context.appColors.errorContainer;
        statusBorder = context.appColors.error;
        cardIcon = Icons.cancel_rounded;
        iconBgColor = context.appColors.errorContainer;
        iconColor = context.appColors.error;
        break;
      default: // Menunggu
        statusColor = context.appColors.warning;
        statusBg = context.appColors.warningContainer;
        statusBorder = context.appColors.warning;
        cardIcon = Icons.hourglass_top_rounded;
        iconBgColor = context.appColors.warningContainer;
        iconColor = context.appColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: statusBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showRealSessionDetail(context, session);
          },
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cardIcon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        psikologName,
                        style: const TextStyle(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: AppColors.neutral600,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  color: AppColors.neutral600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.date_range_rounded,
                                size: 13,
                                color: AppColors.neutral600,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                fullDateStr,
                                style: const TextStyle(
                                  color: AppColors.neutral600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusSm,
                      border: Border.all(color: statusBorder),
                    ),
                  child: Text(
                    statusStr,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRealSessionDetail(
    BuildContext context,
    Map<String, dynamic> session,
  ) {
    final statusStr = session['status']?.toString() ?? 'Menunggu';
    final isCompleted = statusStr.toLowerCase() == 'selesai';
    final isCancelled = statusStr.toLowerCase() == 'dibatalkan';
    final isRejected = statusStr.toLowerCase() == 'ditolak';

    final psikolog = session['psychologist'] as Map<String, dynamic>?;
    final psikologName = psikolog?['name']?.toString() ?? '-';
    final topic = session['topic']?.toString() ?? '-';
    final start = session['start']?.toString() ?? '-';
    final end = session['end']?.toString() ?? '';
    final timeStr = end.isNotEmpty ? '$start - $end' : start;
    final displayDate = session['display_date']?.toString() ?? '-';
    final mode = session['mode']?.toString() ?? 'Tatap Muka';
    final isOnline = mode.toLowerCase() == 'online';
    final linkMeeting = session['link_meeting']?.toString() ?? '';
    final hasMedicalRecord =
        session['has_medical_record'] == true ||
        (session['medical_record_count'] != null &&
            (session['medical_record_count'] as num) > 0);
    final adminNote = session['admin_note']?.toString() ?? '';

    String displayStatusText = 'Menunggu Konfirmasi';
    IconData statusIcon = Icons.pending_actions_rounded;
    Color statusColor = AppColors.warning;

    if (isCompleted) {
      displayStatusText = 'Sesi Selesai';
      statusIcon = Icons.verified_user_rounded;
      statusColor = AppColors.success;
    } else if (isCancelled) {
      displayStatusText = 'Sesi Dibatalkan';
      statusIcon = Icons.cancel_rounded;
      statusColor = AppColors.error;
    } else if (isRejected) {
      displayStatusText = 'Booking Ditolak';
      statusIcon = Icons.error_rounded;
      statusColor = AppColors.error;
    } else if (statusStr.toLowerCase() == 'dikonfirmasi') {
      displayStatusText = 'Sesi Dikonfirmasi';
      statusIcon = Icons.check_circle_rounded;
      statusColor = AppColors.success;
    }

    String locationVal = 'Ruang Konseling BKU';
    if (isOnline) {
      if (linkMeeting.isNotEmpty) {
        locationVal = 'Online (Klik tombol gabung di bawah)';
      } else {
        locationVal = 'Online (Link meeting akan diupdate oleh psikolog)';
      }
    } else {
      locationVal = psikolog?['location']?.toString() ?? 'Ruang Konseling BKU';
      if (locationVal.trim().isEmpty) {
        locationVal = 'Ruang Konseling BKU';
      }
    }

    DateTime? parsedDate;
    if (session['date'] != null) {
      try {
        parsedDate = DateTime.parse(session['date'].toString());
      } catch (_) { /* Silenced: non-critical parse fallback */ }
    }
    final indonesianDays = {
      DateTime.monday: 'Senin',
      DateTime.tuesday: 'Selasa',
      DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis',
      DateTime.friday: 'Jumat',
      DateTime.saturday: 'Sabtu',
      DateTime.sunday: 'Minggu',
    };
    final dayName =
        parsedDate != null ? indonesianDays[parsedDate.weekday] ?? '' : '';
    final fullDateStr =
        dayName.isNotEmpty ? '$dayName, $displayDate' : displayDate;

    final medRecords =
        context.read<StudentCounselingProvider>().myMedicalRecord['records']
            as List?;
    Map<String, dynamic>? matchingNote;
    if (medRecords != null) {
      for (final r in medRecords) {
        if (r is Map<String, dynamic> &&
            r['booking_id']?.toString() == session['id']?.toString()) {
          matchingNote = r;
          break;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        AppThemeColors.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withAlpha(30),
                                blurRadius: 25,
                              ),
                            ],
                            border: Border.all(
                              color: statusColor.withAlpha(20),
                            ),
                          ),
                          child: Icon(statusIcon, size: 56, color: statusColor),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          displayStatusText,
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildDetailSection(
                        'Topik Konseling',
                        topic,
                        Icons.topic_rounded,
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _buildDetailSection(
                        'Psikolog',
                        psikologName,
                        Icons.person_rounded,
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _buildDetailSection(
                        'Waktu Konseling',
                        '$fullDateStr • $timeStr',
                        Icons.access_time_rounded,
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _buildDetailSection(
                        'Mode Konseling',
                        mode,
                        Icons.devices_rounded,
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _buildDetailSection(
                        'Tempat / Lokasi',
                        locationVal,
                        Icons.location_on_rounded,
                      ),
                      if (isOnline && linkMeeting.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(linkMeeting);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } else {
                                if (context.mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    'Tidak dapat membuka link meeting',
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.videocam_rounded),
                            label: const Text(
                              'Gabung Sesi Online',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                      if (adminNote.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s20),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.primary.withAlpha(10),
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color: context.appColors.primary.withAlpha(30),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: context.appColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Catatan Admin / Psikolog',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: context.appColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                adminNote,
                                style: AppTextStyles.labelMd.copyWith(
                                  height: 1.6,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s20),
                      if (matchingNote != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.neutral800.withAlpha(12),
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color: AppColors.neutral800.withAlpha(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                    color: AppColors.neutral800,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Catatan Psikolog',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neutral800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (matchingNote['recommendation']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true) ...[
                                Text(
                                  'Rekomendasi:',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  matchingNote['recommendation'].toString(),
                                  style: AppTextStyles.labelMd.copyWith(
                                    height: 1.6,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              if (matchingNote['kesimpulan']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true) ...[
                                Text(
                                  'Kesimpulan:',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  matchingNote['kesimpulan'].toString(),
                                  style: AppTextStyles.labelMd.copyWith(
                                    height: 1.6,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                      ] else if (hasMedicalRecord) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.neutral800.withAlpha(12),
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color: AppColors.neutral800.withAlpha(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                    color: AppColors.neutral800,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Catatan Sesi & Hasil Pemeriksaan',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neutral800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Sesi konseling ini telah selesai dan catatan pemeriksaan psikolog telah direkam dalam Sistem Rekam Medis (Medical Record) mahasiswa. Silakan unduh dokumen laporan resmi di bawah ini.',
                                style: AppTextStyles.labelMd.copyWith(
                                  height: 1.6,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                      ],
                      if (hasMedicalRecord) ...[
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: BkuButton(
                              onPressed: () async {
                                final token = AuthService().token;
                                final bId = session['id']?.toString() ?? '';
                                final urlStr =
                                    '${ApiGate.baseUrl}/counseling/psychologist-bookings/$bId/export-pdf?token=$token';
                                final uri = Uri.parse(urlStr);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.inAppBrowserView,
                                  );
                                } else {
                                  if (context.mounted) {
                                    AppSnackbar.showError(
                                      context,
                                      'Tidak dapat membuka PDF',
                                    );
                                  }
                                }
                              },
                              icon: Icons.download_rounded,
                              text: 'Unduh Laporan Konseling (PDF)',
                              variant: BkuButtonVariant.danger,
                              height: 44,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (!isCancelled && !isRejected) ...[
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: BkuButton(
                              onPressed: () {
                                Navigator.pop(context); // Close modal
                                final psychId =
                                    (session['psychologist_id'] ??
                                            session['psikolog_id'] ??
                                            session['dosen_id'] ??
                                            session['DosenID'] ??
                                            session['PsychologistID'] ??
                                            session['ID'] ??
                                            session['id'])
                                        ?.toString() ??
                                    '';
                                final bId =
                                    (session['id'] ?? session['ID'])
                                        ?.toString() ??
                                    '';
                                if (isCompleted) {
                                  context.push(
                                    '${AppRoutes.counselingBooking}?psikolog_id=$psychId',
                                  );
                                } else {
                                  context.push(
                                    '${AppRoutes.counselingBooking}?psikolog_id=$psychId&reschedule_booking_id=$bId',
                                  );
                                }
                              },
                              icon: isCompleted
                                  ? Icons.event_repeat_rounded
                                  : Icons.edit_calendar_rounded,
                              text: isCompleted
                                  ? 'Konseling Lanjutan'
                                  : 'Jadwal Ulang Sesi',
                              variant: BkuButtonVariant.success,
                              height: 44,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                      ],
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: BkuButton(
                            onPressed: () => Navigator.pop(context),
                            text: 'Tutup Detail',
                            variant: BkuButtonVariant.outline,
                            height: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ignore: unused_element
  Widget _buildSessionCard(BuildContext context, CounselingSession session) {
    bool isCompleted = session.status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: AppThemeColors.surfaceContainerHighest,
          width: 1.5,
        ),
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
          onTap: () => _showSessionDetail(context, session),
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? AppColors.success.withAlpha(10)
                            : AppColors.neutral800.withAlpha(10),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.calendar_today_rounded,
                    color:
                        isCompleted ? AppColors.success : AppColors.neutral800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.topic,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                      Text(
                        session.psychologistName,
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.neutral800.withAlpha(150),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            session.time,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral800.withAlpha(150),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.neutral800.withAlpha(150),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              session.location ?? 'Ruang Konseling',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral800.withAlpha(150),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? AppColors.success.withAlpha(15)
                            : AppColors.warning.withAlpha(15),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    isCompleted ? 'SELESAI' : 'TERJADWAL',
                    style: AppTextStyles.labelSm.copyWith(
                      color:
                          isCompleted ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, Map<String, dynamic> ref) {
    final type = ref['type'] ?? ref['tipe'] ?? '-';
    final target = ref['target_party'] ?? ref['pihak_tujuan'] ?? '-';
    final status = ref['status'] ?? 'Menunggu';
    final reason = ref['reason'] ?? ref['alasan'] ?? '-';
    final createdAtStr = ref['display_date'] ?? ref['created_at'] ?? '';
    final statusLower = status.toString().toLowerCase();
    final isSuccess =
        statusLower == 'disetujui' ||
        statusLower == 'received' ||
        statusLower == 'sent' ||
        statusLower == 'selesai' ||
        statusLower == 'completed' ||
        statusLower == 'active';
    final isFailed =
        statusLower == 'ditolak' ||
        statusLower == 'dibatalkan' ||
        statusLower == 'failed';
    final refStatusColor =
        isSuccess
            ? AppColors.success
            : isFailed
            ? AppColors.error
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                createdAtStr,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: refStatusColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: refStatusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tujuan: $target',
            style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Tipe Rujukan: $type', style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Alasan: $reason',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.s20),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final status = ref['status'] ?? ref['status_rujukan'] ?? '';
                final lowerStatus = status.toString().toLowerCase();
                if (lowerStatus == 'menunggu approval' ||
                    lowerStatus == 'menunggu') {
                  if (context.mounted) {
                    AppSnackbar.showSuccess(
                      context,
                      'Surat rujukan masih menunggu persetujuan.',
                    );
                  }
                  return;
                }

                final rujukanId = ref['id'] ?? ref['ID'];
                final urlStrPath = ref['surat_rujukan_url'] ??
                    ref['surat_rujiukan_url'] ??
                    ref['referral_pdf_url'] ??
                    '';

                String downloadUrl = '';
                if (urlStrPath.toString().isNotEmpty &&
                    urlStrPath.toString().endsWith('.pdf')) {
                  final baseUrl = ApiGate.baseUrl.replaceAll('/api', '');
                  downloadUrl = urlStrPath.toString().startsWith('http')
                      ? urlStrPath.toString()
                      : '$baseUrl$urlStrPath';
                } else if (rujukanId != null) {
                  downloadUrl =
                      '${ApiGate.baseUrl}/mahasiswa/rujukan/$rujukanId/export-pdf';
                }

                if (downloadUrl.isEmpty) {
                  if (context.mounted) {
                    AppSnackbar.showError(context, 'URL PDF tidak tersedia');
                  }
                  return;
                }

                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                } else {
                  if (context.mounted) {
                    AppSnackbar.showError(context, 'Tidak dapat membuka PDF');
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.error,
                side: BorderSide(color: context.appColors.error),
                backgroundColor: context.appColors.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.br10,
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
              label: const Text(
                'Unduh PDF',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(BuildContext context, CounselingSession session) {
    bool isCompleted = session.status == 'Completed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        AppThemeColors.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                              BoxShadow(
                                color: (isCompleted
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withAlpha(30),
                                blurRadius: 25,
                              ),
                            ],
                            border: Border.all(
                              color: (isCompleted
                                      ? AppColors.success
                                      : AppColors.warning)
                                  .withAlpha(20),
                            ),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.verified_user_rounded
                                : Icons.pending_actions_rounded,
                            size: 56,
                            color:
                                isCompleted
                                    ? AppColors.success
                                    : AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          isCompleted ? 'Sesi Telah Selesai' : 'Sesi Terjadwal',
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildDetailSection(
                        'Topik Konseling',
                        session.topic,
                        Icons.topic_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildDetailSection(
                        'Psikolog',
                        session.psychologistName,
                        Icons.person_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailSection(
                        'Waktu Konseling',
                        '${session.date.day}/${session.date.month}/${session.date.year} • ${session.time}',
                        Icons.access_time_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailSection(
                        'Tempat / Lokasi',
                        session.location ?? 'Ruang Konseling',
                        Icons.location_on_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (isCompleted && session.notes != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.neutral800.withAlpha(12),
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color: AppColors.neutral800.withAlpha(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                    color: AppColors.neutral800,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Catatan Psikolog',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neutral800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                session.notes!,
                                style: AppTextStyles.labelMd.copyWith(
                                  height: 1.6,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final token = AuthService().token;
                              final urlStr =
                                  '${ApiGate.baseUrl}/counseling/psychologist-bookings/${session.id}/export-pdf?token=$token';
                              final uri = Uri.parse(urlStr);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } else {
                                if (context.mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    'Tidak dapat membuka PDF',
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text(
                              'Download PDF Sesi',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                      if (session.status != 'Dibatalkan') ...[
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Close modal
                              if (isCompleted) {
                                // Kalo udah selesai, kita arahin buat booking BARU (Konseling Lanjutan) dengan psikolog yang sama
                                context.push(
                                  '${AppRoutes.counselingBooking}?psikolog_id=${session.psychologistId}',
                                );
                              } else {
                                // Kalo belum selesai, kita arahin buat Reschedule booking ini
                                context.push(
                                  '${AppRoutes.counselingBooking}?psikolog_id=${session.psychologistId}&reschedule_booking_id=${session.id}',
                                );
                              }
                            },
                            icon: Icon(
                              isCompleted
                                  ? Icons.event_repeat_rounded
                                  : Icons.edit_calendar_rounded,
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Konseling Lanjutan'
                                  : 'Reschedule Jadwal',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.success,
                              foregroundColor: context.appColors.onPrimary,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neutral100,
                              foregroundColor: AppColors.neutral800,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                            child: Text(
                              'Tutup Detail',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.neutral500),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPsychologistCardFromMap(
    BuildContext context,
    Map<String, dynamic> p,
  ) {
    final name =
        p['Nama']?.toString() ??
        p['nama']?.toString() ??
        p['name']?.toString() ??
        '-';
    final spec =
        p['Spesialisasi']?.toString() ??
        p['spesialisasi']?.toString() ??
        p['specialization']?.toString() ??
        '-';
    final id =
        (p['id'] ?? p['ID'] ?? p['dosen_id'] ?? p['DosenID'])?.toString() ?? '';
    final isActive =
        p['IsAktif'] == true ||
        p['is_aktif'] == true ||
        p['is_active'] == true ||
        p['isAvailable'] == true;
    final initials =
        name.trim().isEmpty
            ? 'P'
            : name
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w[0].toUpperCase())
                .join();

    final rawPhoto = () {
      final possibleKeys = [
        'foto_url',
        'photo_url',
        'photoUrl',
        'FotoURL',
        'foto',
        'Foto',
        'avatar_url',
        'avatar',
      ];
      for (final key in possibleKeys) {
        if (p[key] != null && p[key].toString().trim().isNotEmpty) {
          return p[key].toString().trim();
        }
      }
      final user = p['user'] ?? p['User'] ?? p['Pengguna'] ?? p['pengguna'];
      if (user is Map) {
        for (final key in possibleKeys) {
          if (user[key] != null && user[key].toString().trim().isNotEmpty) {
            return user[key].toString().trim();
          }
        }
      }
      return '';
    }();
    final photoUrl = rawPhoto.isNotEmpty ? ApiGate.getImageUrl(rawPhoto) : '';

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral100,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              isActive
                  ? () => context.push(
                    '${AppRoutes.counselingBooking}?psikolog_id=$id',
                  )
                  : null,
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: () {
                            if (!isActive) {
                              return [AppColors.neutral500, AppColors.neutral400];
                            }
                            final primaryColor = AppColors.neutral800;
                            final hslPrimary = HSLColor.fromColor(primaryColor);
                            return [
                              hslPrimary
                                  .withLightness(
                                    (hslPrimary.lightness + 0.08).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  )
                                  .toColor(),
                              hslPrimary
                                  .withLightness(
                                    (hslPrimary.lightness - 0.08).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  )
                                  .toColor(),
                            ];
                          }(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child:
                            photoUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: 
                                  photoUrl,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, url, error) => Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            color: context.appColors.onPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  placeholder: (context, url) => Container(color: AppColors.neutral200),
                                )
                                : Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: context.appColors.onPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.success : AppColors.neutral500,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.appColors.surface, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  name.split(',')[0],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  spec.split('&')[0].trim(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isActive
                              ? [AppColors.success, AppColors.success]
                              : [AppColors.neutral300, AppColors.neutral400],
                    ),
                    borderRadius: AppRadius.radiusMd,
                  ),
                    child: Center(
                      child: Text(
                        isActive ? 'Booking' : 'Tidak Aktif',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRecordCard(BuildContext context, Map<String, dynamic> record) {
    final title = record['title'] ?? record['judul'] ?? 'Rekam Medis';
    final date = record['date'] ?? record['tanggal'] ?? '';
    final psychologist = record['psychologist'] ?? record['psikolog'] ?? '-';
    final status = record['status'] ?? 'Selesai';
    final summary = record['summary'] ?? record['ringkasan'] ?? '';
    final statusLower = status.toString().toLowerCase();
    final isSuccess = statusLower == 'selesai' || statusLower == 'completed';
    final statusColor = isSuccess ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date.toString(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                ),
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
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title.toString(),
            style: AppTextStyles.titleSm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Psikolog: $psychologist',
            style: AppTextStyles.bodySm.copyWith(
              color: context.appColors.onSurfaceVariant,
            ),
          ),
          if (summary.toString().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary.toString(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neutral500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: context.appColors.outline.withAlpha(50),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada riwayat konseling',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounselingBanner extends StatelessWidget {
  const _CounselingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.favorite_rounded,
              size: 100,
              color: AppColors.neutral200,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  'CARE & SUPPORT',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral900,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Kamu Tidak Sendirian.',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.neutral900,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Yuk, curhat atau konsultasi dengan psikolog profesional kampus kami.',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PsychologistListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.secondary,
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.search_rounded, size: 16),
                label: const Text(
                  'Cari Psikolog',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}