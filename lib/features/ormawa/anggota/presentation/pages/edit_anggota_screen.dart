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

class EditAnggotaScreen extends StatefulWidget {
  final dynamic member;
  const EditAnggotaScreen({super.key, required this.member});

  @override
  State<EditAnggotaScreen> createState() => _EditAnggotaScreenState();
}

class _EditAnggotaScreenState extends State<EditAnggotaScreen> {
  late String _selectedRole;
  late String _selectedDivision;
  late String _selectedStatus;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSubmitting = false;

  final List<String> _statuses = ['Aktif', 'Nonaktif', 'Alumni', 'Cuti'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role.isEmpty ? 'Anggota' : widget.member.role;
    _selectedDivision = widget.member.division.isEmpty ? 'Umum' : widget.member.division;
    _selectedStatus = widget.member.status;
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    BkuLoadingDialog.show(context);

    try {
      final data = {
        'MahasiswaID': int.tryParse(widget.member.mahasiswaId.toString()),
        'Role': _selectedRole,
        'Divisi': _selectedDivision == 'Umum' ? '' : _selectedDivision,
        'Status': _selectedStatus,
        'Email': _emailController.text.trim(),
        'Phone': _phoneController.text.trim(),
      };

      await context.read<OrmawaProvider>().updateMember(widget.member.id.toString(), data);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Data anggota berhasil diperbarui');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, 'Gagal memperbarui anggota');
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
          if (!roles.contains(_selectedRole)) roles.add(_selectedRole);
          final divisions = [
            'Umum',
            ...provider.divisions.map((d) => d.name),
          ];
          if (!divisions.contains(_selectedDivision)) divisions.add(_selectedDivision);

          return CustomScrollView(
            slivers: [
              BkuAppBar(
                title: 'Edit Anggota',
                subtitle: widget.member.name,
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
                            const SizedBox(height: 14),
                            BkuDropdown<String>(
                              label: 'Status Keanggotaan *',
                              value: _selectedStatus,
                              items: _statuses.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status, style: BkuTheme.textBodyRegular.copyWith(fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Email Anggota',
                              hint: 'nama@example.com',
                              controller: _emailController,
                              prefixIcon: const Icon(Icons.email_outlined, size: 18, color: BkuTheme.textPlaceholder),
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Nomor Telepon / WhatsApp',
                              hint: '08123456789',
                              controller: _phoneController,
                              prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: BkuTheme.textPlaceholder),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),
                            BkuButton.primary(
                              text: 'Simpan Perubahan',
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              icon: Icons.save_rounded,
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