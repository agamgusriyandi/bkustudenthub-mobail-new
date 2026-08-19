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

  @override
  Widget build(BuildContext context) {
    final completeness = _computeLocalCompleteness();
    final contactCount = _computeLocalContactCount();
    final hasBank = _noRekeningController.text.trim().isNotEmpty;

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
              subtitle: 'Konfigurasi Lembaga',
              expandedHeight: 125.0,
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
                              icon: Icons.pie_chart_rounded,
                              badgeText: completeness >= 80 ? 'LENGKAP' : 'BELUM LENGKAP',
                              badgeColor: completeness >= 80 ? OrmawaTheme.primary : const Color(0xFFD97706),
                              subtitle: '$completeness% data terisi',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OrmawaKpiCard(
                              title: 'Kanal Kontak',
                              value: '$contactCount',
                              icon: Icons.contact_mail_rounded,
                              badgeText: 'TERHUBUNG',
                              badgeColor: const Color(0xFF0284C7),
                              subtitle: '$contactCount saluran aktif',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logo & Identitas Visual',
                              style: OrmawaTheme.textSectionTitle,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: OrmawaTheme.primarySoft,
                                        border: Border.all(
                                          color: OrmawaTheme.primaryBorder,
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
                                                  color: OrmawaTheme.primary,
                                                  size: 32,
                                                ),
                                                placeholder: (_, __) =>
                                                    Container(color: const Color(0xFFF1F5F9)),
                                              )
                                            : Icon(
                                                Icons.groups_rounded,
                                                color: OrmawaTheme.primary,
                                                size: 32,
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
                                      Text(
                                        'Format PNG/JPG maksimal 2MB',
                                        style: OrmawaTheme.textCaption,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          BkuBounceButton(
                                            onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: OrmawaTheme.primarySoft,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: OrmawaTheme.primaryBorder),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.upload_rounded, size: 13, color: OrmawaTheme.primaryDark),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Unggah Logo',
                                                    style: OrmawaTheme.textBadge.copyWith(color: OrmawaTheme.primaryDark),
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
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: OrmawaTheme.statusDangerBg,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.delete_outline_rounded, size: 14, color: OrmawaTheme.statusDangerText),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      OrmawaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Dasar',
                              style: OrmawaTheme.textSectionTitle,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nama Lengkap Organisasi *',
                              hintText: 'e.g. Badan Eksekutif Mahasiswa',
                              controller: _namaController,
                              prefixIcon: Icons.account_balance_rounded,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Singkatan / Akronim *',
                              hintText: 'e.g. BEM KEMA UBK',
                              controller: _singkatanController,
                              prefixIcon: Icons.short_text_rounded,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Deskripsi Profil Organisasi',
                              hintText: 'Tuliskan profil singkat lembaga...',
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
                            Text(
                              'Visi & Misi',
                              style: OrmawaTheme.textSectionTitle,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Visi Organisasi',
                              hintText: 'Tuliskan visi kepengurusan...',
                              controller: _visiController,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Misi Organisasi',
                              hintText: 'Tuliskan butir-butir misi (pisahkan baris)...',
                              controller: _misiController,
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
                            Text(
                              'Saluran Komunikasi & Kontak',
                              style: OrmawaTheme.textSectionTitle,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Email Resmi Organisasi',
                              hintText: 'bem@bku.ac.id',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nomor Telepon / WhatsApp',
                              hintText: '081234567890',
                              controller: _phoneController,
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Akun Instagram Resmi',
                              hintText: '@bem_bku',
                              controller: _instagramController,
                              prefixIcon: Icons.camera_alt_outlined,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Website / Linktree',
                              hintText: 'https://bem.bku.ac.id',
                              controller: _websiteController,
                              prefixIcon: Icons.language_rounded,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rekening Penerimaan Dana',
                                  style: OrmawaTheme.textSectionTitle,
                                ),
                                OrmawaBadge(
                                  text: hasBank ? 'TERHUBUNG' : 'BELUM DIATUR',
                                  variant: hasBank ? OrmawaBadgeVariant.success : OrmawaBadgeVariant.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nama Bank / Lembaga Keuangan',
                              hintText: 'Mandiri / BNI / BRI / BCA / BSI',
                              controller: _namaBankController,
                              prefixIcon: Icons.account_balance_outlined,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Nomor Rekening',
                              hintText: '1234-5678-9012',
                              controller: _noRekeningController,
                              prefixIcon: Icons.credit_card_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            OrmawaTextField(
                              label: 'Atas Nama Rekening',
                              hintText: 'BEM UNIVERSITAS BHAKTI KENCANA',
                              controller: _namaRekeningController,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OrmawaButton(
                          text: 'SIMPAN PERUBAHAN ORGANISASI',
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
