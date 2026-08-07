import 'dart:async';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MentorGroupDetailScreen extends StatefulWidget {
  final int groupId;
  const MentorGroupDetailScreen({super.key, required this.groupId});

  @override
  State<MentorGroupDetailScreen> createState() =>
      _MentorGroupDetailScreenState();
}

class _MentorGroupDetailScreenState extends State<MentorGroupDetailScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorGroupDetail(
          widget.groupId,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQRModal(BuildContext context, String groupName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupQrModalContent(
        groupId: widget.groupId,
        groupName: groupName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final detail = provider.mentorGroupDetail;

    final filteredMembers = (detail?.members ?? []).where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return m.name.toLowerCase().contains(q) || m.nim.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorGroupDetail(widget.groupId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: detail?.name ?? 'Detail Kelompok',
              info: detail != null ? 'Kelola anggota mahasiswa kelompok Anda' : null,
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && detail == null)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null && detail == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: context.appColors.error,
                    ),
                  ),
                ),
              )
            else if (detail == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Detail grup tidak tersedia.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.xl,
                  bottom: 120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          // Header Stat Card
                          BkuCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: context.appColors.info.withAlpha(15),
                                        borderRadius: AppRadius.radiusLg,
                                      ),
                                      child: Icon(
                                        Icons.groups_rounded,
                                        color: context.appColors.info,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detail.name,
                                            style: AppTextStyles.titleLg.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Kelola anggota mahasiswa kelompok Anda.',
                                            style: AppTextStyles.labelSm.copyWith(
                                              color: context.appColors.outline,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: context.appColors.surface,
                                          borderRadius: AppRadius.radiusMd,
                                          border: Border.all(color: AppColors.neutral300),
                                        ),
                                        child: Column(
                                          children: [
                                            Text('${detail.members.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const Text('ANGGOTA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.neutral600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: context.appColors.surface,
                                          borderRadius: AppRadius.radiusMd,
                                          border: Border.all(color: AppColors.neutral300),
                                        ),
                                        child: Column(
                                          children: [
                                            Text('${detail.maxCapacity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const Text('KAPASITAS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.neutral600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Search & Action Buttons Bar
                          BkuCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  decoration: InputDecoration(
                                    hintText: 'Cari nama atau NIM...',
                                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                    border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showQRModal(context, detail.name),
                                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                                        label: const Text('Tampilkan QR Absen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.neutral200,
                                          foregroundColor: AppColors.neutral900,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => context.push('/mentor-kencana/attendance'),
                                        icon: const Icon(Icons.checklist_rounded, size: 16),
                                        label: const Text('Kelola Presensi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    final member = filteredMembers[index - 1];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      child: ListTile(
                        onTap: () {
                          context.push(
                            '/mentor-kencana/mentee/${member.id}',
                          );
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neutral300,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                member.avatarUrl != null &&
                                        member.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl: ApiGate.getImageUrl(
                                        member.avatarUrl!,
                                      ),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Center(
                                            child: Text(
                                              member.name.isNotEmpty
                                                  ? member.name
                                                      .substring(0, 1)
                                                      
                                                  : '',
                                              style: const TextStyle(
                                                color: AppColors.neutral700,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                    )
                                    : Center(
                                      child: Text(
                                        member.name.isNotEmpty
                                            ? member.name
                                                .substring(0, 1)
                                                
                                            : '',
                                        style: const TextStyle(
                                          color: AppColors.neutral700,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${member.nim} \u2022 ${member.faculty}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                member.status == 'Lulus' || member.status == 'active'
                                    ? context.appColors.success.withAlpha(15)
                                    : AppColors.neutral200,
                            border: Border.all(
                              color:
                                  member.status == 'Lulus' || member.status == 'active'
                                      ? context.appColors.success.withAlpha(30)
                                      : AppColors.neutral300,
                            ),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Text(
                            member.status,
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  member.status == 'Lulus' || member.status == 'active'
                                      ? context.appColors.success
                                      : AppColors.neutral700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredMembers.length + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupQrModalContent extends StatefulWidget {
  final int groupId;
  final String groupName;

  const _GroupQrModalContent({
    required this.groupId,
    required this.groupName,
  });

  @override
  State<_GroupQrModalContent> createState() => _GroupQrModalContentState();
}

class _GroupQrModalContentState extends State<_GroupQrModalContent> {
  int _selectedSessionId = 0;
  String? _qrToken;
  bool _isLoadingQr = false;
  int _secondsRemaining = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MentorKencanaProvider>();
      if (provider.sessions.isEmpty) {
        await provider.fetchSessions();
      }
      if (provider.sessionMaterials.isEmpty) {
        await provider.fetchSessionMaterialsList();
      }
      if (mounted) {
        final sessions = provider.sessions;
        if (sessions.isNotEmpty) {
          setState(() {
            _selectedSessionId = sessions.first.id;
          });
          _fetchTokenAndStartTimer(_selectedSessionId);
        } else if (provider.sessionMaterials.isNotEmpty) {
          setState(() {
            _selectedSessionId = provider.sessionMaterials.first.id;
          });
          _fetchTokenAndStartTimer(_selectedSessionId);
        }
      }
    });
  }

  void _fetchTokenAndStartTimer(int sessionId) async {
    if (sessionId == 0) return;
    setState(() {
      _isLoadingQr = true;
      _secondsRemaining = 45;
    });

    _countdownTimer?.cancel();

    final provider = context.read<MentorKencanaProvider>();
    final token = await provider.fetchSessionQrToken(sessionId);

    if (mounted) {
      setState(() {
        _qrToken = token ?? 'KENCANA-PRESENSI-SESSION-$sessionId';
        _isLoadingQr = false;
      });

      _startTimer(sessionId);
    }
  }

  void _startTimer(int sessionId) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _fetchTokenAndStartTimer(sessionId);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    final List<Map<String, dynamic>> sessionOptions = [];
    for (final s in provider.sessions) {
      if (!sessionOptions.any((e) => e['id'] == s.id)) {
        sessionOptions.add({'id': s.id, 'title': s.title});
      }
    }
    for (final m in provider.sessionMaterials) {
      if (!sessionOptions.any((e) => e['id'] == m.id)) {
        sessionOptions.add({'id': m.id, 'title': m.title});
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QR Code Presensi', style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Scan oleh Mahasiswa Bimbingan', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11)),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 20, color: context.appColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Pilih Sesi Kencana', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            initialValue: _selectedSessionId,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
            ),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.w600),
            isExpanded: true,
            items: [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text('-- Pilih Sesi --', style: TextStyle(color: AppColors.neutral500)),
              ),
              ...sessionOptions.map(
                (s) => DropdownMenuItem<int>(
                  value: s['id'] as int,
                  child: Text(s['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null && val != _selectedSessionId) {
                setState(() {
                  _selectedSessionId = val;
                });
                _fetchTokenAndStartTimer(val);
              }
            },
          ),
          const SizedBox(height: 20),

          if (_selectedSessionId == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 48, color: context.appColors.outline),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih sesi Kencana terlebih dahulu untuk menampilkan QR Code Presensi',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.neutral300),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: _isLoadingQr
                        ? const SizedBox(
                            width: 180,
                            height: 180,
                            child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
                          )
                        : (_qrToken != null && _qrToken!.isNotEmpty
                            ? QrImageView(
                                data: _qrToken!,
                                version: QrVersions.auto,
                                size: 180.0,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.neutral900,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.neutral900,
                                ),
                              )
                            : const Text('Gagal memuat QR Code')),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Berlaku selama $_secondsRemaining detik (Auto-refresh)',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
