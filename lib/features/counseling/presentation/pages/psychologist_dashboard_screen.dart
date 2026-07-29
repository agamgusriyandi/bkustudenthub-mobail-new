import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/availability_toggle.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/quick_stats_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/psychologist_service_grid.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/upcoming_appointments_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/widgets/dashboard/recent_activities_card.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'dart:async';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class PsychologistDashboardScreen extends StatefulWidget {
  const PsychologistDashboardScreen({super.key});

  @override
  State<PsychologistDashboardScreen> createState() =>
      _PsychologistDashboardScreenState();
}

class _PsychologistDashboardScreenState
    extends State<PsychologistDashboardScreen> {
  Timer? _notificationTimer;
  Timer? _dashboardTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PsychologistDashboardProvider>().loadDashboardData();
      if (mounted) {
        _checkAndTriggerSessionReminders();
      }
      // Load notifikasi untuk badge count
      if (mounted) {
        context.read<CounselingProvider>().loadNotifications();
        // Setup polling for notifications every 15 seconds for snappier pop-ups
        _notificationTimer = Timer.periodic(const Duration(seconds: 15), (
          timer,
        ) {
          if (mounted) {
            context.read<CounselingProvider>().loadNotifications();
          }
        });
      }
      // Load analytics untuk card tren
      if (mounted) {
        context.read<CounselingProvider>().loadAnalytics();
      }
      // Setup polling for dashboard data every 3 seconds
      if (mounted) {
        _dashboardTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
          if (mounted) {
            context.read<PsychologistDashboardProvider>().loadDashboardData(
              silent: true,
            );
            _checkAndTriggerSessionReminders();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _dashboardTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndTriggerSessionReminders() async {
    final dashboardProvider = context.read<PsychologistDashboardProvider>();
    final bookings = dashboardProvider.upcomingBookings;
    if (bookings.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool('pref_session_reminder') ?? true;
    if (!enabled) return;

    final int reminderMinutes =
        prefs.getInt('pref_session_reminder_minutes') ?? 15;
    final now = DateTime.now();

    for (final booking in bookings) {
      final String timeStr = booking['time'] ?? '';
      if (timeStr.isEmpty) continue;

      final parts = timeStr.split('-');
      if (parts.isEmpty) continue;
      final startStr = parts[0].trim();
      final startParts = startStr.split(':');
      if (startParts.length < 2) continue;

      final int? startHour = int.tryParse(startParts[0]);
      final int? startMinute = int.tryParse(startParts[1]);
      if (startHour == null || startMinute == null) continue;

      final bookingTime = DateTime(
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );
      final diffMinutes = bookingTime.difference(now).inMinutes;

      if (diffMinutes >= 0 && diffMinutes <= reminderMinutes) {
        final bookingId =
            booking['id']?.toString() ?? booking['nim']?.toString() ?? '';
        if (bookingId.isEmpty) continue;

        final List<String> shownIds =
            prefs.getStringList('pref_shown_reminder_ids') ?? [];
        if (shownIds.contains(bookingId)) continue;

        shownIds.add(bookingId);
        await prefs.setStringList('pref_shown_reminder_ids', shownIds);

        final studentName = booking['name'] ?? 'Mahasiswa';
        final message =
            'Sesi konseling dengan $studentName akan dimulai dalam $diffMinutes menit lagi! Siapkan ruang konseling online Anda.';

        if (mounted) {
          final counselingProvider = context.read<CounselingProvider>();
          counselingProvider.addLocalNotification({
            'id': 'auto_$bookingId',
            'title': 'Pengingat Sesi Konseling',
            'desc': message,
            'time': 'Baru Saja',
            'type': 'booking',
            'unread': true,
          });

          // Trigger OS-level system tray notification
          LocalNotificationService.showNotification(
            id: bookingId.hashCode,
            title: 'Pengingat Sesi Konseling',
            body: message,
          );

          showDialog(
            context: context,
            builder:
                (context) => CustomDialog(
                  title: 'Pengingat Sesi Konseling',
                  content: message,
                  cancelText: '',
                  confirmText: 'Tutup',
                  onCancel: () {},
                  onConfirm: () => Navigator.pop(context),
                ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistDashboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Layanan Utama'),
                      const SizedBox(height: AppSpacing.lg),
                      const PsychologistServiceGrid(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionHeader('Ringkasan Hari Ini'),
                      const SizedBox(height: AppSpacing.lg),
                      if (provider.isLoading)
                        const BkuShimmer(
                          width: double.infinity,
                          height: 200,
                          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
                        )
                      else
                        QuickStatsCard(
                          totalAppointments: provider.upcomingAppointments,
                          finishedToday: '${provider.completedToday}',
                          waiting: '${provider.waitingCount}',
                          newAppointments: '${provider.newToday}',
                          finishedMonth: '${provider.completedThisMonth}',
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: BkuShimmerList(itemCount: 2, itemHeight: 120),
                      )
                    else
                      UpcomingAppointmentsCard(
                        bookings: provider.upcomingBookings,
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Aktivitas Terbaru'),
                      const SizedBox(height: AppSpacing.lg),
                      if (provider.isLoading)
                        const BkuShimmerList(itemCount: 3, itemHeight: 80)
                      else
                        const RecentActivitiesCard(),
                      const SizedBox(height: AppSpacing.s120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    PsychologistDashboardProvider provider,
  ) {
    final name = provider.profile?.name ?? 'Psikolog';
    final imageUrl = provider.profile?.profileImageUrl ?? '';
    final initials =
        name.trim().isEmpty
            ? 'P'
            : name
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w[0].toUpperCase())
                .join();
    final unreadCount = context.watch<CounselingProvider>().unreadCount;

    return BkuAppBar(
      title: name,
      subtitle: 'Selamat Datang Kembali',
      info: provider.profile?.specialization ?? 'Psikolog Klinis',
      variant: AppBarVariant.psychologist,
      expandedHeight: 250,
      showProfileOnCollapse: true,
      showBackButton: false,
      showNotification: true,
      notificationCount: unreadCount,
      onNotificationTap:
          (context, variant) =>
              context.push(AppRoutes.psychologistNotifications),
      profileImage:
          imageUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: 
                ApiGate.getImageUrl(imageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorWidget: (_, url, error) => _buildInitialsAvatar(initials),
                progressIndicatorBuilder:
                    (_, url, progress) =>
                        _buildInitialsAvatar(initials),
                placeholder: (context, url) => Container(color: AppColors.neutral200),
              )
              : _buildInitialsAvatar(initials),
      bottomChild: _buildHeaderQuickChips(provider),
      child: AvailabilityToggle(
        isAvailable: provider.isAvailable,
        onToggle: (value) => provider.toggleAvailability(),
      ),
    );
  }

  Widget _buildHeaderQuickChips(PsychologistDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGlassChip(
                  icon: Icons.check_circle_rounded,
                  label: '${provider.completedToday} Selesai',
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: _buildGlassChip(
                  icon: Icons.hourglass_top_rounded,
                  label: '${provider.waitingCount} Menunggu',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildGlassChip(
                  icon: Icons.calendar_month_rounded,
                  label: '${provider.upcomingAppointments} Booking',
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: _buildGlassChip(
                  icon: Icons.notifications_active_rounded,
                  label: '${provider.newToday} Baru',
                ),
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
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(45),
        borderRadius: AppRadius.br20,
        border: Border.all(color: Colors.white.withAlpha(90), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: context.appColors.onPrimary),
          const SizedBox(width: AppSpacing.s6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: const Color(0xFF001A4D),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.titleLg.copyWith(
            color: context.appColors.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
