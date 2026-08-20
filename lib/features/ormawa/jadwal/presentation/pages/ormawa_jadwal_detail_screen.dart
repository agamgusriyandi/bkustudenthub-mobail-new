import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_agenda_model.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/jadwal/presentation/pages/edit_kegiatan_screen.dart';

class OrmawaJadwalDetailScreen extends StatelessWidget {
  final dynamic kegiatan;

  const OrmawaJadwalDetailScreen({super.key, required this.kegiatan});

  String _formatRp(dynamic val) {
    if (val == null) return '—';
    final double? numVal = val is num ? val.toDouble() : double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
    if (numVal == null || numVal == 0.0) return '—';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(numVal);
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    if (date is DateTime) return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
    try {
      final parsed = DateTime.parse(date.toString());
      return DateFormat('EEEE, dd MMMM yyyy', 'id').format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    BkuDialog.show(
      context: context,
      title: 'Batalkan Kegiatan?',
      message: 'Apakah Anda yakin ingin membatalkan/menghapus jadwal kegiatan "$title"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteAgenda(id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Kegiatan berhasil dihapus');
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus kegiatan: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final String initialId = (kegiatan is OrmawaAgenda ? (kegiatan as OrmawaAgenda).id : (kegiatan['ID'] ?? kegiatan['id'] ?? '')).toString();
    final k = provider.agendas.cast<OrmawaAgenda>().firstWhere(
      (a) => a.id.toString() == initialId,
      orElse: () => kegiatan is OrmawaAgenda ? (kegiatan as OrmawaAgenda) : OrmawaAgendaModel.fromJson(kegiatan as Map<String, dynamic>),
    );
    final String eventId = k.id;
    final String title = k.title;
    final String desc = k.description;
    final String status = k.status.toLowerCase();
    final String loc = k.location.isNotEmpty ? k.location : 'Lokasi belum ditentukan';
    final String category = k.bentukKegiatan ?? 'Kegiatan Ormawa';
    final String pj = k.pjKegiatan ?? '—';
    final String mitra = k.mitra ?? '';
    final String sasaran = k.sasaranKegiatan ?? '';
    final String sumberDana = k.sumberDana ?? '';
    final double? estimasiDana = k.estimasiDana;
    final String landasan = k.landasanKegiatan ?? '';
    final String latarBelakang = k.latarBelakang ?? '';
    final String tujuan = k.tujuanKegiatan ?? '';
    final String indikator = k.indikatorKeberhasilan ?? '';
    final bool isProposal = k.id.startsWith('prop-');

    final DateTime startDate = k.date;
    final DateTime endDate = k.endDate;

    final String dateDisplay = (startDate.day != endDate.day || startDate.month != endDate.month || startDate.year != endDate.year)
        ? '${DateFormat('dd MMM yyyy', 'id').format(startDate)} s/d ${DateFormat('dd MMM yyyy', 'id').format(endDate)}'
        : _formatDate(startDate);

    final String timeDisplay = '${DateFormat('HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)} WIB';

