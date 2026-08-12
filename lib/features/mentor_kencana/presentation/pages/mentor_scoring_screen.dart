import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_main_screen.dart';

class MentorScoringScreen extends StatefulWidget {
  const MentorScoringScreen({super.key});

  @override
  State<MentorScoringScreen> createState() => _MentorScoringScreenState();
}

class _MentorScoringScreenState extends State<MentorScoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSavingBulk = false;

  // Map to hold bulk scores input: { studentId: { compositeKey: scoreStr } }
  final Map<int, Map<String, TextEditingController>> _bulkControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentees();
        context.read<MentorKencanaProvider>().fetchBulkScores();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _bulkControllers.forEach((_, map) {
      map.forEach((_, c) => c.dispose());
    });
    super.dispose();
  }

  void _saveBulkScores() async {
    setState(() => _isSavingBulk = true);
    final provider = context.read<MentorKencanaProvider>();

    final List<Map<String, dynamic>> bulkPayload = [];
    _bulkControllers.forEach((studentId, controllers) {
      final List<Map<String, dynamic>> itemsPayload = [];
      controllers.forEach((compositeKey, controller) {
        final text = controller.text.trim();
        if (text.isNotEmpty) {
          final score = double.tryParse(text) ?? 0.0;
          final parts = compositeKey.split('_');
          final category = parts[0];
          final itemKey = parts.sublist(1).join('_');
          itemsPayload.add({
            'component': category,
            'item_name': itemKey,
            'score': score,
          });
        }
      });

      if (itemsPayload.isNotEmpty) {
        bulkPayload.add({'student_id': studentId, 'items': itemsPayload});
      }
    });

    if (bulkPayload.isEmpty) {
      setState(() => _isSavingBulk = false);
      AppSnackbar.showError(context, 'Belum ada nilai yang diinput');
      return;
    }

    try {
      final response = await provider.submitBulkScoresPayload({
        'scores': bulkPayload,
      });
      if (mounted) {
        setState(() => _isSavingBulk = false);
        if (response) {
          AppSnackbar.showSuccess(context, 'Berhasil menyimpan semua nilai');
          provider.fetchBulkScores();
        } else {
          AppSnackbar.showError(context, 'Gagal menyimpan nilai kolektif');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingBulk = false);
        AppSnackbar.showError(context, 'Gagal menyimpan nilai kolektif');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final mentees = provider.groups.expand((g) => g.mentees).toList();
    final bulkData = provider.bulkScoresData;

    final filtered =
        mentees.where((m) {
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return m.name.toLowerCase().contains(q) ||
                m.nim.toLowerCase().contains(q);
          }
          return true;
        }).toList();

    // Map scores from bulkData
    final scoresList = (bulkData?['scores'] as List?) ?? [];
    final itemsList = (bulkData?['items'] as List?) ?? [];
    final definitions = (bulkData?['score_definitions'] as Map?) ?? {};
    final mentorScope = bulkData?['mentor_scope'] ?? 'university';
    final weights = (bulkData?['weights'] as Map?) ?? {};
    final cogW = weights['cognitive_weight'] ?? 25;
    final psyW = weights['psychomotor_weight'] ?? 40;
    final affW = weights['affective_weight'] ?? 35;

    final List<Map<String, dynamic>> manualItems = [];
    for (final comp in ['cognitive', 'psychomotor', 'affective']) {
      final list = (definitions[comp] as List?) ?? [];
      for (final it in list) {
        if (it is Map && it['manual'] == true) {
          manualItems.add({
            'component': comp,
            'key': it['key'] ?? '',
            'label': it['label'] ?? '',
          });
        }
      }
    }

    final Map<int, Map<String, double>> existingItemsMap = {};
    for (final it in itemsList) {
      if (it is Map &&
          it['student_id'] != null &&
          it['component'] != null &&
          it['item_name'] != null) {
        final sId = int.tryParse(it['student_id']?.toString() ?? '') ?? 0;
        final comp = it['component'] as String;
        final name = it['item_name'] as String;
        final double scoreVal =
            double.tryParse(it['score']?.toString() ?? '') ?? 0.0;

        if (!existingItemsMap.containsKey(sId)) {
          existingItemsMap[sId] = {};
        }
        existingItemsMap[sId]!['${comp}_$name'] = scoreVal;
      }
    }

    final Map<int, Map<String, dynamic>> scoreMap = {};
    for (final sc in scoresList) {
      if (sc is Map && sc['student_id'] != null) {
        scoreMap[sc['student_id']] = Map<String, dynamic>.from(sc);
      }
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            BkuAppBar(
              title: 'Penilaian Akhir (Skoring)',
              info:
                  'Input dan edit nilai sikap, keterampilan, serta nilai akhir mahasiswa.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () {
                final state =
                    context.findAncestorStateOfType<MentorMainScreenState>();
                if (state != null) {
                  state.setSelectedIndex(0);
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/mentor-kencana');
                }
              },
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: context.appColors.onPrimary,
                  unselectedLabelColor: context.appColors.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: context.appColors.primary,
                    borderRadius: AppRadius.radiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.workspace_premium_rounded, size: 18),
                      text: 'Rekapitulasi Nilai',
                    ),
                    Tab(
                      icon: Icon(Icons.grid_on_rounded, size: 18),
                      text: 'Pengisian Kolektif',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Rekapitulasi Nilai Akhir
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _bulkControllers.clear();
                });
                await provider.fetchMentees();
                await provider.fetchBulkScores();
              },
              color: context.appColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rekapitulasi Nilai Akhir & Kelulusan',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nilai Akhir dihitung otomatis berdasarkan pembobotan Kencana = Kognitif ($cogW%) + Psikomotor ($psyW%) + Afektif ($affW%).',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: context.appColors.outline,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manajemen Data',
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Menampilkan daftar data yang terdaftar dalam sistem.',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.outline,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: AppRadius.radiusXl,
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                  ),
                                ),
                                child: Text(
                                  'TOTAL DATA ${filtered.length}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral900,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          BkuTextField(
                            controller: _searchController,
                            onChanged:
                                (val) => setState(() => _searchQuery = val),
                            hint: 'Cari nama atau NIM mahasiswa...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (provider.isLoading && mentees.isEmpty)
                    const SliverFillRemaining(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: BkuShimmerList(),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada mahasiswa bimbingan',
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        bottom: 80,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final m = filtered[index];
                          final sc = scoreMap[m.id] ?? {};

                          final double cogVal =
                              double.tryParse(
                                (mentorScope == 'faculty'
                                            ? sc['cognitive_average_faculty']
                                            : sc['cognitive_average_univ'])
                                        ?.toString() ??
                                    '',
                              ) ??
                              0.0;
                          final double psyVal =
                              double.tryParse(
                                (mentorScope == 'faculty'
                                            ? sc['psychomotor_average_faculty']
                                            : sc['psychomotor_average_univ'])
                                        ?.toString() ??
                                    '',
                              ) ??
                              0.0;
                          final double affVal =
                              double.tryParse(
                                (mentorScope == 'faculty'
                                            ? sc['affective_average_faculty']
                                            : sc['affective_average_univ'])
                                        ?.toString() ??
                                    '',
                              ) ??
                              0.0;
                          final double finalVal =
                              double.tryParse(
                                (mentorScope == 'faculty'
                                            ? sc['final_score_faculty']
                                            : sc['final_score_univ'])
                                        ?.toString() ??
                                    '',
                              ) ??
                              0.0;
                          final String gradStatus =
                              (mentorScope == 'faculty'
                                      ? sc['graduation_status_faculty']
                                      : sc['graduation_status_univ'])
                                  ?.toString() ??
                              'in_progress';

                          return BkuCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.nim,
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.neutral900,
                                                ),
                                          ),
                                          Text(
                                            m.name,
                                            style: AppTextStyles.labelMd
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.neutral900,
                                                ),
                                          ),
                                          Text(
                                            m.faculty,
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color: AppColors.neutral700,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    BkuStatusBadge(
                                      status: gradStatus == 'passed' ? BkuStatus.success : BkuStatus.info,
                                      customText: gradStatus.replaceAll('_', ' '),
                                      showIcon: false,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildScoreColumn(
                                      'KOGNITIF',
                                      cogVal.toStringAsFixed(1),
                                    ),
                                    _buildScoreColumn(
                                      'PSIKOMOTOR',
                                      psyVal.toStringAsFixed(1),
                                    ),
                                    _buildScoreColumn(
                                      'AFEKTIF',
                                      affVal.toStringAsFixed(1),
                                    ),
                                    _buildScoreColumn(
                                      'NILAI AKHIR',
                                      finalVal.toStringAsFixed(1),
                                      isHighlighted: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    height: 30,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        context.push(
                                          '/mentor-kencana/mentee/${m.id}',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 13,
                                      ),
                                      label: const Text(
                                        'Edit Nilai',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.neutral900,
                                        side: const BorderSide(
                                          color: AppColors.neutral300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.radiusMd,
                                        ),
                                        backgroundColor: AppColors.neutral100,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                ],
              ),
            ),

            // TAB 2: Pengisian Kolektif (Bulk Input)
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _bulkControllers.clear();
                });
                await provider.fetchMentees();
                await provider.fetchBulkScores();
              },
              color: context.appColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Lembar Pengisian Kolektif',
                                        style: AppTextStyles.titleSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral100,
                                        borderRadius: AppRadius.radiusXl,
                                        border: Border.all(
                                          color: AppColors.neutral300,
                                        ),
                                      ),
                                      child: Text(
                                        '$mentorScope SCOPE',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Masukkan nilai (0-100) langsung ke form di bawah.',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                BkuButton(
                                  text: 'Simpan Semua Nilai',
                                  icon: Icons.save_outlined,
                                  isLoading: _isSavingBulk,
                                  fullWidth: true,
                                  onPressed: _saveBulkScores,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Tidak ada mahasiswa bimbingan',
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        bottom: 80,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final m = filtered[index];
                          if (!_bulkControllers.containsKey(m.id)) {
                            _bulkControllers[m.id] = {};
                            for (final item in manualItems) {
                              final comp = item['component'];
                              final key = item['key'];
                              final compositeKey = '${comp}_$key';

                              final double? existingScore =
                                  existingItemsMap[m.id]?[compositeKey];
                              final text =
                                  existingScore != null && existingScore > 0
                                      ? existingScore.toStringAsFixed(1)
                                      : '';
                              _bulkControllers[m.id]![compositeKey] =
                                  TextEditingController(text: text);
                            }
                          }

                          final map = _bulkControllers[m.id]!;

                          return BkuCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                Text(
                                  'NIM: ${m.nim}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (manualItems.isEmpty)
                                  Text(
                                    'Tidak ada komponen nilai manual yang dapat diisi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.appColors.outline,
                                    ),
                                  )
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          manualItems.map((item) {
                                            final comp = item['component'];
                                            final key = item['key'];
                                            final label = item['label'];
                                            final compositeKey = '${comp}_$key';

                                            if (!map.containsKey(
                                              compositeKey,
                                            )) {
                                              map[compositeKey] =
                                                  TextEditingController();
                                            }

                                            return Container(
                                              width: 90,
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: _buildMiniScoreInput(
                                                label,
                                                map[compositeKey]!,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }, childCount: filtered.length),
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

  Widget _buildScoreColumn(
    String label,
    String val, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniScoreInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        BkuTextField(
          controller: controller,
          keyboardType: TextInputType.number,
          hint: '-',
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: context.appColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.neutral200.withAlpha(150),
          borderRadius: AppRadius.radiusLg,
        ),
        padding: const EdgeInsets.all(4),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
