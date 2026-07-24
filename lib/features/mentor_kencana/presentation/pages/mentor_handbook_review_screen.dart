import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorHandbookReviewScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const MentorHandbookReviewScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<MentorHandbookReviewScreen> createState() =>
      _MentorHandbookReviewScreenState();
}

class _MentorHandbookReviewScreenState
    extends State<MentorHandbookReviewScreen> {
  MenteeHandbookData? _handbookData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHandbook();
  }

  Future<void> _loadHandbook() async {
    setState(() => _isLoading = true);
    final provider = context.read<MentorKencanaProvider>();
    final data = await provider.fetchStudentHandbook(widget.studentId);
    if (mounted) {
      setState(() {
        _handbookData = data;
        _isLoading = false;
      });
    }
  }

  void _showReviewDialog(String action) {
    final feedbackController = TextEditingController(
      text: _handbookData?.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return CustomDialog(
              title:
                  action == 'approved'
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
                      widget.studentId,
                      action,
                      feedbackController.text,
                    );
                if (!mounted) return;
                if (!ctx.mounted) return;
                Navigator.pop(ctx);

                if (success) {
                  AppSnackbar.showSuccess(context, 'Review berhasil dikirim');
                  _loadHandbook();
                } else {
                  AppSnackbar.showError(context, 'Gagal mengirim review');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan Review',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Review Handbook',
            subtitle: widget.studentName,
            variant: AppBarVariant.student,
            isExpandable: false,
            showBackButton: true,
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_handbookData == null ||
              _handbookData!.status == 'not_started')
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: AppColors.warning.withAlpha(150),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mahasiswa belum mengirimkan handbook',
                      style: AppTextStyles.labelLg.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                delegate: SliverChildListDelegate([
                  _buildStatusCard(_handbookData!),
                  const SizedBox(height: 24),

                  Text(
                    'Isian Handbook:',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_handbookData!.contentJson != null)
                    ..._handbookData!.contentJson!.entries.map(
                      (e) => _buildJsonEntry(e.key, e.value),
                    )
                  else
                    const Text('Tidak ada konten terstruktur.'),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
        ],
      ),
      bottomNavigationBar:
          _handbookData != null && _handbookData!.status != 'not_started'
              ? Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
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
                    const SizedBox(width: 12),
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

  Widget _buildStatusCard(MenteeHandbookData data) {
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
        statusColor = Colors.grey;
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                if (data.feedback.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Catatan: ${data.feedback}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (data.submittedAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Disubmit: ${data.submittedAt}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return BkuCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral800,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '-',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
