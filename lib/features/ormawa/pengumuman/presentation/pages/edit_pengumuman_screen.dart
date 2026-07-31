import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPengumumanScreen extends StatefulWidget {
  final dynamic announcement;
  const EditPengumumanScreen({super.key, required this.announcement});

  @override
  State<EditPengumumanScreen> createState() => _EditPengumumanScreenState();
}

class _EditPengumumanScreenState extends State<EditPengumumanScreen> {
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;
  late String _selectedTarget;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.announcement.judul);
    _isiController = TextEditingController(text: widget.announcement.isi);
    _selectedTarget = widget.announcement.target.toLowerCase() == 'informasi'
        ? 'info'
        : widget.announcement.target.toLowerCase();
  }

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
      await context.read<OrmawaProvider>().updateAnnouncement(
            widget.announcement.id,
            {
              'Judul': _judulController.text,
              'Isi': _isiController.text,
              'Target': _selectedTarget,
            },
          );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengumuman berhasil diperbarui');
        Navigator.pop(context);
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
        title: 'EDIT PENGUMUMAN',
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
                hint: 'Judul pengumuman...',
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
                hint: 'Isi pengumuman...',
                icon: Icons.description_rounded,
                maxLines: 8),
            const SizedBox(height: AppSpacing.s48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('SIMPAN PERUBAHAN',
                        style: TextStyle(
                            color: Colors.white,
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
                          ? Theme.of(context).colorScheme.primary.withAlpha(15)
                          : AppColors.neutral100,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: _selectedTarget == c['id']
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.neutral300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(c['icon'] as IconData,
                            color: _selectedTarget == c['id']
                                ? Theme.of(context).colorScheme.primary
                                : AppColors.neutral500,
                            size: 20),
                        const SizedBox(height: 4),
                        Text(c['label'] as String,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: _selectedTarget == c['id']
                                    ? Theme.of(context).colorScheme.primary
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
          prefixIcon: Icon(icon, color: AppColors.neutral500, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
