import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import "package:bkuhub_mobile/core/providers/theme_provider.dart";
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_aspiration.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OrmawaAspirasiScreen extends StatefulWidget {
  const OrmawaAspirasiScreen({super.key});

  @override
  State<OrmawaAspirasiScreen> createState() => _OrmawaAspirasiScreenState();
}

class _OrmawaAspirasiScreenState extends State<OrmawaAspirasiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOrder = 'terbaru';
  String _filterStatus = 'Semua';

  final List<String> _sortOptions = ['Terbaru', 'Terlama'];
  final List<String> _filterOptions = [
    'Semua',
    'Menunggu',
    'Ditanggapi',
    'Diabaikan',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('ditanggapi') || s.contains('processed')) {
      return 'Ditanggapi';
    }
    if (s.contains('diabaikan') || s.contains('ignored')) return 'Diabaikan';
    return 'Menunggu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Aspirasi Organisasi',
              subtitle: 'Pusat Aspirasi',
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryGrid(),
                    const SizedBox(height: AppSpacing.xxl),
                    OrmawaListHeader(
                      title: 'Rekapitulasi Aspirasi',
                      searchHint: 'Cari topik aspirasi...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: () => _showSortFilterSheet(),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildAspirasiList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final aspirations = provider.aspirations;
        final countIncoming =
            aspirations.where((e) => e.status == 'pending').length;
        final countProcessed =
            aspirations.where((e) => e.status == 'ditanggapi').length;
        final countIgnored =
            aspirations.where((e) => e.status == 'diabaikan').length;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Masuk',
                countIncoming.toString(),
                Icons.inbox_rounded,
                AppColors.info,
              ),
              Container(width: 1, height: 50, color: AppColors.neutral200),
              _buildStatItem(
                'Ditanggapi',
                countProcessed.toString(),
                Icons.check_circle_rounded,
                AppColors.success,
              ),
              Container(width: 1, height: 50, color: AppColors.neutral200),
              _buildStatItem(
                'Diabaikan',
                countIgnored.toString(),
                Icons.cancel_rounded,
                AppColors.error,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspirasiList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filteredList =
            provider.aspirations.where((item) {
              final matchesSearch =
                  item.judul.toLowerCase().contains(_searchQuery) ||
                  item.isi.toLowerCase().contains(_searchQuery);
              final itemStatus = _normalizeStatus(item.status);
              final matchesFilter =
                  _filterStatus == 'Semua' || itemStatus == _filterStatus;
              return matchesSearch && matchesFilter;
            }).toList();

        // Apply sorting
        filteredList.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return _sortOrder == 'terbaru'
              ? bDate.compareTo(aDate)
              : aDate.compareTo(bDate);
        });

        if (filteredList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                children: [
                  Icon(
                    Icons.speaker_notes_off_rounded,
                    size: 48,
                    color: AppColors.neutral500.withAlpha(50),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tidak ada aspirasi ditemukan',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = filteredList[index];
            Color statusColor = AppColors.info;
            if (item.status == 'ditanggapi') statusColor = AppColors.success;
            if (item.status == 'diabaikan') statusColor = AppColors.error;

            return _buildAspirasiCard(item, statusColor);
          },
        );
      },
    );
  }

  Widget _buildAspirasiCard(OrmawaAspiration item, Color color) {
    String dateStr = 'Baru saja';
    if (item.createdAt != null) {
      dateStr = DateFormat('dd MMM yyyy').format(item.createdAt!);
    }

    return GestureDetector(
      onTap: () => _showAspirasiDetail(item, color),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Text(
                        item.status,
                        style: AppTextStyles.labelSm.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Text(
                        item.kategori,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral400,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              item.judul,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.isi,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    image:
                        item.mahasiswaFoto != null &&
                                item.mahasiswaFoto!.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(
                                ApiGate.getImageUrl(item.mahasiswaFoto!),
                              ),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      item.mahasiswaFoto == null || item.mahasiswaFoto!.isEmpty
                          ? Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: context.appColors.primary,
                          )
                          : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.mahasiswaName,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.mahasiswaNim.isNotEmpty)
                        Text(
                          item.mahasiswaNim,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.neutral300,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAspirasiDetail(OrmawaAspiration item, Color color) {
    final TextEditingController responseController = TextEditingController(
      text: item.tanggapan,
    );
    bool isSubmitting = false;
    final provider = context.read<OrmawaProvider>();
    final canRespond = provider.hasPermission('respond_aspirations');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HEADER
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                context.read<ThemeProvider>().primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppRadius.xxl),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: context.appColors.surface.withValues(alpha: 0.3),
                                  borderRadius: AppRadius.radiusXs,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: context.appColors.surface.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: context.appColors.surface.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: context.appColors.onPrimary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'INCIDENT AUDIT',
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color: context.appColors.info.withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2,
                                                  fontSize: 10,
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: context.appColors.info.withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            '#ASP-${item.id.padLeft(4, '0')}',
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                   color: context.appColors.onPrimary
                                                       .withValues(alpha: 0.7),
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'monospace',
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        item.judul,
                                        style: AppTextStyles.titleLg.copyWith(
                                                  color: context.appColors.onPrimary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: context.appColors.onPrimary.withValues(alpha: 0.7),
                                      size: 14,
                                    ),
                                    const SizedBox(width: AppSpacing.s6),
                                    Text(
                                      'Oleh: ',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.info.withValues(alpha: 0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      item.mahasiswaName,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                    ),
                                    borderRadius: AppRadius.radiusMd,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s6),
                                      Text(
                                        item.status,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: color.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // BODY
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IDENTITAS PELAPOR
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                color: context.appColors.surface,
                                borderRadius: AppRadius.radiusXl,
                                border: Border.all(
                                  color: AppColors.neutral200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.onSurface.withValues(
                                      alpha: 0.02,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: AppRadius.radiusLg,
                                        border: Border.all(
                                          color: AppColors.neutral200,
                                          width: 4,
                                        ),
                                        image:
                                            item.mahasiswaFoto != null &&
                                                    item
                                                        .mahasiswaFoto!
                                                        .isNotEmpty
                                                ? DecorationImage(
                                                  image: NetworkImage(
                                                    ApiGate.getImageUrl(
                                                      item.mahasiswaFoto!,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : null,
                                        color: AppColors.neutral100,
                                      ),
                                      child:
                                          item.mahasiswaFoto == null ||
                                                  item.mahasiswaFoto!.isEmpty
                                              ? Icon(
                                                Icons.person_rounded,
                                                size: 32,
                                                color: AppColors.neutral400,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'IDENTITAS PELAPOR',
                                                style: AppTextStyles.labelSm
                                                    .copyWith(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color:
                                                          AppColors.neutral500,
                                                      letterSpacing: 1.5,
                                                    ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: context.appColors.surface,
                                                  border: Border.all(
                                                    color: AppColors.neutral200,
                                                  ),
                                                  borderRadius:
                                                      AppRadius.radiusXs,
                                                ),
                                                child: Text(
                                                  'VERIFIED',
                                                  style: AppTextStyles.labelSm
                                                      .copyWith(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            AppColors
                                                                .neutral500,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            item.mahasiswaName,
                                            style: AppTextStyles.bodyMd
                                                .copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                  color: AppColors.neutral900,
                                                ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          if (item.mahasiswaNim.isNotEmpty)
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.neutral50,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.neutral200,
                                                    ),
                                                    borderRadius: AppRadius.radiusXs,
                                                  ),
                                                  child: Text(
                                                    item.mahasiswaNim,
                                                    style: AppTextStyles.labelSm
                                                        .copyWith(
                                                          fontFamily:
                                                              'monospace',
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors
                                                                  .neutral700,
                                                        ),
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
                              const SizedBox(height: AppSpacing.xl),

                              // SUBSTANSI ASPIRASI
                              Row(
                                children: [
                                  Icon(
                                    Icons.article_rounded,
                                    size: 20,
                                    color:
                                        context.appColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'SUBSTANSI ASPIRASI',
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.neutral500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: context.appColors.surface,
                                  borderRadius: AppRadius.radiusXl,
                                  border: Border.all(
                                    color: AppColors.neutral200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.appColors.onSurface.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Icon(
                                        Icons.format_quote_rounded,
                                        size: 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.05),
                                      ),
                                    ),
                                    Text(
                                      item.isi,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.neutral800,
                                        height: 1.6,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // PANEL RESOLUSI
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral200,
                                      borderRadius: AppRadius.radiusMd,
                                    ),
                                    child: Icon(
                                      Icons.gavel_rounded,
                                      color: AppColors.neutral600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Panel Resolusi',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                      Text(
                                        'TINDAKAN ADMIN',
                                        style: AppTextStyles.labelSm.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s20),
                              // Tanggapan section - only show if user has permission
                              if (canRespond) ...[
                                Text(
                                  'TANGGAPAN RESMI',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neutral500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.surface,
                                    borderRadius: AppRadius.radiusXl,
                                    border: Border.all(
                                      color: AppColors.neutral200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.appColors.onSurface.withValues(
                                          alpha: 0.02,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: responseController,
                                    maxLines: 4,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.neutral800,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Tuliskan respon resmi, klarifikasi, atau solusi...',
                                      hintStyle: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.neutral400,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // FOOTER ACTIONS - only show if user has permission
                      if (canRespond)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface.withValues(alpha: 0.9),
                            border: Border(
                              top: BorderSide(color: AppColors.neutral200),
                            ),
                          ),
                          child:
                              isSubmitting
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 52,
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              setModalState(
                                                () => isSubmitting = true,
                                              );
                                              try {
                                                await context
                                                    .read<OrmawaProvider>()
                                                    .respondToAspiration(
                                                      item.id,
                                                      {
                                                        'Status': 'diabaikan',
                                                        'Tanggapan':
                                                            responseController
                                                                .text,
                                                      },
                                                    );
                                                if (context.mounted) {
                                                  context.pop();
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  AppSnackbar.showError(
                                                    context,
                                                    'Error: $e',
                                                  );
                                                }
                                              } finally {
                                                setModalState(
                                                  () => isSubmitting = false,
                                                );
                                              }
                                            },

                                            child: Text(
                                              'ABAIKAN',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: AppColors.neutral600,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.5,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setModalState(
                                                () => isSubmitting = true,
                                              );
                                              try {
                                                await context
                                                    .read<OrmawaProvider>()
                                                    .respondToAspiration(
                                                      item.id,
                                                      {
                                                        'Status': 'ditanggapi',
                                                        'Tanggapan':
                                                            responseController
                                                                .text,
                                                      },
                                                    );
                                                if (context.mounted) {
                                                  context.pop();
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  AppSnackbar.showError(
                                                    context,
                                                    'Error: $e',
                                                  );
                                                }
                                              } finally {
                                                setModalState(
                                                  () => isSubmitting = false,
                                                );
                                              }
                                            },

                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.send_rounded,
                                                  color: context.appColors.onPrimary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: AppSpacing.sm),
                                                Text(
                                                  'KIRIM TANGGAPAN',
                                                  style: AppTextStyles.labelSm
                                                      .copyWith(
                                        color: context.appColors.onPrimary,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 1.5,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Urutkan & Filter',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Urutkan',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _sortOptions.map((option) {
                        final isSelected =
                            _sortOrder ==
                            option.toLowerCase().replaceAll('ter', '');
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () =>
                                  _sortOrder = option.toLowerCase().replaceAll(
                                    'ter',
                                    '',
                                  ),
                            );
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? context.appColors.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(10),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              option,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isSelected
                                        ? context.appColors.onPrimary
                                        : context.appColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Filter Status',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _filterOptions.map((option) {
                        final isSelected = _filterStatus == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _filterStatus = option);
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? context.appColors.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(10),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              option,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isSelected
                                        ? context.appColors.onPrimary
                                        : context.appColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (_filterStatus != 'Semua' || _sortOrder != 'terbaru')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _sortOrder = 'terbaru';
                          _filterStatus = 'Semua';
                        });
                        context.pop();
                      },
                      child: Text(
                        'Reset',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
    );
  }
}
