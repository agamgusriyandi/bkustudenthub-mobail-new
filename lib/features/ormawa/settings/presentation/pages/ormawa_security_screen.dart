import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

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

        if (result['success'] == true) {
          AppSnackbar.showSuccess(context, result['message'] ?? 'Kata sandi berhasil diperbarui');
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          AppSnackbar.showError(context, result['message'] ?? 'Gagal memperbarui kata sandi');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Keamanan Akun',
            subtitle: 'Kontrol Akses Pribadi',
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: OrmawaTheme.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            color: OrmawaTheme.primary,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amankan Akun Anda',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: OrmawaTheme.textHeading,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Gunakan kombinasi kata sandi yang kuat dan jangan pernah membagikan akses ke orang lain.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: OrmawaTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Ubah Kata Sandi'),
                  const SizedBox(height: 8),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: OrmawaTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: OrmawaTheme.textHeading,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: OrmawaCard(
        child: Column(
          children: [
            BkuTextField(
              controller: _oldPasswordController,
              label: 'Kata Sandi Saat Ini',
              hint: 'Masukkan kata sandi lama',
              obscureText: _obscureOld,
              prefixIcon: Icon(Icons.lock_outline_rounded, color: OrmawaTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: OrmawaTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureOld = !_obscureOld),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Kata sandi saat ini wajib diisi' : null,
            ),
            SizedBox(height: 14),
            BkuTextField(
              controller: _newPasswordController,
              label: 'Kata Sandi Baru',
              hint: 'Minimal 8 karakter',
              obscureText: _obscureNew,
              prefixIcon: Icon(Icons.lock_reset_rounded, color: OrmawaTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: OrmawaTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
                if (v.length < 8) return 'Minimal 8 karakter';
                return null;
              },
            ),
            SizedBox(height: 14),
            BkuTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Kata Sandi Baru',
              hint: 'Ulangi kata sandi baru',
              obscureText: _obscureConfirm,
              prefixIcon: Icon(Icons.check_circle_outline_rounded, color: OrmawaTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: OrmawaTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                if (v != _newPasswordController.text) return 'Kata sandi tidak cocok';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OrmawaButton(
                text: 'SIMPAN PERUBAHAN',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleSave,
                icon: Icons.save_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
