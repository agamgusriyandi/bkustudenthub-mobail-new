import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';

class KencanaInvitationsScreen extends StatefulWidget {
  const KencanaInvitationsScreen({super.key});

  @override
  State<KencanaInvitationsScreen> createState() =>
      _KencanaInvitationsScreenState();
}

class _KencanaInvitationsScreenState extends State<KencanaInvitationsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final provider = context.read<KencanaProvider>();
    final result = await provider.fetchInvitations();
    if (mounted) {
      setState(() {
        data = result;
        isLoading = false;
      });
    }
  }

  Future<void> _respond(String type, int id, String action) async {
    setState(() => isProcessing = true);
    final provider = context.read<KencanaProvider>();
    await provider.respondInvitation(type, id, action);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Undangan berhasil direspon.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    await _loadData();
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'UNDANGAN FASILITATOR & KELOMPOK',
              subtitle: 'KENCANA',
              variant: AppBarVariant.secondary,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (isLoading)
              SliverFillRemaining(
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                ),
              )
            else if (data == null || data!.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'Belum ada undangan Fasilitator atau Kelompok',
                        style: TextStyle(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  bottom: AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildActiveMentorCard(),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Undangan Fasilitator',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInvitationsList(data?['invitations'] ?? [], 'mentor'),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Undangan Kelompok',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInvitationsList(
                      data?['group_invitations'] ?? [],
                      'group',
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMentorCard() {
    final mentor = data?['active_mentor'];
    if (mentor == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appColors.warning.withAlpha(20),
          borderRadius: AppRadius.radiusLg,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: context.appColors.warning),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                'Kamu belum memiliki Fasilitator yang aktif.',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'FASILITATOR AKTIF',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (mentor['avatar_url'] != null &&
                  mentor['avatar_url'].toString().isNotEmpty)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        ApiGate.getImageUrl(mentor['avatar_url'].toString()),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: AppColors.neutral600,
                  ),
                ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor['name'] ?? 'Fasilitator',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      mentor['email'] ?? '',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      mentor['phone'] ?? '',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Text(
          'Belum ada undangan $type',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: context.appColors.outline,
          ),
        ),
      );
    }

    return Column(
      children:
          items.map((item) {
            final rawStatus = item['status'] ?? item['Status'] ?? 'pending';
            final status = rawStatus.toString().toLowerCase();
            final isPending = status == 'pending';

            String title = 'Undangan Kencana';
            String subtitle = '';

            if (type == 'mentor') {
              final mentor = item['mentor'] ?? item['Mentor'] ?? {};
              final name = mentor['name'] ?? mentor['Name'] ?? 'Fasilitator';
              final fakName = mentor['fakultas']?['name'] ?? mentor['Fakultas']?['Name'] ?? 'Universitas';
              title = 'Undangan Fasilitator: $name';
              subtitle = 'Fasilitator dari $fakName';
            } else {
              final group = item['group'] ?? item['Group'] ?? {};
              final groupName = group['name'] ?? group['Name'] ?? item['group_name'] ?? 'Kelompok Kencana';
              final code = group['code'] ?? group['Code'] ?? item['group_code'] ?? '';
              final mentorObj = group['mentor'] ?? group['Mentor'];
              final mentorName = mentorObj?['name'] ?? mentorObj?['Name'] ?? '';

              title = groupName;
              subtitle = 'Kode: ${code.isNotEmpty ? code : '-'} ${mentorName.isNotEmpty ? '• Fasilitator: $mentorName' : ''}';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.onSurface.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type == 'mentor'
                              ? Icons.person_add_rounded
                              : Icons.group_add_rounded,
                          color: AppColors.neutral600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () => _respond(type, item['id'], 'reject'),
                          child: Text(
                            'Tolak',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        BkuButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () => _respond(type, item['id'], 'accept'),
                          text: 'Terima',
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (status == 'active' || status == 'accepted')
                                ? AppColors.success.withAlpha(20)
                                : AppColors.error.withAlpha(20),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Text(
                        (status == 'active' || status == 'accepted') ? 'DITERIMA' : 'DITOLAK',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              (status == 'active' || status == 'accepted')
                                  ? AppColors.success
                                  : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }
}
