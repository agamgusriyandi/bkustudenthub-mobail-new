import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import "package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart";

class KencanaAttendanceScreen extends StatefulWidget {
  const KencanaAttendanceScreen({super.key});

  @override
  State<KencanaAttendanceScreen> createState() =>
      _KencanaAttendanceScreenState();
}

class _KencanaAttendanceScreenState extends State<KencanaAttendanceScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final provider = context.read<KencanaProvider>();
    final result = await provider.fetchAttendance();
    if (mounted) {
      setState(() {
        data = result;
        isLoading = false;
      });
    }
  }

  Future<void> _submitAbsence(int sessionId, String sessionTitle) async {
    final reasonController = TextEditingController();
    final isSubmitting = ValueNotifier<bool>(false);
    final selectedFile = ValueNotifier<File?>(null);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ajukan Izin',
                            style: TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral900,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.neutral600),
                            onPressed: () => Navigator.pop(ctx, false),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: BkuTheme.emeraldSoft,
                          borderRadius: BkuTheme.r8,
                          border: Border.all(color: BkuTheme.emeraldBorder),
                        ),
                        child: Text(
                          'Sesi: $sessionTitle',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      BkuTextField(
                        controller: reasonController,
                        maxLines: 3,
                        hint: 'Jelaskan alasan ketidakhadiran...',
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Dokumen Bukti *',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                          );
                          if (result != null && result.files.single.path != null) {
                            final file = File(result.files.single.path!);
                            final sizeInMb = file.lengthSync() / (1024 * 1024);
                            if (sizeInMb > 5) {
                              if (ctx.mounted) {
                                AppSnackbar.showWarning(ctx, 'Ukuran file maksimal 5MB');
                              }
                              return;
                            }
                            selectedFile.value = file;
                            setStateDialog(() {});
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedFile.value != null ? AppColors.success : AppColors.neutral300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.neutral100,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.upload_file_rounded,
                                size: 20,
                                color: selectedFile.value != null ? AppColors.success : AppColors.neutral600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFile.value != null
                                      ? selectedFile.value!.path.split('/').last
                                      : 'Pilih file dokumen (Max 5MB)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedFile.value != null ? FontWeight.w700 : FontWeight.w400,
                                    color: selectedFile.value != null
                                        ? AppColors.neutral900
                                        : AppColors.neutral600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedFile.value != null)
                                GestureDetector(
                                  onTap: () {
                                    selectedFile.value = null;
                                    setStateDialog(() {});
                                  },
                                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.neutral600),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.neutral200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: AppColors.neutral900,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isSubmitting,
                              builder: (ctx, submitting, _) {
                                  return BkuButton.success(
                                    text: 'Ajukan Izin',
                                    isLoading: submitting,
                                    onPressed: () async {
                                      if (reasonController.text.trim().isEmpty) {
                                        AppSnackbar.showWarning(
                                          ctx,
                                          'Alasan izin wajib diisi',
                                        );
                                        return;
                                      }
                                      if (selectedFile.value == null) {
                                        AppSnackbar.showWarning(
                                          ctx,
                                          'Dokumen bukti wajib diunggah',
                                        );
                                        return;
                                      }
                                      isSubmitting.value = true;
                                      final provider = context.read<KencanaProvider>();
                                      final success = await provider.submitAbsence(
                                        sessionId,
                                        reasonController.text.trim(),
                                        selectedFile.value,
                                      );
                                      if (ctx.mounted) {
                                        isSubmitting.value = false;
                                        Navigator.pop(ctx, success);
                                      }
                                    },
                                  );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
    );

    if (confirmed == true && mounted) {
      AppSnackbar.showSuccess(context, 'Permohonan izin berhasil diajukan');
      _loadData();
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'permission':
        return 'Izin';
      case 'permission_requested':
        return 'Diajukan';
      default:
        return 'Tidak Hadir';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.success;
      case 'permission':
        return AppColors.warning;
      case 'permission_requested':
        return context.appColors.primary;
      default:
        return AppColors.error;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'permission':
        return Icons.info_rounded;
      case 'permission_requested':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  bool _canSubmitAbsence(String status) {
    return status != 'present' &&
        status != 'permission' &&
        status != 'permission_requested';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'Log Presensi',
              subtitle: 'Kencana',
              variant: AppBarVariant.student,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (isLoading)
              SliverFillRemaining(
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                ),
              )
            else if (data == null || data!.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Gagal memuat presensi')),
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
                    _buildSummaryCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Rincian Presensi',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildItemsList(),
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/kencana/qr-scan'),
        backgroundColor: context.appColors.primary,
        icon: Icon(Icons.qr_code_scanner_rounded, color: context.appColors.onPrimary),
        label: Text(
          'Scan Presensi',
          style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = data?['summary'] ?? {};
    final total = summary['required_sessions'] ?? 0;
    final present = summary['attended_sessions'] ?? 0;
    final percentage = (summary['percentage'] ?? 0.0).toDouble();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sesi',
                total.toString(),
                Icons.event_note_rounded,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Hadir',
                present.toString(),
                Icons.check_circle_rounded,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Persentase',
                '${percentage.toStringAsFixed(0)}%',
                Icons.percent_rounded,
                context.appColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: context.appColors.outlineVariant.withAlpha(55),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Progress Kehadiran',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.radiusXs,
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : percentage / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.neutral200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      height: 100,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.appColors.outlineVariant.withAlpha(55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w900,
              color: context.appColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              color: context.appColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final details = data?['details'] as List<dynamic>? ?? [];
    if (details.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Text(
          'Belum ada sesi presensi',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: context.appColors.outline,
          ),
        ),
      );
    }

    return Column(
      children:
          details.map((item) {
            final sessionId = item['session_id'] ?? 0;
            final title = item['title'] ?? '';
            final status = item['status'] ?? 'absent';
            final checkedAtStr = item['checked_at'];

            final label = _statusLabel(status);
            final color = _statusColor(status);
            final icon = _statusIcon(status);
            final canSubmit = _canSubmitAbsence(status);

            String timeStr = '-';
            if (checkedAtStr != null) {
              try {
                timeStr = DateFormat(
                  'HH:mm, dd MMM',
                ).format(DateTime.parse(checkedAtStr));
              } catch (e) {
                // ignore
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(50),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          status == 'present' ? 'Hadir: $timeStr' : label,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                        if (canSubmit)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () => _submitAbsence(sessionId, title),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: BkuTheme.emeraldSoft,
                                  borderRadius: BkuTheme.r8,
                                  border: Border.all(
                                    color: BkuTheme.emeraldBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.edit_note_rounded,
                                      size: 15,
                                      color: AppColors.neutral900,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Ajukan Izin',
                                      style: TextStyle(
                                        color: AppColors.neutral900,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.labelSm.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
