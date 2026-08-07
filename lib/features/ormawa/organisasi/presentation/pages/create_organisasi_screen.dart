import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CreateOrganisasiScreen extends StatefulWidget {
  const CreateOrganisasiScreen({super.key});

  @override
  State<CreateOrganisasiScreen> createState() => _CreateOrganisasiScreenState();
}

class _CreateOrganisasiScreenState extends State<CreateOrganisasiScreen> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _visiController = TextEditingController();
  final _misiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tahunBerdiriController = TextEditingController();
  String _selectedStatus = 'aktif';
  bool _isSubmitting = false;

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

      await context.read<OrmawaProvider>().createOrganisasi(data);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'Organisasi Dibuat!',
            content: 'Data organisasi baru berhasil disimpan.',
            cancelText: '',
            confirmText: 'Kembali',
            onCancel: () {},
            onConfirm: () {
              context.pop();
              context.pop();
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'TAMBAH ORGANISASI',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('NAMA ORGANISASI *'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _namaController,
              hint: 'Masukkan nama organisasi',
              icon: Icons.business_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _deskripsiController,
              hint: 'Deskripsi singkat organisasi...',
              icon: Icons.description_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('VISI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _visiController,
              hint: 'Visi organisasi...',
              icon: Icons.visibility_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('MISI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _misiController,
              hint: 'Misi organisasi...',
              icon: Icons.flag_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('ALAMAT'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _alamatController,
              hint: 'Alamat organisasi...',
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('EMAIL'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _emailController,
              hint: 'email@organisasi.ac.id',
              icon: Icons.email_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('WEBSITE'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _websiteController,
              hint: 'https://organisasi.ac.id',
              icon: Icons.language_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('INSTAGRAM'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _instagramController,
              hint: '@organisasi',
              icon: Icons.camera_alt_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('TAHUN BERDIRI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _tahunBerdiriController,
              hint: '2020',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('STATUS'),
            const SizedBox(height: AppSpacing.md),
            _buildDropdown(
              value: _selectedStatus,
              items: const ['aktif', 'nonaktif'],
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            const SizedBox(height: AppSpacing.s48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: context.appColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'SIMPAN ORGANISASI',
                        style: TextStyle(
                          color: context.appColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
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
      child: TextField(
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
        child: DropdownButton<String>(
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