    OrmawaBadgeVariant badgeVariant = OrmawaBadgeVariant.info;
    if (status == 'selesai' || status == 'terlaksana' || status == 'completed') {
      badgeVariant = OrmawaBadgeVariant.success;
    } else if (status == 'berlangsung' || status == 'ongoing') {
      badgeVariant = OrmawaBadgeVariant.warning;
    } else if (status == 'dibatalkan' || status == 'batal' || status == 'cancelled') {
      badgeVariant = OrmawaBadgeVariant.danger;
    }

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: title,
            subtitle: 'Rincian Informasi Agenda Kegiatan',
            expandedHeight: 140.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.event_available_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: OrmawaTheme.textCardTitle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      OrmawaBadge(
                                        text: isProposal ? 'PROPOSAL KEGIATAN' : 'KEGIATAN MANDIRI',
                                        variant: isProposal ? OrmawaBadgeVariant.primary : OrmawaBadgeVariant.info,
                                      ),
                                      OrmawaBadge(
                                        text: status.toUpperCase(),
                                        variant: badgeVariant,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (category.isNotEmpty && category != 'Kegiatan Ormawa') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category_rounded, size: 14, color: Color(0xFF7C3AED)),
                                const SizedBox(width: 6),
                                Text(
                                  'Kategori: $category',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.access_time_rounded, color: Color(0xFF059669), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Waktu & Lokasi Pelaksanaan', style: OrmawaTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF059669),
                          label: 'Tanggal Pelaksanaan',
                          value: dateDisplay,
                        ),
                        if (timeDisplay.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFF059669),
                            label: 'Waktu Pelaksanaan',
                            value: timeDisplay,
                          ),
                        ],
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFFE11D48),
                          label: 'Lokasi / Venue',
                          value: loc,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.people_alt_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Penanggung Jawab & Struktur', style: OrmawaTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          label: 'Penanggung Jawab (PJ)',
                          value: pj.isNotEmpty ? pj : '—',
                        ),
                        if (mitra.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.handshake_rounded,
                            iconColor: const Color(0xFF0D9488),
                            label: 'Mitra Kerja Sama',
                            value: mitra,
                          ),
                        ],
                        if (sasaran.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFF0284C7),
                            label: 'Sasaran Peserta',
                            value: sasaran,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (sumberDana.isNotEmpty || (estimasiDana != null && estimasiDana != 0)) ...[
                    OrmawaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFD97706), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Anggaran & Pembiayaan', style: OrmawaTheme.textSectionTitle),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (estimasiDana != null && estimasiDana != 0)
                            _buildDetailRow(
                              icon: Icons.payments_rounded,
                              iconColor: const Color(0xFF059669),
                              label: 'Estimasi Anggaran',
                              value: _formatRp(estimasiDana),
                            ),
                          if (sumberDana.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              icon: Icons.savings_rounded,
                              iconColor: const Color(0xFFD97706),
                              label: 'Sumber Dana',
                              value: sumberDana,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (desc.isNotEmpty || tujuan.isNotEmpty || latarBelakang.isNotEmpty || indikator.isNotEmpty) ...[
                    OrmawaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Rincian & Landasan Strategis', style: OrmawaTheme.textSectionTitle),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (desc.isNotEmpty) ...[
                            _buildSectionBlock('Deskripsi Lengkap', desc),
                            const SizedBox(height: 12),
                          ],
                          if (tujuan.isNotEmpty) ...[
                            _buildSectionBlock('Tujuan Kegiatan', tujuan),
                            const SizedBox(height: 12),
                          ],
                          if (latarBelakang.isNotEmpty) ...[
                            _buildSectionBlock('Latar Belakang', latarBelakang),
                            const SizedBox(height: 12),
                          ],
                          if (landasan.isNotEmpty) ...[
                            _buildSectionBlock('Landasan Kegiatan', landasan),
                            const SizedBox(height: 12),
                          ],
                          if (indikator.isNotEmpty)
                            _buildSectionBlock('Indikator Keberhasilan', indikator),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: BkuBounceButton(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditKegiatanScreen(kegiatan: k),
                              ),
                            );
                            if (context.mounted) {
                              context.read<OrmawaProvider>().refreshData();
                            }
                          },
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: OrmawaTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Edit Kegiatan',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkuBounceButton(
                          onTap: () => _confirmDelete(context, eventId, title),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECDD3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                                SizedBox(width: 6),
                                Text(
                                  'Batalkan',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFE11D48)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: BkuBounceButton(
                      onTap: () {
                        context.push(AppRoutes.ormawaAbsensiManagement);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, size: 16, color: Color(0xFF334155)),
                            SizedBox(width: 6),
                            Text(
                              'Presensi Kehadiran Acara',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 3),
        Text(
          content,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
        ),
      ],
    );
  }
}