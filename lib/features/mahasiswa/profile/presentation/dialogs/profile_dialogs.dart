import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_screen.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

void showLogoutDialog(BuildContext context) {
  BkuDialog.show(
    context: context,
    title: 'Keluar Akun?',
    message: 'Anda harus masuk kembali menggunakan email dan password kampus untuk mengakses aplikasi ini.',
    type: BkuDialogType.error,
    primaryButtonText: 'Keluar',
    onPrimaryPressed: () async {
      Navigator.pop(context); // close dialog first
      await AuthService().logout();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    },
    secondaryButtonText: 'Batal',
    onSecondaryPressed: () => Navigator.pop(context),
  );
}

void showUneditableInfoDialog(BuildContext context) {
  BkuDialog.show(
    context: context,
    title: 'Data Terkunci',
    message: 'Data ini ditarik langsung dari SEVIMA dan tidak dapat diubah secara manual.\n\nJika terdapat kesalahan, silakan ajukan perubahan melalui menu Aspirasi.',
    type: BkuDialogType.warning,
    primaryButtonText: 'Aspirasi',
    onPrimaryPressed: () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentVoiceScreen(),
        ),
      );
    },
    secondaryButtonText: 'Tutup',
    onSecondaryPressed: () => Navigator.pop(context),
  );
}

