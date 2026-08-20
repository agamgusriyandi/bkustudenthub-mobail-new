import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreateKeuanganScreen extends StatefulWidget {
  const CreateKeuanganScreen({super.key});

  @override
  State<CreateKeuanganScreen> createState() => _CreateKeuanganScreenState();
}

class _CreateKeuanganScreenState extends State<CreateKeuanganScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan';
  String _selectedSource = 'organisasi';
  String _selectedCategory = 'Lainnya';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Iuran Anggota',
    'Sponsor',
    'Donasi',
    'Konsumsi',
    'Perlengkapan',
    'Transportasi',
    'Sewa Tempat',
    'Operasional',
    'Pencairan Proposal',
    'Lainnya',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_descriptionController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Deskripsi dan nominal transaksi wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nominal = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      final data = {
        'type': _selectedType,
        'nominal': nominal,
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'sumber': _selectedSource,
        'date': DateTime.now().toIso8601String(),
      };

      await context.read<OrmawaProvider>().addFinance(data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Transaksi kas berhasil dicatat');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan transaksi: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const BkuAppBar(
            title: 'Catat Kas',
            subtitle: 'Tambah Transaksi Keuangan Ormawa',
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: OrmawaTheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.swap_vert_rounded, size: 15, color: OrmawaTheme.primary),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Jenis & Sumber Dana',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeButton(
                                label: 'Pemasukan',
                                value: 'pemasukan',
                                icon: Icons.arrow_downward_rounded,
                                activeColor: const Color(0xFF059669),
                                activeBg: const Color(0xFFECFDF5),
                                activeBorder: const Color(0xFFA7F3D0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTypeButton(
                                label: 'Pengeluaran',
                                value: 'pengeluaran',
                                icon: Icons.arrow_upward_rounded,
                                activeColor: const Color(0xFFE11D48),
                                activeBg: const Color(0xFFFFF1F2),
                                activeBorder: const Color(0xFFFFE4E6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSourceButton(
                                label: 'Kas Mandiri',
                                value: 'organisasi',
                                icon: Icons.account_balance_wallet_rounded,
                                activeColor: const Color(0xFF4338CA),
                                activeBg: const Color(0xFFEEF2FF),
                                activeBorder: const Color(0xFFC7D2FE),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSourceButton(
                                label: 'Pagu Kampus',
                                value: 'kampus',
                                icon: Icons.assured_workload_rounded,
                                activeColor: const Color(0xFF0284C7),
                                activeBg: const Color(0xFFE0F2FE),
                                activeBorder: const Color(0xFFBAE6FD),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: OrmawaTheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.receipt_long_rounded, size: 15, color: OrmawaTheme.primary),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Detail Transaksi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'DESKRIPSI / KETERANGAN *',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Iuran Kas Bulan Mei',
                              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.description_outlined, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'NOMINAL TRANSAKSI (RP) *',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontFamily: 'monospace'),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Kategori Anggaran',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
                              items: _categories.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val ?? 'Lainnya'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _isSubmitting ? null : _handleSubmit,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: OrmawaTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: OrmawaTheme.primary.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan Transaksi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required IconData icon,
    required Color activeColor,
    required Color activeBg,
    required Color activeBorder,
  }) {
    final isSelected = _selectedType == value;

    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeBorder : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? activeColor : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? activeColor : const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required String label,
    required String value,
    required IconData icon,
    required Color activeColor,
    required Color activeBg,
    required Color activeBorder,
  }) {
    final isSelected = _selectedSource == value;

    return InkWell(
      onTap: () => setState(() => _selectedSource = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeBorder : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? activeColor : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}