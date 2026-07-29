import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class TkPatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;

  const TkPatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.radiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.appColors.infoContainer,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        patient.fotoURL != null && patient.fotoURL!.isNotEmpty
                            ? CachedNetworkImage(imageUrl: 
                              ApiGate.getImageUrl(patient.fotoURL),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, url, error) => _buildInitials(context),
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                            )
                            : _buildInitials(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.nama,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: context.appColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        patient.nim,
                          style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.secondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (patient.prodi.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          patient.prodi,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (patient.fakultas.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          patient.fakultas,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        'Semester ${patient.semester}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: AppSpacing.padding6,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.neutral600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 44,
      height: 44,
      color: primary.withAlpha(25),
      child: Center(
        child: Text(
          patient.initials,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
    );
  }
}
