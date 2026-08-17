import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
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
      return context.appColors.success;
    }
    if (typeLower == 'aspiration' || titleLower.contains('aspirasi')) {
      return context.appColors.warning;
    }
    if (titleLower.contains('anggota')) {
      return context.appColors.info;
    }
    if (titleLower.contains('agenda') || titleLower.contains('kegiatan')) {
      return context.appColors.info;
    }
    if (titleLower.contains('lpj')) return context.appColors.info;
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
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'Notifikasi',
              subtitle: 'Informasi Terbaru',
              variant: AppBarVariant.ormawa,
              showBackButton: true,
              showNotification: false,
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
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildTabBar(),
                  const SizedBox(height: AppSpacing.md),
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
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? context.appColors.primary
                        : context.appColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected
                          ? context.appColors.primary
                          : AppColors.neutral300,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.neutral700,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
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
            size: 56,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada notifikasi',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Notifikasi akan muncul di sini',
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral400),
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
          borderRadius: AppRadius.radiusLg,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 22,
        ),
      ),
      onDismissed: (_) {
        context.read<OrmawaProvider>().removeNotification(notification.id);
        AppSnackbar.showSuccess(context, 'Notifikasi berhasil dihapus');
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetail(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.isRead ? context.appColors.surface : color.withAlpha(8),
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color:
                  notification.isRead
                      ? AppColors.neutral200
                      : color.withAlpha(40),
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: context.appColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.neutral600,
                        fontSize: 11,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.createdAt),
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.neutral400,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  context.read<OrmawaProvider>().removeNotification(notification.id);
                  AppSnackbar.showSuccess(context, 'Notifikasi berhasil dihapus');
                },
                tooltip: 'Hapus',
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
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: context.appColors.surface,
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
                const SizedBox(height: AppSpacing.lg),
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(notification.createdAt),
                            style: const TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        context.read<OrmawaProvider>().removeNotification(notification.id);
                        Navigator.pop(context);
                        AppSnackbar.showSuccess(context, 'Notifikasi berhasil dihapus');
                      },
                      tooltip: 'Hapus Notifikasi',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: BkuButton.primary(
                    onPressed: () {
                      context.pop();
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
                    text: 'Tutup & Lihat Detail',
                  ),
                ),
              ],
            ),
          ),
    );

    if (!notification.isRead) {
      context.read<OrmawaProvider>().markAsRead(notification.id);
    }
  }
}