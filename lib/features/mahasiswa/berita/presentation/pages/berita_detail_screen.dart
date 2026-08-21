import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_error_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => context.read<BeritaDetailProvider>().fetchBerita(widget.beritaId),
        color: const Color(0xFF2563EB),
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
              expandedHeight: 120,
              showBackButton: true,
              isExpandable: false,
              actions: [
                if (provider.berita != null)
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.onPrimary),
                    onPressed: () => _showShareOptions(context),
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
                child: _BeritaContent(
                  berita: provider.berita!,
                  onShareTap: () => _showShareOptions(context),
                ),
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

  Future<void> _shareBeritaWithImage(BuildContext context) async {
    final berita = context.read<BeritaDetailProvider>().berita;
    if (berita == null) return;

    final newsUrl = '${ApiGate.webUrl}/student/berita/${widget.beritaId}';
    final shareText = '${berita.title}\n\nBaca berita selengkapnya di:\n$newsUrl';

    try {
      if (berita.imageUrl.toString().isNotEmpty) {
        final fullImageUrl = ApiGate.getImageUrl(berita.imageUrl.toString());
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/berita_${widget.beritaId}.jpg';
        final file = File(filePath);

        if (!await file.exists()) {
          final dio = Dio();
          await dio.download(fullImageUrl, filePath);
        }

        if (await file.exists()) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: shareText,
            ),
          );
          return;
        }
      }
    } catch (_) {}

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _showShareOptions(BuildContext context) {
    final berita = context.read<BeritaDetailProvider>().berita;
    if (berita == null) return;

    final newsUrl = '${ApiGate.webUrl}/student/berita/${widget.beritaId}';

    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bagikan Berita',
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              berita.title,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      newsUrl,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
              ),
              title: Text(
                'Bagikan Foto & Link ke Aplikasi Lain',
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Kirim dengan gambar asli artikel ke WhatsApp, Telegram, dll.',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _shareBeritaWithImage(context);
              },
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
              ),
              title: Text(
                'Salin Tautan Berita',
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                'Salin URL link berita ke clipboard',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(text: newsUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan berita berhasil disalin ke clipboard!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BeritaContent extends StatelessWidget {
  final dynamic berita;
  final VoidCallback onShareTap;
  const _BeritaContent({required this.berita, required this.onShareTap});

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

  Color _getCategoryColor(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'pengabdian':
        return const Color(0xFF2563EB);
      case 'prestasi':
        return const Color(0xFF059669);
      case 'akademik':
        return const Color(0xFF4F46E5);
      case 'kegiatan':
        return const Color(0xFFD97706);
      case 'kesehatan':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(berita.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (berita.imageUrl.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
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
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 240,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 40,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (berita.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    berita.category!,
                    style: AppTextStyles.caption.copyWith(
                      color: catColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                berita.title,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.38,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.author,
                            style: AppTextStyles.bodySm.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                berita.formattedDate,
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11,
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
              const SizedBox(height: 16),
              Text(
                _parseHtmlString(berita.content),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF334155),
                  height: 1.68,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.share_outlined, size: 18, color: Color(0xFF475569)),
                        const SizedBox(width: 8),
                        Text(
                          'Bagikan berita ini',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onShareTap,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Bagikan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
