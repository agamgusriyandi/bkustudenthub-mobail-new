import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

import '../dialogs/profile_dialogs.dart';
import '../utils/profile_utils.dart';
import 'profile_widgets.dart';

class AkademikTabWidget extends StatelessWidget {
  final StudentProvider student;

  const AkademikTabWidget({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final raw = student.rawProfileData;
    final m = raw['mahasiswa'] ?? raw;
    final status = m['StatusAkademik']?.toString() ?? 'Aktif';
    final asalSekolah = m['asal_sekolah']?.toString() ?? '-';
    final jalurMasuk = m['jalur_masuk']?.toString() ?? '-';

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
                '${student.fakultas} - ${student.prodi}',
                Icons.account_balance_rounded,
                Colors.indigo,
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
                Colors.blue,
                () => showUneditableInfoDialog(context),
              ),
            ],
            headerIcon: Icons.school_rounded,
          ),
        ),
        const SizedBox(height: 20),
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
                () => showDigitalID(context, student),
              ),
            ],
            headerIcon: Icons.qr_code_2_rounded,
          ),
        ),
        const SizedBox(height: 20),
        FadeInAnimation(
          delay: 0.3,
          child: buildMenuSection(
            context,
            'Kepemimpinan & Kegiatan',
            [
              buildMenuItem(
                context,
                'Jabatan Aktif',
                getActiveOrganizationRole(student),
                Icons.stars_rounded,
                Colors.amber,
                () => context.push(AppRoutes.organisasi),
              ),
              buildMenuItem(
                context,
                'Portofolio Digital',
                'Lihat Jejak Rekam Organisasi',
                Icons.auto_stories_rounded,
                Colors.cyan,
                () => context.push(AppRoutes.organisasi),
              ),
              buildMenuItem(
                context,
                'E-Sertifikat',
                '${student.validatedAchievements} dari ${student.totalAchievements} Sertifikat',
                Icons.verified_rounded,
                AppColors.success,
                () => showCertificatesBottomSheet(context, student),
              ),
            ],
            headerIcon: Icons.stars_rounded,
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}
