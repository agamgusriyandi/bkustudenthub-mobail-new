import 'package:bkuhub_mobile/core/theme/app_colors.dart';
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
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorAttendanceScreen extends StatefulWidget {
  const MentorAttendanceScreen({super.key});

  @override
  State<MentorAttendanceScreen> createState() => _MentorAttendanceScreenState();
}

class _MentorAttendanceScreenState extends State<MentorAttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sessionSearch = '';
  String _absenceSearch = '';
  String _absenceStatusFilter = 'all';

  final TextEditingController _sessionSearchController = TextEditingController();
  final TextEditingController _absenceSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchSessions();
        context.read<MentorKencanaProvider>().fetchAbsenceRequests();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sessionSearchController.dispose();
    _absenceSearchController.dispose();
    super.dispose();
  }

  void _showAttachmentDialog(BuildContext context, AbsenceRequestData req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Row(
          children: [
            Icon(Icons.description_rounded, color: context.appColors.primary),
            const SizedBox(width: 8),
            Text('Bukti Lampiran Izin', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mahasiswa: ${req.studentName} (${req.nim})', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Alasan: ${req.reason}', style: AppTextStyles.labelSm),
            const SizedBox(height: 12),
            Text('URL / Link File Lampiran:', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            req.attachmentUrl.isNotEmpty
                ? InkWell(
                    onTap: () async {
                      final urlStr = req.attachmentUrl;
                      final baseUrl = ApiGate.baseUrl.replaceAll('/api', '');
                      final finalUrl = urlStr.startsWith('http') ? urlStr : '$baseUrl$urlStr';
                      final uri = Uri.parse(finalUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      }
                    },
                    borderRadius: AppRadius.radiusMd,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withAlpha(15),
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: context.appColors.primary.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 16, color: context.appColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Buka File Lampiran',
                              style: AppTextStyles.labelMd.copyWith(color: context.appColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(15),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: context.appColors.primary.withAlpha(40)),
                    ),
                    child: Text(
                      'Tidak ada lampiran',
                      style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary),
                    ),
                  ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: TextStyle(color: context.appColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _respondAbsenceRequest(int requestId, String action) async {
    final provider = context.read<MentorKencanaProvider>();
    final success = await provider.respondAbsenceRequest(requestId, action);
    if (mounted) {
      if (success) {
        AppSnackbar.showSuccess(context, 'Berhasil memperbarui status izin');
      } else {
        AppSnackbar.showError(context, 'Gagal memperbarui status izin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final sessions = provider.sessions;
    final absenceRequests = provider.absenceRequests;

    final filteredSessions = sessions.where((s) {
      if (_sessionSearch.isNotEmpty) {
        return s.title.toLowerCase().contains(_sessionSearch.toLowerCase());
      }
      return true;
    }).toList();

    final filteredAbsences = absenceRequests.where((a) {
      if (_absenceSearch.isNotEmpty) {
        final q = _absenceSearch.toLowerCase();
        if (!a.studentName.toLowerCase().contains(q) && !a.sessionTitle.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_absenceStatusFilter != 'all') {
        if (a.status.toLowerCase() != _absenceStatusFilter.toLowerCase()) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            BkuAppBar(
              title: 'Validasi Kehadiran',
              info: 'Lihat dan validasi persentase kehadiran mahasiswa bimbingan Anda.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () {
                if (context.canPop()) {
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
                  unselectedLabelColor: context.appColors.onSurface.withValues(alpha: 0.7),
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
                    Tab(icon: Icon(Icons.event_available_rounded, size: 18), text: 'Daftar Sesi'),
                    Tab(icon: Icon(Icons.assignment_ind_rounded, size: 18), text: 'Permohonan Izin'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Daftar Sesi
          RefreshIndicator(
            onRefresh: () => provider.fetchSessions(),
            color: context.appColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manajemen Data', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Menampilkan daftar sesi yang terdaftar.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.appColors.primary.withAlpha(20),
                                borderRadius: AppRadius.radiusXl,
                              ),
                              child: Text(
                                'TOTAL DATA ${filteredSessions.length}',
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _sessionSearchController,
                          onChanged: (val) => setState(() => _sessionSearch = val),
                          decoration: InputDecoration(
                            hintText: 'Cari nama sesi...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading && sessions.isEmpty)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else if (filteredSessions.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text('Tidak ada sesi', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline))),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final session = filteredSessions[index];
                        return BkuCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(session.title, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(session.stageName, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(session.date, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline)),
                              ),
                              SizedBox(
                                height: 32,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.push('/mentor-kencana/attendance/session/${session.id}?title=${Uri.encodeComponent(session.title)}');
                                  },
                                  icon: const Icon(Icons.fact_check_outlined, size: 16),
                                  label: Text('Validasi Absensi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.appColors.primary,
                                    side: BorderSide(color: context.appColors.primary.withAlpha(50)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                                    backgroundColor: context.appColors.primary.withAlpha(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: filteredSessions.length),
                    ),
                  ),
              ],
            ),
          ),
          
          // TAB 2: Permohonan Izin
          RefreshIndicator(
            onRefresh: () => provider.fetchAbsenceRequests(),
            color: context.appColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manajemen Data', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Menampilkan daftar permohonan izin.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.appColors.primary.withAlpha(20),
                                borderRadius: AppRadius.radiusXl,
                              ),
                              child: Text(
                                'TOTAL DATA ${filteredAbsences.length}',
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _absenceSearchController,
                                onChanged: (val) => setState(() => _absenceSearch = val),
                                decoration: InputDecoration(
                                  hintText: 'Cari Mahasiswa...',
                                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _absenceStatusFilter,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                                ),
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900, fontSize: 11),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('Semua', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'Pending', child: Text('Menunggu', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'Approved', child: Text('Disetujui', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'Rejected', child: Text('Ditolak', overflow: TextOverflow.ellipsis)),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _absenceStatusFilter = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading && absenceRequests.isEmpty)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else if (filteredAbsences.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text('Tidak ada permohonan izin', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline))),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final req = filteredAbsences[index];
                        final statusLower = req.status.toLowerCase();
                        final isPending = statusLower == 'permission_requested' || statusLower == 'pending' || statusLower == 'menunggu';
                        final isApproved = statusLower == 'permission' || statusLower == 'approved' || statusLower == 'disetujui' || statusLower == 'present';

                        final statusColor = isPending
                            ? AppColors.warning
                            : (isApproved ? AppColors.success : AppColors.error);
                        
                        return BkuCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req.studentName, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                                        Text(req.nim, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(req.sessionTitle, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11)),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req.reason.isNotEmpty ? req.reason : '-', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11)),
                                        if (req.attachmentUrl.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          GestureDetector(
                                            onTap: () => _showAttachmentDialog(context, req),
                                            child: Row(
                                              children: [
                                                Icon(Icons.description_outlined, size: 12, color: context.appColors.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Lihat Bukti Lampiran',
                                                  style: AppTextStyles.labelSm.copyWith(
                                                    color: context.appColors.primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(req.date, style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
                                  
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(20),
                                          borderRadius: AppRadius.radiusSm,
                                          border: Border.all(color: statusColor.withAlpha(50)),
                                        ),
                                        child: Text(
                                          isPending
                                              ? 'MENUNGGU'
                                              : (isApproved ? 'DISETUJUI' : 'DITOLAK'),
                                          style: AppTextStyles.labelSm.copyWith(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      if (isPending) ...[
                                        SizedBox(
                                          height: 28,
                                          child: ElevatedButton(
                                            onPressed: () => _respondAbsenceRequest(req.id, 'Approved'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.success,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                            child: const Text('Setujui', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          height: 28,
                                          child: ElevatedButton(
                                            onPressed: () => _respondAbsenceRequest(req.id, 'Rejected'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: context.appColors.error,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                            child: const Text('Tolak', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                        ),
                                      ] else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: AppRadius.radiusMd,
                                            border: Border.all(color: context.appColors.outlineVariant),
                                          ),
                                          child: Text(
                                            'Selesai',
                                            style: AppTextStyles.labelSm.copyWith(
                                              color: context.appColors.outline,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }, childCount: filteredAbsences.length),
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
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
