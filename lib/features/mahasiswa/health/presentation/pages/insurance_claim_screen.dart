import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:go_router/go_router.dart';

class InsuranceClaimScreen extends StatefulWidget {
  const InsuranceClaimScreen({super.key});

  @override
  State<InsuranceClaimScreen> createState() => _InsuranceClaimScreenState();
}

class _InsuranceClaimScreenState extends State<InsuranceClaimScreen> {
  @override
  Widget build(BuildContext context) {
    final student = context.watch<ProfileProvider>();
    final health = context.watch<HealthViewModel>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await health.refreshHealthData();
        },
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Klaim Asuransi',
              subtitle: 'PENGAJUAN & RIWAYAT KLAIM',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    if (student.isLoading)
                      const BkuShimmerList(itemCount: 3, itemHeight: 120)
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: BkuButton(
                          onPressed: () => _showInsuranceForm(context, student),
                          icon: Icons.shield_outlined,
                          text: 'Ajukan Klaim Baru',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s28),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: context.appColors.primary,
                              borderRadius: AppRadius.radiusXs,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Text(
                            'Riwayat Pengajuan Klaim',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: context.appColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (health.insuranceClaims.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 36,
                                color: AppColors.neutral400,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Belum ada riwayat pengajuan klaim',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...health.insuranceClaims.map(
                          (claim) =>
                              _buildInsuranceClaimCard(context, student, claim),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceClaimCard(
    BuildContext context,
    ProfileProvider student,
    InsuranceClaim claim,
  ) {
    final dateStr = DateFormat(
      'dd MMMM yyyy',
      'id',
    ).format(claim.tanggalKejadian);
    final formattedCost = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(claim.estimasiBiaya);

    String currentStatus = claim.status;
    String statusLabel = 'Menunggu Verifikasi';
    Color statusColor = context.watch<ThemeProvider>().colors.warning;

    if (currentStatus == 'APPROVED_TK' || currentStatus == 'APPROVED TK') {
      statusLabel = 'Disetujui Nakes';
      statusColor = context.appColors.success;
    } else if (currentStatus == 'APPROVED_FINAL' ||
        currentStatus == 'APPROVED FINAL' ||
        currentStatus == 'FINAL APPROVED' ||
        currentStatus == 'APPROVED') {
      statusLabel = 'Approved Final';
      statusColor = context.watch<ThemeProvider>().colors.success;
    } else if (currentStatus == 'REJECTED' || currentStatus == 'DITOLAK') {
      statusLabel = 'Ditolak';
      statusColor = Theme.of(context).colorScheme.error;
    } else if (currentStatus == 'PENDING' ||
        currentStatus == 'PENDING_VERIFICATION' ||
        currentStatus == 'PENDING VERIFICATION') {
      statusLabel = 'Menunggu Verifikasi';
      statusColor = context.watch<ThemeProvider>().colors.warning;
    } else if (currentStatus.isNotEmpty) {
      statusLabel = claim.status.replaceAll('_', ' '); // Clean fallback
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(2),
            blurRadius: 10,
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
              Text(
                claim.jenisProvider.replaceAll('_', ' '),
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.appColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCardInfoRow(Icons.calendar_today_rounded, 'Kejadian: $dateStr'),
          _buildCardInfoRow(
            Icons.location_on_rounded,
            'Faskes: ${claim.lokasiFaskes}',
          ),
          _buildCardInfoRow(
            Icons.payments_rounded,
            'Jumlah Klaim: $formattedCost',
          ),
          _buildCardInfoRow(
            Icons.description_rounded,
            'Kronologi: ${claim.deskripsi}',
          ),
          if (claim.catatanReview != null &&
              claim.catatanReview!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                'Catatan Peninjau: ${claim.catatanReview}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (claim.namaFile != null && claim.namaFile!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.attachment_rounded,
                    size: 14,
                    color: context.watch<ThemeProvider>().colors.success,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Expanded(
                    child: Text(
                      'Lampiran: ${claim.namaFile}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.watch<ThemeProvider>().colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.neutral200),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: BkuButton(
                  onPressed:
                      () => _uploadInsuranceDocumentPicker(
                        context,
                        student,
                        claim,
                      ),
                  icon: Icons.upload_file_rounded,
                  text: 'Unggah Berkas',
                ),
              ),
              if ((claim.status == 'APPROVED_TK' ||
                      claim.status == 'APPROVED_FINAL') &&
                  claim.suratPengantarUrl != null &&
                  claim.suratPengantarUrl!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: BkuButton(
                    onPressed: () async {
                      final token = AuthService().token;
                      final base =
                          ApiGate.baseUrl.endsWith('/api')
                              ? ApiGate.baseUrl.substring(
                                0,
                                ApiGate.baseUrl.length - 4,
                              )
                              : ApiGate.baseUrl;
                      String urlStr = claim.suratPengantarUrl!;
                      if (!urlStr.startsWith('http')) {
                        urlStr = '$base$urlStr';
                      }
                      if (urlStr.contains('?')) {
                        urlStr += '&token=$token';
                      } else {
                        urlStr += '?token=$token';
                      }
                      final uri = Uri.parse(urlStr);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      } else {
                        if (context.mounted) {
                          AppSnackbar.showError(
                            context,
                            'Gagal mengunduh surat pengantar',
                          );
                        }
                      }
                    },
                    icon: Icons.download_rounded,
                    text: 'Surat Pengantar',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.appColors.outline),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.onSurface, // requested by user
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadInsuranceDocumentPicker(
    BuildContext context,
    ProfileProvider student,
    InsuranceClaim claim,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Sumber File',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.appColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildOptionTile(
                  context,
                  icon: Icons.camera_alt_rounded,
                  title: 'Kamera',
                  subtitle: 'Ambil foto dokumen langsung',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      if (!context.mounted) return;
                      _processUpload(
                        context,
                        student,
                        claim.id,
                        pickedFile.path,
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildOptionTile(
                  context,
                  icon: Icons.photo_library_rounded,
                  title: 'Galeri Foto',
                  subtitle: 'Pilih foto dari galeri',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      if (!context.mounted) return;
                      _processUpload(
                        context,
                        student,
                        claim.id,
                        pickedFile.path,
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildOptionTile(
                  context,
                  icon: Icons.folder_rounded,
                  title: 'File Dokumen',
                  subtitle: 'Pilih file PDF, JPG, dll',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null) {
                      if (!context.mounted) return;
                      _processUpload(
                        context,
                        student,
                        claim.id,
                        result.files.single.path!,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: AppRadius.radiusLg,
          color: AppColors.neutral50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.primary.withAlpha(20),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(icon, color: context.appColors.primary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.neutral600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  void _processUpload(
    BuildContext context,
    ProfileProvider student,
    int claimId,
    String filePath,
  ) async {
    try {
      if (context.mounted) {
        BkuLoadingDialog.show(context, message: 'Mengunggah dokumen...');
      }
      await context.read<HealthViewModel>().uploadInsuranceFile(claimId, filePath, 1);
      if (context.mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          builder:
              (context) => CustomDialog(
                title: 'Berhasil',
                content: 'Dokumen klaim berhasil diunggah!',
                cancelText: '',
                confirmText: 'Tutup',
                onCancel: () {},
                onConfirm: () => context.pop(),
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        BkuLoadingDialog.hide(context);
        showDialog(
          context: context,
          builder:
              (context) => CustomDialog(
                title: 'Gagal',
                content: 'Gagal mengunggah dokumen: $e',
                cancelText: '',
                confirmText: 'Tutup',
                isDestructive: true,
                onCancel: () {},
                onConfirm: () => context.pop(),
              ),
        );
      }
    }
  }

  void _showInsuranceForm(BuildContext context, ProfileProvider student) {
    String selectedProvider = 'BKU_Assurance';
    DateTime selectedDate = DateTime.now();
    final faskesController = TextEditingController();
    final deskripsiController = TextEditingController();
    final biayaController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedFilePath;
    String? selectedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: EdgeInsets.only(
                    top: AppSpacing.xl,
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: AppRadius.radiusXs,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Pengajuan Klaim Asuransi',
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.appColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Provider Asuransi',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          DropdownButtonFormField<String>(
                            initialValue: selectedProvider,
                            items: const [
                              DropdownMenuItem(
                                value: 'BKU_Assurance',
                                child: Text('BKU Assurance'),
                              ),
                              DropdownMenuItem(
                                value: 'BPJS',
                                child: Text('BPJS Kesehatan'),
                              ),
                              DropdownMenuItem(
                                value: 'Asuransi_Lain',
                                child: Text('Asuransi Swasta Lain'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedProvider = val);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Tanggal Kejadian',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.lg,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.neutral400),
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd MMMM yyyy',
                                      'id',
                                    ).format(selectedDate),
                                    style: AppTextStyles.bodyMd,
                                  ),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color:
                                        context.appColors.outline,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Fasilitas Kesehatan (Faskes)',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BkuTextField(
                            controller: faskesController,
                            validator:
                                (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Nama Faskes wajib diisi'
                                        : null,
                            decoration: InputDecoration(
                              hintText:
                                  'Nama Klinik atau Rumah Sakit tempat berobat...',
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Estimasi Total Biaya (Rp)',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BkuTextField(
                            controller: biayaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Biaya wajib diisi';
                              }
                              final unformatted = val.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              if (double.tryParse(unformatted) == null) {
                                return 'Masukkan angka biaya yang valid';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Contoh: 150.000',
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Deskripsi & Kronologi Singkat',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BkuTextField(
                            controller: deskripsiController,
                            maxLines: 2,
                            validator:
                                (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Kronologi wajib diisi'
                                        : null,
                            decoration: InputDecoration(
                              hintText:
                                  'Tulis kronologi singkat keluhan medis dan penanganan yang diterima...',
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              contentPadding: const EdgeInsets.all(
                                AppSpacing.lg,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Unggah Kwitansi / Berkas',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(AppRadius.radius20),
                                      ),
                                    ),
                                    builder: (BuildContext sheetContext) {
                                      return SafeArea(
                                        child: Wrap(
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons.camera_alt,
                                              ),
                                              title: const Text('Kamera'),
                                              onTap: () async {
                                                Navigator.pop(sheetContext);
                                                final picker = ImagePicker();
                                                final pickedFile = await picker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                    );
                                                if (pickedFile != null) {
                                                  setModalState(() {
                                                    selectedFilePath =
                                                        pickedFile.path;
                                                    selectedFileName =
                                                        'kamera_foto.jpg';
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.photo_library,
                                              ),
                                              title: const Text('Galeri Foto'),
                                              onTap: () async {
                                                Navigator.pop(sheetContext);
                                                final picker = ImagePicker();
                                                final pickedFile = await picker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                if (pickedFile != null) {
                                                  setModalState(() {
                                                    selectedFilePath =
                                                        pickedFile.path;
                                                    selectedFileName =
                                                        'galeri_foto.jpg';
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.folder),
                                              title: const Text(
                                                'File Dokumen (PDF, dll)',
                                              ),
                                              onTap: () async {
                                                Navigator.pop(sheetContext);
                                                final result =
                                                    await FilePicker.pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: [
                                                        'pdf',
                                                        'jpg',
                                                        'jpeg',
                                                        'png',
                                                      ],
                                                    );
                                                if (result != null &&
                                                    result.files.single.path !=
                                                        null) {
                                                  setModalState(() {
                                                    selectedFilePath =
                                                        result
                                                            .files
                                                            .single
                                                            .path;
                                                    selectedFileName =
                                                        result
                                                            .files
                                                            .single
                                                            .name;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },

                                icon: const Icon(
                                  Icons.attach_file_rounded,
                                  size: 18,
                                ),
                                label: const Text('Pilih Berkas'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  selectedFileName ??
                                      'Belum ada berkas dipilih',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        selectedFileName != null
                                            ? context
                                                .watch<ThemeProvider>()
                                                .colors
                                                .success
                                            : Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  context.pop();
                                  try {
                                    final unformattedBiaya = biayaController
                                        .text
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    final biaya = double.parse(
                                      unformattedBiaya,
                                    );
                                    final formattedDateStr = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(selectedDate);

                                    AppSnackbar.showSuccess(
                                      context,
                                      'Mengajukan klaim asuransi...',
                                    );
                                    await context.read<HealthViewModel>().submitInsuranceClaim(
                                      provider: selectedProvider,
                                      tanggal: formattedDateStr,
                                      faskes: faskesController.text,
                                      deskripsi: deskripsiController.text,
                                      biaya: biaya,
                                      filePath: selectedFilePath,
                                    );

                                    if (context.mounted) {
                                      AppSnackbar.showSuccess(
                                        context,
                                        'Pengajuan klaim berhasil dikirim!',
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      AppSnackbar.showError(
                                        context,
                                        e.toString(),
                                      );
                                    }
                                  }
                                }
                              },

                              child: const Text(
                                'Kirim Pengajuan Klaim',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final f = NumberFormat("#,###", "id_ID");
      int num = int.parse(newValue.text.replaceAll(RegExp('[^0-9]'), ''));
      final newString = f.format(num);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndexFromTheRight,
        ),
      );
    } else {
      return newValue;
    }
  }
}
