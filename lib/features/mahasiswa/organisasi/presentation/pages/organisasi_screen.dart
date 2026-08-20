import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/add_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/daftar_ormawa_screen.dart';
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
      context.read<OrganizationProvider>().loadOrganizationData();
      _loadExploreData();
    });
  }

  Future<void> _loadExploreData() async {
    if (!mounted) return;
    setState(() => _isExploreLoading = true);
    try {
      final list = await context.read<OrganizationProvider>().getOrmawaList();
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
    final student = context.watch<OrganizationProvider>();
    final orgHistory = student.organizationHistory;

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            BkuLoadingDialog.show(context);
            await PortfolioPdfGenerator.generateAndPrintPortfolio(
              context.read<ProfileProvider>(),
              student,
            );
            if (context.mounted) context.pop();
          } catch (e) {
            if (context.mounted) context.pop();
            if (context.mounted) {
              BkuDialog.show(
                context: context,
                type: BkuDialogType.error,
                title: 'Gagal',
                message: 'Gagal export portofolio: $e',
                primaryButtonText: 'Tutup',
                onPrimaryPressed: () => Navigator.pop(context),
              );
            }
          }
        },
        backgroundColor: BkuTheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BkuTheme.rPill),
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
        label: Text(
          'Export Portofolio',
          style: BkuTheme.textButton.copyWith(color: Colors.white, fontSize: 12.5),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const BkuAppBar(
            title: 'Organisasi & Komunitas',
            subtitle: 'Jejak Kontribusi & Kepemimpinan Mahasiswa',
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
                  const SizedBox(height: AppSpacing.xl),
                  const FadeInAnimation(
                    delay: 0.1,
                    child: _OrganizationBanner(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeInAnimation(
                    delay: 0.15,
                    child: _buildPortfolioStats(orgHistory),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeInAnimation(
                    delay: 0.2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildTabPill(
                            0,
                            'Keanggotaan (${orgHistory.length})',
                          ),
                          const SizedBox(width: 8),
                          _buildTabPill(1, 'Daftar Ormawa Baru'),
                          const SizedBox(width: 8),
                          _buildTabPill(
                            2,
                            'Tagihan Iuran (${student.iuranList.where((i) => i['status'] != 'lunas').length})',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_activeTab == 0) ...[
                    if (student.isLoading)
                      const BkuShimmerList(itemCount: 2, itemHeight: 120)
                    else if (orgHistory.isEmpty)
                      FadeInAnimation(
                        delay: 0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Text(
                            'Belum ada riwayat organisasi yang sinkron.',
                            style: BkuTheme.textCaption,
                          ),
                        ),
                      )
                    else
                      ...orgHistory.asMap().entries.map((entry) {
                        final index = entry.key;
                        final org = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: FadeInAnimation(
                            delay: 0.05 + (index * 0.04),
                            child: _buildOrgCard(context, org),
                          ),
                        );
                      }),
                    const SizedBox(height: AppSpacing.sm),
                    FadeInAnimation(
                      delay: 0.3,
                      child: _buildAddButton(context),
                    ),
                  ] else if (_activeTab == 1) ...[
                    _buildDaftarOrmawaTab(),
                  ] else if (_activeTab == 2) ...[
                    _buildTagihanIuranTab(student),
                  ],
                  const SizedBox(height: AppSpacing.s120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, OrganizationHistory org) {
    final rawName = org.namaOrganisasi;
    final name = rawName.toUpperCase() == rawName
        ? rawName.split(' ').map((w) => w.length > 3 ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : w).join(' ')
        : rawName;
    final type = org.tipe;
    final role = org.jabatan;
    final achievements = org.achievements;
    final period = org.periodeSelesai != null
        ? '${org.periodeMulai} – ${org.periodeSelesai}'
        : '${org.periodeMulai} – Sekarang';
    final statusVerifikasi = org.statusVerifikasi;
    final isVerified = statusVerifikasi.toLowerCase() == 'terverifikasi';
    final isPending = statusVerifikasi.toLowerCase() == 'pending' ||
        statusVerifikasi.toLowerCase() == 'menunggu';

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);
    Color statusBorder = const Color(0xFFFDE68A);
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (isVerified) {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
      statusBorder = const Color(0xFFA7F3D0);
      statusIcon = Icons.check_circle_rounded;
    } else if (!isPending) {
      statusBg = const Color(0xFFFFF1F2);
      statusText = const Color(0xFFE11D48);
      statusBorder = const Color(0xFFFFE4E6);
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrgDetail(context, org),
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: BkuTheme.indigoSoft,
                        borderRadius: BkuTheme.r12,
                        border: Border.all(color: BkuTheme.indigoBorder),
                      ),
                      child: const Icon(Icons.groups_rounded, color: BkuTheme.indigo, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: BkuTheme.textCardTitle.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type,
                            style: BkuTheme.textCaption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BkuTheme.rPill,
                        border: Border.all(color: statusBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusText, size: 11),
                          const SizedBox(width: 3.5),
                          Text(
                            statusVerifikasi,
                            style: BkuTheme.textBadge.copyWith(
                              color: statusText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JABATAN',
                              style: BkuTheme.textBadge.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              role,
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERIODE',
                              style: BkuTheme.textBadge.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              period,
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (achievements.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: achievements.take(2).map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: BkuTheme.amberSoft,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: BkuTheme.amberBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: BkuTheme.amber, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              a,
                              style: BkuTheme.textBadge.copyWith(
                                color: BkuTheme.amber,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioStats(List<OrganizationHistory> orgHistory) {
    final totalOrg = orgHistory.length.toString();
    final verifiedOrg = orgHistory
        .where((org) => org.statusVerifikasi.toLowerCase() == 'terverifikasi')
        .length
        .toString();
    final totalAchievements =
        orgHistory.fold<int>(0, (sum, org) => sum + org.achievements.length).toString();

    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            label: 'Total Organisasi',
            value: totalOrg,
            icon: Icons.groups_rounded,
            color: BkuTheme.indigo,
            bgColor: BkuTheme.indigoSoft,
            borderColor: BkuTheme.indigoBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard(
            label: 'Terverifikasi',
            value: verifiedOrg,
            icon: Icons.verified_rounded,
            color: BkuTheme.emerald,
            bgColor: BkuTheme.emeraldSoft,
            borderColor: BkuTheme.emeraldBorder,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildKpiCard(
            label: 'Pencapaian',
            value: totalAchievements,
            icon: Icons.emoji_events_rounded,
            color: BkuTheme.amber,
            bgColor: BkuTheme.amberSoft,
            borderColor: BkuTheme.amberBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: BkuTheme.textKpiValue.copyWith(
              fontSize: 20,
              color: BkuTheme.textHeading,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: BkuTheme.textCaption.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: BkuTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BkuTheme.rPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isActive ? BkuTheme.primary : BkuTheme.cardSurface,
          borderRadius: BkuTheme.rPill,
          border: Border.all(
            color: isActive ? BkuTheme.primary : BkuTheme.border,
          ),
          boxShadow: isActive ? BkuTheme.cardShadow : null,
        ),
        child: Text(
          label,
          style: BkuTheme.textCaption.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? Colors.white : BkuTheme.textHeading,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDaftarOrmawaTab() {
    final openOrmawas = _exploreOrmawaList.where((o) {
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
          final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
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
          style: BkuTheme.textCaption,
        ),
      );
    }
    return Column(
      children: openOrmawas.map((ormawa) {
        final name = ormawa['Nama'] ?? ormawa['nama'] ?? 'Unknown';
        final kategoriDetail = ormawa['kategori_detail'] ?? ormawa['KategoriDetail'];
        final category = (kategoriDetail != null && kategoriDetail is Map)
            ? (kategoriDetail['nama'] ?? kategoriDetail['Nama'] ?? 'Organisasi')
            : (ormawa['Kategori'] ?? ormawa['kategori'] ?? 'Organisasi');
        final logoUrl = ormawa['LogoURL'] ?? ormawa['logo_url'] ?? '';
        final id = ormawa['id']?.toString() ?? ormawa['ID']?.toString() ?? '';
        final imageUrl = ApiGate.getImageUrl(logoUrl);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r16,
            border: Border.all(color: BkuTheme.border),
            boxShadow: BkuTheme.cardShadow,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BkuTheme.r12,
                child: logoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (_, url, error) => _buildDefaultLogo(),
                        placeholder: (context, url) => Container(color: BkuTheme.borderSubtle),
                      )
                    : _buildDefaultLogo(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      category,
                      style: BkuTheme.textCaption,
                    ),
                  ],
                ),
              ),
              BkuButton(
                text: 'Daftar',
                height: 36,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DaftarOrmawaScreen(
                        ormawaId: id,
                        namaOrmawa: name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: BkuTheme.indigoSoft,
        borderRadius: BkuTheme.r12,
      ),
      child: const Icon(Icons.groups_rounded, color: BkuTheme.indigo, size: 22),
    );
  }

  Widget _buildTagihanIuranTab(OrganizationProvider student) {
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
          style: BkuTheme.textCaption,
        ),
      );
    }
    return Column(
      children: list.map((item) {
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

        Color statusBg = BkuTheme.statusWarningBg;
        Color statusText = BkuTheme.statusWarningText;
        Color statusBorder = BkuTheme.statusWarningBorder;
        String statusLabel = 'Belum Bayar';

        if (status == 'lunas') {
          statusBg = BkuTheme.statusSuccessBg;
          statusText = BkuTheme.statusSuccessText;
          statusBorder = BkuTheme.statusSuccessBorder;
          statusLabel = 'Lunas';
        } else if (status == 'pending') {
          statusBg = BkuTheme.amberSoft;
          statusText = BkuTheme.amber;
          statusBorder = BkuTheme.amberBorder;
          statusLabel = 'Verifikasi';
        } else if (status == 'ditolak') {
          statusBg = BkuTheme.statusDangerBg;
          statusText = BkuTheme.statusDangerText;
          statusBorder = BkuTheme.statusDangerBorder;
          statusLabel = 'Ditolak';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ormawaName, style: BkuTheme.textCaption.copyWith(fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BkuTheme.rPill,
                      border: Border.all(color: statusBorder),
                    ),
                    child: Text(
                      statusLabel,
                      style: BkuTheme.textBadge.copyWith(color: statusText, fontSize: 9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(judul, style: BkuTheme.textCardTitle.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nominal:', style: BkuTheme.textCaption),
                  Text(
                    'Rp ${_formatNominal(nominal)}',
                    style: BkuTheme.textKpiValue.copyWith(fontSize: 14, color: BkuTheme.rose),
                  ),
                ],
              ),
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tenggat:', style: BkuTheme.textCaption),
                    Text(formattedDate, style: BkuTheme.textCaption.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
              if (catatan.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Catatan: $catatan',
                  style: BkuTheme.textCaption.copyWith(color: BkuTheme.rose, fontStyle: FontStyle.italic),
                ),
              ],
              if (status == 'belum_bayar' || status == 'ditolak') ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: BkuButton(
                    onPressed: () => _showPaymentSheet(context, id, iuran),
                    text: 'Bayar Sekarang',
                    height: 38,
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BkuTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Detail Transfer Iuran', style: BkuTheme.textPageTitle.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: BkuTheme.scaffoldBg,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildIuranDetailRow('Bank Tujuan', bankName),
                    const Divider(height: 16),
                    _buildIuranDetailRow('Nomor Rekening', noRekening),
                    const Divider(height: 16),
                    _buildIuranDetailRow('Nama Pemilik', namaRekening),
                    const Divider(height: 16),
                    _buildIuranDetailRow('Nominal', 'Rp ${_formatNominal(nominal)}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: BkuButton(
                  onPressed: () async {
                    final provider = context.read<OrganizationProvider>();
                    final navigator = Navigator.of(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      BkuLoadingDialog.show(context);
                      final success = await provider.payIuran(invoiceId, image.path);
                      navigator.pop();

                      if (!context.mounted) return;
                      BkuDialog.show(
                        context: context,
                        type: success ? BkuDialogType.success : BkuDialogType.error,
                        title: success ? 'Sukses' : 'Gagal',
                        message: success
                            ? 'Bukti pembayaran berhasil diunggah! Menunggu konfirmasi bendahara.'
                            : 'Gagal mengunggah bukti pembayaran.',
                        primaryButtonText: 'OK',
                        onPrimaryPressed: () {
                          Navigator.pop(context);
                          if (success) {
                            provider.loadOrganizationData();
                          }
                        },
                      );
                    }
                  },
                  icon: Icons.upload_file_rounded,
                  text: 'Upload Bukti Pembayaran',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIuranDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: BkuTheme.textCaption),
        Text(value, style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5)),
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
    return BkuButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddOrganisasiScreen()),
        );
      },
      icon: Icons.add_circle_outline_rounded,
      text: 'Tambah Riwayat Organisasi',
      variant: BkuButtonVariant.outline,
      height: 46,
    );
  }

  void _showOrgDetail(BuildContext context, OrganizationHistory org) {
    final name = org.namaOrganisasi;
    final type = org.tipe;
    final role = org.jabatan;
    final period = org.periodeSelesai != null
        ? '${org.periodeMulai} - ${org.periodeSelesai}'
        : '${org.periodeMulai} - Sekarang';
    final achievements = org.achievements;
    final statusVerifikasi = org.statusVerifikasi;
    final description = org.deskripsiKegiatan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: BkuTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(name, style: BkuTheme.textPageTitle.copyWith(fontSize: 18)),
                  Text('$type • $role', style: BkuTheme.textCardSubtitle),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDetailRow('Periode', period),
                  _buildDetailRow('Status', statusVerifikasi),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Deskripsi Kontribusi', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(description, style: BkuTheme.textCaption),
                  ],
                  if (achievements.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Pencapaian', style: BkuTheme.textCardTitle.copyWith(fontSize: 13)),
                    const SizedBox(height: 4),
                    ...achievements.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: BkuTheme.emerald),
                          const SizedBox(width: 6),
                          Expanded(child: Text(a, style: BkuTheme.textCaption)),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed: () {
                            context.pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddOrganisasiScreen(organization: org),
                              ),
                            );
                          },
                          icon: Icons.edit_rounded,
                          text: 'Edit Riwayat',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BkuButton(
                          onPressed: () => _confirmDeleteOrg(context, org.id),
                          icon: Icons.delete_outline_rounded,
                          text: 'Hapus',
                          variant: BkuButtonVariant.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteOrg(BuildContext context, String id) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.warning,
      title: 'Hapus Riwayat Organisasi?',
      message: 'Apakah Anda yakin ingin menghapus data ini? Tindakan ini tidak dapat dibatalkan.',
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
      primaryButtonText: 'Ya, Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          BkuLoadingDialog.show(context);
          await context.read<OrganizationProvider>().deleteOrganizationHistory(id);
          if (context.mounted) {
            BkuLoadingDialog.hide(context);
            context.pop();
            AppSnackbar.showSuccess(context, 'Riwayat organisasi berhasil dihapus');
          }
        } catch (e) {
          if (context.mounted) {
            BkuLoadingDialog.hide(context);
            BkuDialog.show(
              context: context,
              type: BkuDialogType.error,
              title: 'Gagal',
              message: ErrorHandler.getMessage(e),
              primaryButtonText: 'Tutup',
              onPrimaryPressed: () => Navigator.pop(context),
            );
          }
        }
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: BkuTheme.textCaption),
          Text(value, style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _OrganizationBanner extends StatelessWidget {
  const _OrganizationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BkuTheme.indigoSoft,
                    borderRadius: BkuTheme.rPill,
                    border: Border.all(color: BkuTheme.indigoBorder),
                  ),
                  child: Text(
                    'Leadership Portfolio',
                    style: BkuTheme.textBadge.copyWith(
                      color: BkuTheme.indigo,
                      fontSize: 9.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Jejak Kontribusi & Kepemimpinan',
                  style: BkuTheme.textPageTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Catat setiap pengalaman organisasimu untuk masa depan.',
                  style: BkuTheme.textCardSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BkuTheme.indigoSoft,
              borderRadius: BkuTheme.r16,
              border: Border.all(color: BkuTheme.indigoBorder),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: BkuTheme.indigo,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}