import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
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
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return const Color(0xFFFEF3C7);
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return const Color(0xFFD1FAE5);
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return const Color(0xFFFFE4E6);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return const Color(0xFFB45309);
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return const Color(0xFF047857);
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
      case 'ongoing':
        return const Color(0xFFFDE68A);
      case 'selesai':
      case 'terlaksana':
      case 'completed':
        return const Color(0xFFA7F3D0);
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
        return const Color(0xFFFECDD3);
      default:
        return const Color(0xFFBFDBFE);
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
      backgroundColor: const Color(0xFFF8FAFC),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
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
                                borderRadius: BorderRadius.circular(8),
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
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          agenda.title,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                        ),
                        if (agenda.pjKegiatan != null && agenda.pjKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_rounded, size: 14, color: OrmawaTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'PJ Kegiatan: ',
                                  style: TextStyle(fontSize: 11, color: OrmawaTheme.textMuted),
                                ),
                                Text(
                                  agenda.pjKegiatan!,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: OrmawaTheme.textHeading),
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
                        OrmawaTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Selesai Pelaksanaan',
                        _formatDate(agenda.endDate),
                        Icons.event_available_rounded,
                        OrmawaTheme.primary,
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
                        OrmawaTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        'Estimasi Dana',
                        _formatRp(agenda.estimasiDana),
                        Icons.payments_outlined,
                        const Color(0xFF059669),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF94A3B8).withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article_outlined, size: 16, color: OrmawaTheme.primary),
                            const SizedBox(width: 8),
                            Text('Informasi Detail Kegiatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: OrmawaTheme.textHeading)),
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
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context, agenda),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Hapus Agenda', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE11D48),
                            side: const BorderSide(color: Color(0xFFFECDD3)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.ormawaJadwalEdit, extra: agenda),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Edit Kegiatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrmawaTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrmawaAbsensiScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                          label: const Text('Buka Absensi Kegiatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: OrmawaTheme.primaryDark,
                            side: BorderSide(color: OrmawaTheme.primaryBorder),
                            backgroundColor: OrmawaTheme.primarySoft,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: iconColor == const Color(0xFF059669) ? const Color(0xFF059669) : const Color(0xFF0F172A),
                fontFamily: iconColor == const Color(0xFF059669) ? 'monospace' : null,
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
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: const Color(0xFF64748B)),
                const SizedBox(width: 5),
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
