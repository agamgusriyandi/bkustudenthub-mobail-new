import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import "package:bkuhub_mobile/core/providers/theme_provider.dart";
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/availability_toggle.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkDashboardScreen extends StatefulWidget {
  const TkDashboardScreen({super.key});

  @override
  State<TkDashboardScreen> createState() => _TkDashboardScreenState();
}

class _TkDashboardScreenState extends State<TkDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primary;

    return Consumer<TkDashboardProvider>(
      builder: (context, provider, child) {
        final name = provider.profile?.nama ?? 'Tenaga Kesehatan';
        final imageUrl = provider.profile?.fotoURL ?? '';
        final initials = provider.profile?.initials ?? 'TK';

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: RefreshIndicator(
            onRefresh:
                () => context.read<TkDashboardProvider>().loadDashboard(),
            color: primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                BkuAppBar(
                  title: name,
                  subtitle: 'Selamat Datang Kembali',
                  info: provider.profile?.spesialisasi ?? 'Pemeriksaan Umum',
                  variant: AppBarVariant.nakes,
                  expandedHeight: 220,
                  showProfileOnCollapse: true,
                  showBackButton: false,
                  showNotification: true,
                  onNotificationTap:
                      (context, variant) => context.push('/notifications/tk'),
                  profileImage:
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: (() {
                                final url = ApiGate.getImageUrl(imageUrl);
                                final timestamp = DateTime.now().millisecondsSinceEpoch;
                                return url.contains('?') ? '$url&v=$timestamp' : '$url?v=$timestamp';
                              })(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildInitialsAvatar(initials),
                            errorWidget:
                                (_, url, error) => _buildInitialsAvatar(initials),
                            
                          )
                          : _buildInitialsAvatar(initials),
                  bottomChild: _buildHeaderQuickChips(provider),
                  child: _buildAvailabilityToggle(provider),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── LAYANAN UTAMA ──
                        const Text(
                          'Layanan Utama',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildServiceGrid(context),
                        const SizedBox(height: AppSpacing.xl),

                        // ── HERO CARD (Ringkasan Hari Ini) ──
                        _buildHeroCard(provider),
                        const SizedBox(height: AppSpacing.xl),

                        // ── JADWAL MENDATANG ──
                        _buildSectionRow(
                          'Jadwal Mendatang',
                          _formatTodayDateLabel(),
                          onTap: () {
                            final mainState =
                                context
                                    .findAncestorStateOfType<
                                      TkMainScreenState
                                    >();
                            if (mainState != null) {
                              mainState.setSelectedIndex(1);
                            } else {
                              context.go('/tenagakes?tab=1');
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildBookingHorizontalScroll(provider),
                        const SizedBox(height: AppSpacing.xl),

                        // ── MAHASISWA PERLU PERHATIAN ──
                        if (provider.isLoading ||
                            provider.alerts.isNotEmpty) ...[
                          _buildSectionRow('Perlu Perhatian', null),
                          const SizedBox(height: AppSpacing.md),
                          _buildAlertList(provider),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // ── GRAFIK ANALITIK ──
                        if (provider.isLoading ||
                            provider.chartKondisi.isNotEmpty ||
                            provider.chartFakultas.isNotEmpty ||
                            provider.chartTren.isNotEmpty) ...[
                          const Text(
                            'Analitik Kesehatan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (provider.isLoading) ...[
                            const BkuShimmer(
                              width: double.infinity,
                              height: 200,
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.radius20),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const BkuShimmer(
                              width: double.infinity,
                              height: 200,
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.radius20),
                              ),
                            ),
                          ] else ...[
                            if (provider.chartKondisi.isNotEmpty) ...[
                              _buildChartCard(
                                title: 'Sebaran Kondisi',
                                icon: Icons.pie_chart_rounded,
                                child: _buildPieChartKondisi(provider),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            if (provider.chartFakultas.isNotEmpty) ...[
                              _buildChartCard(
                                title: 'Distribusi Fakultas',
                                icon: Icons.bar_chart_rounded,
                                child: _buildBarChartFakultas(provider),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            if (provider.chartTren.isNotEmpty) ...[
                              _buildChartCard(
                                title: 'Tren Kunjungan (7 Hari)',
                                icon: Icons.show_chart_rounded,
                                child: _buildLineChartTren(provider),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        ],

                        const SizedBox(height: AppSpacing.s100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(TkDashboardProvider provider) {
    if (provider.isLoading) {
      return const BkuShimmer(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      );
    }

    final today =
        DateFormat(
          'EEEE, dd MMM yyyy',
          'id_ID',
        ).format(DateTime.now());

    final primaryColor = context.read<ThemeProvider>().primary;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Booking Hari Ini & Mendatang',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${provider.bookingHariIniCount}',
                      style: AppTextStyles.titleLg.copyWith(
                        color: context.appColors.secondary,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'sesi booking hari ini',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(20),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem(
                Icons.check_circle_outline_rounded,
                '${provider.totalDiperiksaHariIni}',
                'Selesai\nHari Ini',
                context.appColors.success,
              ),
              _buildSummaryItem(
                Icons.pending_actions_rounded,
                '${provider.belumScreening}',
                'Menunggu',
                context.appColors.warning,
              ),
              _buildSummaryItem(
                Icons.notifications_active_rounded,
                '${provider.perluPerhatian}',
                'Baru\nHari Ini',
                context.appColors.error,
              ),
              _buildSummaryItem(
                Icons.event_available_rounded,
                '${provider.bookingHariIniCount}',
                'Booking\nAktif',
                context.appColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SERVICE GRID (Squircle Style)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildServiceGrid(BuildContext context) {
    final primary = context.read<ThemeProvider>().primary;
    final services = [
      _ServiceItem(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        bg: primary.withAlpha(25),
        iconColor: primary,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(1) : context.go('/tenagakes?tab=1');
        },
      ),
      _ServiceItem(
        icon: Icons.assignment_turned_in_rounded,
        label: 'Booking',
        bg: context.appColors.success.withAlpha(15),
        iconColor: context.appColors.success,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(2) : context.go('/tenagakes?tab=2');
        },
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        label: 'Pasien',
        bg: context.appColors.info.withAlpha(15),
        iconColor: context.appColors.info,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(3) : context.go('/tenagakes?tab=3');
        },
      ),
      _ServiceItem(
        icon: Icons.send_rounded,
        label: 'Rujukan',
        bg: context.appColors.warning.withAlpha(15),
        iconColor: context.appColors.warning,
        onTap: () => context.push(AppRoutes.tkReferralManagement),
      ),
      _ServiceItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
        bg: primary.withAlpha(25),
        iconColor: primary,
        onTap: () => context.push('/tk/qr-scan'),
      ),
      _ServiceItem(
        icon: Icons.shield_rounded,
        label: 'Asuransi',
        bg: context.appColors.success.withAlpha(15),
        iconColor: context.appColors.success,
        onTap: () => context.push('/tk/insurance-claims'),
      ),
      _ServiceItem(
        icon: Icons.article_rounded,
        label: 'Bap',
        bg: context.appColors.warning.withAlpha(15),
        iconColor: context.appColors.warning,
        onTap: () => context.push('/tk/bap'),
      ),
      _ServiceItem(
        icon: Icons.bar_chart_rounded,
        label: 'Lap. Klinis',
        bg: context.appColors.info.withAlpha(15),
        iconColor: context.appColors.info,
        onTap: () => context.push('/tk/reports'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 8 : 4;
        final aspectRatio = isTablet ? 1.0 : 0.68;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, i) {
            final s = services[i];
            return _buildServiceItem(s);
          },
        );
      },
    );
  }

  Widget _buildServiceItem(_ServiceItem s) {
    return BkuCard(
      onTap: s.onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(s.icon, color: s.iconColor, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            s.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOOKING HORIZONTAL SCROLL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBookingHorizontalScroll(TkDashboardProvider provider) {
    if (provider.isLoading) {
      return SizedBox(
        height: 195,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder:
              (context, index) => const BkuShimmer(
                width: 195,
                height: 195,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
              ),
        ),
      );
    }

    if (provider.bookings.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.neutral200.withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 36,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tidak ada jadwal hari ini',
                style: TextStyle(color: AppColors.neutral400, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: AppSpacing.xs),
        itemCount: provider.bookings.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder:
            (context, index) => _buildBookingCard(provider.bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final primary = context.read<ThemeProvider>().primary;
    final name = booking['name']?.toString() ?? '-';
    final nim = booking['nim']?.toString() ?? '-';
    final time = booking['time']?.toString() ?? '-';
    final status = booking['status']?.toString() ?? '-';
    final tipeLayanan =
        booking['tipe_layanan']?.toString() ?? 'Pemeriksaan Umum';
    final mahasiswaId = booking['mahasiswa_id'];

    final fotoUrl =
        booking['avatar_url']?.toString() ??
        booking['foto_url']?.toString() ??
        booking['foto']?.toString() ??
        booking['avatar']?.toString() ??
        booking['FotoURL']?.toString();

    final parts = name.trim().split(' ');
    final avatarText =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'
            : name.isNotEmpty
            ? name[0]
            : '?';

    final bool isConfirmed = status == 'Dikonfirmasi';

    return BkuCard(
      onTap: () {
        if (mahasiswaId != null) {
          context.read<TkPatientProvider>().clearSelection();
          context.push('/tk/patient/$mahasiswaId');
        }
      },
      width: 170,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primary.withAlpha(25),
                backgroundImage:
                    (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-')
                        ? NetworkImage(ApiGate.getImageUrl(fotoUrl))
                        : null,
                child:
                    (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-')
                        ? null
                        : Text(
                          avatarText,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
              ),
              BkuStatusBadge(
                status: isConfirmed ? BkuStatus.success : (status == 'Menunggu Konfirmasi' ? BkuStatus.pending : BkuStatus.info),
                customText: status == 'Menunggu Konfirmasi' ? 'Menunggu' : status,
                showIcon: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          // Name
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.neutral800,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            nim,
            style: TextStyle(fontSize: 11, color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Time row
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutral800),
              const SizedBox(width: AppSpacing.xs),
              Text(
                time,
                style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Tipe layanan
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 12,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  tipeLayanan,
                  style: TextStyle(fontSize: 11,
                    color: AppColors.neutral600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Action button
          BkuButton(
            onPressed: () {
              if (mahasiswaId != null) {
                context.read<TkPatientProvider>().clearSelection();
                context.push('/tk/patient/$mahasiswaId');
              }
            },
            variant: isConfirmed ? BkuButtonVariant.success : BkuButtonVariant.secondary,
            text: isConfirmed ? 'Periksa' : 'Detail',
            trailingIcon: Icons.arrow_forward_rounded,
            height: 32,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ALERT LIST
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAlertList(TkDashboardProvider provider) {
    if (provider.isLoading) {
      return const BkuShimmerList(itemCount: 2, itemHeight: 80);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.alerts.length.clamp(0, 3),
      itemBuilder: (context, index) => _buildAlertItem(provider.alerts[index]),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final name = alert['nama']?.toString() ?? '-';
    final nim = alert['nim']?.toString() ?? '-';
    final event = alert['event']?.toString() ?? '-';
    final mahasiswaId = alert['mahasiswa_id'];

    return GestureDetector(
      onTap: () {
        if (mahasiswaId != null) {
          context.read<TkPatientProvider>().clearSelection();
          context.push('/tk/patient/$mahasiswaId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.error.withAlpha(15),
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: context.appColors.error.withAlpha(20)),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.error.withAlpha(20),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: context.appColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    'NIM: $nim',
                    style: TextStyle(fontSize: 11,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    event,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.error,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.error,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHARTS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return BkuCard(
      padding: AppSpacing.padding18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.read<ThemeProvider>().primary.withAlpha(25),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  icon,
                  color: context.read<ThemeProvider>().primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Text(
                title,
                style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }

  Widget _buildPieChartKondisi(TkDashboardProvider provider) {
    final total = provider.chartKondisi.fold(
      0,
      (sum, item) => sum + ((item['value'] as num?)?.toInt() ?? 0),
    );
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      context.appColors.info, // Blue
      context.appColors.success, // Emerald
      context.appColors.error, // Rose
      context.appColors.warning, // Amber
      context.appColors.info, // Purple
      context.appColors.info, // Cyan
    ];

    int colorIdx = 0;
    final sections =
        provider.chartKondisi.map((item) {
          final v = double.tryParse(item['value']?.toString() ?? '0') ?? 0.0;
          final c = colors[colorIdx % colors.length];
          colorIdx++;
          return PieChartSectionData(
            color: c,
            value: v,
            title: '${(v / total * 100).toStringAsFixed(0)}%',
            radius: 55,
            titleStyle: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w800,
              color: context.appColors.surface,
            ),
          );
        }).toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 36,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s14),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(provider.chartKondisi.length, (i) {
            final item = provider.chartKondisi[i];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  '${item['name']} (${item['value']})',
                  style: TextStyle(fontSize: 11,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBarChartFakultas(TkDashboardProvider provider) {
    double maxCount = provider.chartFakultas.fold(0.0, (m, item) {
      final v = double.tryParse(item['value']?.toString() ?? '0') ?? 0.0;
      return v > m ? v : m;
    });
    if (maxCount == 0) maxCount = 1;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount + (maxCount * 0.25),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final name =
                    provider.chartFakultas[groupIndex]['name']?.toString() ??
                    '';
                return BarTooltipItem(
                  '$name\n${rod.toY.toInt()}',
                  TextStyle(
                    color: context.appColors.surface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < provider.chartFakultas.length) {
                    final full =
                        provider.chartFakultas[i]['name']?.toString() ?? '';
                    final words = full.split(' ');
                    final abbr =
                        words
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .join()
                            ;
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        abbr.length > 4 ? abbr.substring(0, 4) : abbr,
                        style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxCount / 4,
            getDrawingHorizontalLine:
                (v) => FlLine(color: AppColors.neutral300, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(provider.chartFakultas.length, (i) {
            final val =
                double.tryParse(
                  provider.chartFakultas[i]['value']?.toString() ?? '0',
                ) ??
                0.0;
            final barGradients = [
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.info, context.appColors.info],
              ),
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.success.withAlpha(30), context.appColors.success],
              ),
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.warning.withAlpha(30), context.appColors.warning],
              ),
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.info.withAlpha(30), context.appColors.info],
              ),
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.error.withAlpha(30), context.appColors.error],
              ),
              LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [context.appColors.info.withAlpha(30), context.appColors.info],
              ),
            ];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: val,
                  gradient: barGradients[i % barGradients.length],
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.radius6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLineChartTren(TkDashboardProvider provider) {
    double maxCount = provider.chartTren.fold(0.0, (m, item) {
      final v = double.tryParse(item['value']?.toString() ?? '0') ?? 0.0;
      return v > m ? v : m;
    });
    if (maxCount == 0) maxCount = 1;

    final spots = List.generate(provider.chartTren.length, (i) {
      final v =
          double.tryParse(provider.chartTren[i]['value']?.toString() ?? '0') ??
          0.0;
      return FlSpot(i.toDouble(), v);
    });

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxCount / 4 > 0 ? maxCount / 4 : 1,
            getDrawingHorizontalLine:
                (v) => FlLine(color: AppColors.neutral300, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < provider.chartTren.length) {
                    final dateStr =
                        provider.chartTren[i]['name']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        dateStr,
                        style: TextStyle(fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (provider.chartTren.length - 1).toDouble(),
          minY: 0,
          maxY: maxCount + (maxCount * 0.2),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: LinearGradient(
                colors: [context.appColors.info, context.appColors.info],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter:
                    (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: context.appColors.surface,
                      strokeWidth: 2,
                      strokeColor: context.appColors.info,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.appColors.info.withAlpha(40),
                    context.appColors.info.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInitialsAvatar(String initials) {
    final primary = context.read<ThemeProvider>().primary;
    return Container(
      color: primary,
      child: Center(
          child: Text(
          initials,
          style: TextStyle(
            color: context.appColors.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderQuickChips(TkDashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGlassChip(
                icon: Icons.check_circle_rounded,
                label: '${provider.totalDiperiksaHariIni} Selesai',
              ),
              const SizedBox(width: AppSpacing.s10),
              _buildGlassChip(
                icon: Icons.hourglass_top_rounded,
                label: '${provider.belumScreening} Menunggu',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGlassChip(
                icon: Icons.calendar_month_rounded,
                label: '${provider.bookingHariIniCount} Booking',
              ),
              const SizedBox(width: AppSpacing.s10),
              _buildGlassChip(
                icon: Icons.notifications_active_rounded,
                label: '${provider.perluPerhatian} Perhatian',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.surface.withAlpha(35),
        borderRadius: AppRadius.br20,
        border: Border.all(color: context.appColors.surface.withAlpha(60), width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.appColors.onPrimary),
          const SizedBox(width: AppSpacing.s6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: context.appColors.onPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(TkDashboardProvider provider) {
    return AvailabilityToggle(
      isAvailable: provider.isAvailable,
      onToggle: (_) => provider.toggleAvailability(),
    );
  }

  Widget _buildSectionRow(
    String title,
    String? subtitle, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.neutral800,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
          ],
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Lihat Semua',
              style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral800,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTodayDateLabel() {
    return DateFormat('EEEE, dd MMM', 'id_ID').format(DateTime.now());
  }
}

// ─── Helper Model ───────────────────────────────────────────────────────────
class _ServiceItem {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });
}
