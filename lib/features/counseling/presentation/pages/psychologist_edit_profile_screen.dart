import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:image_picker/image_picker.dart';
import "package:bkuhub_mobile/core/providers/theme_provider.dart";
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

class PsychologistEditProfileScreen extends StatefulWidget {
  const PsychologistEditProfileScreen({super.key});

  @override
  State<PsychologistEditProfileScreen> createState() =>
      _PsychologistEditProfileScreenState();
}

class _PsychologistEditProfileScreenState
    extends State<PsychologistEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isUploading = false;

  late TextEditingController _namaCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _spesialisasiCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _lokasiCtrl;
  late TextEditingController _bahasaCtrl;

  @override
  void initState() {
    super.initState();
    final profile = context.read<PsychologistDashboardProvider>().profile;
    _namaCtrl = TextEditingController(text: profile?.name ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    _spesialisasiCtrl = TextEditingController(
      text: profile?.specialization ?? '',
    );
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _lokasiCtrl = TextEditingController(text: profile?.location ?? '');
    _bahasaCtrl = TextEditingController(text: profile?.languages ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _spesialisasiCtrl.dispose();
    _bioCtrl.dispose();
    _lokasiCtrl.dispose();
    _bahasaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final provider = context.read<PsychologistDashboardProvider>();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        await provider.uploadProfileAvatar(pickedFile.path);
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => CustomDialog(
                  title: 'Berhasil',
                  content: 'Foto profil berhasil diperbarui',
                  isSuccess: true,
                  cancelText: '',
                  confirmText: 'Tutup',
                  onCancel: () {},
                  onConfirm: () => Navigator.pop(ctx),
                ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => CustomDialog(
                  title: 'Gagal',
                  content: 'Gagal mengunggah foto profil: $e',
                  isDestructive: true,
                  cancelText: '',
                  confirmText: 'Tutup',
                  onCancel: () {},
                  onConfirm: () => Navigator.pop(ctx),
                ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<PsychologistDashboardProvider>();
    try {
      await provider.updateProfileData({
        'nama': _namaCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'no_hp': _phoneCtrl.text.trim(),
        'spesialisasi': _spesialisasiCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'lokasi': _lokasiCtrl.text.trim(),
        'bahasa': _bahasaCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Gagal memperbarui profil: $e');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Edit Profil',
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
                    // Avatar
                    Center(
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      context
                                          .read<ThemeProvider>()
                                          .primaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                image:
                                    context
                                                .watch<
                                                  PsychologistDashboardProvider
                                                >()
                                                .profile
                                                ?.profileImageUrl
                                                .isNotEmpty ==
                                            true
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            (() {
                                              final url = ApiGate.getImageUrl(
                                                context
                                                    .read<
                                                      PsychologistDashboardProvider
                                                    >()
                                                    .profile!
                                                    .profileImageUrl,
                                              );
                                              final version =
                                                  context
                                                      .watch<
                                                        PsychologistDashboardProvider
                                                      >()
                                                      .avatarVersion;
                                              return url.contains('?')
                                                  ? '$url&v=$version'
                                                  : '$url?v=$version';
                                            })(),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child:
                                  context
                                              .watch<
                                                PsychologistDashboardProvider
                                              >()
                                              .profile
                                              ?.profileImageUrl
                                              .isNotEmpty ==
                                          true
                                      ? null
                                      : Center(
                                        child: Text(
                                          _namaCtrl.text.trim().isEmpty
                                              ? 'P'
                                              : _namaCtrl.text
                                                  .trim()
                                                  .split(' ')
                                                  .take(2)
                                                  .map(
                                                    (w) =>
                                                        w.isNotEmpty
                                                            ? w[0].toUpperCase()
                                                            : '',
                                                  )
                                                  .join(),
                                          style: AppTextStyles.titleLg.copyWith(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                            ),
                            if (_isUploading)
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(20),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionLabel('Informasi Dasar'),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildField(
                        controller: _namaCtrl,
                        label: 'Nama Lengkap',
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                      ),
                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_rounded,
                        iconColor: const Color(0xFF10B981),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!v.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      _buildField(
                        controller: _phoneCtrl,
                        label: 'No. HP',
                        icon: Icons.phone_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        keyboardType: TextInputType.phone,
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionLabel('Informasi Profesional'),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildField(
                        controller: _spesialisasiCtrl,
                        label: 'Spesialisasi',
                        icon: Icons.workspace_premium_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        hint: 'Contoh: Psikologi Klinis',
                      ),
                      _buildField(
                        controller: _lokasiCtrl,
                        label: 'Lokasi / Ruangan',
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFFEF4444),
                        hint: 'Contoh: Ruang Konseling A',
                      ),
                      _buildField(
                        controller: _bahasaCtrl,
                        label: 'Bahasa',
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF06B6D4),
                        hint: 'Contoh: Indonesia, Inggris',
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionLabel('Bio / Deskripsi'),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildField(
                        controller: _bioCtrl,
                        label: 'Bio',
                        icon: Icons.notes_rounded,
                        iconColor: const Color(0xFF6366F1),
                        maxLines: 4,
                        hint: 'Ceritakan sedikit tentang diri Anda...',
                      ),
                    ]),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Text(
                                  'Simpan Perubahan',
                                  style: AppTextStyles.titleMd.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleMd.copyWith(
        color: AppColors.neutral900,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return BkuCard(child: Column(children: children));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: BkuTextField(
        label: label,
        hint: hint,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        prefixIcon: Icon(icon, color: iconColor ?? AppColors.neutral500, size: 20),
      ),
    );
  }
}
