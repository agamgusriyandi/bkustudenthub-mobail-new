import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:go_router/go_router.dart';

class EditOrganisasiScreen extends StatefulWidget {
  final OrmawaOrganisasi organisasi;
  const EditOrganisasiScreen({super.key, required this.organisasi});

  @override
  State<EditOrganisasiScreen> createState() => _EditOrganisasiScreenState();
}

class _EditOrganisasiScreenState extends State<EditOrganisasiScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _visiController;
  late final TextEditingController _misiController;
  late final TextEditingController _alamatController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _instagramController;
  late final TextEditingController _tahunBerdiriController;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final o = widget.organisasi;
    _namaController = TextEditingController(text: o.nama);
    _deskripsiController = TextEditingController(text: o.deskripsi);
    _visiController = TextEditingController(text: o.visi ?? '');
    _misiController = TextEditingController(text: o.misi ?? '');
    _alamatController = TextEditingController(text: o.alamat ?? '');
    _emailController = TextEditingController(text: o.email ?? '');
    _websiteController = TextEditingController(text: o.website ?? '');
    _instagramController = TextEditingController(text: o.instagram ?? '');
    _tahunBerdiriController = TextEditingController(text: o.tahunBerdiri ?? '');
    _selectedStatus = o.status.toLowerCase().isNotEmpty ? o.status.toLowerCase() : 'aktif';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _tahunBerdiriController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_namaController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Nama organisasi wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'Nama': _namaController.text,
        'Deskripsi': _deskripsiController.text,
        'Visi': _visiController.text.isNotEmpty ? _visiController.text : null,
        'Misi': _misiController.text.isNotEmpty ? _misiController.text : null,
        'Alamat': _alamatController.text.isNotEmpty ? _alamatController.text : null,
        'Email': _emailController.text.isNotEmpty ? _emailController.text : null,
        'Website': _websiteController.text.isNotEmpty ? _websiteController.text : null,
        'Instagram': _instagramController.text.isNotEmpty ? _instagramController.text : null,
        'TahunBerdiri': _tahunBerdiriController.text.isNotEmpty ? _tahunBerdiriController.text : null,
        'Status': _selectedStatus,
      }..removeWhere((_, v) => v == null);

      await context.read<OrmawaProvider>().updateOrganisasi(
            widget.organisasi.id.toString(),
            data,
          );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Organisasi berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Edit Organisasi',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(20),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.organisasi.nama,
                          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'ID: ${widget.organisasi.id}',
                          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('NAMA ORGANISASI *'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _namaController, hint: 'Nama organisasi', icon: Icons.business_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _deskripsiController, hint: 'Deskripsi...', icon: Icons.description_rounded, maxLines: 3),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('VISI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _visiController, hint: 'Visi...', icon: Icons.visibility_rounded, maxLines: 3),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('MISI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _misiController, hint: 'Misi...', icon: Icons.flag_rounded, maxLines: 3),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('ALAMAT'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _alamatController, hint: 'Alamat...', icon: Icons.location_on_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('EMAIL'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _emailController, hint: 'email@organisasi.ac.id', icon: Icons.email_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('WEBSITE'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _websiteController, hint: 'https://...', icon: Icons.language_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('INSTAGRAM'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _instagramController, hint: '@organisasi', icon: Icons.camera_alt_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('TAHUN BERDIRI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _tahunBerdiriController, hint: '2020', icon: Icons.calendar_today_rounded),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel('STATUS'),
            const SizedBox(height: AppSpacing.md),
            _buildDropdown(
              value: _selectedStatus,
              items: const ['aktif', 'nonaktif'],
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            const SizedBox(height: AppSpacing.s48),

            BkuButton.primary(
              text: 'SIMPAN PERUBAHAN',
              onPressed: _isSubmitting ? null : _handleSubmit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        fontSize: 10,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: BkuTextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: context.appColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: DropdownButtonHideUnderline(
        child: BkuDropdown<String>(
          isExpanded: true,
          value: value,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral800),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
