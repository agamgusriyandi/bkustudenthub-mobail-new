import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_medical_records_provider.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _golonganDarahController = TextEditingController();

  String _jenisKelamin = 'Laki-laki';
  String _fakultas = 'Fakultas Teknik';
  int _semester = 1;
  bool _isSaving = false;

  final List<String> _fakultasList = [
    'Fakultas Teknik',
    'Fakultas Ekonomi',
    'Fakultas Ilmu Sosial dan Ilmu Politik',
    'Fakultas Kedokteran',
    'Fakultas Hukum',
    'Fakultas Pertanian',
    'Fakultas Keguruan dan Ilmu Pendidikan',
    'Fakultas Matematika dan Ilmu Pengetahuan Alam',
    'Fakultas Seni dan Desain',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _golonganDarahController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nama': _namaController.text.trim(),
      'nim': _nimController.text.trim(),
      'jenis_kelamin': _jenisKelamin,
      'fakultas': _fakultas,
      'semester': _semester,
      'no_hp': _noHpController.text.trim(),
      'email': _emailController.text.trim(),
      'golongan_darah': _golonganDarahController.text.trim(),
    };

    final success = await context.read<TkMedicalRecordsProvider>().createPatient(data);

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      AppSnackbar.showSuccess(context, 'Pasien berhasil ditambahkan');
      context.pop();
    } else {
      final error = context.read<TkMedicalRecordsProvider>().error;
      AppSnackbar.showError(context, error ?? 'Gagal menambahkan pasien');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Tambah Pasien',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Nama
            _buildField('Nama Lengkap', _namaController,
                hint: 'Masukkan nama lengkap',
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: AppSpacing.lg),

            // NIM
            _buildField('NIM', _nimController,
                hint: 'Masukkan NIM',
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: AppSpacing.lg),

            // Jenis Kelamin
            Text('Jenis Kelamin',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildGenderChip('Laki-laki', Icons.male_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildGenderChip('Perempuan', Icons.female_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Fakultas
            Text('Fakultas',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _fakultas,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
              ),
              items: _fakultasList
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _fakultas = v!),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Semester
            Text('Semester',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: _semester,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
              ),
              items: List.generate(14, (i) => i + 1)
                  .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                  .toList(),
              onChanged: (v) => setState(() => _semester = v!),
            ),
            const SizedBox(height: AppSpacing.lg),

            // No HP
            _buildField('No. HP', _noHpController,
                hint: 'Masukkan nomor HP',
                keyboardType: TextInputType.phone),
            const SizedBox(height: AppSpacing.lg),

            // Email
            _buildField('Email', _emailController,
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: AppSpacing.lg),

            // Golongan Darah
            _buildField('Golongan Darah', _golonganDarahController,
                hint: 'O, A, B, AB'),
            const SizedBox(height: AppSpacing.xxl),

            // Submit
            BkuButton(
              text: 'Simpan Pasien',
              variant: BkuButtonVariant.primary,
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, IconData icon) {
    final isSelected = _jenisKelamin == label;
    return GestureDetector(
      onTap: () => setState(() => _jenisKelamin = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.appColors.primary.withAlpha(20) : AppColors.neutral50,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isSelected ? context.appColors.primary : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? context.appColors.primary : AppColors.neutral500,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? context.appColors.primary : AppColors.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label...',
            hintStyle: TextStyle(color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
