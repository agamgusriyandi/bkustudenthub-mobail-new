import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/providers/kencana_remedial_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/remedial_model.dart';
import 'package:intl/intl.dart';

class KencanaRemedialScreen extends StatefulWidget {
  const KencanaRemedialScreen({super.key});

  @override
  State<KencanaRemedialScreen> createState() => _KencanaRemedialScreenState();
}

class _KencanaRemedialScreenState extends State<KencanaRemedialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaRemedialProvider>().fetchRemedials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaRemedialProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchRemedials(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'REMEDIAL',
              subtitle: 'KENCANA',
              variant: AppBarVariant.clean,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                ),
              )
            else if (provider.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        provider.errorMessage!,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BkuButton(
                        onPressed: () => provider.fetchRemedials(),
                        text: 'Coba Lagi',
                        variant: BkuButtonVariant.primary,
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.remedials.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Tidak ada tugas remedial.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Kamu tidak memiliki tugas remedial saat ini.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.appColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  bottom: AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSummaryCard(provider.remedials),
                    const SizedBox(height: AppSpacing.xl),
                    ...provider.remedials.map(
                      (item) => _buildRemedialCard(item),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<KencanaRemedialItem> items) {
    final pending = items.where((i) => i.isPending).length;
    final submitted = items.where((i) => i.isSubmitted).length;
    final graded = items.where((i) => i.isGraded).length;

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatItem(
          'Menunggu',
          '$pending',
          Icons.pending_actions_rounded,
          AppColors.warning,
        ),
        _buildStatItem(
          'Dikumpulkan',
          '$submitted',
          Icons.upload_rounded,
          AppColors.info,
        ),
        _buildStatItem(
          'Dinilai',
          '$graded',
          Icons.grading_rounded,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 9,
              color: AppColors.neutral600,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRemedialCard(KencanaRemedialItem item) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (item.status) {
      case 'submitted':
        statusColor = AppColors.info;
        statusText = 'Dikumpulkan';
        statusIcon = Icons.upload_rounded;
        break;
      case 'graded':
        statusColor = AppColors.success;
        statusText = 'Dinilai';
        statusIcon = Icons.grading_rounded;
        break;
      case 'expired':
        statusColor = AppColors.error;
        statusText = 'Kedaluwarsa';
        statusIcon = Icons.timer_off_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'Menunggu';
        statusIcon = Icons.pending_actions_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _componentColor(item.component).withAlpha(20),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    _componentIcon(item.component),
                    color: _componentColor(item.component),
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.component,
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _componentColor(item.component),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.reason,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildInfoChip(
                  statusIcon,
                  statusText,
                  statusColor,
                ),
                if (item.deadline != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _buildInfoChip(
                    Icons.schedule_rounded,
                    'Deadline: ${_formatDate(item.deadline)}',
                    item.isDeadlinePassed ? AppColors.error : AppColors.neutral600,
                  ),
                ],
                if (item.score != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _buildInfoChip(
                    Icons.star_rounded,
                    'Nilai: ${item.score!.toStringAsFixed(0)}',
                    AppColors.success,
                  ),
                ],
              ],
            ),
            if (item.feedback != null && item.feedback!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.info.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.feedback_rounded,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.feedback!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (item.isPending && !item.isDeadlinePassed) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: BkuButton(
                  onPressed: () => _showSubmitDialog(item),
                  text: 'KUMPULKAN',
                ),
              ),
            ],
            if (item.isSubmitted) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  'Menunggu penilaian fasilitator',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog(KencanaRemedialItem item) {
    final textController = TextEditingController();
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Kumpulkan Remedial',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.component,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _componentColor(item.component),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.reason,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis jawaban atau penjelasan...',
                  hintStyle: AppTextStyles.bodySm.copyWith(
                    color: context.appColors.outlineVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  hintText: 'Link Google Drive (opsional)',
                  hintStyle: AppTextStyles.bodySm.copyWith(
                    color: context.appColors.outlineVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
          BkuButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) {
                AppSnackbar.showError(ctx, 'Jawaban tidak boleh kosong');
                return;
              }
              Navigator.pop(ctx);
              BkuLoadingDialog.show(context, message: 'Mengirim...');
              final provider = context.read<KencanaRemedialProvider>();
              final success = await provider.submitRemedial(
                remedialId: item.id,
                text: textController.text.trim(),
                linkUrl: linkController.text.trim(),
              );
              if (!mounted) return;
              BkuLoadingDialog.hide(context);
              if (success) {
                AppSnackbar.showSuccess(context, 'Remedial berhasil dikumpulkan');
              } else {
                AppSnackbar.showError(
                  context,
                  provider.errorMessage ?? 'Gagal mengirim remedial',
                );
              }
            },
            text: 'KIRIM',
          ),
        ],
      ),
    );
  }

  Color _componentColor(String component) {
    switch (component.toLowerCase()) {
      case 'cognitive':
        return AppColors.info;
      case 'psychomotor':
        return AppColors.warning;
      case 'affective':
        return context.appColors.error;
      default:
        return AppColors.neutral600;
    }
  }

  IconData _componentIcon(String component) {
    switch (component.toLowerCase()) {
      case 'cognitive':
        return Icons.psychology_rounded;
      case 'psychomotor':
        return Icons.handyman_rounded;
      case 'affective':
        return Icons.favorite_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
