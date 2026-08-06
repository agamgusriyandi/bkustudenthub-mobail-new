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

class CreatePengumumanScreen extends StatefulWidget {
  const CreatePengumumanScreen({super.key});

  @override
  State<CreatePengumumanScreen> createState() => _CreatePengumumanScreenState();
}

class _CreatePengumumanScreenState extends State<CreatePengumumanScreen> {
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  String _selectedTarget = 'umum';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Judul dan Isi wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ormawaId = context.read<OrmawaProvider>().ormawaId;
      final data = {
        'OrmawaID': int.parse(ormawaId!),
        'Judul': _judulController.text,
        'Isi': _isiController.text,
        'Target': _selectedTarget,
      };

      await context.read<OrmawaProvider>().createAnnouncement(data);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'Pengumuman Dipublikasi!',
            content: 'Pengumuman baru berhasil disimpan.',
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
        title: 'BUAT PENGUMUMAN',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JUDUL PENGUMUMAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _judulController,
                hint: 'Masukkan judul...',
                icon: Icons.title_rounded),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('KATEGORI'),
            const SizedBox(height: AppSpacing.md),
            _buildCategorySelector(),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('ISI PENGUMUMAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _isiController,
                hint: 'Tuliskan isi pengumuman...',
                icon: Icons.description_rounded,
                maxLines: 8),
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
                    : Text('PUBLISH SEKARANG',
                        style: TextStyle(
                            color: context.appColors.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
              ),
            ),
          ],
        ),
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

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'umum', 'label': 'UMUM', 'icon': Icons.feed_rounded},
      {'id': 'kegiatan', 'label': 'KEGIATAN', 'icon': Icons.event_rounded},
      {'id': 'penting', 'label': 'PENTING', 'icon': Icons.priority_high_rounded},
      {'id': 'info', 'label': 'INFO', 'icon': Icons.info_rounded},
    ];

    return Row(
      children: categories
          .map((c) => Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTarget = c['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _selectedTarget == c['id']
                          ? context.appColors.primary.withAlpha(15)
                          : AppColors.neutral100,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: _selectedTarget == c['id']
                            ? context.appColors.primary
                            : AppColors.neutral300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(c['icon'] as IconData,
                            color: _selectedTarget == c['id']
                                ? context.appColors.primary
                                : AppColors.neutral500,
                            size: 20),
                        const SizedBox(height: 4),
                        Text(c['label'] as String,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: _selectedTarget == c['id']
                                    ? context.appColors.primary
                                    : AppColors.neutral600)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
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
          prefixIcon:
              Icon(icon, color: AppColors.neutral500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
