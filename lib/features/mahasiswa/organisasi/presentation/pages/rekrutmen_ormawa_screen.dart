import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/daftar_ormawa_screen.dart';

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
      backgroundColor: BkuTheme.scaffoldBg,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: BkuTheme.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_outlined,
                        size: 32,
                        color: BkuTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tidak ada pendaftaran ormawa saat ini.',
                      style: BkuTheme.textBodyRegular.copyWith(
                        color: BkuTheme.textMuted,
                      ),
                    ),
                  ],
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
          _loadData();
        });
      };
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Icon(
                  Icons.diversity_3_rounded,
                  color: BkuTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ormawa['Nama'] ?? ormawa['nama'] ?? 'Unknown',
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BkuTheme.surfaceLight,
                        borderRadius: BkuTheme.rPill,
                        border: Border.all(color: BkuTheme.border),
                      ),
                      child: Text(
                        ormawa['Kategori'] ?? ormawa['kategori'] ?? 'Kategori',
                        style: BkuTheme.textBadge.copyWith(
                          color: BkuTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ormawa['deskripsi'] ?? 'Tidak ada deskripsi',
            style: BkuTheme.textCaption.copyWith(
              color: BkuTheme.textMuted,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          if (minIpk > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    profile.ipk < minIpk && !isNewStudent
                        ? BkuTheme.roseSoft
                        : BkuTheme.emeraldSoft,
                borderRadius: BkuTheme.r8,
                border: Border.all(
                  color:
                      profile.ipk < minIpk && !isNewStudent
                          ? BkuTheme.roseBorder
                          : BkuTheme.emeraldBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color:
                        profile.ipk < minIpk && !isNewStudent
                            ? BkuTheme.danger
                            : BkuTheme.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Syarat IPK: ${minIpk.toStringAsFixed(2)}',
                    style: BkuTheme.textBadge.copyWith(
                      color:
                          profile.ipk < minIpk && !isNewStudent
                              ? BkuTheme.danger
                              : BkuTheme.success,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            width: double.infinity,
            child: BkuButton(
              text: btnText,
              onPressed: action,
              height: 42,
            ),
          ),
        ],
      ),
    );
  }
}
