import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:intl/intl.dart';

class MentorBandingScreen extends StatefulWidget {
  const MentorBandingScreen({super.key});

  @override
  State<MentorBandingScreen> createState() => _MentorBandingScreenState();
}

class _MentorBandingScreenState extends State<MentorBandingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _loadData();
  }

  void _loadData() {
    String status = 'pending';
    if (_tabController.index == 1) status = 'approved';
    if (_tabController.index == 2) status = 'rejected';
    context.read<MentorKencanaProvider>().fetchBandingList(status: status);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Banding Nilai',
            showBackButton: true,
            variant: AppBarVariant.student,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              labelColor: context.appColors.primary,
              unselectedLabelColor: AppColors.neutral500,
              indicatorColor: context.appColors.primary,
              tabs: const [
                Tab(text: 'Menunggu'),
                Tab(text: 'Disetujui'),
                Tab(text: 'Ditolak'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: Consumer<MentorKencanaProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList());
                }
                
                if (provider.errorMessage != null && provider.bandingList.isEmpty) {
                  return Center(child: Text(provider.errorMessage!));
                }
                
                if (provider.bandingList.isEmpty) {
                  return const Center(child: Text('Tidak ada pengajuan banding'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: provider.bandingList.length,
                    itemBuilder: (context, index) {
                      final item = provider.bandingList[index];
                      return _buildBandingCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandingCard(BuildContext context, BandingModel item) {
    String dateStr = '-';
    if (item.createdAt != null) {
      try {
        final dt = DateTime.parse(item.createdAt!);
        dateStr = DateFormat('dd MMM yyyy, HH:mm').format(dt);
      } catch (e) {
        // ignore
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BkuCard(
        onTap: () {
          context.push('/mentor-banding-detail', extra: item).then((_) {
            _loadData();
          });
        },
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName,
                        style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.studentNim,
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ),
                BkuStatusBadge(
                  status: item.type == 'fakultas' ? BkuStatus.info : BkuStatus.warning,
                  customText: item.type == 'fakultas' ? 'Fakultas' : 'Universitas',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Alasan Banding:',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.reason,
              style: AppTextStyles.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontSize: 10)),
                Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
