import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class OrmawaPengumumanScreen extends StatefulWidget {
  const OrmawaPengumumanScreen({super.key});

  @override
  State<OrmawaPengumumanScreen> createState() => _OrmawaPengumumanScreenState();
}

class _OrmawaPengumumanScreenState extends State<OrmawaPengumumanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterTarget = 'Semua';

  final List<String> _targetOptions = [
    'Semua',
    'Umum',
    'Kegiatan',
    'Penting',
    'Informasi',
  ];

  Color _getCategoryColor(String target) {
    switch (target.toLowerCase()) {
      case 'umum':
        return AppColors.neutral600;
      case 'kegiatan':
        return const Color(0xFF2563EB);
      case 'penting':
        return AppColors.error;
      case 'info':
      case 'informasi':
        return const Color(0xFF0EA5E9);
      default:
        return AppColors.neutral600;
    }
  }

  String _getCategoryLabel(String target) {
    switch (target.toLowerCase()) {
      case 'umum':
        return 'UMUM';
      case 'kegiatan':
        return 'KEGIATAN';
      case 'penting':
        return 'PENTING';
      case 'info':
      case 'informasi':
        return 'INFORMASI';
      default:
        return target.toUpperCase();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final canCreateAnnouncement = ormawaProvider.hasPermission(
      'create_announcements',
    );

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'PUSAT PENGUMUMAN',
              subtitle: 'INFORMASI',
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
                    const SizedBox(height: 24),
                    OrmawaListHeader(
                      title: 'REKAPITULASI SIARAN',
                      searchHint: 'Cari judul pengumuman...',
                      searchController: _searchController,
                      onRefresh:
                          () => context.read<OrmawaProvider>().refreshData(),
                      onFilterTap: () => _showFilterSheet(),
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    _buildPengumumanList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          canCreateAnnouncement
              ? FloatingActionButton.extended(
                onPressed: () => _showAddPengumuman(context),
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.campaign_rounded, color: Colors.white),
                label: const Text(
                  'Buat Pengumuman',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildSummaryGrid() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final announcements = provider.announcements;
        final total = announcements.length;
        final now = DateTime.now();
        final active =
            announcements
                .where(
                  (e) =>
                      (e.tanggalMulai == null ||
                          e.tanggalMulai!.isBefore(now)) &&
                      (e.tanggalSelesai == null ||
                          e.tanggalSelesai!.isAfter(now)),
                )
                .length;
        final archived = total - active;

        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            _buildStatCard(
              'Total',
              total.toString(),
              Icons.record_voice_over_rounded,
              Colors.cyan,
            ),
            _buildStatCard(
              'Aktif',
              active.toString(),
              Icons.check_circle_rounded,
              AppColors.success,
            ),
            _buildStatCard(
              'Arsip',
              archived.toString(),
              Icons.archive_rounded,
              Colors.grey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengumumanList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filteredList =
            provider.announcements.where((item) {
              final matchesSearch =
                  item.judul.toLowerCase().contains(_searchQuery) ||
                  item.isi.toLowerCase().contains(_searchQuery);

              if (_filterTarget == 'Semua') {
                return matchesSearch;
              }

              final String normFilter = _filterTarget.toLowerCase();
              final String normItem = item.target.toLowerCase();

              bool matchesFilter = false;
              if (normFilter == 'informasi') {
                matchesFilter = (normItem == 'info' || normItem == 'informasi');
              } else {
                matchesFilter = (normItem == normFilter);
              }

              return matchesSearch && matchesFilter;
            }).toList();

        if (filteredList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 48,
                    color: Colors.grey.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengumuman ditemukan',
                    style: AppTextStyles.labelMd.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final announcement = filteredList[index];
            return _buildPengumumanCard(announcement);
          },
        );
      },
    );
  }

  Widget _buildPengumumanCard(OrmawaAnnouncement announcement) {
    final color = _getCategoryColor(announcement.target);
    final label = _getCategoryLabel(announcement.target);

    final displayDate = announcement.tanggalMulai ?? announcement.createdAt;
    String dateStr = 'Beberapa saat lalu';
    bool isScheduled = false;
    if (displayDate != null) {
      dateStr = DateFormat('dd MMM yyyy', 'id').format(displayDate);
      if (announcement.tanggalMulai != null &&
          announcement.tanggalMulai!.isAfter(DateTime.now())) {
        isScheduled = true;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(10),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.neutral500,
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditPengumuman(context, announcement);
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (dialogCtx) => CustomDialog(
                            title: 'Hapus Pengumuman?',
                            content:
                                'Data yang dihapus tidak dapat dikembalikan.',
                            cancelText: 'Batal',
                            confirmText: 'Hapus',
                            isDestructive: true,
                            onCancel: () => Navigator.pop(dialogCtx, false),
                            onConfirm: () => Navigator.pop(dialogCtx, true),
                          ),
                    );
                    if (confirm == true) {
                      if (mounted) {
                        await context.read<OrmawaProvider>().deleteAnnouncement(
                          announcement.id,
                        );
                      }
                    }
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.judul,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            announcement.isi,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isScheduled
                    ? Icons.schedule_rounded
                    : Icons.access_time_rounded,
                size: 14,
                color: isScheduled ? Colors.amber[700] : AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                isScheduled ? 'Dijadwalkan: $dateStr' : dateStr,
                style: AppTextStyles.labelSm.copyWith(
                  color: isScheduled ? Colors.amber[800] : AppColors.neutral600,
                  fontWeight: isScheduled ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAnnouncementDetail(announcement),
                child: _buildIconButton(
                  Icons.visibility_outlined,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDetail(OrmawaAnnouncement announcement) {
    final label = _getCategoryLabel(announcement.target);

    final displayDate = announcement.tanggalMulai ?? announcement.createdAt;
    bool isScheduled = false;
    String dateLabel = 'Diterbitkan pada';
    if (displayDate != null) {
      if (announcement.tanggalMulai != null &&
          announcement.tanggalMulai!.isAfter(DateTime.now())) {
        isScheduled = true;
        dateLabel = 'Dijadwalkan rilis pada';
      }
    }

    LinearGradient categoryGradient;
    switch (announcement.target.toLowerCase()) {
      case 'umum':
        categoryGradient = const LinearGradient(
          colors: [AppColors.neutral600, AppColors.neutral700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'kegiatan':
        categoryGradient = const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'penting':
        categoryGradient = const LinearGradient(
          colors: [AppColors.error, Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'info':
      case 'informasi':
        categoryGradient = const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      default:
        categoryGradient = const LinearGradient(
          colors: [AppColors.neutral600, AppColors.neutral700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: categoryGradient),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: AppRadius.radiusXs,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              label,
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SIARAN ANN-${announcement.id}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        announcement.judul,
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            isScheduled
                                ? Icons.schedule_rounded
                                : Icons.calendar_month_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            displayDate != null
                                ? '$dateLabel ${DateFormat('dd MMMM yyyy, HH:mm', 'id').format(displayDate)}'
                                : '',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: AppColors.neutral300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.admin_panel_settings_rounded,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'OLEH ORMAWA',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF94A3B8,
                                                    ),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Badan Pengurus Harian',
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF334155,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: AppColors.neutral300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.08,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.people_alt_rounded,
                                          color: AppColors.success,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'TARGET PEMBACA',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF94A3B8,
                                                    ),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Seluruh Anggota',
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF334155,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content Header and Box
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ISI PENGUMUMAN RESMI',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: AppRadius.radiusXl,
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                  ),
                                ),
                                child: Text(
                                  announcement.isi,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.neutral700,
                                    height: 1.6,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Buttons Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.neutral300, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          text: 'TUTUP',
                          onPressed: () => Navigator.pop(context),
                          variant: BkuButtonVariant.outline,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: BkuButton(
                          text: 'EDIT PENGUMUMAN',
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditPengumuman(context, announcement);
                          },
                          variant: BkuButtonVariant.primary,
                          icon: Icons.edit_note_rounded,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  void _showAddPengumuman(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrmawaCreatePengumumanScreen(),
      ),
    );
  }

  void _showEditPengumuman(
    BuildContext context,
    OrmawaAnnouncement announcement,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                OrmawaCreatePengumumanScreen(announcement: announcement),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                const SizedBox(height: 24),
                Text(
                  'Filter Kategori',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _targetOptions.map((option) {
                        final isSelected = _filterTarget == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _filterTarget = option);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
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
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (_filterTarget != 'Semua')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton(
                      onPressed: () {
                        setState(() => _filterTarget = 'Semua');
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset Filter',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}

class OrmawaCreatePengumumanScreen extends StatefulWidget {
  final OrmawaAnnouncement? announcement;

  const OrmawaCreatePengumumanScreen({super.key, this.announcement});

  @override
  State<OrmawaCreatePengumumanScreen> createState() =>
      _OrmawaCreatePengumumanScreenState();
}

class _OrmawaCreatePengumumanScreenState
    extends State<OrmawaCreatePengumumanScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  String _selectedTarget = 'umum';
  bool _isSubmitting = false;
  DateTime? _selectedTanggalMulai;

  bool get isEditing => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _judulController.text = widget.announcement!.judul;
      _isiController.text = widget.announcement!.isi;

      final originalTarget = widget.announcement!.target.toLowerCase();
      if (originalTarget == 'informasi') {
        _selectedTarget = 'info';
      } else {
        _selectedTarget = originalTarget;
      }
      _selectedTanggalMulai = widget.announcement!.tanggalMulai;
    } else {
      _selectedTarget = 'umum';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawaId = context.read<OrmawaProvider>().ormawaId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: isEditing ? 'EDIT PENGUMUMAN' : 'BUAT PENGUMUMAN BARU',
            subtitle: 'PUBLIKASI INFORMASI',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(10),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          Icons.campaign_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: AppRadius.radiusXs,
                              ),
                              child: Text(
                                'ANNOUNCEMENT',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                            Text(
                              'BUAT PENGUMUMAN BARU',
                              style: AppTextStyles.titleLg.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publikasikan informasi penting untuk seluruh anggota.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(
                    'JUDUL PENGUMUMAN',
                    'Masukkan judul pengumuman...',
                    Icons.title_rounded,
                    controller: _judulController,
                  ),
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  _buildDateField(
                    'TANGGAL RILIS (OPSIONAL)',
                    'Pilih tanggal rilis...',
                    Icons.calendar_month_rounded,
                    _selectedTanggalMulai,
                    (date) {
                      setState(() {
                        _selectedTanggalMulai = date;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    'ISI PENGUMUMAN',
                    'Tuliskan isi pengumuman di sini...',
                    Icons.description_rounded,
                    maxLines: 8,
                    controller: _isiController,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          text: 'BATALKAN',
                          onPressed: () => Navigator.pop(context),
                          variant: BkuButtonVariant.outline,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: BkuButton(
                          text:
                              isEditing
                                  ? 'SIMPAN PERUBAHAN'
                                  : 'PUBLISH SEKARANG',
                          onPressed: () async {
                            if (_judulController.text.isEmpty ||
                                _isiController.text.isEmpty) {
                              AppSnackbar.showWarning(
                                context,
                                'Judul dan Isi wajib diisi',
                              );
                              return;
                            }

                            setState(() => _isSubmitting = true);
                            try {
                              final provider = context.read<OrmawaProvider>();
                              if (isEditing) {
                                await provider.updateAnnouncement(
                                  widget.announcement!.id,
                                  {
                                    'Judul': _judulController.text,
                                    'Isi': _isiController.text,
                                    'Target': _selectedTarget,
                                    if (_selectedTanggalMulai != null)
                                      'TanggalMulai':
                                          _selectedTanggalMulai!
                                              .toUtc()
                                              .toIso8601String(),
                                  },
                                );
                              } else {
                                await provider.createAnnouncement({
                                  'OrmawaID': int.parse(ormawaId!),
                                  'Judul': _judulController.text,
                                  'Isi': _isiController.text,
                                  'Target': _selectedTarget,
                                  if (_selectedTanggalMulai != null)
                                    'TanggalMulai':
                                        _selectedTanggalMulai!
                                            .toUtc()
                                            .toIso8601String(),
                                });
                              }
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackbar.showError(context, 'Error: $e');
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                          variant: BkuButtonVariant.success,
                          isLoading: _isSubmitting,
                          icon:
                              isEditing
                                  ? Icons.save_rounded
                                  : Icons.send_rounded,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        BkuTextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral400,
            ),
            prefixIcon: Icon(icon, color: AppColors.neutral500, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: const BorderSide(
                color: AppColors.neutral300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: const BorderSide(
                color: AppColors.neutral300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {
        'id': 'umum',
        'label': 'UMUM',
        'icon': Icons.feed_rounded,
        'color': AppColors.neutral600,
      },
      {
        'id': 'kegiatan',
        'label': 'KEGIATAN',
        'icon': Icons.event_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'id': 'penting',
        'label': 'PENTING',
        'icon': Icons.warning_rounded,
        'color': AppColors.error,
      },
      {
        'id': 'info',
        'label': 'INFORMASI',
        'icon': Icons.info_rounded,
        'color': const Color(0xFF0EA5E9),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH KATEGORI SIARAN',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final id = cat['id'] as String;
            final label = cat['label'] as String;
            final icon = cat['icon'] as IconData;
            final baseColor = cat['color'] as Color;
            final isSelected = _selectedTarget.toLowerCase() == id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTarget = id;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? baseColor : Colors.white,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : AppColors.neutral300,
                    width: 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: baseColor.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : baseColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? Colors.white : AppColors.neutral700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    String hint,
    IconData icon,
    DateTime? date,
    Function(DateTime) onDateSelected,
  ) {
    final displayStr =
        date != null ? DateFormat('dd MMMM yyyy', 'id').format(date) : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary,
                      onPrimary: Colors.white,
                      onSurface: AppColors.neutral800,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          borderRadius: AppRadius.radiusMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.neutral500, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayStr,
                    style: AppTextStyles.bodyMd.copyWith(
                      color:
                          date != null
                              ? AppColors.neutral800
                              : AppColors.neutral500,
                      fontWeight:
                          date != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTanggalMulai = null;
                      });
                    },
                    child: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
