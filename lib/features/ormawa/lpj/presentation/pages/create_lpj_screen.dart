import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CreateLpjScreen extends StatefulWidget {
  const CreateLpjScreen({super.key});

  @override
  State<CreateLpjScreen> createState() => _CreateLpjScreenState();
}

class _CreateLpjScreenState extends State<CreateLpjScreen> {
  final _judulController = TextEditingController();
  final _catatanController = TextEditingController();
  final _realisasiController = TextEditingController();
  String? _selectedProposalId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    _realisasiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_judulController.text.isEmpty || _selectedProposalId == null) {
      AppSnackbar.showWarning(context, 'Judul dan Proposal wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'Judul': _judulController.text,
        'ProposalID': int.parse(_selectedProposalId!),
        'Catatan': _catatanController.text,
        'RealisasiAnggaran': double.tryParse(
                _realisasiController.text.replaceAll('.', '')) ??
            0,
        'Status': 'Menunggu',
      };

      await context.read<OrmawaProvider>().addLPJ(data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CustomDialog(
            title: 'LPJ Dibuat!',
            content: 'Laporan pertanggungjawaban berhasil disimpan.',
            cancelText: '',
            confirmText: 'Kembali',
            onCancel: () {},
            onConfirm: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          final proposals = provider.proposals
              .where((p) =>
                  p.status.toLowerCase().contains('disetujui') ||
                  p.status.toLowerCase() == 'selesai')
              .toList();

          return CustomScrollView(
            slivers: [
              BkuAppBar(
                title: 'BUAT LPJ BARU',
                subtitle: 'LAPORAN PERTANGGUNGJAWABAN',
                variant: AppBarVariant.ormawa,
                expandedHeight: 130.0,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('JUDUL LPJ'),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _judulController,
                        hint: 'Contoh: LPJ Kegiatan Seminar',
                        icon: Icons.title_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLabel('PROPOSAL TERKAIT'),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(color: AppColors.neutral300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProposalId,
                            isExpanded: true,
                            hint: Text('Pilih Proposal',
                                style: AppTextStyles.labelMd
                                    .copyWith(color: AppColors.neutral500)),
                            items: proposals
                                .map((p) => DropdownMenuItem(
                                      value: p.id.toString(),
                                        child: Text(p.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedProposalId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLabel('CATATAN'),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _catatanController,
                        hint: 'Catatan tambahan...',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLabel('REALISASI ANGGRAN (RP)'),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(
                        controller: _realisasiController,
                        hint: '0',
                        icon: Icons.payments_rounded,
                        isNumber: true,
                      ),
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
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'SIMPAN LPJ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
    required IconData icon,
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
          prefixIcon:
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
