import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class EditPsychologistScreen extends StatefulWidget {
  final String psychologistId;
  const EditPsychologistScreen({super.key, required this.psychologistId});

  @override
  State<EditPsychologistScreen> createState() => _EditPsychologistScreenState();
}

class _EditPsychologistScreenState extends State<EditPsychologistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _nidnCtrl = TextEditingController();
  final _spesialisasiCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _bahasaCtrl = TextEditingController();
  final _tarifCtrl = TextEditingController();
  bool _isSaving = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminPsychologistProvider>();
      if (provider.selectedPsychologist == null) {
        await provider.loadPsychologistDetail(widget.psychologistId);
      }
      _fillForm(provider.selectedPsychologist);
    });
  }

  void _fillForm(Map<String, dynamic>? data) {
    if (data == null || _dataLoaded) return;
    _dataLoaded = true;
    _namaCtrl.text = (data['name'] ?? data['nama'] ?? '').toString();
    _emailCtrl.text = (data['email'] ?? '').toString();
    _noHpCtrl.text = (data['no_hp'] ?? data['NoHP'] ?? '').toString();
    _nidnCtrl.text = (data['nidn'] ?? data['NIDN'] ?? '').toString();
    _spesialisasiCtrl.text =
        (data['spesialisasi'] ?? data['specialization'] ?? '').toString();
    _bioCtrl.text = (data['bio'] ?? data['Bio'] ?? '').toString();
    _lokasiCtrl.text = (data['lokasi'] ?? data['Lokasi'] ?? '').toString();
    _bahasaCtrl.text = (data['bahasa'] ?? data['Bahasa'] ?? '').toString();
    _tarifCtrl.text = (data['tarif'] ?? data['Tarif'] ?? '').toString();
    setState(() {});
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _noHpCtrl.dispose();
    _nidnCtrl.dispose();
    _spesialisasiCtrl.dispose();
    _bioCtrl.dispose();
    _lokasiCtrl.dispose();
    _bahasaCtrl.dispose();
    _tarifCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'nama': _namaCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'no_hp': _noHpCtrl.text.trim(),
      'nidn': _nidnCtrl.text.trim(),
      'spesialisasi': _spesialisasiCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'lokasi': _lokasiCtrl.text.trim(),
      'bahasa': _bahasaCtrl.text.trim(),
      'tarif': int.tryParse(_tarifCtrl.text.trim()) ?? 0,
    };

    final success = await context
        .read<AdminPsychologistProvider>()
        .updatePsychologist(widget.psychologistId, data);
    if (!mounted) return;

    setState(() => _isSaving = false);

    BkuDialog.show(
      context: context,
      title: success ? 'Berhasil' : 'Gagal',
      message: success
          ? 'Data psikolog berhasil diperbarui.'
          : 'Gagal memperbarui data psikolog.',
      type: success ? BkuDialogType.success : BkuDialogType.error,
      primaryButtonText: 'Tutup',
      onPrimaryPressed: () {
        Navigator.pop(context);
        if (success) context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPsychologistProvider>(
      builder: (context, provider, _) {
        final data = provider.selectedPsychologist;
        final isLoading = provider.loading && data == null;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                title: 'Edit Psikolog',
                variant: AppBarVariant.psychologist,
                isExpandable: false,
                showBackButton: true,
              ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 80),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.s120,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Informasi Dasar'),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTextField(
                            controller: _namaCtrl,
                            label: 'Nama Lengkap',
                            icon: Icons.person_rounded,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _noHpCtrl,
                            label: 'No. HP',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _nidnCtrl,
                            label: 'Nidn',
                            icon: Icons.badge_rounded,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSectionTitle('Profesi'),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTextField(
                            controller: _spesialisasiCtrl,
                            label: 'Spesialisasi',
                            icon: Icons.psychology_rounded,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _lokasiCtrl,
                            label: 'Lokasi',
                            icon: Icons.location_on_rounded,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _bahasaCtrl,
                            label: 'Bahasa',
                            icon: Icons.translate_rounded,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _tarifCtrl,
                            label: 'Tarif (Rp)',
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSectionTitle('Tentang'),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTextField(
                            controller: _bioCtrl,
                            label: 'Bio',
                            icon: Icons.info_outline_rounded,
                            maxLines: 4,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          BkuButton(
                            onPressed: _isSaving ? null : _save,
                            isLoading: _isSaving,
                            text: 'Simpan Perubahan',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.neutral900,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return BkuTextField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
        prefixIcon: Icon(icon, size: 20, color: AppColors.neutral500),
        filled: true,
        fillColor: context.appColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(
            color: context.appColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.error.withAlpha(100)),
        ),
      ),
    );
  }
}
