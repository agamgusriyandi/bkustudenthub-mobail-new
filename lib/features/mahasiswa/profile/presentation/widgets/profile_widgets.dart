import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import '../dialogs/profile_dialogs.dart';
import '../utils/profile_utils.dart';

Widget buildRoleCard(BuildContext context, ProfileProvider student) {
  final displayName = student.name.isNotEmpty ? student.name.toTitleCase() : 'Mahasiswa';
  final displayProdi = student.prodi.isNotEmpty ? student.prodi : 'MAHASISWA';
  final displaySemester = student.semester > 0 ? 'Sem ${student.semester}' : 'Aktif';
  final displayNim = student.nim.isNotEmpty ? student.nim : '-';

  return Container(
    decoration: BoxDecoration(
      color: BkuTheme.cardSurface,
      borderRadius: BkuTheme.r20,
      border: Border.all(color: BkuTheme.border),
      boxShadow: BkuTheme.cardShadow,
    ),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: BkuTheme.primary.withAlpha(50), width: 2),
                  ),
                  child: ClipOval(
                    child: student.fotoUrl != null && student.fotoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiGate.getImageUrl(student.fotoUrl!),
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Container(
                                width: 58,
                                height: 58,
                                color: BkuTheme.indigoSoft,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: BkuTheme.indigo,
                                ),
                              );
                            },
                            placeholder: (context, url) => Container(
                              width: 58,
                              height: 58,
                              color: BkuTheme.borderSubtle,
                            ),
                          )
                        : Container(
                            width: 58,
                            height: 58,
                            color: BkuTheme.indigoSoft,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: BkuTheme.indigo,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => pickAvatar(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: BkuTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: BkuTheme.cardShadow,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: BkuTheme.textPageTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: BkuTheme.indigoSoft,
                      borderRadius: BkuTheme.rPill,
                      border: Border.all(color: BkuTheme.indigoBorder),
                    ),
                    child: Text(
                      '$displayProdi • $displaySemester',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.indigo,
                        fontSize: 9.5,
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
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: BkuTheme.scaffoldBg,
            borderRadius: BkuTheme.r12,
            border: Border.all(color: BkuTheme.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIM Mahasiswa',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.textMuted,
                        fontSize: 8.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      displayNim,
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BkuTheme.statusSuccessBg,
                  borderRadius: BkuTheme.rPill,
                  border: Border.all(color: BkuTheme.statusSuccessBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: BkuTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Status Aktif',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.emerald,
                        fontSize: 9,
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
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Row(
          children: [
            Icon(
              headerIcon ?? Icons.grid_view_rounded,
              size: 14,
              color: BkuTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: BkuTheme.textSectionTitle.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: BkuTheme.r16,
          border: Border.all(color: BkuTheme.border),
          boxShadow: BkuTheme.cardShadow,
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: BkuTheme.border,
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
    borderRadius: BkuTheme.r16,
    child: InkWell(
      onTap: onTap,
      borderRadius: BkuTheme.r16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BkuTheme.r12,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: BkuTheme.textCaption,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: BkuTheme.textPlaceholder,
                size: 18,
              ),
          ],
        ),
      ),
    ),
  );
}

Widget buildLogoutButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: BkuTheme.statusDangerBg,
      borderRadius: BkuTheme.r16,
      border: Border.all(color: BkuTheme.statusDangerBorder),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BkuTheme.r16,
      child: InkWell(
        onTap: () => showLogoutDialog(context),
        borderRadius: BkuTheme.r16,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: BkuTheme.roseSoft,
                  borderRadius: BkuTheme.r12,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: BkuTheme.rose,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluar Aplikasi',
                      style: BkuTheme.textCardTitle.copyWith(
                        color: BkuTheme.statusDangerText,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Selesaikan sesi dan keluar dari akun Anda',
                      style: BkuTheme.textCaption.copyWith(
                        color: BkuTheme.statusDangerText.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: BkuTheme.rose,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}