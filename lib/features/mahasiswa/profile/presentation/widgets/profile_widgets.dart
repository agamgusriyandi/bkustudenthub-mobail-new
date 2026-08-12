import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import '../dialogs/profile_dialogs.dart';
import '../utils/profile_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

Widget buildRoleCard(BuildContext context, ProfileProvider student) {
  final displayName = student.name.isNotEmpty ? student.name.toTitleCase() : 'Mahasiswa';
  final displayProdi =
      student.prodi.isNotEmpty ? student.prodi : 'MAHASISWA';
  final displaySemester = student.semester > 0 ? 'Sem ${student.semester}' : 'Aktif';
  final displayNim = student.nim.isNotEmpty ? student.nim : '-';

  const accentColor = AppColors.neutral700;
  const accentLight = AppColors.neutral200;

  return BkuCard(
    padding: EdgeInsets.zero,
    borderRadius: 24,
    child: ClipRRect(
      borderRadius: AppRadius.radiusXl,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withAlpha(15),
                    accentColor.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.padding20,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: AppSpacing.padding3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [context.appColors.secondary, AppColors.neutral600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                            boxShadow: [
                              BoxShadow(
                                color: context.appColors.onSurface.withAlpha(30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              shape: BoxShape.circle,
                            ),
                            padding: AppSpacing.padding2,
                            child: ClipOval(
                              child: student.fotoUrl != null &&
                                      student.fotoUrl!.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: 
                                      ApiGate.getImageUrl(student.fotoUrl!),
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (context, url, error) {
                                        return Container(
                                          width: 64,
                                          height: 64,
                                          color: accentLight,
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 38,
                                            color: accentColor,
                                          ),
                                        );
                                      },
                                      placeholder: (context, url) => Container(color: AppColors.neutral200),
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      color: accentLight,
                                      child: const Icon(
                                        Icons.person_rounded,
                                        size: 38,
                                        color: accentColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => pickAvatar(context),
                            child: Container(
                              padding: AppSpacing.padding6,
                              decoration: BoxDecoration(
                                color: context.appColors.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.onSurface.withAlpha(30),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 12,
                                color: context.appColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: context.appColors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accentLight,
                              borderRadius: AppRadius.br20,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  size: 13,
                                  color: accentColor,
                                ),
                                const SizedBox(width: AppSpacing.s6),
                                Flexible(
                                  child: Text(
                                    '$displayProdi • $displaySemester',
                                    style: const TextStyle(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: AppSpacing.padding6,
                              decoration: BoxDecoration(
                                color: accentLight,
                                borderRadius: AppRadius.br10,
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                color: accentColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NIM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.neutral600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    displayNim,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: context.appColors.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                  color: context.appColors.successContainer,
                  borderRadius: AppRadius.br20,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: context.appColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.success.withAlpha(100),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s6),
    Text(
                              'AKTIF',
                              style: TextStyle(
                                color: context.appColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildMenuSection(
  BuildContext context,
  String title,
  List<Widget> items, {
  IconData? headerIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.s10),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.padding6,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(
                headerIcon ?? Icons.grid_view_rounded,
                size: 14,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.neutral900,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
      BkuCard(
        padding: EdgeInsets.zero,
        borderRadius: 22,
    child: Column(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return Column(
          children: [
            entry.value,
            if (!isLast)
              const Divider(
                height: 1,
                indent: 68,
                endIndent: 16,
                color: AppColors.neutral200,
              ),
              ],
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget buildMenuItem(
  BuildContext context,
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback? onTap,
) {
  return Material(
    color: Colors.transparent,
    borderRadius: AppRadius.br22,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.br22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: AppRadius.br13,
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.neutral600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
    color: context.appColors.surface,
    borderRadius: AppRadius.br10,
  ),
  child: Icon(
    Icons.chevron_right_rounded,
    color: AppColors.neutral500,
    size: 18,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget buildLogoutButton(BuildContext context) {
  return BkuCard(
    padding: EdgeInsets.zero,
    backgroundColor: context.appColors.errorContainer,
    borderRadius: 22,
    child: Material(
      color: Colors.transparent,
      borderRadius: AppRadius.br22,
      child: InkWell(
        onTap: () => showLogoutDialog(context),
        borderRadius: AppRadius.br22,
        child: Padding(
          padding: AppSpacing.padding14,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.appColors.error.withAlpha(20),
                  borderRadius: AppRadius.br14,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: context.appColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluar Aplikasi',
                      style: TextStyle(
                        color: context.appColors.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      'Anda akan keluar dari sesi akun ini',
                      style: TextStyle(
                        color: context.appColors.error.withAlpha(170),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.br10,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.error,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
