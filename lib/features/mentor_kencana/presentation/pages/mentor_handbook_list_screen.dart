import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MentorHandbookListScreen extends StatefulWidget {
  const MentorHandbookListScreen({super.key});

  @override
  State<MentorHandbookListScreen> createState() =>
      _MentorHandbookListScreenState();
}

class _MentorHandbookListScreenState extends State<MentorHandbookListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _handbooks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHandbooks();
  }

  Future<void> _loadHandbooks() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final response = await api.client.get('/api/kencana-mentor/handbook');
      final data = response.data;
      if (data is List) {
        _handbooks = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['data'] is List) {
        _handbooks = List<Map<String, dynamic>>.from(data['data']);
      } else {
        _handbooks = [];
      }
    } catch (_) {
      _handbooks = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _handbooks.where((h) {
      if (_searchQuery.isEmpty) return true;
      final title = (h['title'] ?? h['student_name'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Handbook Kencana',
        variant: AppBarVariant.student,
        showBackButton: true,
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHandbooks,
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: BkuShimmerList(itemCount: 5, itemHeight: 100),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAFTAR HANDBOOK (${filtered.length})',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Cari handbook...',
                              prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral400),
                              filled: true,
                              fillColor: AppColors.neutral50,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: BorderSide(color: AppColors.neutral200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: BorderSide(color: AppColors.neutral200),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 60, color: AppColors.neutral300),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum ada handbook',
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHandbookCard(filtered[index]),
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

  Widget _buildHandbookCard(Map<String, dynamic> handbook) {
    final status = (handbook['status'] ?? 'pending').toString().toLowerCase();
    final studentName = handbook['student_name'] ?? handbook['studentName'] ?? '-';
    final title = handbook['title'] ?? 'Handbook Kencana';

    Color statusColor;
    String statusText;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = 'Disetujui';
        break;
      case 'submitted':
        statusColor = AppColors.warning;
        statusText = 'Menunggu';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Ditolak';
        break;
      default:
        statusColor = AppColors.neutral500;
        statusText = 'Draft';
    }

    final handbookId = handbook['id'] ?? 0;

    return GestureDetector(
      onTap: () {
        if (handbookId != 0) {
          context.push('${AppRoutes.mentorHandbookDetail.replaceAll(':id', '')}$handbookId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(15),
                borderRadius: AppRadius.radiusLg,
              ),
              child: Icon(Icons.menu_book_rounded, color: statusColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    studentName,
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Text(
                statusText.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
