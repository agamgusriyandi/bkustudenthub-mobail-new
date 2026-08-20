import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';

class KencanaInvitationsScreen extends StatefulWidget {
  const KencanaInvitationsScreen({super.key});

  @override
  State<KencanaInvitationsScreen> createState() =>
      _KencanaInvitationsScreenState();
}

class _KencanaInvitationsScreenState extends State<KencanaInvitationsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final provider = context.read<KencanaProvider>();
      final result = await provider.fetchInvitations();
      if (mounted) {
        setState(() {
          data = result;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          data = {};
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _respond(String type, dynamic id, String action) async {
    final intId = id is int ? id : (int.tryParse(id.toString()) ?? 0);
    if (intId == 0) return;
    setState(() => isProcessing = true);
    try {
      final provider = context.read<KencanaProvider>();
      await provider.respondInvitation(type, intId, action);
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          action == 'accept' ? 'Undangan berhasil diterima' : 'Undangan ditolak',
        );
      }
    } catch (_) {
    } finally {
      await _loadData();
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorInvites = (data?['invitations'] is List)
        ? (data!['invitations'] as List)
        : [];
    final groupInvites = (data?['group_invitations'] is List)
        ? (data!['group_invitations'] as List)
        : [];

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Undangan Fasilitator & Kelompok',
        subtitle: 'Program Kencana',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: BkuTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: BkuTheme.rPill,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: BkuTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        BkuTheme.primary,
                      ),
                    ),
                  ),
                ),
              FadeInAnimation(
                delay: 0.05,
                child: _buildBannerInfo(),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeInAnimation(
                delay: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fasilitator Aktif',
                      style: BkuTheme.textSectionTitle.copyWith(
                        fontSize: 14,
                        color: BkuTheme.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dosen atau pembimbing yang mendampingi kelompok kamu saat ini.',
                      style: BkuTheme.textCardSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildActiveMentorCard(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FadeInAnimation(
                delay: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Undangan Fasilitator',
                          style: BkuTheme.textSectionTitle.copyWith(
                            fontSize: 14,
                            color: BkuTheme.textHeading,
                          ),
                        ),
                        if (mentorInvites.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: BkuTheme.indigoSoft,
                              borderRadius: BkuTheme.rPill,
                              border: Border.all(color: BkuTheme.indigoBorder),
                            ),
                            child: Text(
                              '${mentorInvites.length} Undangan',
                              style: BkuTheme.textBadge.copyWith(
                                color: BkuTheme.indigo,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Permintaan pembimbingan dari dosen fasilitator Kencana.',
                      style: BkuTheme.textCardSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInvitationsList(mentorInvites, 'mentor'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FadeInAnimation(
                delay: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Undangan Kelompok',
                          style: BkuTheme.textSectionTitle.copyWith(
                            fontSize: 14,
                            color: BkuTheme.textHeading,
                          ),
                        ),
                        if (groupInvites.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: BkuTheme.primarySoft,
                              borderRadius: BkuTheme.rPill,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Text(
                              '${groupInvites.length} Undangan',
                              style: BkuTheme.textBadge.copyWith(
                                color: BkuTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Undangan untuk bergabung ke dalam kelompok mahasiswa Kencana.',
                      style: BkuTheme.textCardSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInvitationsList(groupInvites, 'group'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Icon(
              Icons.mark_email_unread_rounded,
              color: BkuTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Undangan',
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Terima undangan untuk menetapkan fasilitator dan kelompok Kencana kamu.',
                  style: BkuTheme.textCaption.copyWith(
                    color: BkuTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleActiveMentorCard(Map mentor) {
    final avatarUrl = mentor['avatar_url']?.toString();
    final name = mentor['name'] ?? mentor['nama'] ?? 'Fasilitator';
    final email = mentor['email']?.toString();
    final phone = mentor['phone']?.toString();

    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: BkuTheme.emeraldSoft,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(color: BkuTheme.emeraldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: BkuTheme.emerald,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fasilitator Aktif',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.emerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BkuTheme.indigoSoft,
                  border: Border.all(color: BkuTheme.indigoBorder),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ApiGate.getImageUrl(avatarUrl),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 26,
                            color: BkuTheme.indigo,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 26,
                          color: BkuTheme.indigo,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString(),
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 14),
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 13,
                            color: BkuTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: BkuTheme.textCaption.copyWith(
                                color: BkuTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_android_rounded,
                            size: 13,
                            color: BkuTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              phone,
                              style: BkuTheme.textCaption.copyWith(
                                color: BkuTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMentorCard() {
    final mentors = data?['active_mentors'];
    final mentor = data?['active_mentor'];

    if (mentors != null && mentors is List && mentors.isNotEmpty) {
      return Column(
        children: List.generate(mentors.length, (index) {
          final m = mentors[index];
          if (m == null || m is! Map) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == mentors.length - 1 ? 0 : AppSpacing.md,
            ),
            child: _buildSingleActiveMentorCard(m),
          );
        }),
      );
    }

    if (mentor != null && mentor is Map) {
      return _buildSingleActiveMentorCard(mentor);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BkuTheme.amberSoft,
              borderRadius: BkuTheme.r10,
              border: Border.all(color: BkuTheme.amberBorder),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: BkuTheme.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Memiliki Fasilitator Aktif',
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fasilitator akan tampil di sini setelah kamu menerima undangan pembimbingan.',
                  style: BkuTheme.textCaption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(List<dynamic> items, String type) {
    final isMentor = type == 'mentor';

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          borderRadius: BkuTheme.r16,
          border: Border.all(color: BkuTheme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isMentor ? BkuTheme.indigoSoft : BkuTheme.primarySoft,
                borderRadius: BkuTheme.r16,
                border: Border.all(
                  color: isMentor ? BkuTheme.indigoBorder : BkuTheme.border,
                ),
              ),
              child: Icon(
                isMentor ? Icons.how_to_reg_outlined : Icons.groups_outlined,
                size: 26,
                color: isMentor ? BkuTheme.indigo : BkuTheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isMentor
                  ? 'Belum Ada Undangan Fasilitator'
                  : 'Belum Ada Undangan Kelompok',
              textAlign: TextAlign.center,
              style: BkuTheme.textCardTitle.copyWith(
                fontSize: 13,
                color: BkuTheme.textHeading,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isMentor
                  ? 'Undangan dari dosen/pembimbing akan muncul di sini.'
                  : 'Undangan untuk bergabung kelompok Kencana akan muncul di sini.',
              textAlign: TextAlign.center,
              style: BkuTheme.textCaption.copyWith(fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        if (item == null || item is! Map) return const SizedBox.shrink();
        final rawStatus = item['status'] ?? item['Status'] ?? 'pending';
        final status = rawStatus.toString().toLowerCase();
        final isPending = status == 'pending';

        String title = 'Undangan Kencana';
        String subtitle = '';

        if (isMentor) {
          final mData = (item['mentor'] is Map ? item['mentor'] : null) ??
              (item['Mentor'] is Map ? item['Mentor'] : null) ??
              {};
          final name = mData['name'] ?? mData['Name'] ?? 'Fasilitator';
          final fakultas = (mData['fakultas'] is Map ? mData['fakultas'] : null) ??
              (mData['Fakultas'] is Map ? mData['Fakultas'] : null);
          final fakName =
              fakultas?['name'] ?? fakultas?['Name'] ?? 'Universitas';
          title = 'Undangan Fasilitator: $name';
          subtitle = 'Fasilitator dari $fakName';
        } else {
          final group = (item['group'] is Map ? item['group'] : null) ??
              (item['Group'] is Map ? item['Group'] : null) ??
              {};
          final groupName = group['name'] ??
              group['Name'] ??
              item['group_name'] ??
              item['name'] ??
              'Kelompok Kencana';
          final code =
              group['code'] ?? group['Code'] ?? item['group_code'] ?? item['code'] ?? '';
          var mentorName = '';
          final mentorsList = group['mentors'] ?? group['Mentors'] ?? item['mentors'];
          if (mentorsList != null &&
              mentorsList is List &&
              mentorsList.isNotEmpty) {
            mentorName = mentorsList
                .map((m) => (m is Map) ? (m['name'] ?? m['Name'] ?? '') : '')
                .where((s) => s.toString().isNotEmpty)
                .join(', ');
          } else {
            final mentorObj = (group['mentor'] is Map ? group['mentor'] : null) ??
                (group['Mentor'] is Map ? group['Mentor'] : null) ??
                (item['mentor'] is Map ? item['mentor'] : null);
            mentorName = mentorObj?['name'] ?? mentorObj?['Name'] ?? '';
          }

          title = groupName.toString();
          subtitle =
              'Kode: ${code.toString().isNotEmpty ? code : '-'} ${mentorName.isNotEmpty ? '• Fasilitator: $mentorName' : ''}';
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isMentor ? BkuTheme.indigoSoft : BkuTheme.primarySoft,
                      borderRadius: BkuTheme.r12,
                      border: Border.all(
                        color: isMentor ? BkuTheme.indigoBorder : BkuTheme.border,
                      ),
                    ),
                    child: Icon(
                      isMentor
                          ? Icons.person_add_rounded
                          : Icons.diversity_3_rounded,
                      color: isMentor ? BkuTheme.indigo : BkuTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: BkuTheme.textCardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: BkuTheme.textCaption.copyWith(
                            color: BkuTheme.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isProcessing
                            ? null
                            : () => _respond(type, item['id'], 'reject'),
                        borderRadius: BkuTheme.r8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: BkuTheme.roseSoft,
                            borderRadius: BkuTheme.r8,
                            border: Border.all(color: BkuTheme.roseBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: BkuTheme.rose,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tolak',
                                style: BkuTheme.textCaption.copyWith(
                                  color: BkuTheme.rose,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isProcessing
                            ? null
                            : () => _respond(type, item['id'], 'accept'),
                        borderRadius: BkuTheme.r8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isProcessing ? BkuTheme.textMuted : BkuTheme.primary,
                            borderRadius: BkuTheme.r8,
                            boxShadow: isProcessing ? null : BkuTheme.cardShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Terima',
                                style: BkuTheme.textCaption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: (status == 'active' || status == 'accepted')
                        ? BkuTheme.emeraldSoft
                        : BkuTheme.roseSoft,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(
                      color: (status == 'active' || status == 'accepted')
                          ? BkuTheme.emeraldBorder
                          : BkuTheme.roseBorder,
                    ),
                  ),
                  child: Text(
                    (status == 'active' || status == 'accepted')
                        ? 'DITERIMA'
                        : 'DITOLAK',
                    textAlign: TextAlign.center,
                    style: BkuTheme.textBadge.copyWith(
                      color: (status == 'active' || status == 'accepted')
                          ? BkuTheme.emerald
                          : BkuTheme.rose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
