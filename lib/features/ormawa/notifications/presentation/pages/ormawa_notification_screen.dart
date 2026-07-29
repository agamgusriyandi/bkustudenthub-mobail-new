import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:intl/intl.dart';

class OrmawaNotificationScreen extends StatefulWidget {
  const OrmawaNotificationScreen({super.key});

  @override
  State<OrmawaNotificationScreen> createState() =>
      _OrmawaNotificationScreenState();
}

class _OrmawaNotificationScreenState extends State<OrmawaNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                variant: AppBarVariant.ormawa,
                title: 'NOTIFIKASI PORTAL',
                subtitle: 'SISTEM INBOX',
                expandedHeight: 130.0,
                showBackButton: true,
                isExpandable: false,
                actions: [
                  if (notifications.any((n) => !n.isRead))
                    IconButton(
                      icon: const Icon(
                        Icons.done_all_rounded,
                        color: Colors.white,
                      ),
                      tooltip: 'Tandai Semua Dibaca',
                      onPressed: () async {
                        await provider.markAllAsRead();
                        if (context.mounted) {
                          AppSnackbar.showSuccess(
                            context,
                            'Semua notifikasi ditandai sebagai dibaca',
                          );
                        }
                      },
                    ),
                ],
              ),
              if (provider.isLoading && notifications.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                  ),
                )
              else if (notifications.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 72,
                          color: AppColors.neutral300,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Belum ada notifikasi masuk',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notif = notifications[index];
                      final isUnread = !notif.isRead;
                      final dateStr = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(notif.createdAt);

                      IconData notifIcon;
                      Color notifColor;
                      switch (notif.type.toLowerCase()) {
                        case 'approval':
                          notifIcon = Icons.assignment_turned_in_rounded;
                          notifColor = AppColors.success;
                          break;
                        case 'proposal':
                          notifIcon = Icons.article_rounded;
                          notifColor = AppColors.info;
                          break;
                        case 'finance':
                          notifIcon = Icons.account_balance_wallet_rounded;
                          notifColor = AppColors.warning;
                          break;
                        case 'event':
                          notifIcon = Icons.event_available_rounded;
                          notifColor = Colors.indigo;
                          break;
                        default:
                          notifIcon = Icons.notifications_active_rounded;
                          notifColor = Theme.of(context).colorScheme.primary;
                      }

                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.xl),
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) {
                          provider.removeNotification(notif.id);
                          AppSnackbar.showError(context, 'Notifikasi dihapus');
                        },
                        child: GestureDetector(
                          onTap: () {
                            if (isUnread) {
                              provider.markAsRead(notif.id);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color:
                                  isUnread
                                      ? Colors.white
                                      : AppColors.neutral100,
                              borderRadius: AppRadius.radiusXl,
                              border: Border.all(
                                color:
                                    isUnread
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(20)
                                        : AppColors.neutral300,
                                width: isUnread ? 1.5 : 1,
                              ),
                              boxShadow:
                                  isUnread
                                      ? [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(5),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: notifColor.withAlpha(10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    notifIcon,
                                    color: notifColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                    fontWeight:
                                                        isUnread
                                                            ? FontWeight.w900
                                                            : FontWeight.bold,
                                                    color: AppColors.neutral800,
                                                  ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        notif.message,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.neutral600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        dateStr,
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
                    }, childCount: notifications.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
