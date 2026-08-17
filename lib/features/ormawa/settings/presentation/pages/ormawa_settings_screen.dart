import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaSettingsScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaSettingsScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaSettingsScreen> createState() => _OrmawaSettingsScreenState();
}

class _OrmawaSettingsScreenState extends State<OrmawaSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;

  final _namaController = TextEditingController();
  final _singkatanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _visiController = TextEditingController();
  final _misiController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  final _namaBankController = TextEditingController();
  final _noRekeningController = TextEditingController();
  final _namaRekeningController = TextEditingController();

  String _logoUrl = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _singkatanController.dispose();
    _deskripsiController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    _namaBankController.dispose();
    _noRekeningController.dispose();
    _namaRekeningController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings([bool isRefresh = false]) async {
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }
    final provider = context.read<OrmawaProvider>();
    await provider.getOrmawaSettings();
    final d = provider.ormawaSettings;

    if (mounted) {
      setState(() {
        _namaController.text = d['Nama'] ?? d['nama'] ?? '';
        _singkatanController.text = d['Singkatan'] ?? d['singkatan'] ?? '';
        _deskripsiController.text = d['Deskripsi'] ?? d['deskripsi'] ?? '';
        _visiController.text = d['Visi'] ?? d['visi'] ?? '';
        _misiController.text = d['Misi'] ?? d['misi'] ?? '';
        _emailController.text = d['Email'] ?? d['email'] ?? '';
        _phoneController.text = d['Phone'] ?? d['phone'] ?? d['Kontak'] ?? '';
        _instagramController.text = d['Instagram'] ?? d['instagram'] ?? '';
        _websiteController.text = d['Website'] ?? d['website'] ?? '';
        _namaBankController.text = d['NamaBank'] ?? d['nama_bank'] ?? '';
        _noRekeningController.text = d['NoRekening'] ?? d['no_rekening'] ?? d['Rekening'] ?? d['rekening'] ?? '';
        _namaRekeningController.text = d['NamaRekening'] ?? d['nama_rekening'] ?? '';
        _logoUrl = d['LogoURL'] ?? d['logo_url'] ?? d['Logo'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Potong Logo Ormawa',
              toolbarColor: const Color(0xFF2563EB),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Potong Logo Ormawa',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null && mounted) {
          setState(() => _isUploadingLogo = true);
          final provider = context.read<OrmawaProvider>();
          final uploadedUrl = await provider.uploadFile(croppedFile.path);

          if (uploadedUrl != null && mounted) {
            setState(() {
              _logoUrl = uploadedUrl;
            });
            await _saveSettings(silent: true);
            if (mounted) {
              AppSnackbar.showSuccess(context, 'Foto / Logo ormawa berhasil diperbarui');
            }
          } else if (mounted) {
            AppSnackbar.showError(context, 'Gagal mengunggah gambar logo');
          }
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Gagal mengunggah foto: $e');
        }
      } finally {
        if (mounted) setState(() => _isUploadingLogo = false);
      }
    }
  }

  Future<void> _removeLogo() async {
    setState(() {
      _logoUrl = '';
    });
    await _saveSettings(silent: true);
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Foto logo ormawa dihapus');
    }
  }

  Future<void> _saveSettings({bool silent = false}) async {
    setState(() => _isSaving = true);
    try {
      final payload = {
        'Nama': _namaController.text.trim(),
        'Singkatan': _singkatanController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'Visi': _visiController.text.trim(),
        'Misi': _misiController.text.trim(),
        'LogoURL': _logoUrl,
        'Email': _emailController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Instagram': _instagramController.text.trim(),
        'Website': _websiteController.text.trim(),
        'NamaBank': _namaBankController.text.trim(),
        'NoRekening': _noRekeningController.text.trim(),
        'Rekening': _noRekeningController.text.trim(),
        'NamaRekening': _namaRekeningController.text.trim(),
      };

      await context.read<OrmawaProvider>().updateOrmawaSettings(payload);
      if (mounted && !silent) {
        AppSnackbar.showSuccess(context, 'Pengaturan organisasi berhasil disimpan!');
      }
    } catch (e) {
      if (mounted && !silent) {
        AppSnackbar.showError(context, 'Gagal menyimpan perubahan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _computeLocalCompleteness() {
    final fields = [
      _namaController.text.trim(),
      _singkatanController.text.trim(),
      _deskripsiController.text.trim(),
      _visiController.text.trim(),
      _misiController.text.trim(),
      _logoUrl.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _instagramController.text.trim(),
      _noRekeningController.text.trim(),
    ];
    final filled = fields.where((f) => f.isNotEmpty).length;
    return ((filled / fields.length) * 100).round();
  }

  int _computeLocalContactCount() {
    final channels = [
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _instagramController.text.trim(),
      _websiteController.text.trim(),
    ];
    return channels.where((c) => c.isNotEmpty).length;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final completeness = _computeLocalCompleteness();
    final contactCount = _computeLocalContactCount();
    final hasBank = _noRekeningController.text.trim().isNotEmpty;
    final ormawaId = context.watch<OrmawaProvider>().ormawaId ?? '1';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => _loadSettings(true),
        color: const Color(0xFF2563EB),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Pengaturan Ormawa',
              subtitle: 'Konfigurasi Lembaga',
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      FadeInAnimation(
                        delay: 0.1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF94A3B8).withAlpha(20),
                                blurRadius: 16,
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_getGreeting()},',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _singkatanController.text.isNotEmpty ? _singkatanController.text : (_namaController.text.isNotEmpty ? _namaController.text : 'ORMAWA'),
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Kelengkapan: $completeness%',
                                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Pusat konfigurasi kelembagaan, branding identitas organisasi, kontak informasi publik, dan rekening kegiatan resmi.',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _loadSettings(true),
                                      icon: const Icon(Icons.refresh_rounded, size: 14),
                                      label: const Text('Refresh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0F172A),
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isSaving ? null : () => _saveSettings(),
                                      icon: _isSaving
                                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.save_rounded, size: 14),
                                      label: const Text('Simpan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      FadeInAnimation(
                        delay: 0.2,
                        child: Row(
                          children: [
                            _buildStatCard(
                              '$completeness%',
                              'Kelengkapan',
                              completeness >= 80 ? 'Sangat lengkap' : 'Perlu diisi',
                              Icons.account_circle_rounded,
                              completeness >= 80 ? const Color(0xFF059669) : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCard(
                              'Aktif',
                              'Status Lembaga',
                              'ID #$ormawaId',
                              Icons.verified_user_rounded,
                              const Color(0xFF059669),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInAnimation(
                        delay: 0.25,
                        child: Row(
                          children: [
                            _buildStatCard(
                              '$contactCount / 4',
                              'Saluran Info',
                              'Email, WA, IG, Web',
                              Icons.contact_mail_rounded,
                              const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCard(
                              hasBank ? 'Terdaftar' : 'Belum Ada',
                              'Rekening Kas',
                              hasBank ? (_namaBankController.text.isNotEmpty ? _namaBankController.text : 'Bank Aktif') : 'Perlu diisi',
                              Icons.account_balance_rounded,
                              hasBank ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInAnimation(
                        delay: 0.3,
                        child: _buildSectionCard(
                          title: 'Identitas & Branding Lembaga',
                          subtitle: 'Foto/logo resmi, nama lembaga, singkatan, dan profil organisasi.',
                          icon: Icons.badge_rounded,
                          iconColor: const Color(0xFF2563EB),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: _logoUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: ApiGate.getImageUrl(_logoUrl),
                                                fit: BoxFit.contain,
                                                placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                errorWidget: (ctx, url, err) => const Icon(Icons.corporate_fare_rounded, size: 28, color: Color(0xFF94A3B8)),
                                              )
                                            : const Icon(Icons.corporate_fare_rounded, size: 28, color: Color(0xFF94A3B8)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Foto / Logo Resmi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 2),
                                          const Text('PNG, JPG, WebP (Maks 5MB)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF2563EB),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: _isUploadingLogo
                                                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                      : Text(_logoUrl.isNotEmpty ? 'Ganti Foto' : 'Unggah Foto', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                                ),
                                              ),
                                              if (_logoUrl.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: _removeLogo,
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFF1F2),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: const Color(0xFFFECDD3)),
                                                    ),
                                                    child: const Text('Hapus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              _buildTextField(
                                label: 'NAMA RESMI ORMAWA',
                                controller: _namaController,
                                hint: 'Contoh: Badan Eksekutif Mahasiswa (BEM)',
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'SINGKATAN / AKRONIM',
                                controller: _singkatanController,
                                hint: 'Contoh: BEM UBK',
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'NARASI PROFIL LEMBAGA',
                                controller: _deskripsiController,
                                hint: 'Tuliskan deskripsi singkat mengenai latar belakang, peran, dan kegiatan utama organisasi...',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      FadeInAnimation(
                        delay: 0.35,
                        child: _buildSectionCard(
                          title: 'Filosofi Visi & Misi Strategis',
                          subtitle: 'Landasan gerak dan arah tujuan kepengurusan organisasi mahasiswa.',
                          icon: Icons.explore_rounded,
                          iconColor: const Color(0xFF059669),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'PERNYATAAN VISI ORGANISASI',
                                controller: _visiController,
                                hint: 'Tuliskan visi besar organisasi untuk periode kepengurusan ini...',
                                maxLines: 3,
                                prefixIcon: Icons.visibility_rounded,
                                iconColor: const Color(0xFF2563EB),
                              ),
                              const SizedBox(height: 12),

                              _buildTextField(
                                label: 'POIN-POIN MISI STRATEGIS',
                                controller: _misiController,
                                hint: 'Tuliskan butir-butir misi yang akan dilaksanakan (pisahkan baris baru)...',
                                maxLines: 4,
                                prefixIcon: Icons.task_alt_rounded,
                                iconColor: const Color(0xFF059669),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      FadeInAnimation(
                        delay: 0.4,
                        child: _buildSectionCard(
                          title: 'Kontak & Saluran Informasi Publik',
                          subtitle: 'Informasi kontak yang ditampilkan pada direktori kemahasiswaan.',
                          icon: Icons.contact_mail_rounded,
                          iconColor: const Color(0xFF2563EB),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'EMAIL RESMI ORGANISASI',
                                controller: _emailController,
                                hint: 'bem@student.bku.ac.id',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.alternate_email_rounded,
                                iconColor: const Color(0xFFE11D48),
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'NOMOR KONTAK (WHATSAPP)',
                                controller: _phoneController,
                                hint: '0812-3456-7890',
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.call_rounded,
                                iconColor: const Color(0xFF059669),
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'AKUN INSTAGRAM',
                                controller: _instagramController,
                                hint: '@bem_bku',
                                prefixIcon: Icons.photo_camera_rounded,
                                iconColor: const Color(0xFF7C3AED),
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'ALAMAT WEBSITE / LINKTREE',
                                controller: _websiteController,
                                hint: 'https://bem.bku.ac.id',
                                keyboardType: TextInputType.url,
                                prefixIcon: Icons.language_rounded,
                                iconColor: const Color(0xFF0284C7),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      FadeInAnimation(
                        delay: 0.45,
                        child: _buildSectionCard(
                          title: 'Rekening Penerimaan Dana Kegiatan',
                          subtitle: 'Rekening resmi organisasi untuk pencairan dana kegiatan & pagu.',
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFFD97706),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'NAMA BANK / LEMBAGA',
                                controller: _namaBankController,
                                hint: 'Bank Mandiri / BNI / BCA / BSI',
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'NOMOR REKENING',
                                controller: _noRekeningController,
                                hint: '1234-5678-9012',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),

                              _buildTextField(
                                label: 'ATAS NAMA REKENING',
                                controller: _namaRekeningController,
                                hint: 'BEM UNIVERSITAS BHAKTI KENCANA',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInAnimation(
                        delay: 0.5,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _saveSettings(),
                            icon: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_rounded, size: 18),
                            label: const Text('Simpan Perubahan Organisasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s140),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String val, String label, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 1),
            Text(sub, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 12, color: iconColor ?? const Color(0xFF64748B)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFE11D48))),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }


}
