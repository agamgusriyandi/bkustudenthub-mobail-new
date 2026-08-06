import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class CreateMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  const CreateMedicalRecordScreen({super.key, required this.patientId});

  @override
  State<CreateMedicalRecordScreen> createState() =>
      _CreateMedicalRecordScreenState();
}

class _CreateMedicalRecordScreenState extends State<CreateMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jenisCtrl = TextEditingController(text: 'Konseling');
  final _keluhanCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _tindakanCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _keluhanCtrl.dispose();
    _diagnosisCtrl.dispose();
    _catatanCtrl.dispose();
    _tindakanCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'patient_id': widget.patientId,
      'jenis': _jenisCtrl.text.trim(),
      'keluhan': _keluhanCtrl.text.trim(),
      'diagnosis': _diagnosisCtrl.text.trim(),
      'catatan': _catatanCtrl.text.trim(),
      'tindakan': _tindakanCtrl.text.trim(),
    };

    final success = await context
        .read<AdminPsychologistProvider>()
        .createMedicalRecord(data);
    if (!mounted) return;

    setState(() => _isSaving = false);

    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: success ? 'Berhasil' : 'Gagal',
        content: success
            ? 'Rekam medis berhasil dibuat.'
            : 'Gagal membuat rekam medis.',
        cancelText: '',
        confirmText: 'Tutup',
        isSuccess: success,
        onCancel: () {},
        onConfirm: () {
          context.pop();
          if (success) context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Buat Rekam Medis',
            variant: AppBarVariant.psychologist,
            isExpandable: false,
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.s120,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Sesi'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      controller: _jenisCtrl,
                      label: 'Jenis Sesi',
                      icon: Icons.category_rounded,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      controller: _keluhanCtrl,
                      label: 'Keluhan Utama',
                      icon: Icons.sick_rounded,
                      maxLines: 2,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('Diagnosis & Tindakan'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      controller: _diagnosisCtrl,
                      label: 'Diagnosis',
                      icon: Icons.medical_services_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      controller: _tindakanCtrl,
                      label: 'Tindakan',
                      icon: Icons.healing_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('Catatan Tambahan'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      controller: _catatanCtrl,
                      label: 'Catatan',
                      icon: Icons.note_alt_rounded,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: context.appColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.br14,
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: context.appColors.onPrimary,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Simpan Rekam Medis',
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: context.appColors.onPrimary,
                                ),
                              ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.neutral900,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
        prefixIcon: Icon(icon, size: 20, color: AppColors.neutral500),
        filled: true,
        fillColor: context.appColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(
            color: context.appColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.error.withAlpha(100)),
        ),
      ),
    );
  }
}
