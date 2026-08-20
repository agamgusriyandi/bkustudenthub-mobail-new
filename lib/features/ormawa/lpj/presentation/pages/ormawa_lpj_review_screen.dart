import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class OrmawaLpjReviewScreen extends StatefulWidget {
  const OrmawaLpjReviewScreen({super.key});

  @override
  State<OrmawaLpjReviewScreen> createState() => _OrmawaLpjReviewScreenState();
}

class _OrmawaLpjReviewScreenState extends State<OrmawaLpjReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  bool _isLoading = true;
  List<Map<String, dynamic>> _lpjs = [];

  static const List<String> _statusOptions = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Ditolak',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadLpjs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLpjs() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final response = await api.client.get(
        '/ormawa/lpjs',
        queryParameters: {'status': 'pending'},
      );
      final data = response.data;
      if (data is List) {
        _lpjs = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['data'] is List) {
        _lpjs = List<Map<String, dynamic>>.from(data['data']);
      } else {
        _lpjs = [];
      }
    } catch (_) {
      _lpjs = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      case 'menunggu':
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.neutral500;
    }
  }

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('setuju')) return 'Disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'Ditolak';
    if (s.contains('selesai')) return 'Selesai';
    if (s.contains('menunggu') || s.contains('pending')) return 'Menunggu';
    return status;
  }

  BkuStatus _mapStatusToBkuStatus(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('setuju') || s.contains('selesai') || s.contains('acc')) {
      return BkuStatus.success;
    } else if (s.contains('tolak') || s.contains('batal')) {
      return BkuStatus.error;
    } else if (s.contains('revisi')) {
      return BkuStatus.warning;
    }
    return BkuStatus.info;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _lpjs.where((lpj) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (lpj['judul'] ?? lpj['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'Semua' ||
          _normalizeStatus(lpj['status'] ?? '') == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadLpjs,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            BkuAppBar(
              title: 'Review Lpj',
              subtitle: 'Antrian Review Lpj',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: OrmawaListHeader(
                      title: 'ANTRIAN LPJ (${filtered.length})',
                      searchHint: 'Cari judul LPJ...',
                      searchController: _searchController,
                      onRefresh: _loadLpjs,
                      onFilterTap: _showFilterSheet,
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!_isLoading && filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 60, color: AppColors.neutral400.withAlpha(80)),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Tidak ada LPJ untuk direview',
                              style: AppTextStyles.bodyMd.copyWith(color: context.appColors.outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildLpjCard(filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s150)),
          ],
        ),
      ),
    );
  }

  Widget _buildLpjCard(Map<String, dynamic> lpj) {
    final status = lpj['status'] ?? '';
    final statusColor = _getStatusColor(status);
    final normalizedStatus = _normalizeStatus(status);
    final judul = lpj['judul'] ?? lpj['title'] ?? '-';
    final proposalTitle = lpj['proposal_title'] ?? lpj['proposalTitle'];

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.ormawaLpjDetail, extra: lpj);
      },
      child: BkuCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(Icons.description_rounded, color: statusColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900)),
                      if (proposalTitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(proposalTitle, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500)),
                      ],
                    ],
                  ),
                ),
                BkuStatusBadge(
                  status: _mapStatusToBkuStatus(lpj['status'] ?? ''),
                  customText: normalizedStatus,
                  showIcon: false,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: OrmawaTheme.primarySoft,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: OrmawaTheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Review',
                        style: AppTextStyles.labelSm.copyWith(
                          color: OrmawaTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
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
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            Text('Filter Status', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStatus = status);
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected ? OrmawaTheme.primary : OrmawaTheme.primarySoft,
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? Colors.white : OrmawaTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}