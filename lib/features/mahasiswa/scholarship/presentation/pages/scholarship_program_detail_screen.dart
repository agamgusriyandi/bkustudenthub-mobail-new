import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_program_provider.dart';

class ScholarshipProgramDetailScreen extends StatefulWidget {
  final int programId;
  const ScholarshipProgramDetailScreen({super.key, required this.programId});

  @override
  State<ScholarshipProgramDetailScreen> createState() => _ScholarshipProgramDetailScreenState();
}

class _ScholarshipProgramDetailScreenState extends State<ScholarshipProgramDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScholarshipProgramProvider>().fetchProgram(widget.programId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScholarshipProgramProvider>();

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<ScholarshipProgramProvider>().fetchProgram(widget.programId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Detail Beasiswa',
              variant: AppBarVariant.clean,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                ),
              )
            else if (provider.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xxxl),
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: context.appColors.danger.withAlpha(80),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextButton.icon(
                          onPressed: () => provider.fetchProgram(widget.programId),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (provider.program != null)
              SliverToBoxAdapter(
                child: _ProgramContent(program: provider.program!),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
      bottomNavigationBar: provider.program != null && !provider.program!.isApplied
          ? Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.onSurface.withAlpha(8),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: BkuButton(
                  onPressed: provider.isApplying ? null : _applyScholarship,
                  isLoading: provider.isApplying,
                  text: 'Daftar Sekarang',
                  variant: BkuButtonVariant.success,
                  icon: Icons.send_rounded,
                ),
              ),
            )
          : null,
    );
  }

  void _applyScholarship() {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        title: 'Daftar Beasiswa?',
        content: 'Apakah Anda yakin ingin mengajukan beasiswa ini? Pastikan data Anda lengkap.',
        cancelText: 'Batal',
        confirmText: 'Ya, Daftar',
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<ScholarshipProgramProvider>().applyProgram(widget.programId);
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

class _ProgramContent extends StatelessWidget {
  final dynamic program;
  const _ProgramContent({required this.program});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(15),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      program.kategori,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: program.isApplied
                          ? context.appColors.success.withAlpha(15)
                          : context.appColors.warning.withAlpha(15),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          program.isApplied ? Icons.check_circle_rounded : Icons.pending_rounded,
                          size: 12,
                          color: program.isApplied ? context.appColors.success : context.appColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          program.isApplied ? 'Sudah Daftar' : 'Belum Daftar',
                          style: AppTextStyles.labelSm.copyWith(
                            color: program.isApplied ? context.appColors.success : context.appColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                program.nama,
                style: AppTextStyles.titleLg.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: context.appColors.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Oleh ${program.penyelenggara}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _InfoRow(
                icon: Icons.monetization_on_rounded,
                label: 'Nilai Bantuan',
                value: program.nilaiBantuan,
              ),
              if (program.kuota != null)
                _InfoRow(
                  icon: Icons.group_rounded,
                  label: 'Kuota',
                  value: '${program.kuota} orang',
                ),
              if (program.ipkMin != null)
                _InfoRow(
                  icon: Icons.school_rounded,
                  label: 'IPK Minimal',
                  value: program.ipkMin!,
                ),
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'Batas Waktu',
                value: program.formattedDeadline,
                valueColor: context.appColors.danger,
              ),

              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(40),
                  borderRadius: AppRadius.radiusFull,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Deskripsi',
                style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                program.deskripsi,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.appColors.onSurface.withValues(alpha: 0.85),
                  height: 1.7,
                ),
              ),

              if (program.persyaratan != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Persyaratan',
                  style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  program.persyaratan!,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.appColors.onSurface.withValues(alpha: 0.85),
                    height: 1.7,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMd.copyWith(
                color: valueColor ?? AppColors.neutral800,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
