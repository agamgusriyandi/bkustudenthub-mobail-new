import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

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

      final provider = context.read<StudentProvider>();
      if (widget.organization == null) {
        await provider.addOrganizationHistory(org);
      } else {
        await provider.updateOrganizationHistory(org.id, org);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => CustomDialog(
              title: 'Berhasil',
              content: 'Pengajuan riwayat organisasi berhasil ditambahkan.',
              isSuccess: true,
              cancelText: '',
              confirmText: 'Kembali',
              confirmColor: const Color(0xFF10B981),
              onCancel: () {},
              onConfirm: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, size: 19, color: const Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: const BorderSide(
                  color: Color(0xFF334155),
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
              ),
            ),
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          DropdownButtonFormField<String>(
            initialValue: value,
            items:
                items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, size: 19, color: const Color(0xFF64748B)),
              border: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.br14,
                borderSide: const BorderSide(
                  color: Color(0xFF334155),
                  width: 1.8,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.s18),
      padding: AppSpacing.padding18,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.br22,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(18),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(sectionIcon, size: 18, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s18),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                const Color(0xFF2563EB),
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
                const Color(0xFF0D9488),
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
                const Color(0xFFE11D48),
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
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusLg,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withAlpha(40),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: context.appColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusLg,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
