import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_date_field.dart';

class RecruitmentSettingsScreen extends StatefulWidget {
  const RecruitmentSettingsScreen({super.key});

  @override
  State<RecruitmentSettingsScreen> createState() =>
      _RecruitmentSettingsScreenState();
}

class _RecruitmentSettingsScreenState extends State<RecruitmentSettingsScreen> {
  bool _isOpenRecruitment = false;
  DateTime? _startDate;
  DateTime? _endDate;
  double _minIpk = 2.5;
  final _requirementsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentSettings();

    final settings = provider.recruitmentSettings;
    if (settings.isNotEmpty && mounted) {
      setState(() {
        _isOpenRecruitment = settings['isActive'] ?? false;
        _minIpk =
            double.tryParse(settings['minIpk']?.toString() ?? '2.5') ?? 2.5;
        _requirementsController.text = settings['requirements'] ?? '';

        if (settings['startDate'] != null) {
          _startDate = DateTime.tryParse(settings['startDate'].toString());
        }
        if (settings['endDate'] != null) {
          _endDate = DateTime.tryParse(settings['endDate'].toString());
        }
      });
    } else {
      _requirementsController.text =
          'Mahasiswa aktif\nMinimal IPK 2.50\nMengisi formulir pendaftaran';
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await context.read<OrmawaProvider>().updateRecruitmentSettings({
        'isActive': _isOpenRecruitment,
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'minIpk': _minIpk,
        'requirements': _requirementsController.text,
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengaturan berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      _isOpenRecruitment
                          ? [
                            context.appColors.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ]
                          : [AppColors.neutral100, AppColors.neutral200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusXl,
                boxShadow:
                    _isOpenRecruitment
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                        : null,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendaftaran Anggota',
                          style: AppTextStyles.titleSm.copyWith(
                            color:
                                _isOpenRecruitment
                                    ? context.appColors.onPrimary
                                    : AppColors.neutral800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _isOpenRecruitment
                              ? 'Pendaftaran saat ini sedang DIBUKA'
                              : 'Pendaftaran saat ini sedang DITUTUP',
                          style: AppTextStyles.labelMd.copyWith(
                            color:
                                _isOpenRecruitment
                                    ? context.appColors.onPrimary
                                    : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOpenRecruitment,
                    onChanged:
                        (value) => setState(() => _isOpenRecruitment = value),
                    activeThumbColor: context.appColors.onPrimary,
                    activeTrackColor: context.appColors.success,
                    inactiveThumbColor: AppColors.neutral400,
                    inactiveTrackColor: AppColors.neutral300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Periode & Syarat',
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Mulai',
                    date: _startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RecruitmentDateField(
                    label: 'Selesai',
                    date: _endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral200.withValues(alpha: 0.5),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'IPK Minimal',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.primary,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          _minIpk.toStringAsFixed(2),
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.appColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: context.appColors.primary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      thumbColor: context.appColors.primary,
                      overlayColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _minIpk,
                      min: 0,
                      max: 4,
                      divisions: 40,
                      onChanged: (value) => setState(() => _minIpk = value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral200.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.2),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Persyaratan Utama',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _requirementsController,
                    maxLines: 4,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan persyaratan pendaftaran...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral400,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral100.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,

                child:
                    _isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: context.appColors.onPrimary,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Simpan Pengaturan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: AppSpacing.s100),
          ],
        ),
      ),
    );
  }
}

