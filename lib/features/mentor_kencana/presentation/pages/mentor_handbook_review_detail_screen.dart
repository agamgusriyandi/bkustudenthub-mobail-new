import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorHandbookReviewDetailScreen extends StatefulWidget {
  final int handbookId;

  const MentorHandbookReviewDetailScreen({
    super.key,
    required this.handbookId,
  });

  @override
  State<MentorHandbookReviewDetailScreen> createState() =>
      _MentorHandbookReviewDetailScreenState();
}

class _MentorHandbookReviewDetailScreenState
    extends State<MentorHandbookReviewDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchHandbookDetail(widget.handbookId);
      }
    });
  }

  void _showReviewDialog(String action) {
    final feedbackController = TextEditingController(
      text: context.read<MentorKencanaProvider>().handbookDetail?.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return CustomDialog(
              title: action == 'approved'
                  ? 'Setujui Handbook'
                  : 'Tolak / Perlu Perbaikan',
              content: 'Berikan catatan/feedback untuk mahasiswa (opsional).',
              confirmText: 'Kirim Review',
              cancelText: 'Batal',
              isLoading: isSubmitting,
              onCancel: () => Navigator.pop(ctx),
              onConfirm: () async {
                setState(() => isSubmitting = true);
                final success = await context
                    .read<MentorKencanaProvider>()
                    .reviewStudentHandbook(
                      widget.handbookId,
                      action,
                      feedbackController.text,
                    );
                if (!mounted) return;
                if (!ctx.mounted) return;
                Navigator.pop(ctx);

                if (success) {
                  AppSnackbar.showSuccess(context, 'Review berhasil dikirim');
                  context
                      .read<MentorKencanaProvider>()
                      .fetchHandbookDetail(widget.handbookId);
                } else {
                  AppSnackbar.showError(context, 'Gagal mengirim review');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan Review',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final handbook = provider.handbookDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Handbook',
            subtitle: handbook?.studentName ?? '',
            variant: AppBarVariant.student,
            isExpandable: false,
            showBackButton: true,
          ),
          if (provider.isLoading && handbook == null)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (handbook == null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: context.appColors.warning.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 48,
                          color: context.appColors.warning,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Handbook Tidak Ditemukan',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Data handbook tidak tersedia.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatusCard(handbook),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Isian Handbook:',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (handbook.contentJson != null)
                    ...handbook.contentJson!.entries.map(
                      (e) => _buildJsonEntry(e.key, e.value),
                    )
                  else
                    const Text('Tidak ada konten terstruktur.'),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
        ],
      ),
      bottomNavigationBar: handbook != null && handbook.status == 'submitted'
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.onSurface.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BkuButton(
                      onPressed: () => _showReviewDialog('rejected'),
                      variant: BkuButtonVariant.danger,
                      text: 'Tolak / Perbaikan',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: BkuButton(
                      onPressed: () => _showReviewDialog('approved'),
                      variant: BkuButtonVariant.success,
                      text: 'Setujui',
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildStatusCard(MentorHandbookDetail data) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (data.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = 'Disetujui';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Perlu Perbaikan';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'submitted':
        statusColor = AppColors.warning;
        statusText = 'Menunggu Review';
        statusIcon = Icons.pending_actions_rounded;
        break;
      default:
        statusColor = AppColors.neutral500;
        statusText = 'Belum Dikirim';
        statusIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                if (data.feedback.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Catatan: ${data.feedback}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.appColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (data.submittedAt.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Disubmit: ${data.submittedAt}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (data.reviewedAt.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Direview: ${data.reviewedAt}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.onSurfaceVariant,
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

  Widget _buildJsonEntry(String key, dynamic value) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.replaceAll('_', ' '),
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value?.toString() ?? '-',
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
