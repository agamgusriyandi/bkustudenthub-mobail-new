import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
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
    final academic = context.watch<AcademicProvider>();
    final newsList = academic.campusNews;

    if (academic.isLoading && newsList.isEmpty) {
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
            color: AppThemeColors.surfaceContainerHighest,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 48,
              color: context.appColors.outline.withAlpha(100),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada berita kampus',
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Berita terbaru dari kampus akan tampil di sini.',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline.withAlpha(180),
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
    context.push('/berita/${news.id}');
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
                      context.appColors.onSurface.withAlpha(90),
                      context.appColors.onSurface.withAlpha(230),
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
                              color: context.appColors.onSurface.withAlpha(120),
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
                            color: context.appColors.surface.withAlpha(40),
                            borderRadius: AppRadius.radiusXs,
                            border: Border.all(
                              color: context.appColors.surface.withAlpha(100),
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
