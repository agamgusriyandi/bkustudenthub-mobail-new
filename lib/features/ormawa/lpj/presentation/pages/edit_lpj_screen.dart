import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditLpjScreen extends StatefulWidget {
  final dynamic lpj;
  const EditLpjScreen({super.key, required this.lpj});

  @override
  State<EditLpjScreen> createState() => _EditLpjScreenState();
}

class _EditLpjScreenState extends State<EditLpjScreen> {
  late final TextEditingController _judulController;
  late final TextEditingController _catatanController;
  late final TextEditingController _realisasiController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.lpj.judul);
    _catatanController = TextEditingController(text: widget.lpj.catatan);
    _realisasiController = TextEditingController(
      text: widget.lpj.realisasiAnggaran.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    _realisasiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'Judul': _judulController.text,
        'Catatan': _catatanController.text,
        'RealisasiAnggaran': double.tryParse(
                _realisasiController.text.replaceAll('.', '')) ??
            0,
      };
      await context.read<OrmawaProvider>().updateLPJ(widget.lpj.id, data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'LPJ berhasil diperbarui');
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
        title: 'EDIT LPJ',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JUDUL LPJ'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _judulController, hint: 'Judul LPJ'),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('CATATAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _catatanController,
                hint: 'Catatan...',
                maxLines: 3),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('REALISASI ANGGRAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _realisasiController,
                hint: '0',
                isNumber: true),
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
    return Text(
      text,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        fontSize: 10,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
