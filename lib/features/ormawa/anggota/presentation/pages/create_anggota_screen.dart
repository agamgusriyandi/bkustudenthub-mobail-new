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

class CreateAnggotaScreen extends StatefulWidget {
  const CreateAnggotaScreen({super.key});

  @override
  State<CreateAnggotaScreen> createState() => _CreateAnggotaScreenState();
}

class _CreateAnggotaScreenState extends State<CreateAnggotaScreen> {
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  String _selectedRole = 'Anggota';
  String _selectedDivision = 'Umum';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_nimController.text.trim().isEmpty || _namaController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'NIM dan Nama Lengkap wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'NIM': _nimController.text.trim(),
        'Nama': _namaController.text.trim(),
        'Role': _selectedRole,
        'Divisi': _selectedDivision == 'Umum' ? '' : _selectedDivision,
        'Status': 'Aktif',
      };

      await context.read<OrmawaProvider>().addMember(data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Data anggota berhasil ditambahkan');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal menambahkan anggota');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          final roles = provider.roles.map((r) => r.name).toList();
          if (!roles.contains('Anggota')) roles.add('Anggota');
          final divisions = [
            'Umum',
            ...provider.divisions.map((d) => d.name),
          ];

          return CustomScrollView(
            slivers: [
              const BkuAppBar(
                title: 'Tambah Anggota',
                subtitle: 'Pendaftaran Struktur & Anggota',
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
                            OrmawaTextField(
                              label: 'Nomor Induk Mahasiswa (NIM) *',
                              hintText: 'Masukkan NIM mahasiswa',
                              controller: _nimController,
                              prefixIcon: Icons.badge_outlined,
                            ),
                            SizedBox(height: 14),
                            OrmawaTextField(
                              label: 'Nama Lengkap *',
                              hintText: 'Masukkan nama lengkap',
                              controller: _namaController,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Jabatan / Peran *',
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
                                  value: _selectedRole,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: OrmawaTheme.primary),
                                  items: roles.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: OrmawaTheme.textHeading,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedRole = val!),
                                ),
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Divisi / Departemen *',
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
                                  value: _selectedDivision,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: OrmawaTheme.primary),
                                  items: divisions.map((div) {
                                    return DropdownMenuItem(
                                      value: div,
                                      child: Text(
                                        div,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: OrmawaTheme.textHeading,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedDivision = val!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OrmawaButton(
                                text: 'SIMPAN DATA ANGGOTA',
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
          );
        },
      ),
    );
  }
}
