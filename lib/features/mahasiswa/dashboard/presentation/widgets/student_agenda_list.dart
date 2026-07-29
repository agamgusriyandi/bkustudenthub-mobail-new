import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_news.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

String _formatDate(DateTime dt) {
  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  String dayName = days[dt.weekday - 1];
  String monthName = months[dt.month - 1];
  String dayNum = dt.day.toString().padLeft(2, '0');
  return '$dayName, $dayNum $monthName ${dt.year}';
}

String _parseHtmlString(String htmlString) {
  if (htmlString.isEmpty) return '';
  var document = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  document = document
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'");
  return document.trim();
}

class StudentAgendaList extends StatefulWidget {
  const StudentAgendaList({super.key});

  @override
  State<StudentAgendaList> createState() => _StudentAgendaListState();
}

class _StudentAgendaListState extends State<StudentAgendaList> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  int _lastNewsCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _setupAutoScroll(int count) {
    if (count == _lastNewsCount && _timer != null) return;
    _lastNewsCount = count;
    _timer?.cancel();
    if (count <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentIndex + 1) % count;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final newsList = student.campusNews;

    if (student.isLoading && newsList.isEmpty) {
      return const BkuShimmerList(itemCount: 1, itemHeight: 220);
    }

    if (newsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusSm,
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withAlpha(100),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada berita kampus',
              style: AppTextStyles.labelMd.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Berita terbaru dari kampus akan tampil di sini.',
              style: AppTextStyles.labelSm.copyWith(
                color: Theme.of(context).colorScheme.outline.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    _setupAutoScroll(newsList.length);

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return _NewsCard(news: newsList[index]);
            },
          ),
        ),
        if (newsList.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(newsList.length, (index) {
              final isSelected = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isSelected ? 18 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withAlpha(50),
                  borderRadius: AppRadius.br3,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final CampusNews news;

  const _NewsCard({required this.news});

  void _showNewsDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                      child:
                          news.gambarUrl.isNotEmpty
                              ? CachedNetworkImage(imageUrl: 
                                ApiGate.getImageUrl(news.gambarUrl),
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorWidget:
                                    (context, url, error) =>
                                        _buildPlaceholderImage(),
                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                              )
                              : _buildPlaceholderImage(),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(100),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.appColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.padding28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(20),
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Text(
                            news.kategori.isNotEmpty
                                ? news.kategori.toUpperCase()
                                : 'BERITA KAMPUS',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          news.judul,
                          style: AppTextStyles.titleLg.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _formatDate(news.tanggalPublish),
                              style: AppTextStyles.labelSm.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          _parseHtmlString(news.isi),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.black87,
                            height: 1.7,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/ubk_pengumuman.png',
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral200, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNewsDetail(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              news.gambarUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: 
                      ApiGate.getImageUrl(news.gambarUrl),
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) =>
                              _buildPlaceholderImage(),
                      placeholder: (context, url) => Container(color: AppColors.neutral200),
                    )
                  : _buildPlaceholderImage(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(90),
                      Colors.black.withAlpha(230),
                    ],
                    stops: const [0.25, 0.60, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: AppSpacing.padding14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Text(
                              news.kategori.isNotEmpty
                                  ? news.kategori.toUpperCase()
                                  : 'INFO TERBARU',
                              style: TextStyle(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Text(
                              _formatDate(news.tanggalPublish),
                              style: TextStyle(
                                color: context.appColors.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        news.judul,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: context.appColors.onPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: AppRadius.radiusXs,
                            border: Border.all(
                              color: Colors.white.withAlpha(100),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Baca Selengkapnya',
                                style: TextStyle(
                                  color: context.appColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: context.appColors.onPrimary,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
