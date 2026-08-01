import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/unified_bottom_nav_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_insurance_claim_model.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkInsuranceClaimsScreen extends StatefulWidget {
  const TkInsuranceClaimsScreen({super.key});

  @override
  State<TkInsuranceClaimsScreen> createState() =>
      _TkInsuranceClaimsScreenState();
}

class _TkInsuranceClaimsScreenState extends State<TkInsuranceClaimsScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkHealthProvider>().fetchInsuranceClaims();
      final tkPatientProv = context.read<TkPatientProvider>();
      if (tkPatientProv.patients.isEmpty) {
        tkPatientProv.loadPatients();
      }
    });
  }

  Map<String, String> _getStudentData(TkInsuranceClaimModel claim) {
    final patientProv = context.read<TkPatientProvider>();
    Patient? p;
    if (claim.mahasiswaId > 0) {
      for (final item in patientProv.patients) {
        if (item.id == claim.mahasiswaId) {
          p = item;
          break;
        }
      }
    }
    if (p == null &&
        claim.mahasiswaNim.isNotEmpty &&
        claim.mahasiswaNim != '-') {
      for (final item in patientProv.patients) {
        if (item.nim.trim() == claim.mahasiswaNim.trim()) {
          p = item;
          break;
        }
      }
    }

    final nama = p?.nama ??
        (claim.mahasiswaName.isNotEmpty && claim.mahasiswaName != '-'
            ? claim.mahasiswaName
            : 'Mahasiswa');
    final nim = p?.nim ?? claim.mahasiswaNim;
    final prodi = p?.prodi ?? claim.mahasiswaProdi;
    final foto = p?.fotoURL ?? claim.mahasiswaFoto ?? '';

    return {
      'nama': nama,
      'nim': nim,
      'prodi': prodi,
      'foto': foto,
    };
  }

  Widget _buildTopPagination(int totalPages) {
    final bool canPrev = _currentPage > 1;
    final bool canNext = _currentPage < totalPages;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: canPrev ? AppColors.neutral200 : AppColors.neutral100,
            borderRadius: AppRadius.br10,
            child: InkWell(
              borderRadius: AppRadius.br10,
              onTap: canPrev ? () => setState(() => _currentPage--) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                        color:
                            canPrev
                                ? context.appColors.secondary
                                : AppColors.neutral300,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              canPrev
                                  ? context.appColors.secondary
                                  : AppColors.neutral300,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.appColors.secondary,
            ),
          ),
          Material(
            color: canNext ? AppColors.neutral200 : AppColors.neutral100,
            borderRadius: AppRadius.br10,
            child: InkWell(
              borderRadius: AppRadius.br10,
              onTap: canNext ? () => setState(() => _currentPage++) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            canNext
                                ? AppColors.neutral800
                                : AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color:
                          canNext
                              ? AppColors.neutral800
                              : AppColors.neutral400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Klaim Asuransi',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      bottomNavigationBar: UnifiedBottomNavBar.tenagaKesehatan(
        currentIndex: 0,
        onTap: (index) => context.go('/tenagakes?tab=$index'),
      ),
      body: Consumer<TkHealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.claims.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: BkuShimmerList(itemCount: 4, itemHeight: 140),
            );
          }

          if (provider.claims.isEmpty) {
            return _buildEmptyState();
          }

          final claims = provider.claims;
          final totalPages = (claims.length / _itemsPerPage).ceil();
          final safeTotalPages = totalPages > 0 ? totalPages : 1;
          final safePage = _currentPage.clamp(1, safeTotalPages);
          if (safePage != _currentPage) {
            _currentPage = safePage;
          }

          final startIndex = (safePage - 1) * _itemsPerPage;
          final endIndex =
              (startIndex + _itemsPerPage).clamp(0, claims.length);
          final paginatedClaims =
              claims.isEmpty
                  ? <TkInsuranceClaimModel>[]
                  : claims.sublist(startIndex, endIndex);

          return RefreshIndicator(
            onRefresh: () => provider.fetchInsuranceClaims(),
            child: Column(
              children: [
                _buildTopPagination(safeTotalPages),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.s80,
                    ),
                    itemCount: paginatedClaims.length,
                    itemBuilder: (context, index) {
                      final claim = paginatedClaims[index];
                      return _buildClaimCard(context, provider, claim);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_late_rounded,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada klaim asuransi',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(
    BuildContext context,
    TkHealthProvider provider,
    TkInsuranceClaimModel claim,
  ) {
    final student = _getStudentData(claim);
    final nama = student['nama']!;
    final nim = student['nim']!;
    final prodi = student['prodi']!;
    final foto = student['foto']!;
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'M';
    final bool hasFoto =
        foto.trim().isNotEmpty && foto.trim().toLowerCase() != 'null';

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateStr = DateFormat(
      'dd MMMM yyyy',
      'id',
    ).format(claim.tanggalKejadian);
    final formattedCost = formatCurrency.format(claim.estimasiBiaya);

    return BkuCard(
      onTap: () => _showReviewDialog(context, provider, claim),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withAlpha(50),
                    width: 1.5,
                  ),
                  image:
                      hasFoto
                          ? DecorationImage(
                            image: NetworkImage(ApiGate.getImageUrl(foto)),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    !hasFoto
                        ? Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                      nama,
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '$nim â€¢ $prodi',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildStatusBadge(claim.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCardInfoRow(
            Icons.local_hospital_rounded,
            'Provider: ${claim.jenisProvider}',
          ),
          _buildCardInfoRow(
            Icons.calendar_today_rounded,
            'Kejadian: $dateStr',
          ),
          _buildCardInfoRow(
            Icons.location_on_rounded,
            'Faskes: ${claim.lokasiFaskes}',
          ),
          _buildCardInfoRow(
            Icons.payments_rounded,
            'Estimasi Biaya: $formattedCost',
          ),
          _buildCardInfoRow(
            Icons.description_rounded,
            'Kronologi: ${claim.deskripsi}',
          ),
          if (claim.catatanReview != null &&
              claim.catatanReview!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                'Catatan Peninjau: ${claim.catatanReview}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (claim.namaFile != null && claim.namaFile!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.attachment_rounded,
                    size: 14,
                    color: context.watch<ThemeProvider>().colors.success,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Expanded(
                    child: Text(
                      'Lampiran: ${claim.namaFile}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.watch<ThemeProvider>().colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.appColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String label;

    switch (status) {
      case 'PENDING_VERIFICATION':
        statusColor = context.watch<ThemeProvider>().colors.warning;
        label = 'Menunggu';
        break;
      case 'APPROVED_TK':
      case 'APPROVED_FINAL':
        statusColor = context.watch<ThemeProvider>().colors.success;
        label = 'Disetujui';
        break;
      case 'REJECTED':
        statusColor = context.appColors.error;
        label = 'Ditolak';
        break;
      default:
        statusColor = AppColors.neutral500;
        label = status.replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w900,
          fontSize: 9,
        ),
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    TkHealthProvider provider,
    TkInsuranceClaimModel claim,
  ) {
    final noteController = TextEditingController(
      text: claim.catatanReview ?? '',
    );

    final student = _getStudentData(claim);
    final nama = student['nama']!;
    final nim = student['nim']!;
    final prodi = student['prodi']!;
    final foto = student['foto']!;
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'M';
    final bool hasFoto =
        foto.trim().isNotEmpty && foto.trim().toLowerCase() != 'null';

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateStr = DateFormat(
      'dd MMMM yyyy',
      'id',
    ).format(claim.tanggalKejadian);
    final formattedCost = formatCurrency.format(claim.estimasiBiaya);

    final token = AuthService().token;
    final base =
        ApiGate.baseUrl.endsWith('/api')
            ? ApiGate.baseUrl.substring(0, ApiGate.baseUrl.length - 4)
            : ApiGate.baseUrl;

    String? imageUrl;
    if (claim.fileUrl != null && claim.fileUrl!.isNotEmpty) {
      String path = claim.fileUrl!;
      if (!path.startsWith('http')) {
        path = '$base$path';
      }
      if (path.contains('?')) {
        path += '&token=$token';
      } else {
        path += '?token=$token';
      }
      imageUrl = path;
    }

    String? imageUrl2;
    if (claim.fileUrl2 != null && claim.fileUrl2!.isNotEmpty) {
      String path = claim.fileUrl2!;
      if (!path.startsWith('http')) {
        path = '$base$path';
      }
      if (path.contains('?')) {
        path += '&token=$token';
      } else {
        path += '?token=$token';
      }
      imageUrl2 = path;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Detail Review Klaim',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.appColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    children: [
                      // Mahasiswa Info Banner
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.appColors.success.withAlpha(15),
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(
                            color: context.appColors.success.withAlpha(50),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: context.appColors.success.withAlpha(20),
                                shape: BoxShape.circle,
                                image:
                                    hasFoto
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            ApiGate.getImageUrl(foto),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  !hasFoto
                                      ? Center(
                                        child: Text(
                                          initial,
                                          style: TextStyle(
                                            color: context.appColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
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
                                    nama,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w900,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        '$nim â€¢ $prodi',
                        style: AppTextStyles.caption.copyWith(
                          color: context.appColors.secondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _buildStatusBadge(claim.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Information Grid/List
                      Text(
                        'Rincian Pengajuan',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(color: AppColors.neutral300.withAlpha(30)),
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.onSurface.withAlpha(4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildModalDetailRow(
                              Icons.local_hospital_rounded,
                              'Provider',
                              claim.jenisProvider,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildModalDetailRow(
                              Icons.location_on_rounded,
                              'Lokasi Faskes',
                              claim.lokasiFaskes,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildModalDetailRow(
                              Icons.calendar_today_rounded,
                              'Tanggal Kejadian',
                              dateStr,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildModalDetailRow(
                              Icons.payments_rounded,
                              'Estimasi Biaya',
                              formattedCost,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      Text(
                        'Kronologi / Deskripsi',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusXl,
                          border: Border.all(color: AppColors.neutral300.withAlpha(30)),
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.onSurface.withAlpha(4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          claim.deskripsi.isEmpty ? '-' : claim.deskripsi,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral800,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Direct image display
                      if (imageUrl != null) ...[
                        Text(
                          'Gambar Lampiran 1',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(imageUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.inAppBrowserView,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: AppRadius.radiusLg,
                            child: CachedNetworkImage(imageUrl: 
                              imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder: (
                                context,
                                url,
                                loadingProgress,
                              ) {
                                return const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 100,
                                  color: AppColors.neutral100,
                                  child: const Center(
                                    child: Text(
                                      'Gagal memuat gambar lampiran',
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (imageUrl2 != null) ...[
                        Text(
                          'Gambar Lampiran 2',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(imageUrl2!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.inAppBrowserView,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: AppRadius.radiusLg,
                            child: CachedNetworkImage(imageUrl: 
                              imageUrl2,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder: (
                                context,
                                url,
                                loadingProgress,
                              ) {
                                return const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 100,
                                  color: AppColors.neutral100,
                                  child: const Center(
                                    child: Text(
                                      'Gagal memuat gambar lampiran 2',
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (claim.suratPengantarUrl != null &&
                          claim.suratPengantarUrl!.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              String path = claim.suratPengantarUrl!;
                              if (!path.startsWith('http')) {
                                path = '$base$path';
                              }
                              path += '?token=$token';
                              final uri = Uri.parse(path);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const Icon(Icons.file_present_rounded),
                            label: const Text('Buka Surat Pengantar (PDF/Doc)'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      Text(
                        'Catatan Peninjauan',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        style: TextStyle(
                          color: AppColors.neutral800,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Tuliskan alasan jika menolak, atau catatan persetujuan...',
                          hintStyle: TextStyle(color: AppColors.neutral400),
                          filled: true,
                          fillColor: AppColors.neutral50,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.radiusMd,
                            borderSide: const BorderSide(
                              color: AppColors.neutral300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (claim.status == 'PENDING_VERIFICATION') ...[
                        Row(
                          children: [
                            Expanded(
                              child: BkuButton(
                                variant: BkuButtonVariant.danger,
                                onPressed: () async {
                                  if (noteController.text.trim().isEmpty) {
                                    AppSnackbar.showError(
                                      context,
                                      'Mohon isi catatan penolakan',
                                    );
                                    return;
                                  }
                                  final success = await provider.updateClaimStatus(
                                    claim.id,
                                    'REJECTED',
                                    catatanReview: noteController.text,
                                  );
                                  if (success && context.mounted) {
                                    context.pop();
                                    AppSnackbar.showSuccess(
                                      context,
                                      'Klaim ditolak',
                                    );
                                  }
                                },
                                text: 'Tolak',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: BkuButton(
                                variant: BkuButtonVariant.success,
                                onPressed: () async {
                                  final success = await provider.updateClaimStatus(
                                    claim.id,
                                    'APPROVED_TK',
                                    catatanReview: noteController.text,
                                  );
                                  if (success && context.mounted) {
                                    context.pop();
                                    AppSnackbar.showSuccess(
                                      context,
                                      'Klaim disetujui',
                                    );
                                  }
                                },
                                text: 'Setujui',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.neutral700),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              value,
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w800,
                color: context.appColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
