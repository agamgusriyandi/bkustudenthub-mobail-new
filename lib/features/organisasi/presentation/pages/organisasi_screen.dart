import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';
import 'package:go_router/go_router.dart';
import "package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart";

class OrganisasiScreen extends StatelessWidget {
  const OrganisasiScreen({super.key});

  void _showAddOrgBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final roleController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();
    final descController = TextEditingController();
    final achievementsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                      Text(
                        'Tambah Riwayat Organisasi',
                        style: AppTextStyles.titleLg.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BkuTextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Organisasi',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          prefixIcon: const Icon(Icons.business_rounded),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Nama organisasi wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BkuTextField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: 'Tipe Organisasi (e.g. BEM, HIMA, UKM)',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Tipe organisasi wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BkuTextField(
                        controller: roleController,
                        decoration: InputDecoration(
                          labelText: 'Jabatan (Peran)',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          prefixIcon: const Icon(Icons.person_rounded),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Jabatan wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: BkuTextField(
                              controller: startYearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tahun Mulai',
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                ),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: BkuTextField(
                              controller: endYearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tahun Selesai (Opsional)',
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BkuTextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Kegiatan',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          prefixIcon: const Icon(Icons.description_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BkuTextField(
                        controller: achievementsController,
                        decoration: InputDecoration(
                          labelText: 'Pencapaian Utama (pisahkan dengan koma)',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusLg,
                          ),
                          prefixIcon: const Icon(Icons.star_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BkuButton(
                        height: 54,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final organizationProvider =
                                Provider.of<OrganizationProvider>(
                                  context,
                                  listen: false,
                                );
                            final achievementsList =
                                achievementsController.text.isNotEmpty
                                    ? achievementsController.text
                                        .split(',')
                                        .map((s) => s.trim())
                                        .toList()
                                    : <String>[];
                            final startYear =
                                int.tryParse(startYearController.text) ??
                                2023;
                            final endYear = int.tryParse(
                              endYearController.text,
                            );

                            final org = OrganizationHistory(
                              id: '',
                              namaOrganisasi: nameController.text,
                              tipe: typeController.text,
                              jabatan: roleController.text,
                              periodeMulai: startYear,
                              periodeSelesai: endYear,
                              deskripsiKegiatan: descController.text,
                              apresiasi:
                                  achievementsList.isNotEmpty
                                      ? achievementsList.first
                                      : 'Partisipasi aktif',
                              statusVerifikasi: 'Menunggu',
                              achievements:
                                  achievementsList.isNotEmpty
                                      ? achievementsList
                                      : ['Anggota aktif kepengurusan'],
                            );

                            try {
                              await organizationProvider.addOrganizationHistory(
                                org,
                              );
                              if (context.mounted) {
                                context.pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Riwayat organisasi berhasil ditambahkan!',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppSnackbar.showError(
                                  context,
                                  'Gagal menambah riwayat organisasi: $e',
                                );
                              }
                            }
                          }
                        },
                        text: 'Simpan Riwayat',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    const FadeInAnimation(
                      delay: 0.2,
                      child: _OrganizationBanner(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeInAnimation(
                      delay: 0.4,
                      child: Text(
                        'Riwayat Organisasi',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Consumer<OrganizationProvider>(
                      builder: (context, provider, child) {
                        final orgList = provider.organizationHistory;
                        if (orgList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xxl,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.groups_outlined,
                                    size: 64,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withAlpha(80),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'Belum ada riwayat organisasi',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Daftarkan riwayat organisasi Anda di bawah ini.',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orgList.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: AppSpacing.lg),
                          itemBuilder: (context, index) {
                            final org = orgList[index];
                            final isBEM = org.tipe.toLowerCase().contains(
                              'bem',
                            );
                            return FadeInAnimation(
                              delay: 0.3 + (index * 0.1),
                              child: _buildOrgCard(
                                context,
                                org.namaOrganisasi,
                                org.tipe,
                                org.jabatan,
                                "${org.periodeMulai} - ${org.periodeSelesai ?? 'Sekarang'}",
                                org.achievements,
                                isBEM
                                    ? Icons.groups_rounded
                                    : Icons.diversity_3_rounded,
                                isBEM
                                    ? context.appColors.info
                                    : context.appColors.info,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeInAnimation(
                      delay: 0.7,
                      child: _buildAddButton(context),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeInAnimation(
                      delay: 0.8,
                      child: Text(
                        'Dokumentasi Kegiatan',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeInAnimation(delay: 0.9, child: _buildGalleryGrid(context)),
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
                iconTheme: IconThemeData(color: context.appColors.onPrimary),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.zero,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCollapsed =
                constraints.biggest.height <=
                kToolbarHeight + MediaQuery.of(context).padding.top + 10;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: isCollapsed ? AppSpacing.lg : AppSpacing.s48),
              child: Text(
                'Organisasi',
                style: AppTextStyles.titleLg.copyWith(
                  color: context.appColors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.read<ThemeProvider>().primaryGradient,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: 10,
                child: Icon(
                  Icons.groups_rounded,
                  size: 120,
                  color: context.appColors.onPrimary.withAlpha(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrgCard(
    BuildContext context,
    String name,
    String type,
    String role,
    String period,
    List<String> achievements,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(2),
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
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(10),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleLg.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.primary,
                      ),
                    ),
                    Text(
                      type,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.primary.withAlpha(5),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: context.appColors.primary.withAlpha(10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERAN',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        role,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: context.appColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 30,
                  color: context.appColors.primary.withAlpha(15),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERIODE',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        period,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Pencapaian Utama:',
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...achievements.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: iconColor),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: Text(
                      a,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BkuButton(
        onPressed: () => _showAddOrgBottomSheet(context),
        icon: Icons.add_circle_outline_rounded,
        text: 'Tambah Riwayat Organisasi',
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.radiusXl,
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=500&q=80',
              ),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusXl,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, context.appColors.onSurface.withAlpha(180)],
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            alignment: Alignment.bottomLeft,
              child: Text(
                'Kegiatan ${index + 1}',
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationBanner extends StatelessWidget {
  const _OrganizationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.read<ThemeProvider>().primaryGradient,
        ),
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.appColors.onPrimary.withAlpha(40),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'LEADERSHIP PORTFOLIO',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.onPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Jejak Kontribusi\n& Kepemimpinan',
            style: AppTextStyles.headlineMd.copyWith(
              color: context.appColors.onPrimary,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Catat setiap pengalaman organisasimu untuk masa depan.',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.onPrimary.withAlpha(178),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
