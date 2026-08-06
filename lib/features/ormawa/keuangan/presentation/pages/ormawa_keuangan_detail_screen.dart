import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OrmawaKeuanganDetailScreen extends StatelessWidget {
  final dynamic transaksi;

  const OrmawaKeuanganDetailScreen({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final isIncome = t.type == 'pemasukan';
    final isCampus = t.sumber == 'kampus';

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'DETAIL TRANSAKSI',
            subtitle: 'INFORMASI KEUANGAN',
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusXl,
                      border: Border.all(color: AppColors.neutral200),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.onSurface.withAlpha(12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: (isIncome ? AppColors.success : AppColors.error)
                                    .withAlpha(15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isIncome ? AppColors.success : AppColors.error,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.description,
                                    style: AppTextStyles.bodyMd
                                        .copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    DateFormat('dd MMMM yyyy, HH:mm', 'id')
                                        .format(t.date),
                                    style: AppTextStyles.labelSm
                                        .copyWith(color: AppColors.neutral500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(t.nominal)}',
                          style: AppTextStyles.titleLg.copyWith(
                            color: isIncome ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(context, 'INFORMASI TRANSAKSI', [
                    _buildInfoRow('Tipe', isIncome ? 'Pemasukan' : 'Pengeluaran'),
                    _buildInfoRow('Kategori', t.category),
                    _buildInfoRow('Sumber', isCampus ? 'Pagu Kampus' : 'Kas Mandiri'),
                    _buildInfoRow('Nominal',
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(t.nominal)),
                    _buildInfoRow('Tanggal',
                        DateFormat('dd MMMM yyyy', 'id').format(t.date)),
                  ]),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission('edit_finance')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditKeuanganScreen(transaksi: t),
              ),
            ),
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Edit',
              style: TextStyle(
                  color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 10,
              )),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600)),
          Text(value, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class EditKeuanganScreen extends StatefulWidget {
  final dynamic transaksi;
  const EditKeuanganScreen({super.key, required this.transaksi});

  @override
  State<EditKeuanganScreen> createState() => _EditKeuanganScreenState();
}

class _EditKeuanganScreenState extends State<EditKeuanganScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  String _selectedType = 'pemasukan';
  String _selectedSource = 'organisasi';
  String _selectedCategory = 'Lainnya';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Iuran Anggota', 'Sponsor', 'Konsumsi', 'Perlengkapan',
    'Transportasi', 'Sewa Tempat', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transaksi;
    _descriptionController = TextEditingController(text: t.description);
    _amountController = TextEditingController(
        text: t.nominal.toStringAsFixed(0));
    _selectedType = t.type;
    _selectedSource = t.sumber;
    _selectedCategory = t.category;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'type': _selectedType,
        'nominal': double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'sumber': _selectedSource,
      };
      await context.read<OrmawaProvider>().addFinance(data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Transaksi berhasil diperbarui');
        context.pop();
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
        title: 'EDIT TRANSAKSI',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JENIS TRANSAKSI'),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildTypeCard('PEMASUKAN', 'pemasukan', Icons.arrow_downward_rounded, AppColors.success),
                const SizedBox(width: AppSpacing.lg),
                _buildTypeCard('PENGELUARAN', 'pengeluaran', Icons.arrow_upward_rounded, AppColors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('SUMBER DANA'),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildTypeCard('KAS MANDIRI', 'organisasi', Icons.payments_rounded, AppColors.success),
                const SizedBox(width: AppSpacing.lg),
                _buildTypeCard('PAGU KAMPUS', 'kampus', Icons.assured_workload_rounded, AppColors.info),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _descriptionController, hint: 'Deskripsi'),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('NOMINAL (RP)'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _amountController, hint: '0', isNumber: true),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('KATEGORI'),
            const SizedBox(height: AppSpacing.md),
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
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
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
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: context.appColors.onPrimary, strokeWidth: 2))
                    : Text('SIMPAN PERUBAHAN',
                        style: TextStyle(
                            color: context.appColors.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            color: AppColors.neutral600, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10));
  }

  Widget _buildTypeCard(String label, String value, IconData icon, Color color) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(15) : AppColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: isSelected ? color : AppColors.neutral300, width: 2),
          ),
          child: Column(children: [
            Icon(icon, color: isSelected ? color : AppColors.neutral500, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(label,
                style: AppTextStyles.labelSm
                    .copyWith(color: isSelected ? color : AppColors.neutral500, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
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
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: isNumber ? 'Rp ' : null,
          prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral800),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
