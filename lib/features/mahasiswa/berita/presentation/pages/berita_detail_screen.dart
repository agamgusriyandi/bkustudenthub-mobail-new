import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_error_state.dart';
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
                  padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                  child: BkuErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.fetchBerita(widget.beritaId),
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
    
    final shareText = '${berita.title}\n\nBaca selengkapnya di BKU Student Hub!';
    SharePlus.instance.share(ShareParams(text: shareText));
  }
}

class _BeritaContent extends StatelessWidget {
  final dynamic berita;
  const _BeritaContent({required this.berita});

  String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return '';
    var document = htmlString
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    document = document.replaceAll(RegExp(r'<[^>]*>'), '');
    document = document
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return document.trim().replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (berita.imageUrl.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral900.withAlpha(15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xxl),
                bottomRight: Radius.circular(AppRadius.xxl),
              ),
              child: Image.network(
                ApiGate.getImageUrl(berita.imageUrl),
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 260,
                  color: AppColors.neutral200,
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 48,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (berita.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(20),
                    borderRadius: AppRadius.radiusFull,
                    border: Border.all(
                      color: context.appColors.primary.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    berita.category!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                berita.title,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.appColors.onSurface,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withAlpha(50),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: context.appColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.author,
                            style: AppTextStyles.labelLg.copyWith(
                              color: context.appColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: context.appColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                berita.formattedDate,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: context.appColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _parseHtmlString(berita.content),
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.appColors.onSurface.withValues(alpha: 0.9),
                  height: 1.85,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ],
    );
  }
}
