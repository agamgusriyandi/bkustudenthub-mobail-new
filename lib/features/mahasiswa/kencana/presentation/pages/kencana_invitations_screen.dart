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
              title: 'Undangan Fasilitator & Kelompok',
              subtitle: 'Kencana',
              variant: AppBarVariant.student,
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
            else if (data == null || (data?.isEmpty ?? true))
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

  Widget _buildSingleActiveMentorCard(Map mentor) {
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

  Widget _buildActiveMentorCard() {
    final mentors = data?['active_mentors'];
    final mentor = data?['active_mentor'];

    if (mentors != null && mentors is List && mentors.isNotEmpty) {
      return Column(
        children: List.generate(mentors.length, (index) {
          try {
            final m = mentors[index];
            if (m == null || m is! Map) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == mentors.length - 1 ? 0 : AppSpacing.md,
              ),
              child: _buildSingleActiveMentorCard(m),
            );
          } catch (e, stackTrace) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: Colors.red.shade100,
              child: Text('Error rendering active mentor: $e\n$stackTrace', style: const TextStyle(color: Colors.red)),
            );
          }
        }),
      );
    }

    if (mentor != null && mentor is Map) {
      try {
        return _buildSingleActiveMentorCard(mentor);
      } catch (e, stackTrace) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: Colors.red.shade100,
          child: Text('Error rendering active mentor: $e\n$stackTrace', style: const TextStyle(color: Colors.red)),
        );
      }
    }

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
            if (item == null || item is! Map) return const SizedBox.shrink();
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
              var mentorName = '';
              final mentorsList = group['mentors'] ?? group['Mentors'];
              if (mentorsList != null && mentorsList is List && mentorsList.isNotEmpty) {
                mentorName = mentorsList.map((m) => m != null ? (m['name'] ?? m['Name'] ?? '') : '').where((s) => s.toString().isNotEmpty).join(', ');
              } else {
                final mentorObj = group['mentor'] ?? group['Mentor'];
                mentorName = mentorObj?['name'] ?? mentorObj?['Name'] ?? '';
              }

              title = groupName;
              subtitle = 'Kode: ${code.isNotEmpty ? code : '-'} ${mentorName.isNotEmpty ? '• Fasilitator: $mentorName' : ''}';
            }

            try {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: BkuCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              color: AppColors.neutral800,
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
                                    fontWeight: FontWeight.w800,
                                    color: context.appColors.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subtitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: context.appColors.outline,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isPending) ...[
                        const SizedBox(height: AppSpacing.lg),
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
                                  color: AppColors.neutral600,
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
                              variant: BkuButtonVariant.success,
                              fullWidth: false,
                              height: 38,
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
                ),
              );
            } catch (e, stackTrace) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.red.shade100,
                child: Text('Error rendering invitation: $e\n$stackTrace', style: const TextStyle(color: Colors.red)),
              );
            }
          }).toList(),
    );
  }
}
