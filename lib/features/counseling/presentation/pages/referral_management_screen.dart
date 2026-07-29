import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/referral_provider.dart';
import 'package:bkuhub_mobile/features/counseling/data/models/counseling_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class ReferralManagementScreen extends StatefulWidget {
  const ReferralManagementScreen({super.key});

  @override
  State<ReferralManagementScreen> createState() =>
      _ReferralManagementScreenState();
}

class _ReferralManagementScreenState extends State<ReferralManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  int _currentPage = 1;
  final int _pageSize = 5;

  final List<Map<String, dynamic>> _statusFilters = [
    {
      'label': 'Semua',
      'icon': Icons.dashboard_rounded,
      'activeBg': const Color(0xFFF1F5F9),
      'activeFg': const Color(0xFF0F172A),
      'activeBorder': const Color(0xFFCBD5E1),
    },
    {
      'label': 'Pending',
      'icon': Icons.hourglass_empty_rounded,
      'activeBg': const Color(0xFFFEF3C7),
      'activeFg': const Color(0xFFB45309),
      'activeBorder': const Color(0xFFFCD34D),
    },
    {
      'label': 'Sent',
      'icon': Icons.send_rounded,
      'activeBg': const Color(0xFFEFF6FF),
      'activeFg': const Color(0xFF1D4ED8),
      'activeBorder': const Color(0xFF93C5FD),
    },
    {
      'label': 'Selesai',
      'icon': Icons.check_circle_rounded,
      'activeBg': const Color(0xFFF0FDF4),
      'activeFg': const Color(0xFF15803D),
      'activeBorder': const Color(0xFF86EFAC),
    },
    {
      'label': 'Ditolak',
      'icon': Icons.cancel_outlined,
      'activeBg': const Color(0xFFFEF2F2),
      'activeFg': const Color(0xFFB91C1C),
      'activeBorder': const Color(0xFFFCA5A5),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferralProvider>().loadReferrals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Tindak Lanjut',
            variant:
                AuthService().currentRole == UserRole.tenagaKesehatan
                    ? AppBarVariant.nakes
                    : AppBarVariant.psychologist,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Create Referral Button
                  BkuCard(
                    onTap: () {
                      context.push(AppRoutes.createReferral);
                    },
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: themeProvider.primary.withAlpha(20),
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Icon(
                            Icons.add_task_rounded,
                            color: themeProvider.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buat Surat Rujukan',
                                style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.neutral900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s2),
                              Text(
                                'Pusatkan layanan ke instansi ahli',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppSpacing.padding6,
                          decoration: BoxDecoration(
                            color: themeProvider.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: themeProvider.primary,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // Stats Section
                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading || provider.referrals.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final total = provider.referrals.length;
                      final pending =
                          provider.referrals
                              .where(
                                (r) =>
                                    r.status == 'Pending' ||
                                    r.status == 'menunggu_approval',
                              )
                              .length;
                      final selesai =
                          provider.referrals
                              .where(
                                (r) =>
                                    r.status == 'Selesai' ||
                                    r.status == 'Diterima' ||
                                    r.status == 'Received',
                              )
                              .length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total\nRujukan',
                                total.toString(),
                                Icons.analytics_rounded,
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                'Menunggu\nPersetujuan',
                                pending.toString(),
                                Icons.pending_actions_rounded,
                                context.watch<ThemeProvider>().colors.warning,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildStatCard(
                                'Selesai\nDiproses',
                                selesai.toString(),
                                Icons.check_circle_rounded,
                                context.watch<ThemeProvider>().colors.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Search and Filter
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  _buildFilterChips(),
                  const SizedBox(height: AppSpacing.s20),

                  // Referrals List
                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xxl),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (provider.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          margin: const EdgeInsets.only(top: AppSpacing.s20),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withAlpha(20),
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                provider.error!,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      var filteredList =
                          provider.referrals.where((ref) {
                            final matchesSearch =
                                ref.mahasiswaNama.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                ref.pihakTujuan.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                );

                            if (_selectedFilter == 'Semua') {
                              return matchesSearch;
                            }

                            if (_selectedFilter == 'Selesai') {
                              return matchesSearch &&
                                  (ref.status == 'Diterima' ||
                                      ref.status == 'Received' ||
                                      ref.status == 'Selesai');
                            }
                            if (_selectedFilter == 'Pending') {
                              return matchesSearch &&
                                  (ref.status == 'Pending' ||
                                      ref.status == 'menunggu_approval');
                            }

                            return matchesSearch &&
                                ref.status == _selectedFilter;
                          }).toList();

                      final totalPages = (filteredList.length / _pageSize).ceil().clamp(1, 9999);
                      if (_currentPage > totalPages) {
                        _currentPage = totalPages;
                      }
                      final startIndex =
                          filteredList.isEmpty ? 0 : (_currentPage - 1) * _pageSize;
                      final endIndex =
                          (startIndex + _pageSize).clamp(0, filteredList.length);
                      final pagedFiltered =
                          filteredList.isEmpty
                              ? <Referral>[]
                              : filteredList.sublist(startIndex, endIndex);

                      if (filteredList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.neutral300,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                provider.referrals.isEmpty
                                    ? 'Belum Ada Rujukan'
                                    : 'Data Tidak Ditemukan',
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          if (totalPages > 1) ...[
                            _buildTopPagination(totalPages),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pagedFiltered.length,
                            itemBuilder: (context, index) {
                              final referral = pagedFiltered[index];
                              return _ReferralCard(referral: referral);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Cari rujukan',
          hintText: 'Cari nama pasien atau tujuan...',
          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final filterLabel = filter['label'] as String;
          final isSelected = _selectedFilter == filterLabel;
          final activeBg = filter['activeBg'] as Color;
          final activeFg = filter['activeFg'] as Color;
          final activeBorder = filter['activeBorder'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filterLabel;
                  _currentPage = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : context.appColors.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: isSelected ? activeBorder : AppColors.neutral200,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: activeFg.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected ? activeFg : AppColors.neutral500,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      filterLabel,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? activeFg : AppColors.neutral600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPagination(int totalPages) {
    final canPrev = _currentPage > 1;
    final canNext = _currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.br14,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: canPrev ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canPrev ? () => setState(() => _currentPage--) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 16,
                        color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canPrev ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Halaman $_currentPage dari $totalPages',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: canNext ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
              borderRadius: AppRadius.br10,
              child: InkWell(
                borderRadius: AppRadius.br10,
                onTap: canNext ? () => setState(() => _currentPage++) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: canNext ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            count,
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final Referral referral;

  const _ReferralCard({required this.referral});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
      case 'menunggu_approval':
        return AppColors.warning;
      case 'Sent':
        return AppColors.primary;
      case 'Received':
      case 'Selesai':
      case 'Diterima':
        return AppColors.success;
      case 'Ditolak':
        return AppColors.danger;
      default:
        return AppColors.neutral500;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Pending':
      case 'menunggu_approval':
        return AppColors.warningContainer;
      case 'Sent':
        return AppColors.primary.withAlpha(15);
      case 'Received':
      case 'Selesai':
      case 'Diterima':
        return AppColors.successContainer;
      case 'Ditolak':
        return AppColors.dangerContainer;
      default:
        return AppColors.neutral200;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
      case 'menunggu_approval':
        return 'Menunggu Persetujuan';
      case 'Sent':
        return 'Sudah Dikirim';
      case 'Received':
      case 'Selesai':
      case 'Diterima':
        return 'Disetujui & Selesai';
      case 'Ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  void _showDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.s20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Detail Tindak Lanjut',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.neutral200),

                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      // Mahasiswa Info
                      _buildDetailItem(
                        'Nama Pasien/Mahasiswa',
                        referral.mahasiswaNama,
                        Icons.person_rounded,
                      ),
                      _buildDetailItem(
                        'NIM Mahasiswa',
                        referral.mahasiswaNim != null &&
                                referral.mahasiswaNim!.isNotEmpty
                            ? referral.mahasiswaNim!
                            : '-',
                        Icons.badge_rounded,
                      ),
                      if (referral.suhuTubuh != null ||
                          referral.sistole != null) ...[
                        const Divider(height: 32, color: AppColors.neutral200),
                        Text(
                          'Vital Signs',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            if (referral.sistole != null &&
                                referral.diastole != null)
                              Expanded(
                                child: _buildMiniStat(
                                  'BP (mmHg)',
                                  '${referral.sistole}/${referral.diastole}',
                                  Icons.monitor_heart_rounded,
                                ),
                              ),
                            if (referral.denyutNadi != null)
                              Expanded(
                                child: _buildMiniStat(
                                  'HR (bpm)',
                                  '${referral.denyutNadi}',
                                  Icons.favorite_rounded,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            if (referral.suhuTubuh != null)
                              Expanded(
                                child: _buildMiniStat(
                                  'Temp (°C)',
                                  '${referral.suhuTubuh}',
                                  Icons.thermostat_rounded,
                                ),
                              ),
                            if (referral.spo2 != null)
                              Expanded(
                                child: _buildMiniStat(
                                  'SpO2 (%)',
                                  '${referral.spo2}',
                                  Icons.bloodtype_rounded,
                                ),
                              ),
                          ],
                        ),
                      ],

                      const Divider(height: 40, color: AppColors.neutral200),

                      Text(
                        'Metadata Rujukan',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailItem(
                        'Tipe Rujukan',
                        referral.tipe,
                        Icons.category_rounded,
                      ),
                      _buildDetailItem(
                        'Status Rujukan',
                        _getStatusLabel(referral.status),
                        Icons.info_outline_rounded,
                        color: _getStatusColor(referral.status),
                      ),
                      _buildDetailItem(
                        'Tanggal Dibuat',
                        _formatDate(referral.tanggalDibuat),
                        Icons.calendar_today_rounded,
                      ),
                      if (referral.tanggalDikirim != null)
                        _buildDetailItem(
                          'Tanggal Dikirim',
                          _formatDate(referral.tanggalDikirim!),
                          Icons.send_rounded,
                        ),
                      if (referral.tanggalDiterima != null)
                        _buildDetailItem(
                          'Tanggal Diterima',
                          _formatDate(referral.tanggalDiterima!),
                          Icons.check_circle_outline_rounded,
                        ),
                      _buildDetailItem(
                        'Instansi/Faskes Tujuan',
                        referral.pihakTujuan,
                        Icons.apartment_rounded,
                      ),
                      _buildDetailItem(
                        'Email Tujuan',
                        referral.emailTujuan.isNotEmpty
                            ? referral.emailTujuan
                            : '-',
                        Icons.email_rounded,
                      ),

                      const Divider(height: 40, color: AppColors.neutral200),

                      Text(
                        'Diagnosis & Keluhan',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (referral.diagnosis != null &&
                          referral.diagnosis!.isNotEmpty)
                        _buildDetailItem(
                          'Diagnosis / Keluhan Awal',
                          referral.diagnosis!,
                          Icons.medical_services_rounded,
                        ),
                      if (referral.keluhanUtama != null &&
                          referral.keluhanUtama!.isNotEmpty)
                        _buildDetailItem(
                          'Keluhan Utama',
                          referral.keluhanUtama!,
                          Icons.sick_rounded,
                        ),
                      _buildDetailItem(
                        'Alasan Rujukan / Catatan',
                        referral.alasan,
                        Icons.notes_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral500),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.neutral500),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: color ?? AppColors.neutral900,
              fontWeight: color != null ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      onTap: () => _showDetailBottomSheet(context),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Avatar + Name + Status)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withAlpha(15),
                  backgroundImage:
                      referral.mahasiswaAvatar != null &&
                              referral.mahasiswaAvatar!.isNotEmpty
                          ? NetworkImage(
                            ApiGate.getImageUrl(referral.mahasiswaAvatar),
                          )
                          : null,
                  child:
                      referral.mahasiswaAvatar != null &&
                              referral.mahasiswaAvatar!.isNotEmpty
                          ? null
                          : Text(
                            referral.mahasiswaNama.isNotEmpty
                                ? referral.mahasiswaNama[0].toUpperCase()
                                : 'M',
                            style: AppTextStyles.titleMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        referral.mahasiswaNama,
                        style: AppTextStyles.titleSm.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        '${referral.mahasiswaNim != null && referral.mahasiswaNim!.isNotEmpty ? referral.mahasiswaNim! : '-'} • ${referral.tipe}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(referral.status),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    _getStatusLabel(referral.status),
                    style: AppTextStyles.labelSm.copyWith(
                      color: _getStatusColor(referral.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s20),

            // Inner Data Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: AppSpacing.s6),
                          Text(
                            'Tanggal Dibuat',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(referral.tanggalDibuat),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDataRow(
                    'Instansi Tujuan',
                    referral.pihakTujuan,
                    Icons.apartment_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (referral.diagnosis != null &&
                      referral.diagnosis!.isNotEmpty)
                    _buildDataRow(
                      'Diagnosis / Keluhan',
                      referral.diagnosis!,
                      Icons.medical_services_rounded,
                      isLong: true,
                    )
                  else
                    _buildDataRow(
                      'Alasan Rujukan',
                      referral.alasan,
                      Icons.description_rounded,
                      isLong: true,
                    ),
                ],
              ),
            ),

            // Actions
            Consumer<ReferralProvider>(
              builder: (context, provider, _) {
                final bool isWaiting =
                    referral.status == 'Pending' ||
                    referral.status == 'menunggu_approval';
                final bool isSent =
                    referral.status == 'Sent' ||
                    referral.status == 'Sudah Dikirim';
                final bool isDone =
                    referral.status == 'Selesai' ||
                    referral.status == 'Diterima' ||
                    referral.status == 'Received';
                final bool isRejected = referral.status == 'Ditolak';
                final bool showPdf =
                    AuthService().currentRole == UserRole.tenagaKesehatan ||
                    (referral.suratRujiukanUrl != null &&
                        referral.suratRujiukanUrl!.isNotEmpty);

                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main action row
                      Row(
                        children: [
                          // Konfirmasi Diterima button for sent referrals
                          if (isSent)
                            Expanded(
                              child: BkuButton(
                                text: 'Konfirmasi Diterima',
                                icon: Icons.check_circle_outline_rounded,
                                variant: BkuButtonVariant.success,
                                isLoading: provider.isSending,
                                onPressed:
                                    provider.isSending
                                        ? null
                                        : () async {
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => CustomDialog(
                                                  title:
                                                      'Konfirmasi Rujukan Diterima',
                                                  content:
                                                      'Konfirmasi bahwa surat rujukan telah diterima oleh pihak tujuan?',
                                                  cancelText: 'Batal',
                                                  confirmText: 'Konfirmasi',
                                                  onCancel:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  onConfirm:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                ),
                                          );

                                          if (confirm == true &&
                                              context.mounted) {
                                            final success = await provider
                                                .confirmReferralReceived(
                                                  referral.id,
                                                );
                                            if (success && context.mounted) {
                                              AppSnackbar.showSuccess(
                                                context,
                                                'Rujukan berhasil dikonfirmasi',
                                              );
                                            }
                                          }
                                        },
                              ),
                            ),
                          // Kirim Rujukan button for approved but unsent referrals (Psychologist only)
                          if (isWaiting &&
                              referral.approvalStatus == 'disetujui' &&
                              AuthService().currentRole ==
                                  UserRole.psychologist)
                            Expanded(
                              child: BkuButton(
                                text: 'Kirim Rujukan',
                                icon: Icons.send_rounded,
                                variant: BkuButtonVariant.primary,
                                isLoading: provider.isSending,
                                onPressed:
                                    provider.isSending
                                        ? null
                                        : () async {
                                          final success = await provider
                                              .sendReferral(referral.id);
                                          if (success && context.mounted) {
                                            AppSnackbar.showSuccess(
                                              context,
                                              'Rujukan berhasil dikirim ke tujuan',
                                            );
                                          }
                                        },
                              ),
                            ),
                          // Status indicators (non-actionable)
                          if (isWaiting &&
                              referral.approvalStatus != 'disetujui' &&
                              !isSent &&
                              !isDone &&
                              !isRejected)
                            const SizedBox(width: AppSpacing.s10),
                          if (isDone)
                            Expanded(
                              child: BkuButton(
                                text: 'Telah Disetujui',
                                icon: Icons.check_circle_rounded,
                                variant: BkuButtonVariant.success,
                                onPressed: null, // Indicator only
                              ),
                            ),
                          if (isRejected)
                            Expanded(
                              child: BkuButton(
                                text: 'Rujukan Ditolak',
                                icon: Icons.cancel_rounded,
                                variant: BkuButtonVariant.danger,
                                onPressed: null, // Indicator only
                              ),
                            ),
                        ],
                      ),
                      // PDF download row (separate row)
                      if (showPdf) ...[
                        const SizedBox(height: AppSpacing.s10),
                        BkuButton(
                          text: 'Lihat PDF',
                          icon: Icons.picture_as_pdf_rounded,
                          variant: BkuButtonVariant.danger,
                          onPressed: () async {
                            final provider = Provider.of<ReferralProvider>(
                              context,
                              listen: false,
                            );
                            final urlStr = await provider.downloadReferral(
                              referral.id,
                            );
                            if (urlStr != null && urlStr.isNotEmpty) {
                              final token = AuthService().token;
                              final urlWithToken =
                                  urlStr.contains('?')
                                      ? '$urlStr&token=$token'
                                      : '$urlStr?token=$token';
                              final uri = Uri.parse(urlWithToken);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                                if (context.mounted) {
                                  AppSnackbar.showSuccess(
                                    context,
                                    'Berhasil mengunduh Surat Rujukan PDF',
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Tidak dapat membuka tautan PDF',
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Tautan PDF tidak tersedia',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(
    String label,
    String value,
    IconData icon, {
    bool isLong = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.neutral500),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
            height: isLong ? 1.4 : 1.0,
          ),
          maxLines: isLong ? 3 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
