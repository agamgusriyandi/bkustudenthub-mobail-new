import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

import '../dialogs/profile_dialogs.dart';
import '../utils/profile_utils.dart';
import 'profile_widgets.dart';

class AkademikTabWidget extends StatelessWidget {
  const AkademikTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final academic = context.watch<AcademicProvider>();
    final organization = context.watch<OrganizationProvider>();
    final raw = profile.rawProfileData;
    final m = raw['mahasiswa'] ?? raw;
    final status = m['StatusAkademik']?.toString() ?? m['status_akademik']?.toString() ?? 'Aktif';
    final asalSekolah = m['asal_sekolah']?.toString() ?? m['AsalSekolah']?.toString() ?? '-';
    final jalurMasuk = m['jalur_masuk']?.toString() ?? m['JalurMasuk']?.toString() ?? '-';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        FadeInAnimation(
          delay: 0.1,
          child: buildMenuSection(
            context,
            'Data Akademik',
            [
              buildMenuItem(
                context,
                'Fakultas & Prodi',
                '${profile.fakultas} - ${profile.prodi}',
                Icons.account_balance_rounded,
                context.appColors.info,
                () => showUneditableInfoDialog(context),
              ),
              buildMenuItem(
                context,
                'Status Mahasiswa',
                status,
                Icons.info_outline_rounded,
                status.toLowerCase() == 'aktif'
                    ? AppColors.success
                    : AppColors.warning,
                () => showUneditableInfoDialog(context),
              ),
              buildMenuItem(
                context,
                'Jalur Masuk & Asal Sekolah',
                '$jalurMasuk • $asalSekolah',
                Icons.school_rounded,
                context.appColors.info,
                () => showUneditableInfoDialog(context),
              ),
            ],
            headerIcon: Icons.school_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        FadeInAnimation(
          delay: 0.2,
          child: buildMenuSection(
            context,
            'Layanan Akademik',
            [
              buildMenuItem(
                context,
                'Kartu Mahasiswa Digital',
                'Lihat QR Code & ID Mahasiswa',
                Icons.qr_code_scanner_rounded,
                AppColors.info,
                () => showDigitalID(context, profile),
              ),
            ],
            headerIcon: Icons.qr_code_2_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        FadeInAnimation(
          delay: 0.3,
          child: buildMenuSection(
            context,
            'Kepemimpinan & Kegiatan',
            [
              buildMenuItem(
                context,
                'Jabatan Aktif',
                getActiveOrganizationRole(organization),
                Icons.stars_rounded,
                context.appColors.warning,
                () => context.push(AppRoutes.organisasi),
              ),
              buildMenuItem(
                context,
                'Portofolio Digital',
                'Lihat Jejak Rekam Organisasi',
                Icons.auto_stories_rounded,
                context.appColors.info,
                () => context.push(AppRoutes.organisasi),
              ),
              buildMenuItem(
                context,
                'E-Sertifikat',
                '${academic.validatedAchievements} dari ${academic.totalAchievements} Sertifikat',
                Icons.verified_rounded,
                AppColors.success,
                () => showCertificatesBottomSheet(context, academic),
              ),
            ],
            headerIcon: Icons.stars_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.s120),
      ],
    );
  }
}
