import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CreateAnggotaScreen extends StatefulWidget {
  const CreateAnggotaScreen({super.key});

  @override
  State<CreateAnggotaScreen> createState() => _CreateAnggotaScreenState();
}

class _CreateAnggotaScreenState extends State<CreateAnggotaScreen> {
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  String _selectedRole = 'Anggota';
  String _selectedDivision = 'Umum';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_nimController.text.isEmpty || _namaController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'NIM dan Nama wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'NIM': _nimController.text,
        'Nama': _namaController.text,
        'Role': _selectedRole,
        'Divisi': _selectedDivision == 'Umum' ? '' : _selectedDivision,
        'Status': 'Aktif',
      };

      await context.read<OrmawaProvider>().addMember(data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'Anggota Ditambahkan!',
            content: 'Data anggota baru berhasil disimpan.',
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
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Tambah Anggota',
        variant: AppBarVariant.ormawa,
      ),
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          final roles = provider.roles.map((r) => r.name).toList();
          if (!roles.contains('Anggota')) roles.add('Anggota');
          final divisions = [
            'Umum',
            ...provider.divisions.map((d) => d.name),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('NIM'),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                    controller: _nimController,
                    hint: 'Masukkan NIM',
                    icon: Icons.badge_rounded),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('NAMA LENGKAP'),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                    controller: _namaController,
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_rounded),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('JABATAN'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  value: _selectedRole,
                  items: roles,
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('DIVISI'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  value: _selectedDivision,
                  items: divisions,
                  onChanged: (val) =>
                      setState(() => _selectedDivision = val!),
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
                                color: context.appColors.onPrimary, strokeWidth: 2))
                        : Text('SIMPAN ANGGOTA',
                            style: TextStyle(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: 10));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              Icon(icon, color: context.appColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral800)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
