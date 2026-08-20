import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/availability_toggle.dart';

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
    return Consumer<TkDashboardProvider>(
      builder: (context, provider, child) {
        final name = provider.profile?.nama ?? 'Tenaga Kesehatan';
        final imageUrl = provider.profile?.fotoURL ?? '';
        final initials = provider.profile?.initials ?? 'TK';

        return Scaffold(
          backgroundColor: BkuTheme.scaffoldBg,
          body: RefreshIndicator(
            onRefresh: () => context.read<TkDashboardProvider>().loadDashboard(),
            color: BkuTheme.primary,
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
                  onNotificationTap: (context, variant) => context.push('/notifications/tk'),
                  profileImage: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: (() {
                            final url = ApiGate.getImageUrl(imageUrl);
                            final timestamp = DateTime.now().millisecondsSinceEpoch;
                            return url.contains('?') ? '$url&v=$timestamp' : '$url?v=$timestamp';
                          })(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildInitialsAvatar(initials),
                          errorWidget: (_, url, error) => _buildInitialsAvatar(initials),
                        )
                      : _buildInitialsAvatar(initials),
                  bottomChild: _buildHeaderQuickChips(provider),
                  child: _buildAvailabilityToggle(provider),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Layanan Utama',
                          style: BkuTheme.textSectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildServiceGrid(context),
                        const SizedBox(height: AppSpacing.xl),
                        _buildHeroCard(provider),
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionRow(
                          'Jadwal Mendatang',
                          _formatTodayDateLabel(),
                          onTap: () {
                            final mainState = context.findAncestorStateOfType<TkMainScreenState>();
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
                        if (provider.isLoading || provider.alerts.isNotEmpty) ...[
                          _buildSectionRow('Perlu Perhatian', null),
                          const SizedBox(height: AppSpacing.md),
                          _buildAlertList(provider),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        if (provider.isLoading ||
                            provider.chartKondisi.isNotEmpty ||
                            provider.chartFakultas.isNotEmpty ||
                            provider.chartTren.isNotEmpty) ...[
                          Text(
                            'Analitik Kesehatan',
                            style: BkuTheme.textSectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (provider.isLoading) ...[
                            const BkuShimmer(
                              width: double.infinity,
                              height: 200,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const BkuShimmer(
                              width: double.infinity,
                              height: 200,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
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

  Widget _buildHeroCard(TkDashboardProvider provider) {
    if (provider.isLoading) {
      return const BkuShimmer(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );
    }

    final today = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
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
                      today.toUpperCase(),
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.textMuted,
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking Hari Ini & Mendatang',
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${provider.bookingHariIniCount}',
                      style: BkuTheme.textMetricValue.copyWith(
                        color: BkuTheme.primary,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'sesi booking aktif',
                      style: BkuTheme.textCaption,
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r16,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: BkuTheme.indigo,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryItem(
                Icons.check_circle_outline_rounded,
                '${provider.totalDiperiksaHariIni}',
                'Selesai',
                BkuTheme.emerald,
                BkuTheme.emeraldSoft,
              ),
              _buildSummaryItem(
                Icons.pending_actions_rounded,
                '${provider.belumScreening}',
                'Menunggu',
                BkuTheme.amber,
                BkuTheme.amberSoft,
              ),
              _buildSummaryItem(
                Icons.notifications_active_rounded,
                '${provider.perluPerhatian}',
                'Perhatian',
                BkuTheme.rose,
                BkuTheme.roseSoft,
              ),
              _buildSummaryItem(
                Icons.event_available_rounded,
                '${provider.bookingHariIniCount}',
                'Booking',
                BkuTheme.cyan,
                BkuTheme.cyanSoft,
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
    Color bgColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BkuTheme.r12,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: BkuTheme.textBadge.copyWith(
              color: BkuTheme.textMuted,
              fontSize: 9.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    final services = [
      _ServiceItem(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        bg: BkuTheme.indigoSoft,
        iconColor: BkuTheme.indigo,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(1) : context.go('/tenagakes?tab=1');
        },
      ),
      _ServiceItem(
        icon: Icons.assignment_turned_in_rounded,
        label: 'Booking',
        bg: BkuTheme.emeraldSoft,
        iconColor: BkuTheme.emerald,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(2) : context.go('/tenagakes?tab=2');
        },
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        label: 'Pasien',
        bg: BkuTheme.cyanSoft,
        iconColor: BkuTheme.cyan,
        onTap: () {
          final s = context.findAncestorStateOfType<TkMainScreenState>();
          s != null ? s.setSelectedIndex(3) : context.go('/tenagakes?tab=3');
        },
      ),
      _ServiceItem(
        icon: Icons.send_rounded,
        label: 'Rujukan',
        bg: BkuTheme.amberSoft,
        iconColor: BkuTheme.amber,
        onTap: () => context.push(AppRoutes.tkReferralManagement),
      ),
      _ServiceItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
        bg: BkuTheme.indigoSoft,
        iconColor: BkuTheme.indigo,
        onTap: () => context.push('/tk/qr-scan'),
      ),
      _ServiceItem(
        icon: Icons.shield_rounded,
        label: 'Asuransi',
        bg: BkuTheme.emeraldSoft,
        iconColor: BkuTheme.emerald,
        onTap: () => context.push('/tk/insurance-claims'),
      ),
      _ServiceItem(
        icon: Icons.article_rounded,
        label: 'BAP',
        bg: BkuTheme.amberSoft,
        iconColor: BkuTheme.amber,
        onTap: () => context.push('/tk/bap'),
      ),
      _ServiceItem(
        icon: Icons.bar_chart_rounded,
        label: 'Lap. Klinis',
        bg: BkuTheme.cyanSoft,
        iconColor: BkuTheme.cyan,
        onTap: () => context.push('/tk/reports'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(4, 8);
        final itemWidth = (constraints.maxWidth - (6 * (crossAxisCount - 1))) / crossAxisCount;
        final aspectRatio = itemWidth / 96;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 6,
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
    return GestureDetector(
      onTap: s.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BkuTheme.r16,
              border: Border.all(color: s.iconColor.withAlpha(40)),
            ),
            child: Center(
              child: Icon(s.icon, color: s.iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              s.label,
              textAlign: TextAlign.center,
              style: BkuTheme.textBadge.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: BkuTheme.textPrimary,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHorizontalScroll(TkDashboardProvider provider) {
    if (provider.isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) => const BkuShimmer(
            width: 175,
            height: 180,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
    }

    if (provider.bookings.isEmpty) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: BkuTheme.r16,
          border: Border.all(color: BkuTheme.border),
          boxShadow: BkuTheme.cardShadow,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_rounded,
                size: 32,
                color: BkuTheme.textPlaceholder,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tidak ada jadwal hari ini',
                style: BkuTheme.textCaption,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.bookings.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _buildBookingCard(provider.bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final name = booking['name']?.toString() ?? '-';
    final nim = booking['nim']?.toString() ?? '-';
    final time = booking['time']?.toString() ?? '-';
    final status = booking['status']?.toString() ?? '-';
    final tipeLayanan = booking['tipe_layanan']?.toString() ?? 'Pemeriksaan Umum';
    final mahasiswaId = booking['mahasiswa_id'];

    final fotoUrl = booking['avatar_url']?.toString() ??
        booking['foto_url']?.toString() ??
        booking['foto']?.toString() ??
        booking['avatar']?.toString() ??
        booking['FotoURL']?.toString();

    final parts = name.trim().split(' ');
    final avatarText = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'
        : name.isNotEmpty
            ? name[0]
            : '?';

    final bool isConfirmed = status == 'Dikonfirmasi';

    return Container(
      width: 175,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: BkuTheme.indigoSoft,
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-')
                    ? NetworkImage(ApiGate.getImageUrl(fotoUrl))
                    : null,
                child: (fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != '-')
                    ? null
                    : Text(
                        avatarText,
                        style: const TextStyle(
                          color: BkuTheme.indigo,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
              ),
              BkuStatusBadge(
                status: isConfirmed
                    ? BkuStatus.success
                    : (status == 'Menunggu Konfirmasi' ? BkuStatus.pending : BkuStatus.info),
                customText: status == 'Menunggu Konfirmasi' ? 'Menunggu' : status,
                showIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            nim,
            style: BkuTheme.textCaption.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 11, color: BkuTheme.textHeading),
              const SizedBox(width: 4),
              Text(
                time,
                style: BkuTheme.textCardTitle.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 11, color: BkuTheme.textPlaceholder),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tipeLayanan,
                  style: BkuTheme.textCaption.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
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
            height: 28,
            fontSize: 10.5,
          ),
        ],
      ),
    );
  }

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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: BkuTheme.roseSoft,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.roseBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BkuTheme.r16,
        child: InkWell(
          onTap: () {
            if (mahasiswaId != null) {
              context.read<TkPatientProvider>().clearSelection();
              context.push('/tk/patient/$mahasiswaId');
            }
          },
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: BkuTheme.rose.withAlpha(25),
                    borderRadius: BkuTheme.r10,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: BkuTheme.rose,
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
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                      ),
                      Text(
                        'NIM: $nim',
                        style: BkuTheme.textCaption,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event,
                        style: BkuTheme.textBadge.copyWith(
                          color: BkuTheme.rose,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: BkuTheme.rose,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r8,
                ),
                child: Icon(
                  icon,
                  color: BkuTheme.indigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Text(
                title,
                style: BkuTheme.textSectionTitle.copyWith(fontSize: 14),
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
      BkuTheme.cyan,
      BkuTheme.emerald,
      BkuTheme.rose,
      BkuTheme.amber,
      BkuTheme.indigo,
      BkuTheme.violet,
    ];

    int colorIdx = 0;
    final sections = provider.chartKondisi.map((item) {
      final v = double.tryParse(item['value']?.toString() ?? '0') ?? 0.0;
      final c = colors[colorIdx % colors.length];
      colorIdx++;
      return PieChartSectionData(
        color: c,
        value: v,
        title: '${(v / total * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(provider.chartKondisi.length, (i) {
            final item = provider.chartKondisi[i];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['name']} (${item['value']})',
                  style: BkuTheme.textCaption.copyWith(fontSize: 10.5),
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
      height: 190,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount + (maxCount * 0.25),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final name = provider.chartFakultas[groupIndex]['name']?.toString() ?? '';
                return BarTooltipItem(
                  '$name\n${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
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
                    final full = provider.chartFakultas[i]['name']?.toString() ?? '';
                    final words = full.split(' ');
                    final abbr = words.map((w) => w.isNotEmpty ? w[0] : '').join();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        abbr.length > 4 ? abbr.substring(0, 4) : abbr,
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 9.5,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxCount / 4,
            getDrawingHorizontalLine: (v) => FlLine(color: BkuTheme.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(provider.chartFakultas.length, (i) {
            final val = double.tryParse(provider.chartFakultas[i]['value']?.toString() ?? '0') ?? 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: BkuTheme.indigo,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
      final v = double.tryParse(provider.chartTren[i]['value']?.toString() ?? '0') ?? 0.0;
      return FlSpot(i.toDouble(), v);
    });

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxCount / 4 > 0 ? maxCount / 4 : 1,
            getDrawingHorizontalLine: (v) => FlLine(color: BkuTheme.border, strokeWidth: 1),
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
                    final dateStr = provider.chartTren[i]['name']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dateStr,
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 9,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              color: BkuTheme.cyan,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: BkuTheme.cyan,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    BkuTheme.cyan.withAlpha(40),
                    BkuTheme.cyan.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: BkuTheme.indigo,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BkuTheme.rPill,
        border: Border.all(color: Colors.white.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: BkuTheme.textBadge.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
              style: BkuTheme.textSectionTitle,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: BkuTheme.textCaption,
              ),
          ],
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Lihat Semua',
              style: BkuTheme.textButton.copyWith(
                color: BkuTheme.primary,
                fontSize: 12,
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