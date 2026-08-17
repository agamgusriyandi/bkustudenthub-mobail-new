import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BkuSectionHeader(title: 'Anggota Terbaru'),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BkuShimmer(
              width: double.infinity,
              height: 90,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
            ),
          ),
        ],
      );
    }

    if (members.isEmpty) return const SizedBox.shrink();

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
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: BkuCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            borderRadius: AppRadius.radius20,
            child: SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentMembers.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final member = recentMembers[index];
                  final name = member.name.isNotEmpty ? member.name : 'Unknown';
                  final firstName = name.split(' ').first;
                  final initial = name.substring(0, 1).toUpperCase();

                  return Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.appColors.primary.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.appColors.primary.withAlpha(30),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child:
                            member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiGate.getImageUrl(member.fotoUrl!),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorWidget:
                                        (context, url, error) => Text(
                                          initial,
                                          style: TextStyle(
                                            color: context.appColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                    placeholder: (context, url) => Container(color: AppColors.neutral200),
                                  ),
                                )
                                : Text(
                                  initial,
                                  style: TextStyle(
                                    color: context.appColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 52,
                        child: Text(
                          firstName,
                          style: const TextStyle(
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
