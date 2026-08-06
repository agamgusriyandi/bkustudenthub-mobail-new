import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_role.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OrmawaRbacScreen extends StatefulWidget {
  const OrmawaRbacScreen({super.key});

  @override
  State<OrmawaRbacScreen> createState() => _OrmawaRbacScreenState();
}

class _OrmawaRbacScreenState extends State<OrmawaRbacScreen> {
  List<OrmawaRole> _roles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = Dio();
      final response = await dio.get('/ormawa/roles');
      final data = response.data;

      List<OrmawaRole> roles;
      if (data is List) {
        roles = data.map((e) => OrmawaRole(
          id: (e['id'] ?? '').toString(),
          name: e['name'] ?? '',
          description: e['description'] ?? '',
          permissions: (e['permissions'] as List<dynamic>?)
                  ?.map((p) => p.toString())
                  .toList() ??
              [],
        )).toList();
      } else if (data is Map && data['data'] is List) {
        roles = (data['data'] as List).map((e) => OrmawaRole(
          id: (e['id'] ?? '').toString(),
          name: e['name'] ?? '',
          description: e['description'] ?? '',
          permissions: (e['permissions'] as List<dynamic>?)
                  ?.map((p) => p.toString())
                  .toList() ??
              [],
        )).toList();
      } else {
        roles = [];
      }

      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? 'Gagal memuat data role';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: _fetchRoles,
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'ROLE-BASED ACCESS CONTROL',
              subtitle: 'HAK AKSES ROLE',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _buildErrorState(),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      if (_roles.isEmpty)
                        _buildEmptyState()
                      else
                        ...List.generate(_roles.length, (index) {
                          final role = _roles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildRoleCard(role),
                          );
                        }),
                      const SizedBox(height: AppSpacing.s80),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appColors.primary.withAlpha(10),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: context.appColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_roles.length} ROLE TERDAFTAR',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kelola hak akses untuk setiap role dalam organisasi',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(OrmawaRole role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(10),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: context.appColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (role.description.isNotEmpty)
                      Text(
                        role.description,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                  color: context.appColors.primary.withAlpha(10),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  '${role.permissions.length}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (role.permissions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'HAK AKSES',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: role.permissions.map((perm) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.s6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(10),
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(color: AppColors.success.withAlpha(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        perm,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withAlpha(10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Belum ada role',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Role dan hak akses akan muncul di sini\nsetelah dikonfigurasi di server.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Gagal Memuat Data',
              style: AppTextStyles.titleLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _fetchRoles,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Muat Ulang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
