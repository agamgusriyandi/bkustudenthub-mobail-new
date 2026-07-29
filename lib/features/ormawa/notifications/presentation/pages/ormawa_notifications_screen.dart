import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notification.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:go_router/go_router.dart';

class OrmawaNotificationsScreen extends StatefulWidget {
  const OrmawaNotificationsScreen({super.key});

  @override
  State<OrmawaNotificationsScreen> createState() =>
      _OrmawaNotificationsScreenState();
}

class _OrmawaNotificationsScreenState extends State<OrmawaNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Semua', 'Agenda', 'LPJ', 'Pengumuman'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNotifications();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  Future<void> _loadNotifications() async {
    await context.read<OrmawaProvider>().fetchNotifications();
  }

  Future<void> _markAllAsRead() async {
    await context.read<OrmawaProvider>().markAllAsRead();
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        'Semua notifikasi ditandai sebagai dibaca',
      );
    }
  }

  List<OrmawaNotification> _getFilteredNotifications(
    List<OrmawaNotification> all,
  ) {
    final sorted = List<OrmawaNotification>.from(all)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_selectedTabIndex == 0) return sorted;

    final typeMap = {1: 'agenda', 2: 'lpj', 3: 'pengumuman'};

    final type = typeMap[_selectedTabIndex];
    if (type == null) return sorted;

    return sorted.where((n) {
      final t = n.type.toLowerCase();
      final title = n.title.toLowerCase();
      if (type == 'agenda') {
        return t == 'agenda' ||
            title.contains('agenda') ||
            title.contains('kegiatan');
      }
      if (type == 'lpj') return t == 'lpj' || title.contains('lpj');
      if (type == 'pengumuman') {
        return t == 'announcement' ||
            t == 'pengumuman' ||
            title.contains('pengumuman');
      }
      return false;
    }).toList();
  }

  IconData _getNotificationIcon(String type, String title) {
    final typeLower = type.toLowerCase();
    final titleLower = title.toLowerCase();

    if (titleLower.contains('setuju') || titleLower.contains('lulus')) {
      return Icons.check_circle_rounded;
    }
    if (titleLower.contains('tolak') || titleLower.contains('gagal')) {
      return Icons.cancel_rounded;
    }
    if (typeLower == 'proposal' || titleLower.contains('proposal')) {
      return Icons.description_rounded;
    }
    if (typeLower == 'finance' ||
        titleLower.contains('kas') ||
        titleLower.contains('uang')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (typeLower == 'aspiration' || titleLower.contains('aspirasi')) {
      return Icons.forum_rounded;
    }
    if (titleLower.contains('anggota') || titleLower.contains('daftar')) {
      return Icons.person_add_rounded;
    }
    if (titleLower.contains('agenda') || titleLower.contains('kegiatan')) {
      return Icons.event_available_rounded;
    }
    if (titleLower.contains('lpj')) return Icons.assignment_turned_in_rounded;
    if (titleLower.contains('pengumuman')) return Icons.campaign_rounded;

    return Icons.notifications_active_rounded;
  }

  Color _getNotificationColor(String type, String title) {
    final typeLower = type.toLowerCase();
    final titleLower = title.toLowerCase();

    if (titleLower.contains('setuju') || titleLower.contains('lulus')) {
      return AppColors.success;
    }
    if (titleLower.contains('tolak') || titleLower.contains('gagal')) {
      return AppColors.error;
    }
    if (typeLower == 'proposal' || titleLower.contains('proposal')) {
      return AppColors.info;
    }
    if (typeLower == 'finance' || titleLower.contains('kas')) {
      return const Color(0xFF14B8A6);
    }
    if (typeLower == 'aspiration' || titleLower.contains('aspirasi')) {
      return const Color(0xFFF97316);
    }
    if (titleLower.contains('anggota')) {
      return const Color(0xFF2563EB);
    }
    if (titleLower.contains('agenda') || titleLower.contains('kegiatan')) {
      return const Color(0xFF06B6D4);
    }
    if (titleLower.contains('lpj')) return const Color(0xFF6366F1);
    if (titleLower.contains('pengumuman')) {
      return AppColors.warning;
    }

    return AppColors.primary;
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'NOTIFIKASI',
              subtitle: 'INFORMASI TERBARU',
              variant: AppBarVariant.ormawa,
              expandedHeight: 140.0,
              showBackButton: true,
              showNotification: false,
              isExpandable: false,
              actions: [
                TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Baca Semua',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  _buildTabBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildNotificationList(),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.neutral300,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Text(
                _tabs[index],
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.neutral600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: BkuShimmerList(itemCount: 5, itemHeight: 80),
          );
        }

        final filteredNotifications = _getFilteredNotifications(
          provider.notifications,
        );

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredNotifications.length,
          itemBuilder: (context, index) {
            final notification = filteredNotifications[index];
            return _buildNotificationCard(notification);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada notifikasi',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Notifikasi akan muncul di sini',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral400),
          ),
        ],
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
        padding: const EdgeInsets.only(right: AppSpacing.s20),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: AppRadius.radiusXl,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 24,
        ),
      ),
      onDismissed:
          (_) => context.read<OrmawaProvider>().removeNotification(
            notification.id,
          ),
      child: GestureDetector(
        onTap: () => _showNotificationDetail(notification),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : color.withAlpha(6),
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color:
                  notification.isRead
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : color.withAlpha(30),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow:
                notification.isRead
                    ? []
                    : [
                      BoxShadow(
                        color: color.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                            notification.title,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.message,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  void _showNotificationDetail(OrmawaNotification notification) {
    final color = _getNotificationColor(notification.type, notification.title);
    final icon = _getNotificationIcon(notification.type, notification.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
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
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.7), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.radiusLg,
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatTime(notification.createdAt),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      notification.message,
                      style: AppTextStyles.bodyMd.copyWith(height: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final t = notification.type.toLowerCase();
                      if (t.contains('proposal')) {
                        context.push(AppRoutes.ormawaProposal);
                      } else if (t.contains('recruitment') ||
                          t.contains('rekrutmen') ||
                          t.contains('anggota')) {
                        context.push(AppRoutes.ormawaRecruitment);
                      } else if (t.contains('aspirasi')) {
                        context.push(AppRoutes.ormawaAspirasi);
                      } else if (t.contains('pengumuman')) {
                        context.push(AppRoutes.ormawaPengumuman);
                      }
                    },

                    child: const Text(
                      'Tutup & Lihat Detail',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    // Mark as read
    if (!notification.isRead) {
      context.read<OrmawaProvider>().markAsRead(notification.id);
    }
  }
}