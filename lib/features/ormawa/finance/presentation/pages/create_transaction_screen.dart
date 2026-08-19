import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
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
      backgroundColor: OrmawaTheme.scaffoldBg,
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
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JENIS TRANSAKSI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: OrmawaTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeCard(
                              'Pemasukan',
                              'pemasukan',
                              Icons.arrow_downward_rounded,
                              OrmawaTheme.statusSuccessText,
                              OrmawaTheme.statusSuccessBg,
                            ),
                            SizedBox(width: 8),
                            _buildTypeCard(
                              'Pengeluaran',
                              'pengeluaran',
                              Icons.arrow_upward_rounded,
                              OrmawaTheme.statusDangerText,
                              OrmawaTheme.statusDangerBg,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'SUMBER DANA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: OrmawaTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSourceCard('Kas Mandiri', 'organisasi', Icons.account_balance_wallet_outlined),
                            const SizedBox(width: 8),
                            _buildSourceCard('Pagu Kampus', 'kampus', Icons.assured_workload_outlined),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OrmawaTextField(
                          label: 'Deskripsi / Keterangan *',
                          hintText: 'Contoh: Iuran Kas Bulan Mei',
                          controller: _descriptionController,
                          prefixIcon: Icons.edit_note_rounded,
                        ),
                        const SizedBox(height: 14),
                        OrmawaTextField(
                          label: 'Nominal (Rp) *',
                          hintText: '0',
                          controller: _amountController,
                          prefixIcon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Kategori Transaksi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: OrmawaTheme.textHeading,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: OrmawaTheme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: OrmawaTheme.primary),
                              items: _categories.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: OrmawaTheme.textHeading,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OrmawaButton(
                            text: 'SIMPAN TRANSAKSI',
                            isLoading: _isSubmitting,
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            icon: Icons.check_circle_outline_rounded,
                          ),
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

  Widget _buildTypeCard(String label, String value, IconData icon, Color color, Color bg) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? bg : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : OrmawaTheme.textMuted),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : OrmawaTheme.textHeading,
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
            color: isSelected ? OrmawaTheme.primarySoft : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? OrmawaTheme.primary : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? OrmawaTheme.primary : OrmawaTheme.textMuted),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? OrmawaTheme.primaryDark : OrmawaTheme.textHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
