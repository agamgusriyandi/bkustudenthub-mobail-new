import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class CreateTkScreen extends StatefulWidget {
  const CreateTkScreen({super.key});

  @override
  State<CreateTkScreen> createState() => _CreateTkScreenState();
}

class _CreateTkScreenState extends State<CreateTkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _spesialisasiController = TextEditingController();
  final _lokasiController = TextEditingController();

  String _scopeType = 'Klinik Kampus';
  bool _isSaving = false;

  final List<String> _scopeList = [
    'Klinik Kampus',
    'Unit Kesehatan Mahasiswa',
    'Fakultas',
    'Pusat',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _spesialisasiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulated save - in production would call repository
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isSaving = false);

    if (!mounted) return;
    AppSnackbar.showSuccess(context, 'Tenaga kesehatan berhasil ditambahkan');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Tambah Tenaga Kesehatan',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Avatar placeholder
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded, size: 36, color: context.appColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Nama
            _buildField('Nama Lengkap', _namaController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: AppSpacing.lg),

            // Email
            _buildField('Email', _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: AppSpacing.lg),

            // No HP
            _buildField('No. HP', _noHpController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: AppSpacing.lg),

            // Spesialisasi
            _buildField('Spesialisasi', _spesialisasiController,
                hint: 'Contoh: Umum, Gigi, dll'),
            const SizedBox(height: AppSpacing.lg),

            // Lokasi
            _buildField('Lokasi', _lokasiController,
                hint: 'Contoh: Klinik Utama BKU'),
            const SizedBox(height: AppSpacing.lg),

            // Scope Type
            Text('Scope',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _scopeType,
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
              items: _scopeList
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _scopeType = v!),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Submit
            BkuButton(
              text: 'Simpan',
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
