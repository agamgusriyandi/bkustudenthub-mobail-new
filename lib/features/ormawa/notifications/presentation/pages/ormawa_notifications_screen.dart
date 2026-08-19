import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notification.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaNotificationsScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaNotificationsScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaNotificationsScreen> createState() => _OrmawaNotificationsScreenState();
}

class _OrmawaNotificationsScreenState extends State<OrmawaNotificationsScreen> {
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await context.read<OrmawaProvider>().fetchNotifications();
  }

  Future<void> _markAllAsRead() async {
    await context.read<OrmawaProvider>().markAllAsRead();
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Semua notifikasi ditandai sebagai dibaca');
    }
  }

  List<OrmawaNotification> _getFilteredNotifications(List<OrmawaNotification> all) {
    final sorted = List<OrmawaNotification>.from(all)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_activeTab == 'all') return sorted;

    return sorted.where((n) {
      final t = n.type.toLowerCase();
      final title = n.title.toLowerCase();
      if (_activeTab == 'agenda') {
        return t == 'agenda' || title.contains('agenda') || title.contains('kegiatan');
      }
      if (_activeTab == 'lpj') return t == 'lpj' || title.contains('lpj');
      if (_activeTab == 'pengumuman') {
        return t == 'announcement' || t == 'pengumuman' || title.contains('pengumuman');
      }
      return false;
    }).toList();
  }

  IconData _getNotificationIcon(String type, String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('setuju') || titleLower.contains('lulus')) {
      return Icons.check_circle_rounded;
    }
    if (titleLower.contains('tolak') || titleLower.contains('gagal')) {
      return Icons.cancel_rounded;
    }
    if (titleLower.contains('proposal')) return Icons.description_rounded;
    if (titleLower.contains('kas') || titleLower.contains('uang')) return Icons.account_balance_wallet_rounded;
    if (titleLower.contains('aspirasi')) return Icons.chat_bubble_outline_rounded;
    if (titleLower.contains('agenda') || titleLower.contains('kegiatan')) return Icons.event_available_rounded;
    if (titleLower.contains('lpj')) return Icons.assignment_turned_in_rounded;
    if (titleLower.contains('pengumuman')) return Icons.campaign_rounded;

    return Icons.notifications_active_rounded;
  }

  Color _getNotificationColor(String type, String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('setuju') || titleLower.contains('lulus')) {
      return const Color(0xFF059669);
    }
    if (titleLower.contains('tolak') || titleLower.contains('gagal')) {
      return const Color(0xFFE11D48);
    }
    if (titleLower.contains('proposal')) return const Color(0xFF0284C7);
    if (titleLower.contains('kas')) return const Color(0xFF059669);
    if (titleLower.contains('aspirasi')) return const Color(0xFFD97706);
    if (titleLower.contains('agenda') || titleLower.contains('kegiatan')) return const Color(0xFF0284C7);
    if (titleLower.contains('lpj')) return const Color(0xFF0284C7);
    if (titleLower.contains('pengumuman')) return const Color(0xFFD97706);

    return OrmawaTheme.primary;
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} Menit Lalu';
    if (diff.inHours < 24) return '${diff.inHours} Jam Lalu';
    if (diff.inDays < 7) return '${diff.inDays} Hari Lalu';
    return DateFormat('dd MMM yyyy', 'id').format(date);
  }

  void _showNotificationDetail(OrmawaNotification notification) {
    context.read<OrmawaProvider>().markAsRead(notification.id);
    final color = _getNotificationColor(notification.type, notification.title);
    final icon = _getNotificationIcon(notification.type, notification.title);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: OrmawaTheme.textHeading,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: OrmawaTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 12.5,
                color: OrmawaTheme.textBody,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrmawaTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: OrmawaTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Notifikasi',
              subtitle: 'Informasi & Pembaruan Sistem',
              variant: AppBarVariant.ormawa,
              showBackButton: widget.showBackButton,
              showNotification: false,
              expandedHeight: 125.0,
              isExpandable: false,
              actions: [
                IconButton(
                  onPressed: _markAllAsRead,
                  icon: const Icon(
                    Icons.done_all_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Tandai Semua Dibaca',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Consumer<OrmawaProvider>(
                builder: (context, provider, _) {
                  final notifications = provider.notifications;
                  final totalCount = notifications.length;
                  final agendaCount = notifications.where((n) {
                    final t = n.type.toLowerCase();
                    final title = n.title.toLowerCase();
                    return t == 'agenda' || title.contains('agenda') || title.contains('kegiatan');
                  }).length;
                  final lpjCount = notifications.where((n) {
                    final t = n.type.toLowerCase();
                    final title = n.title.toLowerCase();
                    return t == 'lpj' || title.contains('lpj');
                  }).length;
                  final pengumumanCount = notifications.where((n) {
                    final t = n.type.toLowerCase();
                    final title = n.title.toLowerCase();
                    return t == 'announcement' || t == 'pengumuman' || title.contains('pengumuman');
                  }).length;

                  final filtered = _getFilteredNotifications(notifications);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrmawaFilterTabs(
                          tabs: [
                            OrmawaTabItem(key: 'all', label: 'Semua', count: totalCount),
                            OrmawaTabItem(key: 'agenda', label: 'Agenda', count: agendaCount),
                            OrmawaTabItem(key: 'lpj', label: 'LPJ', count: lpjCount),
                            OrmawaTabItem(key: 'pengumuman', label: 'Pengumuman', count: pengumumanCount),
                          ],
                          activeKey: _activeTab,
                          onTabChanged: (val) => setState(() => _activeTab = val),
                        ),
                        const SizedBox(height: 14),
                        if (provider.isLoading && notifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                            child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                          )
                        else if (filtered.isEmpty)
                          const OrmawaEmptyCard(
                            title: 'Belum Ada Notifikasi',
                            description: 'Notifikasi terbaru mengenai kegiatan, proposal, dan pengumuman akan muncul di sini.',
                            icon: Icons.notifications_none_rounded,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notification = filtered[index];
                              return _buildNotificationCard(notification);
                            },
                          ),
                        const SizedBox(height: AppSpacing.s140),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(OrmawaNotification notification) {
    final color = _getNotificationColor(notification.type, notification.title);
    final icon = _getNotificationIcon(notification.type, notification.title);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFDC2626),
          size: 22,
        ),
      ),
      onDismissed: (_) {
        context.read<OrmawaProvider>().removeNotification(notification.id);
        AppSnackbar.showSuccess(context, 'Notifikasi berhasil dihapus');
      },
      child: OrmawaCard(
        onTap: () => _showNotificationDetail(notification),
        color: notification.isRead ? Colors.white : color.withAlpha(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900,
                            fontSize: 13,
                            color: OrmawaTheme.textHeading,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
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
                  SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: OrmawaTheme.textBody,
                      fontSize: 11,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      color: OrmawaTheme.textPlaceholder,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
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
}