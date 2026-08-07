import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_member_model.dart';

class OrmawaStrukturScreen extends StatefulWidget {
  const OrmawaStrukturScreen({super.key});

  @override
  State<OrmawaStrukturScreen> createState() => _OrmawaStrukturScreenState();
}

class _OrmawaStrukturScreenState extends State<OrmawaStrukturScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final members = ormawaProvider.members;

    final ketua = members.firstWhere(
      (m) =>
          m.role.toUpperCase() == 'KETUA UMUM' ||
          m.role.toUpperCase() == 'KETUA',
      orElse:
          () => OrmawaMemberModel(
            id: '',
            mahasiswaId: '',
            name: '-',
            nim: '-',
            role: 'Ketua Umum',
            division: 'BPH',
            status: 'Aktif',
          ),
    );
    final wakil = members.firstWhere(
      (m) => m.role.toUpperCase().contains('WAKIL KETUA'),
      orElse:
          () => OrmawaMemberModel(
            id: '',
            mahasiswaId: '',
            name: '-',
            nim: '-',
            role: 'Wakil Ketua Umum',
            division: 'BPH',
            status: 'Aktif',
          ),
    );

    final sekretaris =
        members
            .where((m) => m.role.toUpperCase().contains('SEKRETARIS'))
            .toList();
    final bendahara =
        members
            .where((m) => m.role.toUpperCase().contains('BENDAHARA'))
            .toList();

    final Map<String, List<OrmawaMember>> departments = {};
    for (var m in members) {
      if (m.division != 'BPH' && m.division != '-' && m.division.isNotEmpty) {
        if (!departments.containsKey(m.division)) {
          departments[m.division] = [];
        }
        departments[m.division]!.add(m);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Struktur Organisasi',
            subtitle: ormawaProvider.orgName,
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
                  _buildCabinetInfo(ormawaProvider.academicYear),
                  const SizedBox(height: AppSpacing.xxl),

                  _buildSectionTitle(
                    'PIMPINAN INTI',
                    action:
                        ormawaProvider.hasPermission('manage_structure')
                            ? TextButton.icon(
                              onPressed: () {
                                context.push(AppRoutes.ormawaStrukturManage);
                              },
                              icon: const Icon(
                                Icons.group_add_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Kelola Pengurus BPH',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.neutral700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                backgroundColor: AppColors.neutral200,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (ketua.name != '-') ...[
                    _buildPrimaryMemberCard(
                      context,
                      ketua,
                      Icons.stars_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (wakil.name != '-') ...[
                    _buildSecondaryMemberCard(
                      context,
                      wakil,
                      Icons.shield_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  if (sekretaris.isNotEmpty || bendahara.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s20),
                    _buildSectionTitle('BADAN PENGURUS HARIAN'),
                    const SizedBox(height: AppSpacing.lg),
                    ...sekretaris.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildStaffTile(context, m, isHead: false),
                      ),
                    ),
                    ...bendahara.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildStaffTile(context, m, isHead: false),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxl),

                  // 2. Departments
                  if (departments.isNotEmpty) ...[
                    _buildSectionTitle('DIVISI & DEPARTEMEN'),
                    const SizedBox(height: AppSpacing.lg),
                    ...departments.entries.map(
                      (dept) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: _buildDepartmentCard(dept.key, [
                          ...dept.value.map(
                            (m) => _buildStaffTile(
                              context,
                              m,
                              isHead:
                                  m.role.toUpperCase().contains('KEPALA') ||
                                  m.role.toUpperCase().contains('KADEP') ||
                                  m.role.toUpperCase().contains('KOORDINATOR'),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],

                  if (members.isEmpty && !ormawaProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.xxxl,
                        ),
                        child: Text('Data pengurus belum tersedia'),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, ormawaProvider),
    );
  }

  Widget? _buildFab(BuildContext context, OrmawaProvider provider) {
    if (!provider.hasPermission('manage_structure')) return null;
    return FloatingActionButton.extended(
      onPressed: () {
        context.push(AppRoutes.ormawaStrukturManage);
      },
      backgroundColor: context.appColors.primary,
      elevation: 8,
      icon: Icon(Icons.auto_fix_high_rounded, color: context.appColors.onPrimary),
      label: Text(
        'Kelola Struktur',
        style: TextStyle(
          color: context.appColors.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCabinetInfo(String year) {
    return FadeInAnimation(
      delay: 0.2,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: context.appColors.onPrimary.withAlpha(50), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withAlpha(12),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.padding18,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withAlpha(30),
                    context.appColors.primary.withAlpha(10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusXl,
              ),
              child: Icon(
                Icons.account_tree_rounded,
                color: context.appColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.s20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Struktur Kepengurusan',
                    style: AppTextStyles.titleLg.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(10),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      'Periode $year',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
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

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: context.appColors.secondary,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildPrimaryMemberCard(
    BuildContext context,
    OrmawaMember member,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.ormawaAnggotaDetail, extra: member);
        },
        borderRadius: AppRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral600.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(15),
                  shape: BoxShape.circle,
                  image:
                      member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              ApiGate.getImageUrl(member.fotoUrl!),
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    member.fotoUrl == null || member.fotoUrl!.isEmpty
                        ? Icon(
                          icon,
                          color: context.appColors.primary,
                          size: 24,
                        )
                        : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.neutral800,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      member.role,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
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
                  color: context.appColors.primary.withAlpha(15),
                  borderRadius: AppRadius.radiusSm,
                  border: Border.all(
                    color: context.appColors.primary.withAlpha(30),
                  ),
                ),
                child: Text(
                  'BPH',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryMemberCard(
    BuildContext context,
    OrmawaMember member,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.ormawaAnggotaDetail, extra: member);
        },
        borderRadius: AppRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral600.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(15),
                  shape: BoxShape.circle,
                  image:
                      member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              ApiGate.getImageUrl(member.fotoUrl!),
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    member.fotoUrl == null || member.fotoUrl!.isEmpty
                        ? Icon(
                          icon,
                          color: context.appColors.primary,
                          size: 24,
                        )
                        : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.neutral800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      member.role,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(String title, List<Widget> members) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral600.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100.withAlpha(150),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.appColors.primary,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w900,

                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.neutral200, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: members),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(
    BuildContext context,
    OrmawaMember member, {
    bool isHead = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.ormawaAnggotaDetail, extra: member);
        },
        borderRadius: AppRadius.radiusMd,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isHead ? AppColors.neutral100 : Colors.transparent,
            borderRadius: AppRadius.radiusMd,
            border:
                isHead
                    ? Border.all(color: AppColors.neutral300, width: 1)
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient:
                      isHead
                          ? LinearGradient(
                            colors: [
                              context.appColors.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(200),
                            ],
                          )
                          : null,
                  color: isHead ? null : AppColors.neutral200,
                  shape: BoxShape.circle,
                  image:
                      member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              ApiGate.getImageUrl(member.fotoUrl!),
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                  boxShadow:
                      isHead
                          ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child:
                    member.fotoUrl == null || member.fotoUrl!.isEmpty
                        ? Center(
                          child: Text(
                            member.initial.isNotEmpty ? member.initial[0] : '?',
                            style: TextStyle(
                              color:
                                  isHead
                                      ? context.appColors.onPrimary
                                      : context.appColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: isHead ? FontWeight.w900 : FontWeight.w700,
                        color: AppColors.neutral800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      member.role,
                      style: AppTextStyles.labelSm.copyWith(
                        color:
                            isHead
                                ? context.appColors.primary
                                : AppColors.neutral500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                  member.nim,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
