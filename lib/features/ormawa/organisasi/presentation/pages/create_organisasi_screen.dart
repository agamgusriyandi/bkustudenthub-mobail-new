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

class CreateOrganisasiScreen extends StatefulWidget {
  const CreateOrganisasiScreen({super.key});

  @override
  State<CreateOrganisasiScreen> createState() => _CreateOrganisasiScreenState();
}

class _CreateOrganisasiScreenState extends State<CreateOrganisasiScreen> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _visiController = TextEditingController();
  final _misiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tahunBerdiriController = TextEditingController();
  String _selectedStatus = 'aktif';
  bool _isSubmitting = false;

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

      await context.read<OrmawaProvider>().createOrganisasi(data);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Organisasi berhasil ditambahkan');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal menyimpan organisasi: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Tambah Organisasi',
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
                    hintText: 'Contoh: BEM Fakultas Ilmu Komputer',
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
              text: 'Simpan Organisasi',
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