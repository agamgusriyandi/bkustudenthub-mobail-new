import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OrmawaJadwalDetailScreen extends StatelessWidget {
  final dynamic kegiatan;

  const OrmawaJadwalDetailScreen({super.key, required this.kegiatan});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return AppColors.success;
      case 'selesai':
        return AppColors.neutral500;
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = kegiatan;
    final statusColor = _getStatusColor(k.status);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'DETAIL KEGIATAN',
            subtitle: 'INFORMASI JADWAL',
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
                          color: AppColors.onSurface.withAlpha(12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                k.judul ?? '-',
                                style: AppTextStyles.titleLg
                                    .copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(15),
                                borderRadius: AppRadius.radiusSm,
                              ),
                              child: Text(
                                (k.status ?? '-'),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(context, 'DETAIL', [
                    if (k.deskripsi != null && k.deskripsi!.isNotEmpty)
                      _buildInfoRow('Deskripsi', k.deskripsi!),
                    if (k.lokasi != null && k.lokasi!.isNotEmpty)
                      _buildInfoRow('Lokasi', k.lokasi!),
                    if (k.tanggalMulai != null)
                      _buildInfoRow('Tanggal Mulai', k.tanggalMulai!),
                    if (k.tanggalSelesai != null)
                      _buildInfoRow('Tanggal Selesai', k.tanggalSelesai!),
                    if (k.pjKegiatan != null && k.pjKegiatan!.isNotEmpty)
                      _buildInfoRow('PJ Kegiatan', k.pjKegiatan!),
                    if (k.sumberDana != null && k.sumberDana!.isNotEmpty)
                      _buildInfoRow('Sumber Dana', k.sumberDana!),
                    if (k.estimasiDana != null && k.estimasiDana! > 0)
                      _buildInfoRow(
                          'Estimasi Dana', 'Rp ${k.estimasiDana!.toStringAsFixed(0)}'),
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
          if (!provider.hasPermission('edit_events')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditKegiatanScreen(kegiatan: k),
              ),
            ),
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
            label: Text('Edit',
                style: TextStyle(
                    color: context.appColors.onPrimary,
                    fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.neutral600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMd
                    .copyWith(fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class EditKegiatanScreen extends StatefulWidget {
  final dynamic kegiatan;
  const EditKegiatanScreen({super.key, required this.kegiatan});

  @override
  State<EditKegiatanScreen> createState() => _EditKegiatanScreenState();
}

class _EditKegiatanScreenState extends State<EditKegiatanScreen> {
  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;
  late String _selectedStatus;
  bool _isSubmitting = false;

  final List<String> _statuses = [
    'Dijadwalkan',
    'Berlangsung',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.kegiatan.judul ?? '');
    _deskripsiController = TextEditingController(text: widget.kegiatan.deskripsi ?? '');
    _lokasiController = TextEditingController(text: widget.kegiatan.lokasi ?? '');
    _selectedStatus = widget.kegiatan.status ?? 'Dijadwalkan';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final data = {
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _lokasiController.text,
        'status': _selectedStatus,
      };
      await context
          .read<OrmawaProvider>()
          .updateAgenda(widget.kegiatan.id.toString(), data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Kegiatan berhasil diperbarui');
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
        title: 'EDIT KEGIATAN',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('JUDUL KEGIATAN'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _judulController, hint: 'Judul'),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('DESKRIPSI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
                controller: _deskripsiController,
                hint: 'Deskripsi...',
                maxLines: 3),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('LOKASI'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(controller: _lokasiController, hint: 'Lokasi'),
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
                    : Text('SIMPAN PERUBAHAN',
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
      ),
    );
  }
}
