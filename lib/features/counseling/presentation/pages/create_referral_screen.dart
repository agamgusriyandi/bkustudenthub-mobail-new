import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/referral_provider.dart';

class CreateReferralScreen extends StatefulWidget {
  final String? studentId;

  const CreateReferralScreen({super.key, this.studentId});

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  int? _selectedStudentId;
  String _selectedType = 'Medis';
  final List<String> _referralTypes = ['Medis', 'Akademik'];

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _selectedStudentId = int.tryParse(widget.studentId!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counselingProvider = context.read<CounselingProvider>();
      if (counselingProvider.patients.isEmpty) {
        counselingProvider.loadPatients();
      }
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _targetCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      bottomNavigationBar: _buildBottomActions(),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Buat Rujukan Baru',
            variant: AppBarVariant.psychologist,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Pilih Pasien'),
                          const SizedBox(height: AppSpacing.lg),
                          _buildStudentSelector(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Detail Rujukan'),
                          const SizedBox(height: AppSpacing.s20),
                          _buildDropdownField('Tipe Rujukan', _referralTypes),
                          const SizedBox(height: AppSpacing.s20),
                          _buildTextField(
                            label: 'Alasan Rujukan',
                            hint:
                                'Tulis deskripsi klinis singkat dan alasan perlunya rujukan...',
                            controller: _reasonCtrl,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Alasan rujukan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.s20),
                          _buildTextField(
                            label: 'Pihak Tujuan',
                            hint: 'Contoh: RS Jiwa Dr. Soeharto Heerdjan',
                            controller: _targetCtrl,
                            icon: Icons.business_rounded,
                            iconColor: context.appColors.warning,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Pihak tujuan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.s20),
                          _buildTextField(
                            label: 'Email Tujuan',
                            hint: 'Contoh: rujukan@rsj.com',
                            controller: _emailCtrl,
                            icon: Icons.email_rounded,
                            iconColor: context.appColors.success,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email tujuan wajib diisi';
                              }
                              final emailRegex = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        color: AppColors.neutral900,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Consumer<CounselingProvider>(
      builder: (context, provider, child) {
        if (provider.patientsLoading) {
          return const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList());
        }

        final patients = provider.patients;
        if (patients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(10),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.error.withAlpha(30)),
            ),
            child: Text(
              'Tidak ada mahasiswa aktif untuk dirujuk.',
              style: AppTextStyles.bodyMd.copyWith(color: context.appColors.error),
            ),
          );
        }

        // Check if preselected student exists in list
        final hasPreselected =
            widget.studentId != null &&
            patients.any((p) => p['id'].toString() == widget.studentId);

        if (hasPreselected) {
          final patient = patients.firstWhere(
            (p) => p['id'].toString() == widget.studentId,
          );
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral500.withAlpha(40)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person_rounded, color: context.appColors.onPrimary),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name']?.toString() ?? '',
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NIM: ${patient['nim']?.toString() ?? ''}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.lock_rounded, color: AppColors.neutral500, size: 18),
              ],
            ),
          );
        }

        // Ensure initialValue exists in items to prevent Dropdown crash
        final bool isIdValid = patients.any(
          (p) => (int.tryParse(p['id'].toString()) ?? 0) == _selectedStudentId,
        );

        return BkuDropdown<int>(
          initialValue: isIdValid ? _selectedStudentId : null,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.neutral50,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: context.appColors.info,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          hint: 'Pilih Pasien',
          validator: (value) {
            if (value == null) {
              return 'Harap pilih mahasiswa';
            }
            return null;
          },
          items:
              patients.map((patient) {
                final id = int.tryParse(patient['id'].toString()) ?? 0;
                final name = patient['name']?.toString() ?? '';
                final nim = patient['nim']?.toString() ?? '';
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    '$name ($nim)',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStudentId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    Color? iconColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral500,
            ),
            filled: true,
            fillColor: AppColors.neutral50,
            prefixIcon:
                icon != null
                    ? Icon(icon, color: iconColor ?? AppColors.primary, size: 20)
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuDropdown<String>(
          initialValue: _selectedType,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.neutral50,
            prefixIcon: Icon(
              Icons.category_rounded,
              color: context.appColors.info,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.neutral500.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items:
              items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedType = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Consumer<ReferralProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isCreating;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
          color: context.appColors.surface,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => context.pop(),

                    child: Text(
                      'Batal',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.success,
                      foregroundColor: context.appColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.br10,
                      ),
                    ),
                    child:
                        isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: context.appColors.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Simpan Rujukan',
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w900,
                                color: context.appColors.onPrimary,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStudentId == null) {
        AppSnackbar.showWarning(
          context,
          'Harap pilih mahasiswa terlebih dahulu',
        );
        return;
      }

      final provider = context.read<ReferralProvider>();
      final success = await provider.createReferral(
        mahasiswaId: _selectedStudentId!,
        tipe: _selectedType,
        alasan: _reasonCtrl.text.trim(),
        pihakTujuan: _targetCtrl.text.trim(),
        emailTujuan: _emailCtrl.text.trim(),
      );

      if (mounted) {
        if (success) {
          AppSnackbar.showSuccess(context, 'Rujukan berhasil dibuat!');
          context.pop();
        } else {
          String errorMessage =
              provider.error ?? 'Gagal membuat rujukan. Silakan coba lagi.';
          if (errorMessage.toLowerCase().contains('out of range')) {
            errorMessage =
                'Terjadi kesalahan sistem (Data pasien tidak ditemukan/tidak valid). Silakan coba lagi.';
          } else if (errorMessage.toLowerCase().contains('index')) {
            errorMessage = 'Terjadi kesalahan indeks data. Silakan coba lagi.';
          }

          AppSnackbar.showError(context, errorMessage);
        }
      }
    }
  }
}
