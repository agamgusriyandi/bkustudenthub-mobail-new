import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';

class EditTkScreen extends StatefulWidget {
  final String tkId;
  final Map<String, dynamic>? initialData;

  const EditTkScreen({
    super.key,
    required this.tkId,
    this.initialData,
  });

  @override
  State<EditTkScreen> createState() => _EditTkScreenState();
}

class _EditTkScreenState extends State<EditTkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _spesialisasiController = TextEditingController();
  final _lokasiController = TextEditingController();

  String _scopeType = 'Klinik Kampus';
  bool _isSaving = false;
  bool _isLoading = true;

  final List<String> _scopeList = [
    'Klinik Kampus',
    'Unit Kesehatan Mahasiswa',
    'Fakultas',
    'Pusat',
  ];

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final data = widget.initialData;
    if (data != null) {
      _namaController.text = data['nama'] ?? data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _noHpController.text = data['no_hp'] ?? data['phone'] ?? '';
      _spesialisasiController.text = data['spesialisasi'] ?? '';
      _lokasiController.text = data['lokasi'] ?? '';
      final scope = data['scope'] ?? data['scope_type'] ?? 'Klinik Kampus';
      if (_scopeList.contains(scope)) {
        _scopeType = scope;
      }
    }
    setState(() => _isLoading = false);
  }

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

    try {
      final api = ApiClient();
      await api.client.put('/api/admin/tenagakes/${widget.tkId}', data: {
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'no_hp': _noHpController.text.trim(),
        'spesialisasi': _spesialisasiController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'scope_type': _scopeType,
      });

      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Data berhasil diperbarui');
      context.pop();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memperbarui data: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Edit Tenaga Kesehatan',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_rounded, size: 36, color: context.appColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildField('Nama Lengkap', _namaController,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('Email', _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('No. HP', _noHpController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('Spesialisasi', _spesialisasiController,
                      hint: 'Contoh: Umum, Gigi, dll'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('Lokasi', _lokasiController,
                      hint: 'Contoh: Klinik Utama BKU'),
                  const SizedBox(height: AppSpacing.lg),
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
                  BkuButton(
                    text: 'Simpan Perubahan',
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
