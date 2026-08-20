import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
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
      backgroundColor: BkuTheme.scaffoldBg,
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
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: BkuTheme.primarySoft,
                            borderRadius: BkuTheme.r12,
                            border: Border.all(color: BkuTheme.primaryBorder),
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            color: BkuTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amankan Akun Anda',
                                style: BkuTheme.textSectionTitle,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Gunakan kombinasi kata sandi yang kuat dan jangan pernah membagikan akses ke orang lain.',
                                style: BkuTheme.textCaption.copyWith(
                                  color: BkuTheme.textMuted,
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
                  const SizedBox(height: AppSpacing.s100),
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
            color: BkuTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title,
          style: BkuTheme.textSectionTitle,
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 16,
        child: Column(
          children: [
            BkuTextField(
              controller: _oldPasswordController,
              label: 'KATA SANDI SAAT INI *',
              hint: 'Masukkan kata sandi lama',
              obscureText: _obscureOld,
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: BkuTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: BkuTheme.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureOld = !_obscureOld),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Kata sandi saat ini wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            BkuTextField(
              controller: _newPasswordController,
              label: 'KATA SANDI BARU *',
              hint: 'Minimal 8 karakter',
              obscureText: _obscureNew,
              prefixIcon: Icon(Icons.lock_reset_rounded, size: 20, color: BkuTheme.purple),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: BkuTheme.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
                if (v.length < 8) return 'Minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            BkuTextField(
              controller: _confirmPasswordController,
              label: 'KONFIRMASI KATA SANDI BARU *',
              hint: 'Ulangi kata sandi baru',
              obscureText: _obscureConfirm,
              prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: BkuTheme.emerald),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: BkuTheme.textMuted,
                  size: 20,
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
              child: BkuButton.primary(
                text: 'Simpan Perubahan',
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