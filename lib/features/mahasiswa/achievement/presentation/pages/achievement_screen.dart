import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/achievement.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/report_achievement_screen.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  String _searchQuery = '';
  String _filterTipe = 'Semua';
  String _filterStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().loadAcademicData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();

    final filteredAchievements = academic.achievements.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchOrg = item.organizer.toLowerCase().contains(q);
        final matchCabang = (item.cabang ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchOrg && !matchCabang) return false;
      }

      if (_filterTipe != 'Semua') {
        final tipe = item.tipe ?? 'Prestasi Mandiri';
        if (_filterTipe == 'Prestasi Mandiri' && tipe != 'Prestasi Mandiri' && tipe != 'Laporan Prestasi') {
          return false;
        } else if (_filterTipe != 'Prestasi Mandiri' && !tipe.toLowerCase().contains(_filterTipe.toLowerCase())) {
          return false;
        }
      }

      if (_filterStatus != 'Semua') {
        final st = item.status.toLowerCase();
        if (_filterStatus == 'Menunggu' && !st.contains('menunggu') && !st.contains('pending')) {
          return false;
        } else if (_filterStatus == 'Diverifikasi' && !st.contains('verifikasi') && !st.contains('valid') && !st.contains('disetujui')) {
          return false;
        } else if (_filterStatus == 'Ditolak' && !st.contains('tolak') && !st.contains('reject')) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => academic.loadAcademicData(),
        color: BkuTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            const BkuAppBar(
              title: 'Prestasi Mahasiswa',
              subtitle: 'Rekap Capaian & Pengajuan Dana',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const FadeInAnimation(delay: 0.1, child: _KpiStatsSection()),
                    const SizedBox(height: AppSpacing.xl),
                    FadeInAnimation(
                      delay: 0.2,
                      child: _buildSearchAndFilters(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Prestasi (${filteredAchievements.length})',
                          style: BkuTheme.textSectionTitle.copyWith(
                            fontSize: 14,
                            color: BkuTheme.textHeading,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _filterTipe != 'Semua' || _filterStatus != 'Semua')
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                                _filterTipe = 'Semua';
                                _filterStatus = 'Semua';
                              });
                            },
                            child: Text(
                              'Reset Filter',
                              style: BkuTheme.textCaption.copyWith(
                                color: BkuTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (academic.isLoading)
                      const BkuShimmerList(itemCount: 3, itemHeight: 140)
                    else if (filteredAchievements.isEmpty)
                      FadeInAnimation(
                        delay: 0.3,
                        child: _EmptyState(
                          hasFilter: _searchQuery.isNotEmpty || _filterTipe != 'Semua' || _filterStatus != 'Semua',
                        ),
                      )
                    else
                      ...List.generate(filteredAchievements.length, (index) {
                        return FadeInAnimation(
                          delay: 0.3 + (index * 0.05),
                          child: _AchievementCard(
                            achievement: filteredAchievements[index],
                            onRefresh: () => academic.loadAcademicData(),
                          ),
                        );
                      }),
                    const SizedBox(height: AppSpacing.s160),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          border: const Border(top: BorderSide(color: BkuTheme.borderSubtle)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x080F172A),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BkuButton(
            text: 'Ajukan Prestasi Baru',
            icon: Icons.add_rounded,
            variant: BkuButtonVariant.primary,
            onPressed: () => context.push(AppRoutes.createAchievement),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r16,
            border: Border.all(color: BkuTheme.border),
            boxShadow: BkuTheme.cardShadow,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari nama kegiatan / penyelenggara...',
              hintStyle: BkuTheme.textCardSubtitle.copyWith(
                color: BkuTheme.textPlaceholder,
                fontSize: 13,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: BkuTheme.primary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: BkuTheme.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Semua Tipe',
                isSelected: _filterTipe == 'Semua',
                onTap: () => setState(() => _filterTipe = 'Semua'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Prestasi Mandiri',
                isSelected: _filterTipe == 'Prestasi Mandiri',
                onTap: () => setState(() => _filterTipe = 'Prestasi Mandiri'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Pengajuan Dana',
                isSelected: _filterTipe == 'Pengajuan Dana',
                onTap: () => setState(() => _filterTipe = 'Pengajuan Dana'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Sertifikasi',
                isSelected: _filterTipe == 'Sertifikasi',
                onTap: () => setState(() => _filterTipe = 'Sertifikasi'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Rekognisi',
                isSelected: _filterTipe == 'Rekognisi',
                onTap: () => setState(() => _filterTipe = 'Rekognisi'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStatusChip(
                label: 'Semua Status',
                isSelected: _filterStatus == 'Semua',
                color: BkuTheme.textHeading,
                bgColor: BkuTheme.cardSurface,
                borderColor: BkuTheme.border,
                onTap: () => setState(() => _filterStatus = 'Semua'),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                label: 'Menunggu',
                isSelected: _filterStatus == 'Menunggu',
                color: BkuTheme.amber,
                bgColor: BkuTheme.amberSoft,
                borderColor: BkuTheme.amberBorder,
                onTap: () => setState(() => _filterStatus = 'Menunggu'),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                label: 'Diverifikasi',
                isSelected: _filterStatus == 'Diverifikasi',
                color: BkuTheme.emerald,
                bgColor: BkuTheme.emeraldSoft,
                borderColor: BkuTheme.emeraldBorder,
                onTap: () => setState(() => _filterStatus = 'Diverifikasi'),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                label: 'Ditolak',
                isSelected: _filterStatus == 'Ditolak',
                color: BkuTheme.rose,
                bgColor: BkuTheme.roseSoft,
                borderColor: BkuTheme.roseBorder,
                onTap: () => setState(() => _filterStatus = 'Ditolak'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BkuTheme.rPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BkuTheme.primary : BkuTheme.cardSurface,
          borderRadius: BkuTheme.rPill,
          border: Border.all(
            color: isSelected ? BkuTheme.primary : BkuTheme.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: BkuTheme.primary.withAlpha(50),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: BkuTheme.textBadge.copyWith(
            color: isSelected ? Colors.white : BkuTheme.textHeading,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isSelected,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BkuTheme.rPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : BkuTheme.cardSurface,
          borderRadius: BkuTheme.rPill,
          border: Border.all(
            color: isSelected ? borderColor : BkuTheme.border,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: BkuTheme.textBadge.copyWith(
            color: isSelected ? color : BkuTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _KpiStatsSection extends StatelessWidget {
  const _KpiStatsSection();

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total Pengajuan',
            value: '${academic.totalAchievements}',
            icon: Icons.emoji_events_rounded,
            color: BkuTheme.indigo,
            bgColor: BkuTheme.indigoSoft,
            borderColor: BkuTheme.indigoBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KpiCard(
            label: 'Diverifikasi',
            value: '${academic.validatedAchievements}',
            icon: Icons.verified_rounded,
            color: BkuTheme.emerald,
            bgColor: BkuTheme.emeraldSoft,
            borderColor: BkuTheme.emeraldBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KpiCard(
            label: 'Menunggu Review',
            value: '${academic.pendingAchievements}',
            icon: Icons.hourglass_top_rounded,
            color: BkuTheme.amber,
            bgColor: BkuTheme.amberSoft,
            borderColor: BkuTheme.amberBorder,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: BkuTheme.textKpiValue.copyWith(
              fontSize: 20,
              color: BkuTheme.textHeading,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: BkuTheme.textCaption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: BkuTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onRefresh;

  const _AchievementCard({
    required this.achievement,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final status = achievement.status;
    final isVerified = status == 'Validated' || status == 'Diverifikasi' || status == 'Valid' || status == 'Disetujui';
    final isRejected = status == 'Rejected' || status == 'Ditolak';

    Color statusBg = isVerified
        ? BkuTheme.statusSuccessBg
        : isRejected
            ? BkuTheme.statusDangerBg
            : BkuTheme.statusWarningBg;
    Color statusText = isVerified
        ? BkuTheme.statusSuccessText
        : isRejected
            ? BkuTheme.statusDangerText
            : BkuTheme.statusWarningText;
    Color statusBorder = isVerified
        ? BkuTheme.statusSuccessBorder
        : isRejected
            ? BkuTheme.statusDangerBorder
            : BkuTheme.statusWarningBorder;
    IconData statusIcon = isVerified
        ? Icons.check_circle_rounded
        : isRejected
            ? Icons.cancel_rounded
            : Icons.hourglass_empty_rounded;

    final date = achievement.date;
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

    final isDana = achievement.tipe == 'Pengajuan Dana' ||
        (achievement.danaDiajukan != null && double.tryParse(achievement.danaDiajukan ?? '0') != null && double.parse(achievement.danaDiajukan ?? '0') > 0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAchievementDetail(context, achievement),
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDana ? BkuTheme.emeraldSoft : BkuTheme.indigoSoft,
                            borderRadius: BkuTheme.rPill,
                            border: Border.all(color: isDana ? BkuTheme.emeraldBorder : BkuTheme.indigoBorder),
                          ),
                          child: Text(
                            isDana ? 'Pengajuan Dana' : (achievement.tipe ?? 'Laporan Prestasi'),
                            style: BkuTheme.textBadge.copyWith(
                              color: isDana ? BkuTheme.emerald : BkuTheme.indigo,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (achievement.level.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BkuTheme.amberSoft,
                              borderRadius: BkuTheme.rPill,
                              border: Border.all(color: BkuTheme.amberBorder),
                            ),
                            child: Text(
                              achievement.level,
                              style: BkuTheme.textBadge.copyWith(
                                color: BkuTheme.amber,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BkuTheme.rPill,
                        border: Border.all(color: statusBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusText, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? 'Diverifikasi' : (isRejected ? 'Ditolak' : 'Menunggu'),
                            style: BkuTheme.textBadge.copyWith(
                              color: statusText,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDana ? BkuTheme.emeraldSoft : BkuTheme.amberSoft,
                        borderRadius: BkuTheme.r12,
                        border: Border.all(color: isDana ? BkuTheme.emeraldBorder : BkuTheme.amberBorder),
                      ),
                      child: Icon(
                        isDana ? Icons.payments_rounded : Icons.emoji_events_rounded,
                        color: isDana ? BkuTheme.emerald : BkuTheme.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: BkuTheme.textCardTitle.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            achievement.organizer,
                            style: BkuTheme.textCardSubtitle.copyWith(
                              fontSize: 11,
                              color: BkuTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDana && achievement.danaDiajukan != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BkuTheme.emeraldSoft.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Nominal Diajukan: Rp ${_formatRupiah(achievement.danaDiajukan)}',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.emerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _MiniStatusTimeline(status: achievement.status),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: BkuTheme.textPlaceholder),
                    const SizedBox(width: 5),
                    Text(formattedDate, style: BkuTheme.textCaption.copyWith(fontSize: 10.5)),
                    const Spacer(),
                    if (achievement.isSynced)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: BkuTheme.tealSoft,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: BkuTheme.tealBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sync_rounded, size: 10, color: BkuTheme.teal),
                            const SizedBox(width: 3),
                            Text(
                              'SIMKATMAWA',
                              style: BkuTheme.textBadge.copyWith(
                                fontSize: 8.5,
                                color: BkuTheme.teal,
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
        ),
      ),
    );
  }

  static String _formatRupiah(String? raw) {
    if (raw == null || raw.isEmpty) return '0';
    final numVal = double.tryParse(raw) ?? 0;
    return numVal.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    final status = achievement.status;
    final isVerified = status == 'Validated' || status == 'Diverifikasi' || status == 'Valid' || status == 'Disetujui';
    final isRejected = status == 'Rejected' || status == 'Ditolak';
    final isPending = !isVerified && !isRejected;

    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _StatusTimelineFull(status: achievement.status),
                  const SizedBox(height: AppSpacing.lg),
                  if (achievement.catatanVerifikator != null && achievement.catatanVerifikator!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isRejected ? BkuTheme.roseSoft : BkuTheme.amberSoft,
                        borderRadius: BkuTheme.r12,
                        border: Border.all(color: isRejected ? BkuTheme.roseBorder : BkuTheme.amberBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isRejected ? Icons.warning_rounded : Icons.info_outline_rounded,
                            color: isRejected ? BkuTheme.rose : BkuTheme.amber,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRejected ? 'Alasan Penolakan:' : 'Catatan Verifikator:',
                                  style: BkuTheme.textCardTitle.copyWith(
                                    fontSize: 11.5,
                                    color: isRejected ? BkuTheme.rose : BkuTheme.amber,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  achievement.catatanVerifikator!,
                                  style: BkuTheme.textCardSubtitle.copyWith(
                                    fontSize: 11.5,
                                    color: BkuTheme.textHeading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    achievement.title,
                    style: BkuTheme.textPageTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.organizer,
                    style: BkuTheme.textCardSubtitle.copyWith(
                      color: BkuTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Informasi Capaian', style: BkuTheme.textSectionTitle),
                  const SizedBox(height: AppSpacing.md),
                  _DetailRow(icon: Icons.category_rounded, label: 'Tipe', value: achievement.tipe ?? 'Prestasi Mandiri'),
                  _DetailRow(icon: Icons.layers_rounded, label: 'Tingkat', value: achievement.level),
                  _DetailRow(icon: Icons.emoji_events_rounded, label: 'Pencapaian', value: achievement.rank),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal',
                    value: "${achievement.date.day}/${achievement.date.month}/${achievement.date.year}",
                  ),
                  if (achievement.danaDiajukan != null && double.tryParse(achievement.danaDiajukan ?? '0') != null && double.parse(achievement.danaDiajukan ?? '0') > 0)
                    _DetailRow(
                      icon: Icons.payments_rounded,
                      label: 'Dana Diajukan',
                      value: 'Rp ${_formatRupiah(achievement.danaDiajukan)}',
                      valueColor: BkuTheme.emerald,
                    ),
                  _DetailRow(
                    icon: Icons.sync_rounded,
                    label: 'SIMKATMAWA',
                    value: achievement.isSynced ? 'Sinkron ke Belmawa' : 'Belum Sinkron',
                    valueColor: achievement.isSynced ? BkuTheme.emerald : BkuTheme.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Dokumen & Berkas Lampiran', style: BkuTheme.textSectionTitle),
                  const SizedBox(height: AppSpacing.md),
                  if (achievement.certificateUrl != null && achievement.certificateUrl!.isNotEmpty)
                    _buildDocumentTile(
                      title: 'Sertifikat_Prestasi',
                      url: achievement.certificateUrl!,
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: BkuTheme.rose,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('Tidak ada berkas sertifikat yang dilampirkan.', style: BkuTheme.textCaption),
                    ),
                  if (achievement.urlDokumenUndangan != null && achievement.urlDokumenUndangan!.isNotEmpty)
                    _buildDocumentTile(
                      title: 'Surat_Tugas_Undangan',
                      url: achievement.urlDokumenUndangan!,
                      icon: Icons.description_rounded,
                      iconColor: BkuTheme.indigo,
                    ),
                  if (achievement.urlPeserta != null && achievement.urlPeserta!.isNotEmpty)
                    _buildDocumentTile(
                      title: 'Tautan Dokumentasi / Lomba',
                      url: achievement.urlPeserta!,
                      icon: Icons.link_rounded,
                      iconColor: BkuTheme.primary,
                    ),
                  const SizedBox(height: AppSpacing.s20),
                ],
              ),
            ),
            if (isPending) ...[
              const Divider(height: 24, color: BkuTheme.borderSubtle),
              Row(
                children: [
                  Expanded(
                    child: BkuButton(
                      text: 'Hapus',
                      icon: Icons.delete_outline_rounded,
                      variant: BkuButtonVariant.outline,
                      onPressed: () => _handleDelete(context, achievement),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: BkuButton(
                      text: 'Edit Data',
                      icon: Icons.edit_rounded,
                      variant: BkuButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportAchievementScreen(achievement: achievement),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildDocumentTile({
    required String title,
    required String url,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('Ketuk untuk melihat berkas', style: BkuTheme.textCaption.copyWith(fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_new_rounded, size: 18, color: BkuTheme.primary),
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, Achievement achievement) async {
    final confirm = await BkuDialog.show(
      context: context,
      type: BkuDialogType.warning,
      title: 'Hapus Laporan Prestasi?',
      message: 'Apakah Anda yakin ingin menghapus data pengajuan ini? Tindakan ini tidak dapat dibatalkan.',
      primaryButtonText: 'Ya, Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () => context.pop(true),
      onSecondaryPressed: () => context.pop(false),
    );

    if (confirm == true && context.mounted) {
      try {
        BkuLoadingDialog.show(context);
        await context.read<AcademicProvider>().deleteAchievement(achievement.id);
        if (context.mounted) BkuLoadingDialog.hide(context);
        if (context.mounted) Navigator.pop(context);
        onRefresh();
      } catch (e) {
        if (context.mounted) BkuLoadingDialog.hide(context);
        if (context.mounted) {
          BkuDialog.show(
            context: context,
            type: BkuDialogType.error,
            title: 'Gagal Menghapus',
            message: ErrorHandler.getMessage(e),
            primaryButtonText: 'Tutup',
            onPrimaryPressed: () => context.pop(),
          );
        }
      }
    }
  }
}

class _MiniStatusTimeline extends StatelessWidget {
  final String status;
  const _MiniStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final isVerified = status == 'Validated' || status == 'Diverifikasi' || status == 'Valid' || status == 'Disetujui';
    final isRejected = status == 'Rejected' || status == 'Ditolak';

    final steps = [
      {'label': 'Terkirim', 'done': true, 'error': false},
      {'label': 'Diproses', 'done': isVerified || isRejected, 'error': false},
      {'label': isRejected ? 'Ditolak' : 'Disetujui', 'done': isVerified || isRejected, 'error': isRejected},
    ];

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (steps[i]['done'] as bool)
                      ? ((steps[i]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                      : BkuTheme.borderSubtle,
                ),
                child: Icon(
                  (steps[i]['done'] as bool)
                      ? ((steps[i]['error'] as bool) ? Icons.close_rounded : Icons.check_rounded)
                      : Icons.circle,
                  size: 9,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                steps[i]['label'] as String,
                style: BkuTheme.textCaption.copyWith(
                  fontSize: 9.5,
                  fontWeight: (steps[i]['done'] as bool) ? FontWeight.w700 : FontWeight.w500,
                  color: (steps[i]['done'] as bool)
                      ? ((steps[i]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                      : BkuTheme.textMuted,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: (steps[i + 1]['done'] as bool)
                    ? ((steps[i + 1]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                    : BkuTheme.borderSubtle,
              ),
            ),
        ],
      ],
    );
  }
}

class _StatusTimelineFull extends StatelessWidget {
  final String status;
  const _StatusTimelineFull({required this.status});

  @override
  Widget build(BuildContext context) {
    final isVerified = status == 'Validated' || status == 'Diverifikasi' || status == 'Valid' || status == 'Disetujui';
    final isRejected = status == 'Rejected' || status == 'Ditolak';

    final steps = [
      {'label': 'Terkirim', 'icon': Icons.upload_file_rounded, 'done': true, 'error': false},
      {'label': 'Diproses Verifikator', 'icon': Icons.manage_search_rounded, 'done': isVerified || isRejected, 'error': false},
      {'label': isRejected ? 'Ditolak' : 'Disetujui', 'icon': isRejected ? Icons.cancel_rounded : Icons.verified_rounded, 'done': isVerified || isRejected, 'error': isRejected},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: (steps[i]['done'] as bool)
                          ? ((steps[i]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                          : BkuTheme.borderSubtle,
                    ),
                    child: Icon(
                      steps[i]['icon'] as IconData,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[i]['label'] as String,
                    textAlign: TextAlign.center,
                    style: BkuTheme.textCaption.copyWith(
                      fontSize: 10,
                      fontWeight: (steps[i]['done'] as bool) ? FontWeight.w700 : FontWeight.w500,
                      color: (steps[i]['done'] as bool)
                          ? ((steps[i]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                          : BkuTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: (steps[i + 1]['done'] as bool)
                    ? ((steps[i + 1]['error'] as bool) ? BkuTheme.rose : BkuTheme.emerald)
                    : BkuTheme.borderSubtle,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: BkuTheme.textPlaceholder),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: BkuTheme.textCardSubtitle.copyWith(fontSize: 12)),
          const Spacer(),
          Text(
            value,
            style: BkuTheme.textCardTitle.copyWith(
              fontSize: 12,
              color: valueColor ?? BkuTheme.textHeading,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: BkuTheme.amberSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined, color: BkuTheme.amber, size: 36),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasFilter ? 'Tidak Ada Prestasi yang Cocok' : 'Belum Ada Riwayat Prestasi',
            style: BkuTheme.textSectionTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            hasFilter
                ? 'Coba gunakan kata kunci lain atau ubah filter tipe dan status.'
                : 'Ajukan laporan prestasi atau pengajuan dana untuk menambah capaian portofolio kamu.',
            textAlign: TextAlign.center,
            style: BkuTheme.textCardSubtitle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
