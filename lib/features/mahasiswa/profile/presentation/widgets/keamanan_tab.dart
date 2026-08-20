import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

class KeamananTabWidget extends StatefulWidget {
  const KeamananTabWidget({super.key});

  @override
  State<KeamananTabWidget> createState() => _KeamananTabWidgetState();
}

class _KeamananTabWidgetState extends State<KeamananTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submitChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    BkuDialog.show(
      context: context,
      type: BkuDialogType.warning,
      title: 'Perbarui Password?',
      message:
          'Anda akan memperbarui kata sandi akun Anda. Pastikan untuk mengingat kata sandi baru Anda.',
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
      primaryButtonText: 'Ya, Perbarui',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        setState(() => _isSubmitting = true);
        try {
          final provider = context.read<ProfileProvider>();
          await provider.changePassword(
            '********',
            _newPasswordCtrl.text,
            _confirmPasswordCtrl.text,
          );

          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();

          if (mounted) {
            AppSnackbar.showSuccess(context, 'Password berhasil diperbarui');
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, ErrorHandler.getMessage(e));
          }
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      },
    );
  }

  void _handleLogout() {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Keluar dari Akun?',
      message:
          'Anda akan keluar dari sesi aplikasi saat ini. Anda perlu login kembali untuk mengakses data Anda.',
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
      primaryButtonText: 'Ya, Keluar',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          BkuLoadingDialog.show(context);
          await AuthService().logout();
          if (mounted) {
            BkuLoadingDialog.hide(context);
            context.go(AppRoutes.login);
          }
        } catch (_) {
          if (mounted) {
            BkuLoadingDialog.hide(context);
            context.go(AppRoutes.login);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return RefreshIndicator(
      onRefresh: () async {},
      color: BkuTheme.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          _buildChangePasswordSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildEmailSection(profile.email),
          const SizedBox(height: AppSpacing.lg),
          _buildLogoutButton(),
          const SizedBox(height: AppSpacing.s80),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganti Password',
              style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'Pastikan password kamu kuat dan sulit ditebak.',
              style: BkuTheme.textCaption.copyWith(fontSize: 11),
            ),
            const Divider(height: 24, color: BkuTheme.borderSubtle),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Saat Ini',
                  style: BkuTheme.textBadge.copyWith(
                    color: BkuTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r10,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Text(
                    '••••••••',
                    style: TextStyle(
                      letterSpacing: 2,
                      color: BkuTheme.textPlaceholder,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Baru',
                  style: BkuTheme.textBadge.copyWith(
                    color: BkuTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newPasswordCtrl,
                  obscureText: !_showNew,
                  style: BkuTheme.textBodyRegular,
                  decoration: InputDecoration(
                    hintText: 'Minimal 8 karakter',
                    hintStyle: BkuTheme.textCaption.copyWith(
                      color: BkuTheme.textPlaceholder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: BkuTheme.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: const BorderSide(color: BkuTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: const BorderSide(color: BkuTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: BorderSide(
                        color: BkuTheme.primary,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: BkuTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _showNew = !_showNew),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password baru wajib diisi';
                    }
                    if (val.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konfirmasi Password Baru',
                  style: BkuTheme.textBadge.copyWith(
                    color: BkuTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: !_showConfirm,
                  style: BkuTheme.textBodyRegular,
                  decoration: InputDecoration(
                    hintText: 'Ulangi password baru',
                    hintStyle: BkuTheme.textCaption.copyWith(
                      color: BkuTheme.textPlaceholder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: BkuTheme.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: const BorderSide(color: BkuTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: const BorderSide(color: BkuTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BkuTheme.r10,
                      borderSide: BorderSide(
                        color: BkuTheme.primary,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: BkuTheme.textMuted,
                      ),
                      onPressed:
                          () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  validator: (val) {
                    if (val != _newPasswordCtrl.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            BkuButton(
              text: 'Perbarui Password',
              onPressed: _isSubmitting ? null : _submitChangePassword,
              isLoading: _isSubmitting,
              height: 46,
              fontSize: 13,
              variant: BkuButtonVariant.primary,
              customRadius: BkuTheme.r12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(String email) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Terdaftar',
            style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            'Email yang digunakan untuk login dan pengiriman notifikasi.',
            style: BkuTheme.textCaption.copyWith(fontSize: 11),
          ),
          const Divider(height: 24, color: BkuTheme.borderSubtle),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: BkuTheme.scaffoldBg,
              borderRadius: BkuTheme.r10,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: BkuTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email.isNotEmpty ? email : '-',
                    style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
                  ),
                ),
                Text(
                  'Read-Only',
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 9.5,
                    color: BkuTheme.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return BkuButton(
      onPressed: _handleLogout,
      text: 'Keluar dari Akun',
      icon: Icons.logout_rounded,
      variant: BkuButtonVariant.danger,
      height: 46,
      customRadius: BkuTheme.r12,
    );
  }
}
