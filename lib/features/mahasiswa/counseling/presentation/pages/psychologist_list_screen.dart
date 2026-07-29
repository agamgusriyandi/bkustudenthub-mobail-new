import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PsychologistListScreen extends StatefulWidget {
  final bool autoFocusSearch;
  const PsychologistListScreen({super.key, this.autoFocusSearch = false});

  @override
  State<PsychologistListScreen> createState() => _PsychologistListScreenState();
}

class _PsychologistListScreenState extends State<PsychologistListScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCounselingProvider>().loadPsychologists();
      if (widget.autoFocusSearch) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        final psychologists = provider.psychologists;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                title: 'Daftar Psikolog',
                subtitle: 'PROFESIONAL KAMPUS',
                variant: AppBarVariant.student,
                expandedHeight: 140,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    0,
                  ),
                  child: _buildSearchBar(provider),
                ),
              ),
              if (provider.psychologistsLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  ),
                )
              else if (provider.psychologistsError != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 56,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          provider.psychologistsError!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BkuButton(
                          onPressed: () => provider.loadPsychologists(),
                          text: 'Coba Lagi',
                        ),
                      ],
                    ),
                  ),
                )
              else if (psychologists.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 64,
                          color: AppColors.neutral300,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Tidak ada psikolog tersedia',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildPsychologistCard(context, psychologists[index]),
                      childCount: psychologists.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(StudentCounselingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _focusNode,
        onChanged: (v) => provider.loadPsychologists(search: v),
        decoration: InputDecoration(
          hintText: 'Cari psikolog...',
          hintStyle: AppTextStyles.labelMd.copyWith(
            color: AppColors.neutral500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.neutral600,
            size: 20,
          ),
          suffixIcon:
              _searchCtrl.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: AppColors.neutral500,
                    ),
                    onPressed: () {
                      _searchCtrl.clear();
                      provider.loadPsychologists();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLg,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildPsychologistCard(BuildContext context, Map<String, dynamic> p) {
    final name =
        p['Nama']?.toString() ??
        p['nama']?.toString() ??
        p['name']?.toString() ??
        '-';
    final spec =
        p['Spesialisasi']?.toString() ??
        p['spesialisasi']?.toString() ??
        p['specialization']?.toString() ??
        '-';
    final id =
        (p['id'] ?? p['ID'] ?? p['dosen_id'] ?? p['DosenID'])?.toString() ?? '';
    final isActive =
        p['IsAktif'] == true ||
        p['is_aktif'] == true ||
        p['is_active'] == true ||
        p['isAvailable'] == true;
    final location = p['location']?.toString() ?? '';
    final fee = p['fee'] as int? ?? 0;

    final initials =
        name.trim().isEmpty
            ? 'P'
            : name
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w[0].toUpperCase())
                .join();

    final rawPhoto = () {
      final possibleKeys = [
        'foto_url',
        'photo_url',
        'photoUrl',
        'FotoURL',
        'foto',
        'Foto',
        'avatar_url',
        'avatar',
      ];
      for (final key in possibleKeys) {
        if (p[key] != null && p[key].toString().trim().isNotEmpty) {
          return p[key].toString().trim();
        }
      }
      final user = p['user'] ?? p['User'] ?? p['Pengguna'] ?? p['pengguna'];
      if (user is Map) {
        for (final key in possibleKeys) {
          if (user[key] != null && user[key].toString().trim().isNotEmpty) {
            return user[key].toString().trim();
          }
        }
      }
      return '';
    }();
    final photoUrl = rawPhoto.isNotEmpty ? ApiGate.getImageUrl(rawPhoto) : '';

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: () {
                            if (!isActive) {
                              return [Colors.grey, Colors.grey.shade400];
                            }
                            final primaryColor = AppColors.neutral600;
                            final hslPrimary = HSLColor.fromColor(primaryColor);
                            return [
                              hslPrimary
                                  .withLightness(
                                    (hslPrimary.lightness + 0.08).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  )
                                  .toColor(),
                              hslPrimary
                                  .withLightness(
                                    (hslPrimary.lightness - 0.08).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  )
                                  .toColor(),
                            ];
                          }(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.radiusLg,
                        child:
                            photoUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: 
                                  photoUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, url, error) => Center(
                                       child: Text(
                                         initials,
                                         style: TextStyle(
                                           color: context.appColors.onPrimary,
                                           fontSize: 20,
                                           fontWeight: FontWeight.w900,
                                         ),
                                       ),
                                     ),
                                     placeholder: (context, url) => Container(color: AppColors.neutral200),
                                   )
                                   : Center(
                                     child: Text(
                                       initials,
                                       style: TextStyle(
                                         color: context.appColors.onPrimary,
                                         fontSize: 20,
                                         fontWeight: FontWeight.w900,
                                       ),
                                  ),
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.success : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        spec,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? AppColors.success.withAlpha(15)
                                      : Colors.grey.withAlpha(15),
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Text(
                              isActive ? 'Tersedia' : 'Tidak Tersedia',
                              style: TextStyle(
                                color:
                                    isActive ? AppColors.success : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (fee > 0) ...[
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              'Rp ${_formatFee(fee)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (location.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: AppSpacing.sm),
                BkuButton(
                  onPressed:
                      isActive ? () => _showTopicPicker(context, id, name) : null,
                  text: isActive ? 'Booking Sesi' : 'Tidak Tersedia',
                  variant:
                      isActive
                          ? BkuButtonVariant.success
                          : BkuButtonVariant.secondary,
                  height: 34,
                  fullWidth: false,
                  fontSize: 12,
                  icon: Icons.calendar_month_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicPicker(
    BuildContext context,
    String psikologId,
    String psikologName,
  ) {
    const topics = [
      ('Masalah Akademik', Icons.school_rounded),
      ('Kesehatan Mental & Stres', Icons.psychology_rounded),
      ('Masalah Keluarga/Pribadi', Icons.family_restroom_rounded),
      ('Karir & Masa Depan', Icons.work_rounded),
      ('Lainnya', Icons.more_horiz_rounded),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
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
                      color: Colors.grey.withAlpha(60),
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Konseling dengan $psikologName',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'Pilih topik yang ingin kamu diskusikan',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                ...topics.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '${AppRoutes.counselingBooking}?psikolog_id=$psikologId',
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          t.$2,
                          color: AppColors.neutral800,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        t.$1,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.neutral500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                        side: BorderSide(color: Colors.grey.withAlpha(30)),
                      ),
                      tileColor: context.appColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatFee(int fee) {
    if (fee >= 1000000) return '${(fee / 1000000).toStringAsFixed(0)}jt';
    if (fee >= 1000) return '${(fee / 1000).toStringAsFixed(0)}rb';
    return fee.toString();
  }
}