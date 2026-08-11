import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_screen.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  final NotificationService _service = NotificationService();

  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];

  static const _filters = [
    'Semua',
    'achievement',
    'beasiswa',
    'konseling',
    'student_voice',
    'kencana',
    'sistem',
  ];

  static const _filterLabels = {
    'Semua': 'Semua',
    'achievement': 'Achievement',
    'beasiswa': 'Beasiswa',
    'konseling': 'Konseling',
    'student_voice': 'Student Voice',
    'kencana': 'KENCANA',
    'sistem': 'Sistem',
  };

  @override
  void initState() {
    super.initState();
    _load();
    NotificationService().addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    NotificationService().removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      final allNotifs = NotificationService().notifications;
      setState(() {
        _notifications =
            _selectedFilter == 'Semua'
                ? allNotifs
                : allNotifs
                    .where(
                      (n) =>
                          n.type.toLowerCase() == _selectedFilter.toLowerCase(),
                    )
                    .toList();
      });
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _service.getNotifications(
      tipe: _selectedFilter == 'Semua' ? null : _selectedFilter,
    );
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final ok = await _service.markAllAsRead();
    if (ok && mounted) {
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      AppSnackbar.showSuccess(context, 'Semua notifikasi ditandai dibaca');
    }
  }

  Future<void> _markOneRead(NotificationItem notif) async {
    if (!notif.isRead && notif.id.isNotEmpty && notif.id != '0') {
      final ok = await _service.markAsRead(notif.id);
      if (ok && mounted) {
        setState(() {
          final idx = _notifications.indexWhere((n) => n.id == notif.id);
          if (idx != -1) {
            _notifications[idx] = notif.copyWith(isRead: true);
          }
        });
      }
    }

    if (notif.link != null && notif.link!.isNotEmpty && mounted) {
      context.push(notif.link!);
    } else if (mounted) {
      final titleLow = notif.title.toLowerCase();
      final contentLow = notif.content.toLowerCase();

      if (titleLow.contains('psikolog') ||
          titleLow.contains('konseling') ||
          contentLow.contains('psikolog') ||
          contentLow.contains('konseling')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CounselingScreen()),
        );
      } else if (notif.type == 'referral' || titleLow.contains('rujukan')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
      } else if (notif.type == 'booking') {
        context.go('/dashboard?tab=1'); // or wherever health is
      }
    }
  }

  Future<void> _deleteOne(NotificationItem notif) async {
    final ok = await _service.deleteNotification(notif.id);
    if (ok && mounted) {
      setState(() => _notifications.removeWhere((n) => n.id == notif.id));
      AppSnackbar.showSuccess(context, 'Notifikasi dihapus');
    }
  }

  Future<void> _deleteRead() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => CustomDialog(
            title: 'Hapus notifikasi?',
            content: 'Semua notifikasi yang sudah dibaca akan dihapus.',
            isSuccess: false,
            isDestructive: true,
            cancelText: 'Batal',
            confirmText: 'Hapus',
            onCancel: () => Navigator.pop(ctx, false),
            onConfirm: () => Navigator.pop(ctx, true),
          ),
    );
    if (confirm != true) return;

    final ok = await _service.deleteReadNotifications();
    if (ok && mounted) {
      setState(
        () => _notifications = _notifications.where((n) => !n.isRead).toList(),
      );
      AppSnackbar.showSuccess(context, 'Notifikasi yang sudah dibaca dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.neutral800,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Notifikasi',
              subtitle: 'Update Terbaru',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
              showNotification: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s20,
                  AppSpacing.s20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: unread badge + aksi
                    Row(
                      children: [
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: Text(
                              '$unreadCount belum dibaca',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral800,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: _markAllRead,
                            child: Text(
                              'Tandai Semua Dibaca',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: context.appColors.outline,
                          ),

                          onSelected: (v) {
                            if (v == 'delete_read') _deleteRead();
                          },
                          itemBuilder:
                              (_) => [
                                const PopupMenuItem(
                                  value: 'delete_read',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_sweep_rounded,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text('Hapus yang Sudah Dibaca'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Filter chips
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.s20),

                    // Content
                    if (_isLoading)
                      const BkuShimmerList(itemCount: 4, itemHeight: 88)
                    else if (_notifications.isEmpty)
                      _buildEmptyState()
                    else
                      ...List.generate(
                        _notifications.length,
                        (i) => FadeInAnimation(
                          delay: 0.05 * i,
                          child: _buildNotificationCard(_notifications[i]),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.s100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _filters.map((f) {
              final isSelected = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(_filterLabels[f] ?? f),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = f);
                      _load();
                    }
                  },
                  selectedColor: AppColors.neutral100,
                  labelStyle: AppTextStyles.labelSm.copyWith(
                    color:
                        isSelected
                            ? AppColors.neutral800
                            : context.appColors.outline,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: context.appColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                    side: BorderSide(
                      color:
                          isSelected
                              ? AppColors.neutral800
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  elevation: isSelected ? 3 : 0,
                  pressElevation: 0,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif) {
    final color = _getTypeColor(notif.type);
    final icon = _getTypeIcon(notif.type);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.s20),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.watch<ThemeProvider>().colors.error.withAlpha(20),
          borderRadius: AppRadius.radiusXl,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: context.watch<ThemeProvider>().colors.error,
          size: 24,
        ),
      ),
      onDismissed: (_) => _deleteOne(notif),
      child: GestureDetector(
        onTap: () => _markOneRead(notif),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: !notif.isRead ? color.withAlpha(8) : context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color:
                  !notif.isRead
                      ? color.withAlpha(60)
                      : context.appColors.outline.withAlpha(25),
              width: !notif.isRead ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withAlpha(!notif.isRead ? 12 : 8),
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
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.appColors.onSurface,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.sm, top: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notif.content,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withAlpha(150),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatTime(notif.createdAt),
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withAlpha(150),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(15),
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Text(
                            _typeLabel(notif.type),
                            style: AppTextStyles.labelSm.copyWith(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s60),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: context.appColors.outline.withAlpha(50),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada notifikasi',
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Semua update dari kampus akan muncul di sini.',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'beasiswa':
        return AppColors.success;
      case 'kencana':
        return AppColors.info;
      case 'kesehatan':
      case 'health':
        return AppColors.error;
      case 'prestasi':
      case 'achievement':
        return context.appColors.info;
      case 'konseling':
      case 'counseling':
        return AppColors.warning;
      case 'referral':
      case 'rujukan':
        return context.appColors.info; // Indigo color for referrals
      default:
        return AppColors.neutral700;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'beasiswa':
        return Icons.school_rounded;
      case 'kencana':
        return Icons.auto_awesome_rounded;
      case 'kesehatan':
      case 'health':
        return Icons.monitor_heart_rounded;
      case 'prestasi':
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'konseling':
      case 'counseling':
        return Icons.psychology_rounded;
      case 'referral':
      case 'rujukan':
        return Icons.send_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'beasiswa':
        return 'BEASISWA';
      case 'kencana':
        return 'PKKMB';
      case 'health':
      case 'kesehatan':
        return 'KESEHATAN';
      case 'prestasi':
        return 'PRESTASI';
      case 'konseling':
        return 'KONSELING';
      case 'referral':
      case 'rujukan':
        return 'RUJUKAN';
      default:
        return type;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 2) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
