import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/bku_app_bar.dart';
import '../../../../../core/widgets/bku_loading_dialog.dart';
import '../../../../../core/widgets/custom_dialog.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan';
  String _selectedSource = 'organisasi';
  String _selectedCategory = 'Lainnya';
  final bool _isSubmitting = false;

  final List<String> _categories = [
    'Iuran Anggota',
    'Sponsor',
    'Konsumsi',
    'Perlengkapan',
    'Transportasi',
    'Sewa Tempat',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BkuStaticAppBar(
        title: 'CATAT TRANSAKSI',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JENIS TRANSAKSI'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeCard(
                  'PEMASUKAN',
                  'pemasukan',
                  Icons.arrow_downward_rounded,
                  AppColors.success,
                ),
                const SizedBox(width: 16),
                _buildTypeCard(
                  'PENGELUARAN',
                  'pengeluaran',
                  Icons.arrow_upward_rounded,
                  AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('SUMBER DANA'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSourceCard(
                  'KAS MANDIRI',
                  'organisasi',
                  Icons.payments_rounded,
                  AppColors.success,
                ),
                const SizedBox(width: 16),
                _buildSourceCard(
                  'PAGU KAMPUS',
                  'kampus',
                  Icons.assured_workload_rounded,
                  const Color(0xFF0EA5E9),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('DESKRIPSI / KETERANGAN'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Contoh: Iuran Kas Bulan Mei',
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 24),

            _buildLabel('NOMINAL (RP)'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _amountController,
              hint: '0',
              icon: Icons.payments_rounded,
              isNumber: true,
            ),
            const SizedBox(height: 24),

            _buildLabel('KATEGORI'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items:
                      _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,

                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'SIMPAN TRANSAKSI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
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

  Widget _buildTypeCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(15) : Colors.white,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: isSelected ? color : AppColors.neutral300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedSource == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSource = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(15) : Colors.white,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: isSelected ? color : AppColors.neutral300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [ThousandsSeparatorInputFormatter()] : null,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: isNumber ? 'Rp ' : null,
          prefixStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      AppSnackbar.showWarning(context, 'Harap isi semua field');
      return;
    }

    BkuLoadingDialog.show(context);

    try {
      final data = {
        'type': _selectedType,
        'nominal': double.parse(_amountController.text.replaceAll('.', '')),
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'sumber': _selectedSource,
        'date': DateTime.now().toIso8601String(),
      };

      await context.read<OrmawaProvider>().addFinance(data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => CustomDialog(
                title: 'Transaksi Disimpan!',
                content: 'Data transaksi keuangan berhasil ditambahkan.',
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
    }
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format with dot separator
    final buffer = StringBuffer();
    for (int i = 0; i < cleanedText.length; i++) {
      if (i > 0 && (cleanedText.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanedText[i]);
    }

    final newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
