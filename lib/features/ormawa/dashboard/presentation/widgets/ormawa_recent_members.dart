import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_section_header.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';

import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class OrmawaRecentMembers extends StatelessWidget {
  const OrmawaRecentMembers({super.key});

  @override
  Widget build(BuildContext context) {
    final ormawa = context.watch<OrmawaProvider>();
    final members = ormawa.members;

    if (ormawa.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BkuSectionHeader(title: 'Anggota Terbaru'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: const BkuShimmer(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
          ),
        ],
      );
    }

    if (members.isEmpty) return const SizedBox.shrink();

    // Take max 8 members
    final recentMembers = members.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: BkuSectionHeader(
            title: 'Anggota Terbaru',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrmawaAnggotaScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: BkuCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentMembers.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final member = recentMembers[index];
                  final name = member.name.isNotEmpty ? member.name : 'Unknown';
                  final firstName = name.split(' ').first;
                  final initial = name.substring(0, 1).toUpperCase();

                  return Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(30),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child:
                            member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: AppRadius.br25,
                                  child: CachedNetworkImage(imageUrl: 
                                    ApiGate.getImageUrl(member.fotoUrl!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorWidget:
                                        (context, url, error) => Text(
                                          initial,
                                          style: AppTextStyles.titleLg.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                    placeholder: (context, url) => Container(color: AppColors.neutral200),
                                  ),
                                )
                                : Text(
                                  initial,
                                  style: AppTextStyles.titleLg.copyWith(
                                    color:
                                        context.appColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      SizedBox(
                        width: 60,
                        child: Text(
                          firstName,
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
