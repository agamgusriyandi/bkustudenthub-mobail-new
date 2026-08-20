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
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';

class OrmawaAgendaDetailScreen extends StatelessWidget {
  final OrmawaAgenda agenda;

  const OrmawaAgendaDetailScreen({super.key, required this.agenda});

  String _formatRp(double? val) {
    if (val == null || val == 0.0) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return BkuTheme.amberSoft;
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return BkuTheme.emeraldSoft;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return BkuTheme.roseSoft;
      default:
        return BkuTheme.skySoft;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return BkuTheme.amber;
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return BkuTheme.emerald;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return BkuTheme.rose;
      default:
        return BkuTheme.sky;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return BkuTheme.amberBorder;
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return BkuTheme.emeraldBorder;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return BkuTheme.roseBorder;
      default:
        return BkuTheme.skyBorder;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return 'Sedang Berlangsung (Ongoing)';
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return 'Selesai (Completed)';
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return 'Dibatalkan (Cancelled)';
      default:
        return 'Terjadwal (Planned)';
    }
  }

  void _confirmDelete(BuildContext context, OrmawaAgenda agenda) {
    BkuDialog.show(
      context: context,
      title: 'Hapus Jadwal Kegiatan?',
      message: 'Apakah Anda yakin ingin menghapus agenda "${agenda.title}"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus Agenda',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteAgenda(agenda.id);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Jadwal kegiatan berhasil dihapus');
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
    final statusLabel = _getStatusLabel(agenda.status);
    final statusBg = _getStatusBgColor(agenda.status);
    final statusColor = _getStatusTextColor(agenda.status);
    final statusBorder = _getStatusBorderColor(agenda.status);

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail Kegiatan',
            subtitle: 'Event Management',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BkuTheme.r8,
                                border: Border.all(color: statusBorder),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor),
                              ),
                            ),
                            if (agenda.id.isNotEmpty)
                              Text(
                                'ID #${agenda.id}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: BkuTheme.textPlaceholder,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          agenda.title,
                          style: BkuTheme.textCardTitle.copyWith(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        if (agenda.pjKegiatan != null && agenda.pjKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r10,
                              border: Border.all(color: BkuTheme.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_rounded, size: 14, color: BkuTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'PJ Kegiatan: ',
                                  style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textMuted),
                                ),
                                Text(
                                  agenda.pjKegiatan!,
                                  style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textHeading),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _buildMetricCard(
                        'Mulai Pelaksanaan',
                        _formatDate(agenda.date),
                        Icons.calendar_today_rounded,
                        BkuTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Selesai Pelaksanaan',
                        _formatDate(agenda.endDate),
                        Icons.event_available_rounded,
                        BkuTheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMetricCard(
                        'Lokasi Kegiatan',
                        agenda.location.isNotEmpty ? agenda.location : 'Belum ditentukan',
                        Icons.location_on_outlined,
                        BkuTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Estimasi Dana',
                        _formatRp(agenda.estimasiDana),
                        Icons.payments_outlined,
                        BkuTheme.emerald,
                      ),
                    ],
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
                            Icon(Icons.article_outlined, size: 16, color: BkuTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Detail Kegiatan',
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildDetailTile('Landasan Kegiatan', agenda.landasanKegiatan, Icons.balance_rounded),
                        _buildDetailTile('Bentuk Kegiatan', agenda.bentukKegiatan, Icons.category_rounded),
                        _buildDetailTile('Mitra Kerja / Sponsor', agenda.mitra, Icons.group_rounded),
                        _buildDetailTile('Sasaran Kegiatan', agenda.sasaranKegiatan, Icons.track_changes_rounded),
                        _buildDetailTile('Sumber Pendanaan', agenda.sumberDana, Icons.account_balance_wallet_rounded),
                        _buildDetailTile('Waktu Pelaksanaan Spesifik', agenda.jadwalPelaksanaan, Icons.schedule_rounded),
                        _buildDetailTile('Indikator Keberhasilan', agenda.indikatorKeberhasilan, Icons.verified_rounded),
                        _buildDetailTile('Latar Belakang', agenda.latarBelakang, Icons.history_edu_rounded),
                        _buildDetailTile('Tujuan Kegiatan', agenda.tujuanKegiatan, Icons.flag_rounded),
                        _buildDetailTile('Deskripsi & Mekanisme Kegiatan', agenda.description, Icons.description_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: BkuButton.outline(
                          onPressed: () => _confirmDelete(context, agenda),
                          icon: Icons.delete_outline_rounded,
                          text: 'Hapus Agenda',
                          height: 44,
                          fontSize: 11,
                          customRadius: BkuTheme.r12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BkuButton.primary(
                          onPressed: () => context.push(AppRoutes.ormawaJadwalEdit, extra: agenda),
                          icon: Icons.edit_rounded,
                          text: 'Edit Kegiatan',
                          height: 44,
                          fontSize: 11,
                          customRadius: BkuTheme.r12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Consumer<OrmawaProvider>(
                    builder: (context, prov, _) {
                      if (!prov.hasPermission('view_attendance')) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: BkuButton.outline(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrmawaAbsensiScreen(),
                              ),
                            );
                          },
                          icon: Icons.qr_code_scanner_rounded,
                          text: 'Buka Absensi Kegiatan',
                          height: 44,
                          fontSize: 11,
                          customRadius: BkuTheme.r12,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.s140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: BkuCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: BkuTheme.textBadge.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: iconColor == BkuTheme.emerald ? BkuTheme.emerald : BkuTheme.textHeading,
                fontFamily: iconColor == BkuTheme.emerald ? 'monospace' : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String? value, IconData icon) {
    final val = (value != null && value.trim().isNotEmpty) ? value.trim() : '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: BkuTheme.borderSubtle,
          borderRadius: BkuTheme.r12,
          border: Border.all(color: BkuTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: BkuTheme.textMuted),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: BkuTheme.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: BkuTheme.textBodyRegular.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: BkuTheme.textHeading,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}