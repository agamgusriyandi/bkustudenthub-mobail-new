import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
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
              toolbarColor: OrmawaTheme.primaryDark,
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
          AppSnackbar.showError(context, 'Gagal mengunggah foto');
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
      final provider = context.read<OrmawaProvider>();
      final canManageSettings = provider.hasPermission('ormawa.settings.manage, ormawa.settings.update, ormawa.core.update');
      final canManageFinance = provider.hasPermission('ormawa.finance.update, ormawa.finance.create, ormawa.finance.manage, view_finance');

      if (canManageFinance) {
        final bankPayload = {
          'nama_bank': _namaBankController.text.trim(),
          'no_rekening': _noRekeningController.text.trim(),
          'nama_rekening': _namaRekeningController.text.trim(),
        };
        await provider.updateBankAccount(bankPayload);
      }

      if (canManageSettings) {
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
        await provider.updateOrmawaSettings(payload);
      }

      if (mounted && !silent) {
        AppSnackbar.showSuccess(
          context,
          canManageSettings
              ? 'Pengaturan organisasi berhasil disimpan!'
              : 'Rekening bank organisasi berhasil disimpan!',
        );
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final ormawaId = provider.ormawaId?.toString() ?? '—';
    final completeness = _computeLocalCompleteness();
    final contactCount = _computeLocalContactCount();
    final hasBank = _noRekeningController.text.trim().isNotEmpty;
    final bankName = _namaBankController.text.trim();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => _loadSettings(true),
        color: OrmawaTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Pengaturan Ormawa',
              subtitle: 'Pusat Konfigurasi Kelembagaan',
              info: 'Kelengkapan: $completeness%',
              expandedHeight: 140.0,
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Kelengkapan Profil',
                              value: '$completeness%',
                              icon: Icons.account_circle_rounded,
                              badgeText: completeness == 100 ? '100% Sempurna' : (completeness >= 80 ? 'LENGKAP' : 'BELUM LENGKAP'),
                              badgeColor: completeness >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                              subtitle: completeness >= 80 ? 'Profil sangat lengkap' : 'Lengkapi data lembaga',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Status Lembaga',
                              value: 'Aktif',
                              icon: Icons.verified_user_rounded,
                              badgeText: 'ID #$ormawaId',
                              badgeColor: const Color(0xFF059669),
                              subtitle: 'Terdaftar resmi di BKU',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Saluran Informasi',
                              value: '$contactCount / 4',
                              icon: Icons.contact_mail_rounded,
                              badgeText: 'Kanal Aktif',
                              badgeColor: const Color(0xFF7C3AED),
                              subtitle: 'Email, WA, IG, Web',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Rekening Kas',
                              value: hasBank ? 'Terdaftar' : 'Belum Ada',
                              icon: Icons.account_balance_rounded,
                              badgeText: hasBank ? 'AKTIF' : 'PERLU DIISI',
                              badgeColor: hasBank ? const Color(0xFF059669) : const Color(0xFFD97706),
                              subtitle: hasBank ? (bankName.isNotEmpty ? bankName : 'Bank Resmi') : 'Belum diatur',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.badge_rounded, color: Color(0xFF2563EB), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Identitas & Branding Lembaga',
                                        style: OrmawaTheme.textSectionTitle,
                                      ),
                                      const Text(
                                        'Foto resmi, nama lembaga, dan profil publik organisasi.',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: const Color(0xFFEFF6FF),
                                        border: Border.all(
                                          color: const Color(0xFFBFDBFE),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: _logoUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: ApiGate.getImageUrl(_logoUrl),
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) => const Icon(
                                                  Icons.groups_rounded,
                                                  color: Color(0xFF2563EB),
                                                  size: 36,
                                                ),
                                                placeholder: (_, __) =>
                                                    Container(color: const Color(0xFFF1F5F9)),
                                              )
                                            : const Icon(
                                                Icons.groups_rounded,
                                                color: Color(0xFF2563EB),
                                                size: 36,
                                              ),
                                      ),
                                    ),
                                    if (_isUploadingLogo)
                                      const Positioned.fill(
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(strokeWidth: 2.5),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _singkatanController.text.isNotEmpty
                                            ? _singkatanController.text
                                            : 'Logo Organisasi',
                                        style: OrmawaTheme.textCardTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'PNG, JPG, WebP maksimal 5MB (Rasio 1:1)',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          BkuBounceButton(
                                            onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.add_photo_alternate_rounded, size: 13, color: Colors.white),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _logoUrl.isNotEmpty ? 'Ganti Foto' : 'Unggah Foto',
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_logoUrl.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            BkuBounceButton(
                                              onTap: _removeLogo,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFF1F2),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFFECDD3)),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFE11D48)),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      'Hapus',
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                                                    ),
                                                  ],
                                                ),
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
                            const SizedBox(height: 14),
                            OrmawaTextField(
                              label: 'Nama Resmi Ormawa *',
                              hintText: 'e.g. Badan Eksekutif Mahasiswa',
                              controller: _namaController,
                              prefixIcon: Icons.account_balance_rounded,
                              prefixIconColor: const Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Singkatan / Akronim *',
                              hintText: 'e.g. BEM KEMA UBK',
                              controller: _singkatanController,
                              prefixIcon: Icons.short_text_rounded,
                              prefixIconColor: const Color(0xFF0284C7),
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Narasi Profil Lembaga',
                              hintText: 'Tuliskan profil singkat latar belakang dan fokus organisasi...',
                              controller: _deskripsiController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.explore_rounded, color: Color(0xFF059669), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filosofi Visi & Misi Strategis',
                                        style: OrmawaTheme.textSectionTitle,
                                      ),
                                      const Text(
                                        'Landasan gerak dan arah tujuan kepengurusan.',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OrmawaTextField(
                              label: 'Pernyataan Visi Organisasi',
                              hintText: 'Tuliskan visi besar organisasi untuk periode kepengurusan...',
                              controller: _visiController,
                              prefixIcon: Icons.visibility_rounded,
                              prefixIconColor: const Color(0xFF2563EB),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Poin-Poin Misi Strategis',
                              hintText: 'Tuliskan butir-butir misi yang akan dilaksanakan (pisahkan baris baru)...',
                              controller: _misiController,
                              prefixIcon: Icons.task_alt_rounded,
                              prefixIconColor: const Color(0xFF059669),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.contact_mail_rounded, color: Color(0xFF7C3AED), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kontak & Saluran Informasi Publik',
                                        style: OrmawaTheme.textSectionTitle,
                                      ),
                                      const Text(
                                        'Informasi kontak direktori kemahasiswaan.',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OrmawaTextField(
                              label: 'Email Resmi Organisasi',
                              hintText: 'bem@student.bku.ac.id',
                              controller: _emailController,
                              prefixIcon: Icons.alternate_email_rounded,
                              prefixIconColor: const Color(0xFFE11D48),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nomor Kontak (WhatsApp)',
                              hintText: '0812-3456-7890',
                              controller: _phoneController,
                              prefixIcon: Icons.call_rounded,
                              prefixIconColor: const Color(0xFF059669),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Akun Instagram Resmi',
                              hintText: '@bem_bku',
                              controller: _instagramController,
                              prefixIcon: Icons.photo_camera_rounded,
                              prefixIconColor: const Color(0xFF9333EA),
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Alamat Website / Linktree',
                              hintText: 'https://bem.bku.ac.id',
                              controller: _websiteController,
                              prefixIcon: Icons.language_rounded,
                              prefixIconColor: const Color(0xFF0284C7),
                              keyboardType: TextInputType.url,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF059669), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rekening Penerimaan Dana Kegiatan',
                                        style: OrmawaTheme.textSectionTitle,
                                      ),
                                      const Text(
                                        'Rekening resmi untuk pencairan dana proposal & kas.',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                OrmawaBadge(
                                  text: hasBank ? 'TERDAFTAR' : 'BELUM DIATUR',
                                  variant: hasBank ? OrmawaBadgeVariant.success : OrmawaBadgeVariant.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OrmawaTextField(
                              label: 'Nama Bank / Lembaga Keuangan',
                              hintText: 'Bank Mandiri / BNI / BRI / BCA / BSI',
                              controller: _namaBankController,
                              prefixIcon: Icons.account_balance_outlined,
                              prefixIconColor: const Color(0xFF0D9488),
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nomor Rekening',
                              hintText: '1234-5678-9012',
                              controller: _noRekeningController,
                              prefixIcon: Icons.credit_card_rounded,
                              prefixIconColor: const Color(0xFF2563EB),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Atas Nama Rekening',
                              hintText: 'BEM UNIVERSITAS BHAKTI KENCANA',
                              controller: _namaRekeningController,
                              prefixIcon: Icons.person_outline_rounded,
                              prefixIconColor: const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OrmawaButton(
                          text: provider.hasPermission('ormawa.settings.manage, ormawa.settings.update, ormawa.core.update')
                              ? 'SIMPAN PERUBAHAN ORGANISASI'
                              : 'SIMPAN REKENING BANK',
                          isLoading: _isSaving,
                          onPressed: _isSaving ? null : () => _saveSettings(),
                          icon: Icons.save_rounded,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s100),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}