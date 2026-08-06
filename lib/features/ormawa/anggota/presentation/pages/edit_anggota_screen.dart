import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class EditAnggotaScreen extends StatefulWidget {
  final dynamic member;
  const EditAnggotaScreen({super.key, required this.member});

  @override
  State<EditAnggotaScreen> createState() => _EditAnggotaScreenState();
}

class _EditAnggotaScreenState extends State<EditAnggotaScreen> {
  late String _selectedRole;
  late String _selectedDivision;
  late String _selectedStatus;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSubmitting = false;

  final List<String> _statuses = ['Aktif', 'Nonaktif', 'Alumni', 'Cuti'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role.isEmpty ? 'Anggota' : widget.member.role;
    _selectedDivision =
        widget.member.division.isEmpty ? 'Umum' : widget.member.division;
    _selectedStatus = widget.member.status;
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'MahasiswaID': int.tryParse(widget.member.mahasiswaId),
        'Role': _selectedRole,
        'Divisi': _selectedDivision == 'Umum' ? '' : _selectedDivision,
        'Status': _selectedStatus,
        'EmailKampus': _emailController.text,
        'NoHP': _phoneController.text,
      };

      await context.read<OrmawaProvider>().updateMember(widget.member.id, data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Data anggota berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal: $e');
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
        title: 'EDIT ANGGOTA',
        variant: AppBarVariant.ormawa,
      ),
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          final roles = provider.roles.map((r) => r.name).toList();
          if (!roles.contains('Anggota')) roles.add('Anggota');
          final divisions = ['Umum', ...provider.divisions.map((d) => d.name)];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            context.appColors.primary.withAlpha(20),
                        child: Text(widget.member.initial,
                            style: TextStyle(
                                color: context.appColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.member.name,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.w900)),
                            Text(widget.member.nim,
                                style: AppTextStyles.labelSm
                                    .copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('JABATAN'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  value: roles.contains(_selectedRole)
                      ? _selectedRole
                      : roles.first,
                  items: roles,
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('DIVISI'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  value: divisions.contains(_selectedDivision)
                      ? _selectedDivision
                      : 'Umum',
                  items: divisions,
                  onChanged: (val) =>
                      setState(() => _selectedDivision = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('STATUS'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  value: _selectedStatus,
                  items: _statuses,
                  onChanged: (val) =>
                      setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('EMAIL KAMPUS'),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                    controller: _emailController,
                    hint: 'email@kampus.ac.id',
                    icon: Icons.email_rounded),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('NOMOR HP'),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                    controller: _phoneController,
                    hint: '08123456789',
                    icon: Icons.phone_android_rounded),
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
                        : Text('SIMPAN PERUBAHAN',
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
}
