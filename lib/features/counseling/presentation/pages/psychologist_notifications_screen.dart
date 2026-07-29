import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';

class PsychologistNotificationsScreen extends StatefulWidget {
  const PsychologistNotificationsScreen({super.key});

  @override
  State<PsychologistNotificationsScreen> createState() =>
      _PsychologistNotificationsScreenState();
}

class _PsychologistNotificationsScreenState
    extends State<PsychologistNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications;
        final unread = notifications.where((n) => n['unread'] == true).length;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Notifikasi',
                info:
                    unread > 0 ? '$unread belum dibaca' : 'Semua sudah dibaca',
                variant: AppBarVariant.psychologist,
                showBackButton: true,
                showNotification: false,
                isExpandable: false,
                actions: [
                  if (unread > 0)
                    IconButton(
                      icon: Icon(
                        Icons.done_all_rounded,
                        color: context.appColors.onPrimary,
                      ),
                      tooltip: 'Tandai semua dibaca',
                      onPressed: () => provider.markAllNotificationsRead(),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child:
                    provider.notificationsLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                        )
                        : notifications.isEmpty
                        ? _buildEmpty()
                        : _buildList(notifications, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada notifikasi',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<Map<String, dynamic>> notifications,
    CounselingProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children:
            notifications.map((notif) {
              return _buildNotifCard(notif, provider);
            }).toList(),
      ),
    );
  }

  Widget _buildNotifCard(
    Map<String, dynamic> notif,
    CounselingProvider provider,
  ) {
    final id = notif['id']?.toString() ?? '';
    final title = notif['title']?.toString() ?? '-';
    final desc = notif['desc']?.toString() ?? '';
    final time = notif['time']?.toString() ?? '-';
    final type = notif['type']?.toString() ?? 'info';
    final isUnread = notif['unread'] == true;

    // Icon dan warna berdasarkan tipe
    IconData icon;
    Color color;
    switch (type) {
      case 'booking':
        icon = Icons.event_available_rounded;
        color = AppColors.primary;
        break;
      case 'assessment':
        icon = Icons.quiz_rounded;
        color = Colors.purple;
        break;
      case 'report':
        icon = Icons.picture_as_pdf_rounded;
        color = AppColors.error;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        break;
      case 'referral':
        icon = Icons.assignment_turned_in_rounded;
        color = AppColors.info;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = Colors.teal;
    }

    String displayTitle = title;
    if (displayTitle.toLowerCase().contains('booking confirmed')) {
      displayTitle = 'Sesi Dikonfirmasi';
    } else if (displayTitle.toLowerCase().contains('booking cancelled')) {
      displayTitle = 'Sesi Dibatalkan';
    } else if (displayTitle.toLowerCase().contains('booking rescheduled')) {
      displayTitle = 'Sesi Dijadwalkan Ulang';
    } else if (displayTitle.toLowerCase().contains('new assessment')) {
      displayTitle = 'Asesmen Baru';
    } else if (displayTitle.toLowerCase().contains('new referral')) {
      displayTitle = 'Rujukan Baru Masuk';
    } else if (displayTitle.toLowerCase().contains('report generated')) {
      displayTitle = 'Laporan Tersedia';
    } else if (displayTitle.toLowerCase().contains('reminder')) {
      displayTitle = 'Pengingat Jadwal';
    } else if (displayTitle.toLowerCase().contains('warning')) {
      displayTitle = 'Peringatan Sistem';
    }

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: AppRadius.radiusLg,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) {
        provider.deleteNotification(id);
      },
      child: InkWell(
        onTap: () {
          if (isUnread) {
            provider.markNotificationRead(id);
          }

          final nav = context.read<NavigationProvider>();

          switch (type) {
            case 'booking':
              nav.setIndex(1); // Bookings tab
              context.go(AppRoutes.psychologistMain);
              break;
            case 'assessment':
              nav.setIndex(2); // Patient tab
              context.go(AppRoutes.psychologistMain);
              break;
            case 'report':
              context.push(AppRoutes.psychologistAnalytics);
              break;
            case 'warning':
              nav.setIndex(1); // Bookings tab
              context.go(AppRoutes.psychologistMain);
              break;
            case 'referral':
              context.push(AppRoutes.referralManagement);
              break;
            default:
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isUnread ? color.withAlpha(12) : context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: isUnread ? color.withAlpha(60) : Colors.grey.withAlpha(20),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isUnread ? 6 : 3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isUnread ? color : color.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isUnread ? context.appColors.onPrimary : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w800 : FontWeight.w600,
                              color: isUnread ? color : AppColors.neutral800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      desc,
                      style: AppTextStyles.bodySm.copyWith(
                        color:
                            isUnread
                                ? const Color(0xFF334155)
                                : AppColors.neutral600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: color.withAlpha(isUnread ? 200 : 150),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          time,
                          style: AppTextStyles.bodySm.copyWith(
                            color: color.withAlpha(isUnread ? 200 : 150),
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w500,
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
      ),
    );
  }
}
