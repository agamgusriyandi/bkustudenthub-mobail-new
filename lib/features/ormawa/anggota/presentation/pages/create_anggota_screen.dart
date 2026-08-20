import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
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
      backgroundColor: BkuTheme.scaffoldBg,
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
                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        borderRadius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BkuTextField(
                              label: 'Nomor Induk Mahasiswa (NIM) *',
                              hint: 'Masukkan NIM mahasiswa',
                              controller: _nimController,
                              prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: BkuTheme.textPlaceholder),
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Nama Lengkap *',
                              hint: 'Masukkan nama lengkap',
                              controller: _namaController,
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: BkuTheme.textPlaceholder),
                            ),
                            const SizedBox(height: 14),
                            BkuDropdown<String>(
                              label: 'Jabatan / Peran *',
                              value: _selectedRole,
                              items: roles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role, style: BkuTheme.textBodyRegular.copyWith(fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedRole = val);
                              },
                            ),
                            const SizedBox(height: 14),
                            BkuDropdown<String>(
                              label: 'Divisi / Departemen *',
                              value: _selectedDivision,
                              items: divisions.map((div) {
                                return DropdownMenuItem(
                                  value: div,
                                  child: Text(div, style: BkuTheme.textBodyRegular.copyWith(fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDivision = val);
                              },
                            ),
                            const SizedBox(height: 24),
                            BkuButton.primary(
                              text: 'Simpan Data Anggota',
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
          );
        },
      ),
    );
  }
}