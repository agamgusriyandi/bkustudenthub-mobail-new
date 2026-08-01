import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';

class TimelineEvent {
  final String id;
  final String tipeEvent;
  final DateTime createdAt;
  final String isiRespons;
  final String level;

  TimelineEvent({
    required this.id,
    required this.tipeEvent,
    required this.createdAt,
    required this.isiRespons,
    required this.level,
  });
}

class StudentVoiceDetailScreen extends StatefulWidget {
  final String aspirationId;

  const StudentVoiceDetailScreen({super.key, required this.aspirationId});

  @override
  State<StudentVoiceDetailScreen> createState() =>
      _StudentVoiceDetailScreenState();
}

class _StudentVoiceDetailScreenState extends State<StudentVoiceDetailScreen> {
  bool _isLoading = true;
  Aspiration? _aspiration;
  String? _errorMsg;
  List<TimelineEvent> _timeline = [];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final provider = context.read<StudentProvider>();
      final result = await provider.getAspirationDetail(widget.aspirationId);
      if (mounted) {
        setState(() {
          _aspiration = result;
          _timeline = _buildTimeline(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  List<TimelineEvent> _buildTimeline(Aspiration aspiration) {
    final createdAt = aspiration.date;
    final updatedAt = aspiration.updatedAt ?? createdAt;
    final status = aspiration.status.toLowerCase();
    final respon = aspiration.feedback?.trim() ?? '';
    final events = <TimelineEvent>[];

    events.add(
      TimelineEvent(
        id: 'evt-${aspiration.id}-created',
        tipeEvent: 'dikirim',
        createdAt: createdAt,
        level: 'sistem',
        isiRespons: '',
      ),
    );

    if ([
      'diproses',
      'ditindaklanjuti',
      'selesai',
      'disetujui fakultas',
      'ditolak fakultas',
    ].contains(status)) {
      events.add(
        TimelineEvent(
          id: 'evt-${aspiration.id}-accepted',
          tipeEvent: 'diterima_fakultas',
          createdAt: updatedAt,
          level: 'fakultas',
          isiRespons: '',
        ),
      );
    }

    if (status == 'dibatalkan') {
      events.add(
        TimelineEvent(
          id: 'evt-${aspiration.id}-cancelled',
          tipeEvent: 'dibatalkan',
          createdAt: updatedAt,
          level: 'sistem',
          isiRespons: respon,
        ),
      );
    } else if (status == 'selesai') {
      events.add(
        TimelineEvent(
          id: 'evt-${aspiration.id}-done',
          tipeEvent: 'selesai',
          createdAt: updatedAt,
          level: 'fakultas',
          isiRespons: respon,
        ),
      );
    } else if (respon.isNotEmpty) {
      events.add(
        TimelineEvent(
          id: 'evt-${aspiration.id}-response',
          tipeEvent: 'respons_fakultas',
          createdAt: updatedAt,
          level: 'fakultas',
          isiRespons: respon,
        ),
      );
    }

    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return AppColors.success;
      case 'diproses':
      case 'ditindaklanjuti':
      case 'disetujui fakultas':
        return AppColors.primary;
      case 'dibatalkan':
      case 'ditolak fakultas':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Tiket',
            subtitle:
                _aspiration != null
                    ? 'ASP-${_aspiration!.id.padLeft(5, '0')}'
                    : 'MEMUAT...',
            variant: AppBarVariant.student,
            expandedHeight: 120,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? _buildSkeleton()
                    : _errorMsg != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BkuShimmer(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          ),
          SizedBox(height: AppSpacing.xl),
          BkuShimmer(
            width: double.infinity,
            height: 300,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _errorMsg ?? 'Gagal memuat detail aspirasi.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.xl),
          BkuButton(
            onPressed: _fetchDetail,
            text: 'Coba Lagi',
            variant: BkuButtonVariant.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final ticket = _aspiration!;
    final statusColor = _getStatusColor(ticket.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Metadata
          FadeInAnimation(
            delay: 0.1,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    ticket.category.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title & Date
          FadeInAnimation(
            delay: 0.2,
            child: Text(
              ticket.title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FadeInAnimation(
            delay: 0.3,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormat(
                    'dd MMMM yyyy, HH:mm',
                    'id_ID',
                  ).format(ticket.date),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                if (ticket.isAnonim) ...[
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: AppRadius.radiusXs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 12,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Anonim',
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Content
          FadeInAnimation(
            delay: 0.4,
            child: Text(
              ticket.description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral800,
                height: 1.6,
              ),
            ),
          ),

          // Attachment
          if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            FadeInAnimation(
              delay: 0.5,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lampiran Pendukung',
                            style: AppTextStyles.titleSm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'File Attachment',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final urlStr = ticket.imageUrl!;
                        final uri = Uri.parse(
                          urlStr.startsWith('http')
                              ? urlStr
                              : '${ApiGate.baseUrl.replaceAll('/api', '')}$urlStr',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (mounted) {
                            AppSnackbar.showError(
                              context,
                              'Gagal membuka lampiran',
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
          FadeInAnimation(
            delay: 0.6,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.radiusSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Journey Tracker',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Timeline
          FadeInAnimation(
            delay: 0.7,
            child:
                _timeline.isEmpty
                    ? const Text('Belum ada riwayat proses.')
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _timeline.length,
                      itemBuilder: (context, index) {
                        final event = _timeline[index];
                        final isFirst = index == 0;
                        final isLast = index == _timeline.length - 1;
                        return _buildTimelineEvent(event, isFirst, isLast);
                      },
                    ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(TimelineEvent event, bool isFirst, bool isLast) {
    IconData iconData;
    Color iconColor;
    String labelText;

    switch (event.tipeEvent) {
      case 'dikirim':
        iconData = Icons.send_rounded;
        iconColor = AppColors.info;
        labelText = 'Dikirim';
        break;
      case 'diterima_fakultas':
        iconData = Icons.inbox_rounded;
        iconColor = AppColors.warning;
        labelText = 'Diterima';
        break;
      case 'respons_fakultas':
        iconData = Icons.comment_rounded;
        iconColor = AppColors.primary;
        labelText = 'Respons';
        break;
      case 'dibatalkan':
        iconData = Icons.cancel_rounded;
        iconColor = AppColors.error;
        labelText = 'Dibatalkan';
        break;
      case 'selesai':
        iconData = Icons.task_alt_rounded;
        iconColor = AppColors.success;
        labelText = 'Selesai';
        break;
      default:
        iconData = Icons.circle;
        iconColor = AppColors.neutral400;
        labelText = 'Sistem';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Icon
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isFirst ? iconColor : AppColors.neutral300,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appColors.surface, width: 3),
                    boxShadow: [
                      if (isFirst)
                        BoxShadow(
                          color: iconColor.withAlpha(50),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Icon(iconData, size: 14, color: context.appColors.onPrimary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color:
                          isFirst
                              ? AppColors.primary.withAlpha(100)
                              : AppColors.neutral300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Event Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: [
                    if (isFirst)
                      BoxShadow(
                        color: context.appColors.onSurface.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withAlpha(20),
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Text(
                            labelText.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                            'id_ID',
                          ).format(event.createdAt),
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                    if (event.isiRespons.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        event.isiRespons,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral800,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(
                          event.level == 'sistem'
                              ? Icons.business_rounded
                              : Icons.security_rounded,
                          size: 12,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Oleh ${event.level == 'sistem' ? 'Sistem' : 'Admin ${event.level[0].toUpperCase()}${event.level.substring(1)}'}',
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
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
}
