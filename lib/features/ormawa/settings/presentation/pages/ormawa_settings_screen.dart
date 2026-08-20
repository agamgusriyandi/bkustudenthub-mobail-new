import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
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
              toolbarColor: BkuTheme.primaryDark,
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
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => _loadSettings(true),
        color: BkuTheme.primary,
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
                              badgeText: completeness == 100 ? '100% Sempurna' : (completeness >= 80 ? 'Lengkap' : 'Belum Lengkap'),
                              badgeColor: completeness >= 80 ? BkuTheme.emerald : BkuTheme.amber,
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
                              badgeColor: BkuTheme.emerald,
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
                              badgeColor: BkuTheme.purple,
                              subtitle: 'Email, WA, IG, Web',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Rekening Kas',
                              value: hasBank ? 'Terdaftar' : 'Belum Ada',
                              icon: Icons.account_balance_rounded,
                              badgeText: hasBank ? 'Aktif' : 'Perlu Diisi',
                              badgeColor: hasBank ? BkuTheme.emerald : BkuTheme.amber,
                              subtitle: hasBank ? (bankName.isNotEmpty ? bankName : 'Bank Resmi') : 'Belum diatur',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.primarySoft,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: Icon(Icons.badge_rounded, color: BkuTheme.primary, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Identitas & Branding Lembaga',
                                        style: BkuTheme.textSectionTitle,
                                      ),
                                      Text(
                                        'Foto resmi, nama lembaga, dan profil publik organisasi.',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
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
                                        borderRadius: BkuTheme.r16,
                                        color: BkuTheme.primarySoft,
                                        border: Border.all(
                                          color: BkuTheme.primaryBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: _logoUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: ApiGate.getImageUrl(_logoUrl),
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) => Icon(
                                                  Icons.groups_rounded,
                                                  color: BkuTheme.primary,
                                                  size: 36,
                                                ),
                                                placeholder: (_, __) =>
                                                    Container(color: BkuTheme.borderSubtle),
                                              )
                                            : Icon(
                                                Icons.groups_rounded,
                                                color: BkuTheme.primary,
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
                                        style: BkuTheme.textCardTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PNG, JPG, WebP maksimal 5MB (Rasio 1:1)',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          BkuBounceButton(
                                            onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: BkuTheme.primary,
                                                borderRadius: BkuTheme.r8,
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
                                                  color: BkuTheme.roseSoft,
                                                  borderRadius: BkuTheme.r8,
                                                  border: Border.all(color: BkuTheme.roseBorder),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.delete_outline_rounded, size: 13, color: BkuTheme.rose),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      'Hapus',
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BkuTheme.rose),
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
                            BkuTextField(
                              label: 'Nama Resmi Ormawa *',
                              hint: 'e.g. Badan Eksekutif Mahasiswa',
                              controller: _namaController,
                              prefixIcon: Icon(Icons.account_balance_rounded, size: 18, color: BkuTheme.primary),
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Singkatan / Akronim *',
                              hint: 'e.g. BEM KEMA UBK',
                              controller: _singkatanController,
                              prefixIcon: Icon(Icons.short_text_rounded, size: 18, color: BkuTheme.sky),
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Narasi Profil Lembaga',
                              hint: 'Tuliskan profil singkat latar belakang dan fokus organisasi...',
                              controller: _deskripsiController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.emeraldSoft,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: const Icon(Icons.explore_rounded, color: BkuTheme.emerald, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filosofi Visi & Misi Strategis',
                                        style: BkuTheme.textSectionTitle,
                                      ),
                                      Text(
                                        'Landasan gerak dan arah tujuan kepengurusan.',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Pernyataan Visi Organisasi',
                              hint: 'Tuliskan visi besar organisasi untuk periode kepengurusan...',
                              controller: _visiController,
                              prefixIcon: Icon(Icons.visibility_rounded, size: 18, color: BkuTheme.primary),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Poin-Poin Misi Strategis',
                              hint: 'Tuliskan butir-butir misi yang akan dilaksanakan (pisahkan baris baru)...',
                              controller: _misiController,
                              prefixIcon: const Icon(Icons.task_alt_rounded, size: 18, color: BkuTheme.emerald),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.purpleSoft,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: const Icon(Icons.contact_mail_rounded, color: BkuTheme.purple, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kontak & Saluran Informasi Publik',
                                        style: BkuTheme.textSectionTitle,
                                      ),
                                      Text(
                                        'Informasi kontak direktori kemahasiswaan.',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Email Resmi Organisasi',
                              hint: 'bem@student.bku.ac.id',
                              controller: _emailController,
                              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: BkuTheme.rose),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Nomor Kontak (WhatsApp)',
                              hint: '0812-3456-7890',
                              controller: _phoneController,
                              prefixIcon: const Icon(Icons.call_rounded, size: 18, color: BkuTheme.emerald),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Akun Instagram Resmi',
                              hint: '@bem_bku',
                              controller: _instagramController,
                              prefixIcon: const Icon(Icons.photo_camera_rounded, size: 18, color: BkuTheme.purple),
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Alamat Website / Linktree',
                              hint: 'https://bem.bku.ac.id',
                              controller: _websiteController,
                              prefixIcon: Icon(Icons.language_rounded, size: 18, color: BkuTheme.sky),
                              keyboardType: TextInputType.url,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      BkuCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: BkuTheme.emeraldSoft,
                                    borderRadius: BkuTheme.r8,
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: BkuTheme.emerald, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rekening Penerimaan Dana Kegiatan',
                                        style: BkuTheme.textSectionTitle,
                                      ),
                                      Text(
                                        'Rekening resmi untuk pencairan dana proposal & kas.',
                                        style: BkuTheme.textCaption.copyWith(fontSize: 10, color: BkuTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                BkuStatusBadge(
                                  status: hasBank ? BkuStatus.success : BkuStatus.neutral,
                                  customText: hasBank ? 'Terdaftar' : 'Belum Diatur',
                                  showIcon: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            BkuTextField(
                              label: 'Nama Bank / Lembaga Keuangan',
                              hint: 'Bank Mandiri / BNI / BRI / BCA / BSI',
                              controller: _namaBankController,
                              prefixIcon: const Icon(Icons.account_balance_outlined, size: 18, color: BkuTheme.teal),
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Nomor Rekening',
                              hint: '1234-5678-9012',
                              controller: _noRekeningController,
                              prefixIcon: Icon(Icons.credit_card_rounded, size: 18, color: BkuTheme.primary),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            BkuTextField(
                              label: 'Atas Nama Rekening',
                              hint: 'BEM Universitas Bhakti Kencana',
                              controller: _namaRekeningController,
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: BkuTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: BkuButton.primary(
                          text: provider.hasPermission('ormawa.settings.manage, ormawa.settings.update, ormawa.core.update')
                              ? 'Simpan Perubahan Organisasi'
                              : 'Simpan Rekening Bank',
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