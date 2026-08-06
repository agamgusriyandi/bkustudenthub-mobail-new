import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

class OrmawaSecurityScreen extends StatefulWidget {
  const OrmawaSecurityScreen({super.key});

  @override
  State<OrmawaSecurityScreen> createState() => _OrmawaSecurityScreenState();
}

class _OrmawaSecurityScreenState extends State<OrmawaSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await AuthService().changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result['success']
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: context.appColors.onPrimary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    result['message'] ??
                        (result['success'] ? 'Berhasil' : 'Gagal'),
                    style: AppTextStyles.bodyMd.copyWith(color: context.appColors.onPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor:
                result['success'] ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,

            margin: const EdgeInsets.all(AppSpacing.xl),
          ),
        );

        if (result['success']) {
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    }
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
            variant: AppBarVariant.ormawa,
            title: 'KEAMANAN AKUN',
            subtitle: 'KONTROL AKSES PRIBADI',
            expandedHeight: 120.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityAlertCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('UBAH KATA SANDI'),
                  const SizedBox(height: AppSpacing.md),
                  _buildPasswordForm(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.primary.withAlpha(15),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: context.appColors.primary.withAlpha(50),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security_rounded,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amankan Akun Anda',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Gunakan kombinasi kata sandi yang kuat dan jangan pernah membagikan akses ke orang lain.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.overline.copyWith(
          color: AppColors.neutral500,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              label: 'Kata Sandi Saat Ini',
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(
              label: 'Kata Sandi Baru',
              controller: _newPasswordController,
              obscureText: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPasswordField(
              label: 'Konfirmasi Sandi Baru',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              onToggle:
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (val) {
                if (val != _newPasswordController.text) {
                  return 'Konfirmasi sandi tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,

                child:
                    _isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: context.appColors.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'PERBARUI SANDI',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: context.appColors.onPrimary,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.bodyLg,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
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
              borderSide: BorderSide(
                color: context.appColors.primary,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.neutral400,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
          validator:
              validator ??
              (val) {
                if (val == null || val.isEmpty) {
                  return 'Bagian ini tidak boleh kosong';
                }
                if (val.length < 6) return 'Minimal 6 karakter';
                return null;
              },
        ),
      ],
    );
  }
}
