import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/presentation/providers/berita_detail_provider.dart';

class BeritaDetailScreen extends StatefulWidget {
  final int beritaId;
  const BeritaDetailScreen({super.key, required this.beritaId});

  @override
  State<BeritaDetailScreen> createState() => _BeritaDetailScreenState();
}

class _BeritaDetailScreenState extends State<BeritaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BeritaDetailProvider>().fetchBerita(widget.beritaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BeritaDetailProvider>();

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<BeritaDetailProvider>().fetchBerita(widget.beritaId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Detail Berita',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
              actions: [
                if (provider.berita != null)
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: AppColors.onPrimary),
                    onPressed: _shareBerita,
                  ),
              ],
            ),
            if (provider.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                ),
              )
            else if (provider.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xxxl),
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: context.appColors.danger.withAlpha(80),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextButton.icon(
                          onPressed: () => provider.fetchBerita(widget.beritaId),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (provider.berita != null)
              SliverToBoxAdapter(
                child: _BeritaContent(berita: provider.berita!),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  void _shareBerita() {
    final berita = context.read<BeritaDetailProvider>().berita;
    if (berita == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membagikan: ${berita.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BeritaContent extends StatelessWidget {
  final dynamic berita;
  const _BeritaContent({required this.berita});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (berita.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xl),
              bottomRight: Radius.circular(AppRadius.xl),
            ),
            child: Image.network(
              ApiGate.getImageUrl(berita.imageUrl),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 220,
                color: AppColors.neutral200,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  size: 48,
                  color: AppColors.neutral400,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (berita.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(15),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    berita.category!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                berita.title,
                style: AppTextStyles.titleLg.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: context.appColors.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    berita.author,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    berita.formattedDate,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(40),
                  borderRadius: AppRadius.radiusFull,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                berita.content,
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.appColors.onSurface.withValues(alpha: 0.85),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ],
    );
  }
}
