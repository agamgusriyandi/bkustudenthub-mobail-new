import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';

class AddOrganisasiScreen extends StatefulWidget {
  final OrganizationHistory? organization;

  const AddOrganisasiScreen({super.key, this.organization});

  @override
  State<AddOrganisasiScreen> createState() => _AddOrganisasiScreenState();
}

class _AddOrganisasiScreenState extends State<AddOrganisasiScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _apresiasiController = TextEditingController();
  final _tahunMulaiController = TextEditingController();
  final _tahunSelesaiController = TextEditingController();

  String _tipe = 'UKM';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.organization != null) {
      _namaController.text = widget.organization!.namaOrganisasi;
      _jabatanController.text = widget.organization!.jabatan;
      _deskripsiController.text = widget.organization!.deskripsiKegiatan;
      _apresiasiController.text = widget.organization!.apresiasi;
      _tipe = widget.organization!.tipe;
      _tahunMulaiController.text = widget.organization!.periodeMulai.toString();
      _tahunSelesaiController.text =
          widget.organization!.periodeSelesai?.toString() ?? '';
    } else {
      _tipe = 'UKM';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jabatanController.dispose();
    _deskripsiController.dispose();
    _apresiasiController.dispose();
    _tahunMulaiController.dispose();
    _tahunSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final tahunMulai = int.tryParse(_tahunMulaiController.text);
    if (tahunMulai == null) {
      AppSnackbar.showError(context, 'Tahun Mulai harus diisi dengan angka');
      return;
    }

    final tahunSelesai =
        _tahunSelesaiController.text.isNotEmpty
            ? int.tryParse(_tahunSelesaiController.text)
            : null;

    if (tahunSelesai != null && tahunSelesai < tahunMulai) {
      AppSnackbar.showError(
        context,
        'Tahun Selesai tidak boleh kurang dari Tahun Mulai',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final org = OrganizationHistory(
        id:
            widget.organization?.id ??
            'ORG${DateTime.now().millisecondsSinceEpoch}',
        namaOrganisasi: _namaController.text,
        tipe: _tipe,
        jabatan: _jabatanController.text,
        periodeMulai: tahunMulai,
        periodeSelesai: tahunSelesai,
        deskripsiKegiatan: _deskripsiController.text,
        apresiasi:
            _apresiasiController.text.isNotEmpty
                ? _apresiasiController.text
                : '',
        statusVerifikasi: widget.organization?.statusVerifikasi ?? 'Menunggu',
        achievements: widget.organization?.achievements ?? [],
      );

      final provider = context.read<OrganizationProvider>();
      if (widget.organization == null) {
        await provider.addOrganizationHistory(org);
      } else {
        await provider.updateOrganizationHistory(org.id, org);
      }

      if (!mounted) return;

      BkuDialog.show(
        context: context,
        type: BkuDialogType.success,
        title: 'Berhasil',
        message: 'Pengajuan riwayat organisasi berhasil ditambahkan.',
        primaryButtonText: 'Kembali',
        onPrimaryPressed: () {
          context.pop();
          context.pop();
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: BkuTheme.textBadge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: BkuTheme.textPrimary,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: BkuTheme.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          BkuTextField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            keyboardType: keyboardType,
            hint: hint,
            prefixIcon: Icon(icon, size: 19, color: BkuTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: BkuTheme.textBadge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: BkuTheme.textPrimary,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: BkuTheme.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          BkuDropdown<String>(
            initialValue: value,
            items:
                items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: BkuTheme.textBodyRegular.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: BkuTheme.surfaceLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, size: 19, color: BkuTheme.textMuted),
              border: OutlineInputBorder(
                borderRadius: BkuTheme.r12,
                borderSide: BorderSide(color: BkuTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BkuTheme.r12,
                borderSide: BorderSide(color: BkuTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BkuTheme.r12,
                borderSide: BorderSide(
                  color: BkuTheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData sectionIcon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BkuTheme.r10,
                  border: Border.all(color: accentColor.withAlpha(40)),
                ),
                child: Icon(sectionIcon, size: 18, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: BkuTheme.textCardTitle.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Laporkan Keaktifan Organisasi',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                'Informasi Organisasi',
                Icons.business_rounded,
                BkuTheme.indigo,
                [
                  _buildField(
                    controller: _namaController,
                    label: 'Nama Organisasi',
                    hint: 'Contoh: Himpunan Mahasiswa Informatika',
                    icon: Icons.business_rounded,
                    isRequired: true,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama organisasi wajib diisi' : null,
                  ),
                  _buildDropdown(
                    label: 'Tipe Organisasi',
                    value: _tipe,
                    items: const [
                      'UKM',
                      'Himpunan Prodi',
                      'BEM',
                      'DPM',
                      'Komunitas',
                      'Lainnya',
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _tipe = val);
                    },
                    icon: Icons.category_rounded,
                    isRequired: true,
                  ),
                  _buildField(
                    controller: _jabatanController,
                    label: 'Jabatan',
                    hint: 'Contoh: Ketua, Anggota',
                    icon: Icons.person_rounded,
                    isRequired: true,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Jabatan wajib diisi' : null,
                  ),
                ],
              ),
              _buildSectionCard(
                'Periode Jabatan',
                Icons.date_range_rounded,
                BkuTheme.primary,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _tahunMulaiController,
                          label: 'Tahun Mulai',
                          hint: 'Contoh: 2026',
                          icon: Icons.calendar_today_rounded,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wajib diisi';
                            }
                            final year = int.tryParse(value);
                            if (year == null || value.length != 4) {
                              return 'Format salah';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildField(
                          controller: _tahunSelesaiController,
                          label: 'Tahun Selesai',
                          hint: 'Contoh: 2026',
                          icon: Icons.calendar_today_rounded,
                          isRequired: false,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final year = int.tryParse(value);
                              if (year == null || value.length != 4) {
                                return 'Format salah';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSectionCard(
                'Detail Kegiatan',
                Icons.assignment_outlined,
                BkuTheme.amber,
                [
                  _buildField(
                    controller: _deskripsiController,
                    label: 'Deskripsi Kegiatan',
                    hint: 'Deskripsikan kontribusi atau peran Anda...',
                    icon: Icons.description_rounded,
                    maxLines: 4,
                    isRequired: false,
                  ),
                  _buildField(
                    controller: _apresiasiController,
                    label: 'Apresiasi/Penghargaan (Opsional)',
                    hint: 'Contoh: Anggota Terbaik Periode 2025',
                    icon: Icons.emoji_events_rounded,
                    isRequired: false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BkuButton(
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitForm,
                text: 'Simpan',
                icon: Icons.save_rounded,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
