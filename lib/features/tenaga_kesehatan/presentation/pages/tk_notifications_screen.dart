import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TkNotificationsScreen extends StatefulWidget {
  const TkNotificationsScreen({super.key});

  @override
  State<TkNotificationsScreen> createState() => _TkNotificationsScreenState();
}

class _TkNotificationsScreenState extends State<TkNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _loadNotifications();
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifikasi dihapus'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifService = context.watch<NotificationService>();
    final notifications = notifService.notifications;
    final unreadCount = notifService.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Notifikasi',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        showNotification: false,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                    )
                    : notifications.isEmpty
                    ? _buildEmpty()
                    : _buildList(notifications),
          ),
        ],
      ),
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
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi aktivitas, pembaruan, dan pengingat akan muncul di sini',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationItem> notifications) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: notifications.map((notif) => _buildNotifCard(notif)).toList(),
      ),
    );
  }

  Widget _buildNotifCard(NotificationItem notif) {
    IconData icon;
    Color color;
    switch (notif.type) {
      case 'booking':
        icon = Icons.event_available_rounded;
        color = Theme.of(context).colorScheme.primary;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = Colors.teal;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: AppRadius.radiusXl,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => _deleteNotification(notif.id),
      child: GestureDetector(
        onTap: () async {
          if (!notif.isRead) {
            await _notificationService.markAsRead(notif.id);
            _loadNotifications();
          }
          if (notif.link != null && notif.link!.isNotEmpty && mounted) {
            context.push(notif.link!);
          } else if (mounted) {
            // Fallback navigation based on notification type
            final type = notif.type.toLowerCase();
            final title = notif.title.toLowerCase();

            if (type.contains('referral') || title.contains('rujukan')) {
              context.push('/counseling/referrals');
            } else if (type.contains('booking') ||
                title.contains('jadwal') ||
                title.contains('janji temu')) {
              context.go('/tenagakes?tab=2');
            } else if (type.contains('insurance') ||
                title.contains('asuransi') ||
                title.contains('klaim')) {
              context.push('/tk/insurance-claims');
            } else if (type.contains('bap') || title.contains('berita acara')) {
              context.push('/tk/bap');
            } else if (type.contains('report') ||
                title.contains('laporan') ||
                title.contains('klinis')) {
              context.push('/tk/reports');
            } else {
              context.go('/tenagakes?tab=0');
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: !notif.isRead ? color.withAlpha(8) : Colors.white,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color:
                  !notif.isRead
                      ? color.withAlpha(60)
                      : Theme.of(context).colorScheme.outline.withAlpha(25),
              width: !notif.isRead ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(!notif.isRead ? 12 : 8),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight:
                                  !notif.isRead
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                              color: AppColors.neutral800,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
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
                    if (notif.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notif.content,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notif.createdAt.day}/${notif.createdAt.month}/${notif.createdAt.year}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 10,
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
