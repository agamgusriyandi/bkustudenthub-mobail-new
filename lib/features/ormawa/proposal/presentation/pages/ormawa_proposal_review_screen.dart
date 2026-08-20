import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

class OrmawaProposalReviewScreen extends StatefulWidget {
  const OrmawaProposalReviewScreen({super.key});

  @override
  State<OrmawaProposalReviewScreen> createState() =>
      _OrmawaProposalReviewScreenState();
}

class _OrmawaProposalReviewScreenState
    extends State<OrmawaProposalReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  bool _isLoading = true;
  List<Map<String, dynamic>> _proposals = [];

  static const List<String> _statusOptions = [
    'Semua',
    'Diajukan',
    'Diproses',
    'Disetujui',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final response = await api.client.get(
        '/ormawa/proposals',
        queryParameters: {'status': 'pending'},
      );
      final data = response.data;
      if (data is List) {
        _proposals = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['data'] is List) {
        _proposals = List<Map<String, dynamic>>.from(data['data']);
      } else {
        _proposals = [];
      }
    } catch (_) {
      _proposals = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('setuju')) return 'Disetujui';
    if (s.contains('ditolak') || s.contains('tolak')) return 'Ditolak';
    if (s.contains('diajukan') || s.contains('proses')) return 'Diproses';
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
    final filtered = _proposals.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (p['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p['code'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == 'Semua' ||
          _normalizeStatus(p['status'] ?? '') == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadProposals,
        color: BkuTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            const BkuAppBar(
              title: 'Review Proposal',
              subtitle: 'Antrian Review Proposal',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: OrmawaListHeader(
                      title: 'ANTRIAN PROPOSAL (${filtered.length})',
                      searchHint: 'Cari proposal...',
                      searchController: _searchController,
                      onRefresh: _loadProposals,
                      onFilterTap: _showFilterSheet,
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!_isLoading && filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                      child: BkuEmptyState(
                        title: 'Tidak Ada Proposal',
                        message: 'Tidak ada proposal yang menunggu antrian review saat ini.',
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProposalCard(filtered[index]),
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

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    final normalizedStatus = _normalizeStatus(proposal['status'] ?? '');
    final title = proposal['title'] ?? '-';
    final code = proposal['code'] ?? '';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.ormawaProposalDetail, extra: proposal),
      child: BkuCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.primarySoft,
                    borderRadius: BkuTheme.r10,
                  ),
                  child: Icon(Icons.send_rounded, color: BkuTheme.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: BkuTheme.textCardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w900)),
                      if (code.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(code, style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted)),
                      ],
                    ],
                  ),
                ),
                BkuStatusBadge(
                  status: _mapStatusToBkuStatus(proposal['status'] ?? ''),
                  customText: normalizedStatus,
                  showIcon: false,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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
                    color: BkuTheme.primarySoft,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: BkuTheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Review',
                        style: TextStyle(
                          color: BkuTheme.primary,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
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
                  color: BkuTheme.border,
                  borderRadius: BkuTheme.r8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Filter Status', style: BkuTheme.textCardTitle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
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
                      color: isSelected ? BkuTheme.primary : BkuTheme.primarySoft,
                      borderRadius: BkuTheme.rPill,
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isSelected ? Colors.white : BkuTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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