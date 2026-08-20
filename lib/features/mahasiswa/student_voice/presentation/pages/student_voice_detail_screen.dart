import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_voice_provider.dart';
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
  State<StudentVoiceDetailScreen> createState() => _StudentVoiceDetailScreenState();
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
      final provider = context.read<StudentVoiceProvider>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          BkuAppBar(
            title: 'Detail Tiket',
            subtitle: _aspiration != null
                ? 'ASP-${_aspiration!.id.padLeft(5, '0')}'
                : 'MEMUAT...',
            variant: AppBarVariant.student,
            expandedHeight: 120,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: _isLoading
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
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BkuShimmer(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          SizedBox(height: AppSpacing.xl),
          BkuShimmer(
            width: double.infinity,
            height: 300,
            borderRadius: BorderRadius.all(Radius.circular(16)),
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
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: BkuTheme.textPlaceholder,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _errorMsg ?? 'Gagal memuat detail aspirasi.',
            textAlign: TextAlign.center,
            style: BkuTheme.textCaption,
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInAnimation(
            delay: 0.1,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: BkuTheme.cardSurface,
                borderRadius: BkuTheme.r16,
                border: Border.all(color: BkuTheme.border),
                boxShadow: BkuTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: BkuTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.category,
                          style: BkuTheme.textBadge.copyWith(
                            color: BkuTheme.textMuted,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(ticket.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ticket.title,
                    style: BkuTheme.textPageTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 13,
                        color: BkuTheme.textPlaceholder,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(ticket.date),
                        style: BkuTheme.textCaption.copyWith(fontSize: 10.5),
                      ),
                      if (ticket.isAnonim) ...[
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BkuTheme.indigoSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.security_rounded,
                                size: 10,
                                color: BkuTheme.indigo,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Anonim',
                                style: BkuTheme.textBadge.copyWith(
                                  fontSize: 8.5,
                                  color: BkuTheme.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1, color: BkuTheme.borderSubtle),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ticket.description,
                    style: BkuTheme.textBodyRegular.copyWith(height: 1.5),
                  ),
                  if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: () async {
                        final urlStr = ticket.imageUrl!;
                        final uri = Uri.parse(
                          urlStr.startsWith('http')
                              ? urlStr
                              : '${ApiGate.baseUrl.replaceAll('/api', '')}$urlStr',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          if (mounted) {
                            AppSnackbar.showError(context, 'Gagal membuka lampiran');
                          }
                        }
                      },
                      borderRadius: BkuTheme.r12,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: BkuTheme.indigoSoft,
                          borderRadius: BkuTheme.r12,
                          border: Border.all(color: BkuTheme.indigoBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file_rounded,
                              color: BkuTheme.indigo,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lampiran Pendukung',
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 12),
                                  ),
                                  Text(
                                    'Klik untuk mengunduh / membuka berkas',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.download_rounded,
                              color: BkuTheme.indigo,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FadeInAnimation(
            delay: 0.2,
            child: Text(
              'Perjalanan Tiket (Timeline)',
              style: BkuTheme.textSectionTitle.copyWith(
                fontSize: 14,
                color: BkuTheme.textHeading,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeInAnimation(
            delay: 0.25,
            child: _timeline.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: BkuTheme.cardSurface,
                      borderRadius: BkuTheme.r16,
                      border: Border.all(color: BkuTheme.border),
                    ),
                    child: Center(
                      child: Text('Belum ada riwayat proses', style: BkuTheme.textCaption),
                    ),
                  )
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
          const SizedBox(height: AppSpacing.s80),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = BkuTheme.statusWarningBg;
    Color text = BkuTheme.statusWarningText;
    Color border = BkuTheme.statusWarningBorder;

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = BkuTheme.statusSuccessBg;
        text = BkuTheme.statusSuccessText;
        border = BkuTheme.statusSuccessBorder;
        break;
      case 'diproses':
      case 'ditindaklanjuti':
      case 'disetujui fakultas':
        bg = BkuTheme.indigoSoft;
        text = BkuTheme.indigo;
        border = BkuTheme.indigoBorder;
        break;
      case 'dibatalkan':
      case 'ditolak fakultas':
        bg = BkuTheme.statusDangerBg;
        text = BkuTheme.statusDangerText;
        border = BkuTheme.statusDangerBorder;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BkuTheme.rPill,
        border: Border.all(color: border),
      ),
      child: Text(
        status.toUpperCase(),
        style: BkuTheme.textBadge.copyWith(
          color: text,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(TimelineEvent event, bool isFirst, bool isLast) {
    IconData iconData;
    Color iconColor;
    Color iconBg;
    Color iconBorder;
    String labelText;

    switch (event.tipeEvent) {
      case 'dikirim':
        iconData = Icons.send_rounded;
        iconColor = BkuTheme.indigo;
        iconBg = BkuTheme.indigoSoft;
        iconBorder = BkuTheme.indigoBorder;
        labelText = 'Dikirim';
        break;
      case 'diterima_fakultas':
        iconData = Icons.inbox_rounded;
        iconColor = BkuTheme.amber;
        iconBg = BkuTheme.amberSoft;
        iconBorder = BkuTheme.amberBorder;
        labelText = 'Diterima';
        break;
      case 'respons_fakultas':
        iconData = Icons.comment_rounded;
        iconColor = BkuTheme.teal;
        iconBg = BkuTheme.tealSoft;
        iconBorder = BkuTheme.tealBorder;
        labelText = 'Respons';
        break;
      case 'dibatalkan':
        iconData = Icons.cancel_rounded;
        iconColor = BkuTheme.rose;
        iconBg = BkuTheme.roseSoft;
        iconBorder = BkuTheme.roseBorder;
        labelText = 'Dibatalkan';
        break;
      case 'selesai':
        iconData = Icons.task_alt_rounded;
        iconColor = BkuTheme.emerald;
        iconBg = BkuTheme.emeraldSoft;
        iconBorder = BkuTheme.emeraldBorder;
        labelText = 'Selesai';
        break;
      default:
        iconData = Icons.circle;
        iconColor = BkuTheme.textPlaceholder;
        iconBg = BkuTheme.borderSubtle;
        iconBorder = BkuTheme.border;
        labelText = 'Sistem';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isFirst ? iconBg : BkuTheme.borderSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst ? iconBorder : BkuTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    size: 14,
                    color: isFirst ? iconColor : BkuTheme.textPlaceholder,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isFirst ? BkuTheme.primary.withValues(alpha: 0.3) : BkuTheme.borderSubtle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: BkuTheme.cardSurface,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.border),
                  boxShadow: isFirst ? BkuTheme.cardShadow : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            labelText,
                            style: BkuTheme.textBadge.copyWith(
                              fontSize: 9,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(event.createdAt),
                          style: BkuTheme.textCaption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    if (event.isiRespons.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        event.isiRespons,
                        style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Oleh ${event.level == 'sistem' ? 'Sistem' : 'Admin ${event.level[0].toUpperCase()}${event.level.substring(1)}'}',
                      style: BkuTheme.textCaption.copyWith(
                        fontSize: 9.5,
                        color: BkuTheme.textPlaceholder,
                      ),
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