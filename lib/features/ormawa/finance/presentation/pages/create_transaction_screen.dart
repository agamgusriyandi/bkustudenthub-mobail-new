import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan';
  String _selectedSource = 'organisasi';
  String _selectedCategory = 'Lainnya';
  bool _isSubmitting = false;

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
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final desc = _descriptionController.text.trim();
    final rawAmount = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(rawAmount);

    if (desc.isEmpty) {
      AppSnackbar.showWarning(context, 'Deskripsi transaksi wajib diisi');
      return;
    }

    if (amount == null || amount <= 0) {
      AppSnackbar.showWarning(context, 'Nominal transaksi harus lebih dari 0');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final payload = {
        'Tipe': _selectedType,
        'SumberDana': _selectedSource,
        'Deskripsi': desc,
        'Nominal': amount,
        'Kategori': _selectedCategory,
        'Tanggal': DateTime.now().toIso8601String(),
      };

      await context.read<OrmawaProvider>().addFinance(payload);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Transaksi berhasil dicatat');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal mencatat transaksi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Catat Transaksi',
            subtitle: 'Buku Kas & Keuangan',
            variant: AppBarVariant.ormawa,
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
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jenis Transaksi',
                          style: BkuTheme.textBadge.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: BkuTheme.textHeading,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeCard(
                              'Pemasukan',
                              'pemasukan',
                              Icons.arrow_downward_rounded,
                              BkuTheme.emerald,
                              BkuTheme.emeraldSoft,
                              BkuTheme.emeraldBorder,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeCard(
                              'Pengeluaran',
                              'pengeluaran',
                              Icons.arrow_upward_rounded,
                              BkuTheme.rose,
                              BkuTheme.roseSoft,
                              BkuTheme.roseBorder,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sumber Dana',
                          style: BkuTheme.textBadge.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: BkuTheme.textHeading,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSourceCard('Kas Mandiri', 'organisasi', Icons.account_balance_wallet_outlined),
                            const SizedBox(width: 8),
                            _buildSourceCard('Pagu Kampus', 'kampus', Icons.assured_workload_outlined),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BkuTextField(
                          label: 'Deskripsi / Keterangan *',
                          hint: 'Contoh: Iuran Kas Bulan Mei',
                          controller: _descriptionController,
                          prefixIcon: const Icon(Icons.edit_note_rounded, size: 20, color: BkuTheme.textMuted),
                        ),
                        const SizedBox(height: 14),
                        BkuTextField(
                          label: 'Nominal (Rp) *',
                          hint: '0',
                          controller: _amountController,
                          prefixIcon: const Icon(Icons.payments_outlined, size: 20, color: BkuTheme.textMuted),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Kategori Transaksi',
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        BkuDropdown<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: BkuTheme.textCardTitle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                        const SizedBox(height: 24),
                        BkuButton.primary(
                          text: 'Simpan Transaksi',
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: Icons.check_circle_outline_rounded,
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String label, String value, IconData icon, Color color, Color bg, Color border) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? bg : BkuTheme.borderSubtle,
            borderRadius: BkuTheme.r12,
            border: Border.all(
              color: isSelected ? border : BkuTheme.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : BkuTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: BkuTheme.textCardTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : BkuTheme.textHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(String label, String value, IconData icon) {
    final isSelected = _selectedSource == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSource = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? BkuTheme.primarySoft : BkuTheme.borderSubtle,
            borderRadius: BkuTheme.r12,
            border: Border.all(
              color: isSelected ? BkuTheme.primary : BkuTheme.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? BkuTheme.primary : BkuTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: BkuTheme.textCardTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? BkuTheme.primaryDark : BkuTheme.textHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}