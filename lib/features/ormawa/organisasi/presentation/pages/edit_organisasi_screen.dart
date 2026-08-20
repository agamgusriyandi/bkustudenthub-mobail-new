import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';

class EditOrganisasiScreen extends StatefulWidget {
  final OrmawaOrganisasi organisasi;
  const EditOrganisasiScreen({super.key, required this.organisasi});

  @override
  State<EditOrganisasiScreen> createState() => _EditOrganisasiScreenState();
}

class _EditOrganisasiScreenState extends State<EditOrganisasiScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _visiController;
  late final TextEditingController _misiController;
  late final TextEditingController _alamatController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _instagramController;
  late final TextEditingController _tahunBerdiriController;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final o = widget.organisasi;
    _namaController = TextEditingController(text: o.nama);
    _deskripsiController = TextEditingController(text: o.deskripsi);
    _visiController = TextEditingController(text: o.visi ?? '');
    _misiController = TextEditingController(text: o.misi ?? '');
    _alamatController = TextEditingController(text: o.alamat ?? '');
    _emailController = TextEditingController(text: o.email ?? '');
    _websiteController = TextEditingController(text: o.website ?? '');
    _instagramController = TextEditingController(text: o.instagram ?? '');
    _tahunBerdiriController = TextEditingController(text: o.tahunBerdiri ?? '');
    _selectedStatus = o.status.toLowerCase().isNotEmpty ? o.status.toLowerCase() : 'aktif';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _tahunBerdiriController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_namaController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama organisasi wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'Nama': _namaController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'Visi': _visiController.text.trim().isNotEmpty ? _visiController.text.trim() : null,
        'Misi': _misiController.text.trim().isNotEmpty ? _misiController.text.trim() : null,
        'Alamat': _alamatController.text.trim().isNotEmpty ? _alamatController.text.trim() : null,
        'Email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        'Website': _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
        'Instagram': _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
        'TahunBerdiri': _tahunBerdiriController.text.trim().isNotEmpty ? _tahunBerdiriController.text.trim() : null,
        'Status': _selectedStatus,
      }..removeWhere((_, v) => v == null);

      await context.read<OrmawaProvider>().updateOrganisasi(
            widget.organisasi.id.toString(),
            data,
          );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Organisasi berhasil diperbarui');
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
      backgroundColor: OrmawaTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Edit Organisasi',
        subtitle: 'Data Organisasi Mahasiswa',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrmawaCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_rounded, size: 18, color: OrmawaTheme.primary),
                      const SizedBox(width: 8),
                      Text('Informasi Umum', style: OrmawaTheme.textSectionTitle),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OrmawaTextField(
                    label: 'Nama Organisasi *',
                    controller: _namaController,
                    hintText: 'Contoh: BEM Universitas',
                    prefixIcon: Icons.business_rounded,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Deskripsi',
                    controller: _deskripsiController,
                    hintText: 'Deskripsi singkat organisasi...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Visi',
                    controller: _visiController,
                    hintText: 'Visi organisasi...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Misi',
                    controller: _misiController,
                    hintText: 'Misi organisasi...',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OrmawaCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_mail_outlined, size: 18, color: OrmawaTheme.primary),
                      const SizedBox(width: 8),
                      Text('Kontak & Media Sosial', style: OrmawaTheme.textSectionTitle),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OrmawaTextField(
                    label: 'Alamat Sekretariat',
                    controller: _alamatController,
                    hintText: 'Gedung / Ruang sekretariat...',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'email@organisasi.ac.id',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Website',
                    controller: _websiteController,
                    hintText: 'https://organisasi.ac.id',
                    prefixIcon: Icons.language_rounded,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Instagram',
                    controller: _instagramController,
                    hintText: '@organisasi',
                    prefixIcon: Icons.camera_alt_outlined,
                  ),
                  const SizedBox(height: 12),
                  OrmawaTextField(
                    label: 'Tahun Berdiri',
                    controller: _tahunBerdiriController,
                    hintText: '2020',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calendar_today_rounded,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Organisasi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: OrmawaTheme.textHeading,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: OrmawaTheme.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'aktif', child: Text('Aktif', style: TextStyle(fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            onChanged: (val) => setState(() => _selectedStatus = val ?? 'aktif'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OrmawaButton(
              text: 'Simpan Perubahan',
              icon: Icons.save_rounded,
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
              width: double.infinity,
            ),
            const SizedBox(height: AppSpacing.s140),
          ],
        ),
      ),
    );
  }
}