void showDigitalID(BuildContext context, ProfileProvider student) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kartu Mahasiswa Digital',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: context.appColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusXl,
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.onSurface.withAlpha(8),
                              blurRadius: 25,
                            ),
                          ],
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: ClipRRect(
                                borderRadius: AppRadius.radiusSm,
                                child: Image.asset(
                                  'assets/images/logoBKU.jpg',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            CachedNetworkImage(imageUrl: 
                              'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${student.nim}',
                              height: 180,
                              width: 180,
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                              errorWidget: (context, url, error) => Icon(Icons.error, color: AppColors.neutral400),
                            ),
                            const SizedBox(height: AppSpacing.s20),
                            Text(
                              student.name,
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              student.nim,
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.outline,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Gunakan QR Code ini untuk keperluan administrasi, perpustakaan, dan presensi di lingkungan kampus BKU.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              BkuButton.primary(
                text: 'Tutup',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
  );
}

void showEditPersonalData(BuildContext context, ProfileProvider student) {
  final parts = student.birthPlaceDate.split(',');
  final tempatLahirInitial = parts.isNotEmpty ? parts[0].trim() : '';
  final tglLahirInitialStr = parts.length > 1 ? parts[1].trim() : '';

  final phoneController = TextEditingController(text: student.phone);
  final tempatLahirController = TextEditingController(text: tempatLahirInitial);
  final alamatDomisiliVal =
      student.address.trim() == 'Jl. Soekarno Hatta No. 123, Bandung' &&
              student.name == 'Mahasiswa Lama'
          ? ''
          : student
              .address; // Jika default dummy untuk mahasiswa lama, kosongkan
  final alamatController = TextEditingController(text: alamatDomisiliVal);
  final tglLahirController = TextEditingController(
    text: tglLahirInitialStr.contains('0001-01-01') ? '' : tglLahirInitialStr,
  );

  DateTime? selectedDate;
  try {
    if (tglLahirInitialStr.isNotEmpty &&
        !tglLahirInitialStr.contains('0001-01-01')) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(tglLahirInitialStr);
    }
  } catch (_) {
    try {
      if (tglLahirInitialStr.isNotEmpty &&
          !tglLahirInitialStr.contains('0001-01-01')) {
        selectedDate = DateFormat('dd MMMM yyyy').parse(tglLahirInitialStr);
      }
    } catch (_) {}
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          return Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              MediaQuery.of(stateContext).viewInsets.bottom + AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: AppRadius.radiusXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Edit Data Pribadi',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(stateContext).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // Input No WhatsApp
                  Text(
                    'Nomor WhatsApp',
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BkuTextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    hint: 'Contoh: 081234567890',
                    prefixIcon: const Icon(
                      Icons.phone_android_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Input Tempat Lahir
                  Text(
                    'Tempat Lahir',
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BkuTextField(
                    controller: tempatLahirController,
                    hint: 'Contoh: Bandung',
                    prefixIcon: Icon(
                      Icons.location_city_rounded,
                      color: context.appColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Input Tanggal Lahir
                  Text(
                    'Tanggal Lahir',
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: stateContext,
                        initialDate: selectedDate ?? DateTime(2004, 1, 1),
                        firstDate: DateTime(1980),
                        lastDate: DateTime.now(),
                        builder: (stateContext, child) {
                          return Theme(
                            data: Theme.of(stateContext).copyWith(
                              colorScheme: ColorScheme.light(
                                primary:
                                    Theme.of(stateContext).colorScheme.primary,
                                onPrimary: context.appColors.surface,
                                onSurface: context.appColors.onSurface,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          tglLahirController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: BkuTextField(
                        controller: tglLahirController,
                        hint: 'Pilih Tanggal Lahir',
                        prefixIcon: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Input Alamat Domisili
                  Text(
                    'Alamat Domisili',
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BkuTextField(
                    controller: alamatController,
                    maxLines: 3,
                    hint: 'Tulis alamat lengkap domisili saat ini',
                    prefixIcon: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton.outline(
                          text: 'Batal',
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BkuButton.primary(
                          text: 'Simpan',
                          isLoading: student.isLoading,
                          onPressed: () async {
                            try {
                              final Map<String, dynamic> updateData = {
                                'no_hp': phoneController.text,
                                'tempat_lahir':
                                    tempatLahirController.text,
                                'tanggal_lahir':
                                    tglLahirController.text,
                                'alamat': alamatController.text,
                              };
                              await student.updateProfile(updateData);
                              if (stateContext.mounted) {
                                Navigator.pop(sheetContext);
                                AppSnackbar.showSuccess(
                                  context,
                                  'Profil berhasil diperbarui',
                                );
                              }
                            } catch (e) {
                              if (stateContext.mounted) {
                                AppSnackbar.showError(
                                  context,
                                  'Gagal memperbarui profil: ${ErrorHandler.getMessage(e)}',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showEmailInfoDialog(BuildContext context) {
  BkuDialog.show(
    context: context,
    title: 'Informasi Akun',
    message: 'Email institusi digunakan untuk keperluan perkuliahan, akses e-learning, dan komunikasi resmi dari kampus BKU.',
    type: BkuDialogType.info,
    primaryButtonText: 'Tutup',
    onPrimaryPressed: () => Navigator.pop(context),
  );
}

void showAcademicInfoDialog(BuildContext context, ProfileProvider student) {
  BkuDialog.show(
    context: context,
    title: 'Informasi Akademik Resmi',
    message: 'Data akademik seperti NIM, Program Studi (${student.prodi}), Fakultas (${student.fakultas}), dan Angkatan (${student.intakeYear}) ditarik langsung secara resmi dari sistem SEVIMA BKU.\n\nJika terdapat ketidaksesuaian data, silakan hubungi bagian Administrasi Akademik (BAA).',
    type: BkuDialogType.info,
    primaryButtonText: 'Tutup',
    onPrimaryPressed: () => Navigator.pop(context),
  );
}

void showCertificatesBottomSheet(
  BuildContext context,
  AcademicProvider student,
) {
  final certificates =
      student.achievements.where((a) {
        final status = a.status.toLowerCase();
        return status == 'validated' ||
            status == 'diverifikasi' ||
            status == 'disetujui' ||
            status == 'valid' ||
            a.certificateUrl != null;
      }).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final themeProvider = sheetContext.watch<ThemeProvider>();
      return Container(
        decoration: BoxDecoration(
          color: sheetContext.appColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        height: MediaQuery.of(sheetContext).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E-Sertifikat Saya',
                  style: AppTextStyles.titleLg.copyWith(
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
                    color: themeProvider.primary.withAlpha(15),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    '${certificates.length} Sertifikat',
                    style: TextStyle(
                      color: themeProvider.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child:
                  certificates.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 64,
                              color: AppColors.neutral300,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Text(
                              'Belum ada sertifikat terverifikasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Laporkan prestasi mandiri Anda untuk memvalidasi e-sertifikat.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.neutral500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        physics: const ClampingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: certificates.length,
                        itemBuilder: (context, index) {
                          final cert = certificates[index];
                          final status = cert.status.toLowerCase();
                          final isValidated =
                              status == 'validated' ||
                              status == 'diverifikasi' ||
                              status == 'disetujui' ||
                              status == 'valid';
                          final isPending =
                              status == 'pending' || status == 'menunggu';

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              borderRadius: AppRadius.radiusXl,
                              border: Border.all(
                                color: AppColors.neutral200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.appColors.onSurface.withAlpha(5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color:
                                        isValidated
                                            ? AppColors.success.withAlpha(15)
                                            : isPending
                                            ? AppColors.warning.withAlpha(15)
                                            : AppColors.error.withAlpha(15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isValidated
                                        ? Icons.verified_rounded
                                        : isPending
                                        ? Icons.pending_actions_rounded
                                        : Icons.error_outline_rounded,
                                    color:
                                        isValidated
                                            ? AppColors.success
                                            : isPending
                                            ? AppColors.warning
                                            : AppColors.error,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cert.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isValidated
                                                      ? AppColors.success
                                                          .withAlpha(15)
                                                      : isPending
                                                      ? AppColors.warning
                                                          .withAlpha(15)
                                                      : AppColors.error
                                                          .withAlpha(15),
                                              borderRadius: AppRadius.radiusSm,
                                            ),
                                            child: Text(
                                              isValidated
                                                  ? 'Valid'
                                                  : isPending
                                                  ? 'Menunggu'
                                                  : 'Ditolak',
                                              style: TextStyle(
                                                color:
                                                    isValidated
                                                        ? AppColors.success
                                                        : isPending
                                                        ? AppColors.warning
                                                        : AppColors.error,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        cert.organizer,
                                        style: TextStyle(
                                          color: AppColors.neutral500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: BkuButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.read<NavigationProvider>().setIndex(2);
                },
                icon: Icons.add_rounded,
                text: 'Lapor Prestasi Baru',
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showNotificationPreferences(
  BuildContext context,
  ProfileProvider student,
) {
  bool emailNotif = student.emailNotif;
  bool pushNotif = student.pushNotif;
  bool inAppNotif = student.inAppNotif;
  bool isSaving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          return Container(
            decoration: BoxDecoration(
              color: stateContext.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Preferensi Notifikasi',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Atur bagaimana Anda menerima pemberitahuan kuliah & pengumuman.',
                  style: TextStyle(color: AppColors.neutral500, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xl),

                SwitchListTile(
                  title: const Text(
                    'Notifikasi Push',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Terima pemberitahuan instan di perangkat Anda',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: pushNotif,
                  activeThumbColor: Theme.of(stateContext).colorScheme.primary,
                  onChanged:
                      isSaving
                          ? null
                          : (val) {
                            setState(() {
                              pushNotif = val;
                            });
                          },
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text(
                    'Notifikasi Email',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Kirim salinan pengumuman penting ke email kampus',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: emailNotif,
                  activeThumbColor: Theme.of(stateContext).colorScheme.primary,
                  onChanged:
                      isSaving
                          ? null
                          : (val) {
                            setState(() {
                              emailNotif = val;
                            });
                          },
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text(
                    'Peringatan In-App',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Tampilkan tanda merah di ikon notifikasi aplikasi',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: inAppNotif,
                  activeThumbColor: Theme.of(stateContext).colorScheme.primary,
                  onChanged:
                      isSaving
                          ? null
                          : (val) {
                            setState(() {
                              inAppNotif = val;
                            });
                          },
                ),
                const SizedBox(height: AppSpacing.lg),
                BkuButton(
                  onPressed: () async {
                    try {
                      await LocalNotificationService.showNotification(
                        id: 999,
                        title: 'Test Notifikasi BKU',
                        body:
                            'Ini adalah uji coba notifikasi push pada perangkat Anda.',
                      );
                    } catch (e) {
                      debugPrint('Gagal mengirim test notifikasi: $e');
                    }

                    if (!context.mounted) return;
                    AppSnackbar.showSuccess(
                      context,
                      'Test Push Notifikasi berhasil dikirim',
                    );
                  },
                  text: 'Test Push Notifikasi',
                  icon: Icons.notifications_active_rounded,
                  variant: BkuButtonVariant.outline,
                ),
                const SizedBox(height: AppSpacing.md),
                BkuButton(
                  onPressed: () async {
                    setState(() {
                      isSaving = true;
                    });
                    try {
                      await student.updateProfile({
                        'email_notif': emailNotif,
                        'push_notif': pushNotif,
                        'in_app_notif': inAppNotif,
                      });
                      if (stateContext.mounted) {
                        Navigator.pop(sheetContext);
                        BkuDialog.show(
                          context: context,
                          title: 'Berhasil',
                          message: 'Preferensi notifikasi berhasil disimpan',
                          type: BkuDialogType.success,
                          primaryButtonText: 'Tutup',
                          onPrimaryPressed: () => Navigator.pop(context),
                        );
                      }
                    } catch (e) {
                      if (stateContext.mounted) {
                        setState(() {
                          isSaving = false;
                        });
                        BkuDialog.show(
                          context: context,
                          title: 'Gagal',
                          message: 'Gagal menyimpan preferensi: ${ErrorHandler.getMessage(e)}',
                          type: BkuDialogType.error,
                          primaryButtonText: 'Tutup',
                          onPrimaryPressed: () => Navigator.pop(context),
                        );
                      }
                    }
                  },
                  text: 'Simpan Pengaturan',
                  isLoading: isSaving,
                  variant: BkuButtonVariant.primary,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showChangePasswordDialog(BuildContext context) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isSaving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(stateContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
              ),
              padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: AppRadius.radiusXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.neutral800,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        'Ubah Password',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Demi keamanan akun Anda, pastikan password baru memiliki kombinasi huruf dan angka.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BkuTextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: const BorderSide(
                          color: AppColors.neutral800,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BkuTextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_open_rounded, size: 20),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: const BorderSide(
                          color: AppColors.neutral800,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BkuTextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: BorderSide(color: AppColors.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLg,
                        borderSide: const BorderSide(
                          color: AppColors.neutral800,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed:
                              isSaving
                                  ? null
                                  : () => Navigator.pop(sheetContext),
                          text: 'Batal',
                          variant: BkuButtonVariant.outline,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BkuButton(
                          onPressed:
                              isSaving
                                  ? null
                                  : () async {
                                    if (newPasswordController.text !=
                                        confirmPasswordController.text) {
                                      AppSnackbar.showError(
                                        context,
                                        'Password baru tidak cocok',
                                      );
                                      return;
                                    }
                                    setState(() {
                                      isSaving = true;
                                    });
                                    try {
                                      await context
                                          .read<ProfileProvider>()
                                          .changePassword(
                                            oldPasswordController.text,
                                            newPasswordController.text,
                                            confirmPasswordController.text,
                                          );
                                      if (stateContext.mounted) {
                                        Navigator.pop(sheetContext);
                                        AppSnackbar.showSuccess(
                                          context,
                                          'Password berhasil diubah',
                                        );
                                      }
                                    } catch (e) {
                                      if (stateContext.mounted) {
                                        setState(() {
                                          isSaving = false;
                                        });
                                        AppSnackbar.showError(
                                          context,
                                          ErrorHandler.getMessage(e),
                                        );
                                      }
                                    }
                                  },
                          text: 'Simpan',
                          isLoading: isSaving,
                          variant: BkuButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
