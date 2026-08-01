import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:flutter/material.dart';

class MentorNotificationsScreen extends StatefulWidget {
  const MentorNotificationsScreen({super.key});

  @override
  State<MentorNotificationsScreen> createState() =>
      _MentorNotificationsScreenState();
}

class _MentorNotificationsScreenState extends State<MentorNotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final response = await api.client.get('/api/kencana-mentor/notifications');
      final data = response.data;
      if (data is List) {
        _notifications = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['data'] is List) {
        _notifications = List<Map<String, dynamic>>.from(data['data']);
      } else {
        _notifications = [];
      }
    } catch (_) {
      _notifications = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Notifikasi Mentor',
        variant: AppBarVariant.student,
        showBackButton: true,
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: BkuShimmerList(itemCount: 5, itemHeight: 80),
              )
            : _notifications.isEmpty
                ? _buildEmpty()
                : _buildList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 72, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada notifikasi',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Notifikasi aktivitas mentor akan muncul di sini',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: _notifications.length,
      itemBuilder: (context, index) => _buildNotifCard(_notifications[index]),
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> notif) {
    final isRead = notif['is_read'] == true || notif['read'] == true;
    final title = notif['title'] ?? 'Notifikasi';
    final body = notif['body'] ?? notif['message'] ?? '';
    final createdAt = notif['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: !isRead ? context.appColors.primary.withAlpha(8) : context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: !isRead
              ? context.appColors.primary.withAlpha(60)
              : AppColors.neutral200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 12,
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
              color: context.appColors.primary.withAlpha(15),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Icon(Icons.notifications_rounded, color: context.appColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: !isRead ? FontWeight.w900 : FontWeight.w600,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.appColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral600,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    createdAt,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
