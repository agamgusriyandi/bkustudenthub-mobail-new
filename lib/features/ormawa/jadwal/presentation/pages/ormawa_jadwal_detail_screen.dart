import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
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

    Color statusColor = BkuTheme.sky;
    Color statusBg = BkuTheme.skySoft;
    Color statusBorder = BkuTheme.skyBorder;

    if (status == 'selesai' || status == 'terlaksana' || status == 'completed') {
      statusColor = BkuTheme.emerald;
      statusBg = BkuTheme.emeraldSoft;
      statusBorder = BkuTheme.emeraldBorder;
    } else if (status == 'berlangsung' || status == 'ongoing') {
      statusColor = BkuTheme.amber;
      statusBg = BkuTheme.amberSoft;
      statusBorder = BkuTheme.amberBorder;
    } else if (status == 'dibatalkan' || status == 'batal' || status == 'cancelled') {
      statusColor = BkuTheme.rose;
      statusBg = BkuTheme.roseSoft;
      statusBorder = BkuTheme.roseBorder;
    }

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
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
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
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
                                color: BkuTheme.primarySoft,
                                borderRadius: BkuTheme.r12,
                              ),
                              child: Icon(Icons.event_available_rounded, color: BkuTheme.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isProposal ? BkuTheme.primarySoft : BkuTheme.skySoft,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(
                                            color: isProposal ? BkuTheme.primaryBorder : BkuTheme.skyBorder,
                                          ),
                                        ),
                                        child: Text(
                                          isProposal ? 'Proposal Kegiatan' : 'Kegiatan Mandiri',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: isProposal ? BkuTheme.primary : BkuTheme.sky,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: statusBorder),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: statusColor,
                                          ),
                                        ),
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
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r8,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.category_rounded, size: 14, color: BkuTheme.purple),
                                const SizedBox(width: 6),
                                Text(
                                  'Kategori: $category',
                                  style: BkuTheme.textBodyRegular.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.emeraldSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.access_time_rounded, color: BkuTheme.emerald, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Waktu & Lokasi Pelaksanaan', style: BkuTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: BkuTheme.emerald,
                          label: 'Tanggal Pelaksanaan',
                          value: dateDisplay,
                        ),
                        if (timeDisplay.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.schedule_rounded,
                            iconColor: BkuTheme.emerald,
                            label: 'Waktu Pelaksanaan',
                            value: timeDisplay,
                          ),
                        ],
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.location_on_rounded,
                          iconColor: BkuTheme.rose,
                          label: 'Lokasi / Venue',
                          value: loc,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.purpleSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: Icon(Icons.people_alt_rounded, color: BkuTheme.purple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Penanggung Jawab & Struktur', style: BkuTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.person_rounded,
                          iconColor: BkuTheme.purple,
                          label: 'Penanggung Jawab (PJ)',
                          value: pj.isNotEmpty ? pj : '—',
                        ),
                        if (mitra.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.handshake_rounded,
                            iconColor: BkuTheme.primary,
                            label: 'Mitra Kerja Sama',
                            value: mitra,
                          ),
                        ],
                        if (sasaran.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.groups_rounded,
                            iconColor: BkuTheme.sky,
                            label: 'Sasaran Peserta',
                            value: sasaran,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (sumberDana.isNotEmpty || (estimasiDana != null && estimasiDana != 0)) ...[
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: BkuTheme.amberSoft,
                                  borderRadius: BkuTheme.r8,
                                ),
                                child: Icon(Icons.account_balance_wallet_rounded, color: BkuTheme.amber, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Anggaran & Pembiayaan', style: BkuTheme.textSectionTitle),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (estimasiDana != null && estimasiDana != 0)
                            _buildDetailRow(
                              icon: Icons.payments_rounded,
                              iconColor: BkuTheme.emerald,
                              label: 'Estimasi Anggaran',
                              value: _formatRp(estimasiDana),
                            ),
                          if (sumberDana.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              icon: Icons.savings_rounded,
                              iconColor: BkuTheme.amber,
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
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: BkuTheme.primarySoft,
                                  borderRadius: BkuTheme.r8,
                                ),
                                child: Icon(Icons.description_rounded, color: BkuTheme.primary, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Rincian & Landasan Strategis', style: BkuTheme.textSectionTitle),
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
                        child: BkuButton.primary(
                          text: 'Edit Kegiatan',
                          icon: Icons.edit_rounded,
                          height: 46,
                          onPressed: () async {
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkuButton.outline(
                          text: 'Batalkan',
                          icon: Icons.delete_outline_rounded,
                          height: 46,
                          onPressed: () => _confirmDelete(context, eventId, title),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: BkuButton.outline(
                      text: 'Presensi Kehadiran Acara',
                      icon: Icons.qr_code_scanner_rounded,
                      height: 46,
                      onPressed: () {
                        context.push(AppRoutes.ormawaAbsensiManagement);
                      },
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
            borderRadius: BkuTheme.r8,
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
                style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
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
          style: BkuTheme.textBadge.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
        ),
        const SizedBox(height: 3),
        Text(
          content,
          style: BkuTheme.textBodyRegular.copyWith(fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}