import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CreateKegiatanScreen extends StatefulWidget {
  const CreateKegiatanScreen({super.key});

  @override
  State<CreateKegiatanScreen> createState() => _CreateKegiatanScreenState();
}

class _CreateKegiatanScreenState extends State<CreateKegiatanScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  String _selectedStatus = 'Dijadwalkan';
  DateTime? _selectedTanggalMulai;
  bool _isSubmitting = false;

  final List<String> _statuses = [
    'Dijadwalkan',
    'Berlangsung',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_judulController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Judul kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _lokasiController.text,
        'status': _selectedStatus,
        'tanggalMulai': _selectedTanggalMulai?.toUtc().toIso8601String(),
      };

      await context.read<OrmawaProvider>().addAgenda(data);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'Kegiatan Dibuat!',
            content: 'Kegiatan baru berhasil disimpan.',
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
      if (mounted) AppSnackbar.showError(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedTanggalMulai = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'TAMBAH KEGIATAN',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JUDUL KEGIATAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _judulController,
                hint: 'Contoh: Rapat Koordinasi',
                icon: Icons.event_rounded),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _deskripsiController,
                hint: 'Deskripsi kegiatan...',
                icon: Icons.description_rounded,
                maxLines: 3),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('LOKASI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _lokasiController,
                hint: 'Contoh: Aula Utama',
                icon: Icons.location_on_rounded),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('TANGGAL PELAKSANAAN'),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: context.appColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _selectedTanggalMulai != null
                          ? '${_selectedTanggalMulai!.day}/${_selectedTanggalMulai!.month}/${_selectedTanggalMulai!.year}'
                          : 'Pilih tanggal...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedTanggalMulai != null
                            ? AppColors.neutral800
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('STATUS'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedStatus = val!),
                ),
              ),
            ),
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
                    : Text('SIMPAN KEGIATAN',
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
              Icon(icon, color: context.appColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
