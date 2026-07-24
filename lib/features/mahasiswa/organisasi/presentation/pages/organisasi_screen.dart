import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/add_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/daftar_ormawa_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import '../../utils/portfolio_pdf_generator.dart';

class OrganisasiScreen extends StatefulWidget {
  const OrganisasiScreen({super.key});

  @override
  State<OrganisasiScreen> createState() => _OrganisasiScreenState();
}

class _OrganisasiScreenState extends State<OrganisasiScreen> {
  List<Map<String, dynamic>> _exploreOrmawaList = [];
  bool _isExploreLoading = true;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAllData();
      _loadExploreData();
    });
  }

  Future<void> _loadExploreData() async {
    if (!mounted) return;
    setState(() => _isExploreLoading = true);
    try {
      final list = await context.read<StudentProvider>().getOrmawaList();
      if (mounted) {
        setState(() {
          _exploreOrmawaList = list;
          _isExploreLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isExploreLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final orgHistory = student.organizationHistory;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );
            await PortfolioPdfGenerator.generateAndPrintPortfolio(student);
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (ctx) => CustomDialog(
                      title: 'Gagal',
                      content: 'Gagal export portofolio: $e',
                      cancelText: '',
                      confirmText: 'Tutup',
                      onCancel: () {},
                      onConfirm: () => Navigator.pop(ctx),
                      isDestructive: true,
                    ),
              );
            }
          }
        },
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
        label: Text(
          'Export Portfolio',
          style: AppTextStyles.labelMd.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Organisasi & Komunitas',
            subtitle: 'KAMPUS BHAKTI KENCANA',
            variant: AppBarVariant.student,
            expandedHeight: 130,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const FadeInAnimation(
                    delay: 0.2,
                    child: _OrganizationBanner(),
                  ),
                  const SizedBox(height: 24),
                  FadeInAnimation(
                    delay: 0.3,
                    child: _buildPortfolioStats(orgHistory),
                  ),
                  const SizedBox(height: 32),
                  FadeInAnimation(
                    delay: 0.4,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabPill(
                            0,
                            'Keanggotaan & Riwayat (${orgHistory.length})',
                          ),
                          const SizedBox(width: 8),
                          _buildTabPill(1, 'Daftar Ormawa Baru'),
                          const SizedBox(width: 8),
                          _buildTabPill(
                            2,
                            'Tagihan Iuran Kas (${student.iuranList.where((i) => i['status'] != 'lunas').length})',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_activeTab == 0) ...[
                    if (student.isLoading)
                      const BkuShimmerList(itemCount: 2, itemHeight: 120)
                    else if (orgHistory.isEmpty)
                      FadeInAnimation(
                        delay: 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxxl,
                            horizontal: AppSpacing.xl,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Belum ada riwayat organisasi yang sinkron.',
                            style: AppTextStyles.labelMd.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      )
                    else
                      ...orgHistory.asMap().entries.map((entry) {
                        final index = entry.key;
                        final org = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FadeInAnimation(
                            delay: 0.5 + (index * 0.1),
                            child: _buildOrgCard(
                              context,
                              org,
                              index % 2 == 0
                                  ? Icons.groups_rounded
                                  : Icons.diversity_3_rounded,
                              index % 2 == 0
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF9333EA),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                    FadeInAnimation(
                      delay: 0.7,
                      child: _buildAddButton(context),
                    ),
                  ] else if (_activeTab == 1) ...[
                    _buildDaftarOrmawaTab(),
                  ] else if (_activeTab == 2) ...[
                    _buildTagihanIuranTab(student),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgCard(
    BuildContext context,
    OrganizationHistory org,
    IconData icon,
    Color iconColor,
  ) {
    final name = org.namaOrganisasi;
    final type = org.tipe;
    final role = org.jabatan;
    final achievements = org.achievements;
    final period =
        org.periodeSelesai != null
            ? '${org.periodeMulai} - ${org.periodeSelesai}'
            : '${org.periodeMulai} - Sekarang';
    final statusVerifikasi = org.statusVerifikasi;
    final isVerified = statusVerifikasi.toLowerCase() == 'terverifikasi';
    final isPending = statusVerifikasi.toLowerCase() == 'pending';

    Color statusBgColor = Colors.grey.withAlpha(20);
    Color statusTextColor = Theme.of(context).colorScheme.outline;

    if (isVerified) {
      statusBgColor = AppColors.success.withAlpha(20);
      statusTextColor = AppColors.success;
    } else if (isPending) {
      statusBgColor = AppColors.warning.withAlpha(20);
      statusTextColor = AppColors.warning;
    } else if (statusVerifikasi.toLowerCase() == 'ditolak') {
      statusBgColor = AppColors.error.withAlpha(20);
      statusTextColor = AppColors.error;
    }

    return BkuCard(
      child: InkWell(
        onTap: () => _showOrgDetail(context, org, icon, iconColor),
        borderRadius: AppRadius.radiusXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(10),
                      borderRadius: AppRadius.radiusLg,
                    ),
                    child: Icon(icon, color: iconColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.titleLg.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type,
                          style: AppTextStyles.labelMd.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Text(
                      statusVerifikasi.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(
                        color: statusTextColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JABATAN',
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 25,
                    color: AppColors.neutral300,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERIODE',
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
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
            if (achievements.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencapaian Utama:',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...achievements.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: iconColor.withAlpha(15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 10,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a,
                                style: AppTextStyles.labelMd.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioStats(List<OrganizationHistory> orgHistory) {
    final totalOrg = orgHistory.length.toString();
    final verifiedOrg =
        orgHistory
            .where(
              (org) => org.statusVerifikasi.toLowerCase() == 'terverifikasi',
            )
            .length
            .toString();
    final totalAchievements =
        orgHistory
            .fold<int>(0, (sum, org) => sum + org.achievements.length)
            .toString();

    return Row(
      children: [
        _buildStatItem(
          totalOrg,
          'Total Organisasi',
          Icons.bolt_rounded,
          AppColors.warning,
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          verifiedOrg,
          'Terverifikasi',
          Icons.verified_user_rounded,
          AppColors.info,
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          totalAchievements,
          'Pencapaian',
          Icons.emoji_events_rounded,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              count,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.neutral800,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _tabPillColors = [
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFF7C3AED),
  ];

  Widget _buildTabPill(int index, String label) {
    final isActive = _activeTab == index;
    final activeColor = _tabPillColors[index % _tabPillColors.length];

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(70),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDaftarOrmawaTab() {
    final openOrmawas =
        _exploreOrmawaList.where((o) {
          if (o['open_recruitment'] != true) return false;

          final startStr = o['recruitment_start'];
          final endStr = o['recruitment_end'];
          final now = DateTime.now();

          if (startStr != null && startStr.toString().isNotEmpty) {
            try {
              final start = DateTime.parse(startStr.toString());
              if (now.isBefore(start)) return false;
            } catch (_) {}
          }

          if (endStr != null && endStr.toString().isNotEmpty) {
            try {
              final end = DateTime.parse(endStr.toString());
              final endOfDay = DateTime(
                end.year,
                end.month,
                end.day,
                23,
                59,
                59,
              );
              if (now.isAfter(endOfDay)) return false;
            } catch (_) {}
          }

          return true;
        }).toList();
    if (_isExploreLoading) {
      return const BkuShimmerList(itemCount: 2, itemHeight: 90);
    }
    if (openOrmawas.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'Tidak ada pendaftaran ormawa saat ini.',
          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
        ),
      );
    }
    return Column(
      children:
          openOrmawas.map((ormawa) {
            final name = ormawa['Nama'] ?? ormawa['nama'] ?? 'Unknown';
            final kategoriDetail =
                ormawa['kategori_detail'] ?? ormawa['KategoriDetail'];
            final category =
                (kategoriDetail != null && kategoriDetail is Map)
                    ? (kategoriDetail['nama'] ??
                        kategoriDetail['Nama'] ??
                        'Organisasi')
                    : (ormawa['Kategori'] ??
                        ormawa['kategori'] ??
                        'Organisasi');
            final logoUrl = ormawa['LogoURL'] ?? ormawa['logo_url'] ?? '';
            final id =
                ormawa['id']?.toString() ?? ormawa['ID']?.toString() ?? '';
            final imageUrl = ApiGate.getImageUrl(logoUrl);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        logoUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                            )
                            : _buildDefaultLogo(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DaftarOrmawaScreen(
                                ormawaId: id,
                                namaOrmawa: name,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Daftar'),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.neutral200,
      child: const Icon(Icons.groups_rounded, color: AppColors.neutral500),
    );
  }

  Widget _buildTagihanIuranTab(StudentProvider student) {
    final list = student.iuranList;
    if (student.isLoading) {
      return const BkuShimmerList(itemCount: 2, itemHeight: 90);
    }
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'Tidak ada tagihan iuran aktif.',
          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
        ),
      );
    }
    return Column(
      children:
          list.map((item) {
            final id = item['id']?.toString() ?? item['ID']?.toString() ?? '';
            final status = item['status'] ?? 'belum_bayar';
            final catatan = item['catatan'] ?? '';

            final iuran = item['iuran'] ?? {};
            final ormawa = iuran['ormawa'] ?? {};
            final ormawaName = ormawa['Nama'] ?? ormawa['nama'] ?? 'Ormawa';
            final judul = iuran['judul'] ?? 'Iuran Kas';
            final nominal = iuran['nominal'] ?? 0.0;
            final tenggatStr = iuran['tenggat'] ?? '';

            String formattedDate = '';
            if (tenggatStr.isNotEmpty) {
              try {
                final date = DateTime.parse(tenggatStr);
                formattedDate = '${date.day}/${date.month}/${date.year}';
              } catch (_) {
                formattedDate = tenggatStr;
              }
            }

            Color statusColor;
            String statusLabel;
            if (status == 'lunas') {
              statusColor = AppColors.success;
              statusLabel = 'Lunas';
            } else if (status == 'pending') {
              statusColor = AppColors.warning;
              statusLabel = 'Menunggu Verifikasi';
            } else if (status == 'ditolak') {
              statusColor = AppColors.error;
              statusLabel = 'Ditolak';
            } else {
              statusColor = AppColors.neutral500;
              statusLabel = 'Belum Bayar';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ormawaName,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.bodySm.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    judul,
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nominal:',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      Text(
                        'Rp ${_formatNominal(nominal)}',
                        style: AppTextStyles.titleMd.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tenggat Pembayaran:',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (catatan.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: $catatan',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (status == 'belum_bayar' || status == 'ditolak') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showPaymentSheet(context, id, iuran),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Bayar Sekarang'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  void _showPaymentSheet(
    BuildContext context,
    String invoiceId,
    Map<String, dynamic> iuran,
  ) {
    final bankName = iuran['nama_bank'] ?? '-';
    final noRekening = iuran['no_rekening'] ?? '-';
    final namaRekening = iuran['nama_rekening'] ?? '-';
    final nominal = iuran['nominal'] ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Detail Pembayaran Transfer',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildIuranDetailRow('Bank Tujuan', bankName),
                        const Divider(height: 24),
                        _buildIuranDetailRow('Nomor Rekening', noRekening),
                        const Divider(height: 24),
                        _buildIuranDetailRow(
                          'Nama Pemilik Rekening',
                          namaRekening,
                        ),
                        const Divider(height: 24),
                        _buildIuranDetailRow(
                          'Nominal Transfer',
                          'Rp ${_formatNominal(nominal)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = context.read<StudentProvider>();
                        final navigator = Navigator.of(context);
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          );
                          final success = await provider.payIuran(
                            invoiceId,
                            image.path,
                          );
                          navigator.pop();

                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder:
                                (dialogCtx) => CustomDialog(
                                  title: success ? 'Sukses' : 'Gagal',
                                  content:
                                      success
                                          ? 'Bukti pembayaran berhasil diunggah! Menunggu konfirmasi bendahara.'
                                          : 'Gagal mengunggah bukti pembayaran.',
                                  cancelText: '',
                                  confirmText: 'OK',
                                  onCancel: () {},
                                  onConfirm: () => Navigator.pop(dialogCtx),
                                ),
                          );
                        }
                      },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Pilih Bukti Pembayaran & Kirim'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIuranDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatNominal(dynamic val) {
    if (val == null) return '0';
    try {
      final double num = double.parse(val.toString());
      return num.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } catch (_) {
      return val.toString();
    }
  }

  Widget _buildAddButton(BuildContext context) {
    const accentColor = Color(0xFF1E293B);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddOrganisasiScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: accentColor,
              size: 26,
            ),
            SizedBox(height: 8),
            Text(
              'Tambah Riwayat Organisasi',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrgDetail(
    BuildContext context,
    OrganizationHistory org,
    IconData icon,
    Color iconColor,
  ) {
    final name = org.namaOrganisasi;
    final type = org.tipe;
    final role = org.jabatan;
    final period =
        org.periodeSelesai != null
            ? '${org.periodeMulai} - ${org.periodeSelesai}'
            : '${org.periodeMulai} - Sekarang';
    final achievements = org.achievements;
    final statusVerifikasi = org.statusVerifikasi;
    final description = org.deskripsiKegiatan;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: iconColor.withAlpha(15),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Icon(icon, color: iconColor, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.titleLg.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                Text(
                                  type,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildDetailSection('Detail Posisi', [
                        _buildDetailRow(Icons.badge_rounded, 'Jabatan', role),
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Periode',
                          period,
                        ),
                        _buildDetailRow(
                          Icons.info_outline_rounded,
                          'Status Verifikasi',
                          statusVerifikasi,
                        ),
                      ]),
                      const SizedBox(height: 32),
                      Text(
                        'Deskripsi Kontribusi',
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description.isNotEmpty
                            ? description
                            : 'Tidak ada deskripsi kontribusi.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      if (achievements.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Pencapaian & Impact',
                          style: AppTextStyles.titleLg.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...achievements.map(
                          (a) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(30),
                              borderRadius: AppRadius.radiusLg,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    a,
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dokumentasi',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral800,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null && context.mounted) {
                                try {
                                  BkuLoadingDialog.show(context);
                                  await context
                                      .read<StudentProvider>()
                                      .uploadOrganizationDokumentasi(
                                        org.id,
                                        pickedFile.path,
                                      );
                                  if (!context.mounted) return;
                                  BkuLoadingDialog.hide(context);
                                  Navigator.pop(context);
                                  AppSnackbar.showSuccess(
                                    context,
                                    'Dokumentasi berhasil diunggah',
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  BkuLoadingDialog.hide(context);
                                  AppSnackbar.showError(
                                    context,
                                    ErrorHandler.getMessage(e),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.upload_rounded, size: 16),
                            label: Text(
                              org.dokumentasi != null &&
                                      org.dokumentasi!.isNotEmpty
                                  ? 'Ganti'
                                  : 'Upload',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (org.dokumentasi != null &&
                          org.dokumentasi!.isNotEmpty)
                        org.dokumentasi!.toLowerCase().endsWith('.pdf')
                            ? InkWell(
                              onTap: () async {
                                final urlStr = org.dokumentasi!;
                                final uri = Uri.parse(
                                  urlStr.startsWith('http')
                                      ? urlStr
                                      : '${ApiGate.baseUrl.replaceAll('/api', '')}$urlStr',
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: AppRadius.radiusLg,
                                  border: Border.all(
                                    color: AppColors.neutral200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: AppColors.error,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Dokumen PDF',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18,
                                      color: AppColors.neutral600,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: AppRadius.radiusLg,
                              child: Image.network(
                                org.dokumentasi!.startsWith('http')
                                    ? org.dokumentasi!
                                    : '${ApiGate.baseUrl.replaceAll('/api', '')}${org.dokumentasi}',
                                fit: BoxFit.cover,
                                height: 180,
                                width: double.infinity,
                                errorBuilder:
                                    (ctx, err, stack) => Container(
                                      height: 100,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Icon(Icons.broken_image_rounded),
                                      ),
                                    ),
                              ),
                            )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: AppRadius.radiusLg,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library_rounded,
                                size: 40,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada dokumentasi',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (statusVerifikasi.toLowerCase() == 'menunggu' ||
                          statusVerifikasi.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: BkuButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddOrganisasiScreen(
                                              organization: org,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icons.edit_rounded,
                                  text: 'Edit Riwayat',
                                  variant: BkuButtonVariant.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: BkuButton(
                                  onPressed:
                                      () => _confirmDeleteOrg(context, org.id),
                                  icon: Icons.delete_outline_rounded,
                                  text: 'Hapus',
                                  variant: BkuButtonVariant.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: BkuButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icons.close_rounded,
                            text: 'Tutup',
                            variant: BkuButtonVariant.outline,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: BkuButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icons.close_rounded,
                            text: 'Tutup',
                            variant: BkuButtonVariant.outline,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteOrg(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            title: 'Hapus Riwayat Organisasi?',
            content:
                'Apakah Anda yakin ingin menghapus riwayat organisasi ini? Tindakan ini tidak dapat dibatalkan.',
            isDestructive: true,
            cancelText: 'Batal',
            confirmText: 'Ya, Hapus',
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              Navigator.pop(dialogContext);

              try {
                BkuLoadingDialog.show(context);
                await context
                    .read<StudentProvider>()
                    .deleteOrganizationHistory(id);
                if (context.mounted) {
                  BkuLoadingDialog.hide(context);
                  Navigator.pop(context);
                  AppSnackbar.showSuccess(
                    context,
                    'Riwayat organisasi berhasil dihapus',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  BkuLoadingDialog.hide(context);
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => CustomDialog(
                          title: 'Gagal Menghapus Data',
                          content: ErrorHandler.getMessage(e),
                          cancelText: '',
                          confirmText: 'Tutup',
                          onConfirm: () => Navigator.pop(ctx),
                          onCancel: () {},
                        ),
                  );
                }
              }
            },
          ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLg.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 16),
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrganizationBanner extends StatelessWidget {
  const _OrganizationBanner();

  @override
  Widget build(BuildContext context) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'LEADERSHIP PORTFOLIO',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral800,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Jejak Kontribusi\n& Kepemimpinan',
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.neutral800,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat setiap pengalaman organisasimu untuk masa depan.',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
