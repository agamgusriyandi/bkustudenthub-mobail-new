import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/daftar_ormawa_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class RekrutmenOrmawaScreen extends StatefulWidget {
  const RekrutmenOrmawaScreen({super.key});

  @override
  State<RekrutmenOrmawaScreen> createState() => _RekrutmenOrmawaScreenState();
}

class _RekrutmenOrmawaScreenState extends State<RekrutmenOrmawaScreen> {
  List<Map<String, dynamic>> _ormawaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await context.read<OrganizationProvider>().getOrmawaList();
      if (mounted) {
        setState(() {
          _ormawaList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final organization = context.watch<OrganizationProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: const BkuStaticAppBar(
        title: 'Rekrutmen Ormawa',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body:
          _isLoading
              ? const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: BkuShimmerList(itemCount: 5, itemHeight: 80),
              )
              : _ormawaList.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada pendaftaran ormawa saat ini.',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: _ormawaList.length,
                itemBuilder: (context, index) {
                  final ormawa = _ormawaList[index];
                  return _buildOrmawaCard(ormawa, profile, organization);
                },
              ),
    );
  }

  Widget _buildOrmawaCard(
    Map<String, dynamic> ormawa,
    ProfileProvider profile,
    OrganizationProvider organization,
  ) {
    final minIpk = double.tryParse(ormawa['min_ipk']?.toString() ?? '0') ?? 0.0;
    final isNewStudent = profile.semester == 1;

    final ormawaName = ormawa['Nama'] ?? ormawa['nama'] ?? '';
    final hasPending = organization.organizationHistory.any(
      (h) =>
          h.namaOrganisasi.toLowerCase() ==
              ormawaName.toString().toLowerCase() &&
          h.statusVerifikasi.toLowerCase() == 'pending',
    );
    final hasDiterima = organization.organizationHistory.any(
      (h) =>
          h.namaOrganisasi.toLowerCase() ==
              ormawaName.toString().toLowerCase() &&
          (h.statusVerifikasi.toLowerCase() == 'terverifikasi' ||
              h.statusVerifikasi.toLowerCase() == 'aktif'),
    );

    String btnText = 'Daftar Sekarang';
    VoidCallback? action;

    final isOpenRecruitment = ormawa['open_recruitment'] == true;

    if (hasDiterima) {
      btnText = 'Terdaftar';
    } else if (hasPending) {
      btnText = 'Menunggu Persetujuan';
    } else if (!isOpenRecruitment) {
      btnText = 'Pendaftaran Ditutup';
      action = null;
    } else {
      action = () {
        final studentIpk = profile.ipk;
        if (minIpk > 0 && studentIpk < minIpk && !isNewStudent) {
          AppSnackbar.showSuccess(
            context,
            'IPK Anda (${studentIpk.toStringAsFixed(2)})',
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DaftarOrmawaScreen(
                  ormawaId: ormawa['id'].toString(),
                  namaOrmawa: ormawa['Nama'] ?? ormawa['nama'] ?? 'Ormawa',
                ),
          ),
        ).then((_) {
          // Refresh list when returning
          _loadData();
        });
      };
    }

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.diversity_3_rounded,
                    color: AppColors.neutral600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ormawa['Nama'] ?? ormawa['nama'] ?? 'Unknown',
                        style: AppTextStyles.titleLg.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ormawa['Kategori'] ?? ormawa['kategori'] ?? 'Kategori',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ormawa['deskripsi'] ?? 'Tidak ada deskripsi',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (minIpk > 0) ...[
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Syarat IPK: ${minIpk.toStringAsFixed(2)}',
                    style: AppTextStyles.labelSm.copyWith(
                      color:
                          profile.ipk < minIpk && !isNewStudent
                              ? AppColors.danger
                              : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            BkuButton(text: btnText, onPressed: action),
          ],
        ),
      ),
    );
  }
}
