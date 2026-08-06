import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/edit_absensi_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrmawaAbsensiManagementDetailScreen extends StatefulWidget {
  final String absensiId;
  final Map<String, dynamic> absensiData;

  const OrmawaAbsensiManagementDetailScreen({
    super.key,
    required this.absensiId,
    required this.absensiData,
  });

  @override
  State<OrmawaAbsensiManagementDetailScreen> createState() => _OrmawaAbsensiManagementDetailScreenState();
}

class _OrmawaAbsensiManagementDetailScreenState extends State<OrmawaAbsensiManagementDetailScreen> {
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.success;
      case 'selesai':
        return AppColors.info;
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.absensiData;
    final nama = (data['Nama'] ?? data['nama'] ?? '').toString();
    final deskripsi = (data['Deskripsi'] ?? data['deskripsi'] ?? '-').toString();
    final lokasi = (data['Lokasi'] ?? data['lokasi'] ?? '-').toString();
    final status = (data['Status'] ?? data['status'] ?? '').toString();
    final tanggal = (data['Tanggal'] ?? data['tanggal'] ?? '').toString();
    final waktuMulai = (data['WaktuMulai'] ?? data['waktu_mulai'] ?? '-').toString();
    final waktuSelesai = (data['WaktuSelesai'] ?? data['waktu_selesai'] ?? '-').toString();
    final jumlahHadir = data['JumlahHadir'] ?? data['jumlah_hadir'] ?? 0;
    final jumlahTotal = data['JumlahTotal'] ?? data['jumlah_total'] ?? 0;

    final statusColor = _getStatusColor(status);
    DateTime? date;
    try {
      date = DateTime.parse(tanggal);
    } catch (_) {}

    final attendanceRate = jumlahTotal > 0 ? ((jumlahHadir / jumlahTotal) * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'DETAIL ABSENSI',
            subtitle: 'KEHADIRAN KEGIATAN',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(nama, status, statusColor, date),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(context, 'INFORMASI KEGIATAN', [
                    _buildInfoRow('Lokasi', lokasi),
                    _buildInfoRow('Tanggal', date != null ? DateFormat('dd MMMM yyyy', 'id').format(date) : tanggal),
                    _buildInfoRow('Waktu Mulai', waktuMulai),
                    _buildInfoRow('Waktu Selesai', waktuSelesai),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(context, 'STATISTIK KEHADIRAN', [
                    _buildInfoRow('Jumlah Total', '$jumlahTotal orang'),
                    _buildInfoRow('Hadir', '$jumlahHadir orang'),
                    _buildInfoRow('Tidak Hadir', '${jumlahTotal - jumlahHadir} orang'),
                    const SizedBox(height: AppSpacing.md),
                    _buildAttendanceBar(attendanceRate),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tingkat Kehadiran: $attendanceRate%',
                      style: AppTextStyles.labelSm.copyWith(
                        color: attendanceRate >= 75 ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                  if (deskripsi.isNotEmpty && deskripsi != '-') ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoCard(context, 'DESKRIPSI', [
                      Text(
                        deskripsi,
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral700, height: 1.5),
                      ),
                    ]),
                  ],
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<OrmawaProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission('edit_attendance')) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAbsensiScreen(absensiId: widget.absensiId, absensiData: data),
                ),
              );
            },
            backgroundColor: context.appColors.primary,
            icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Edit Absensi',
              style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(String nama, String status, Color statusColor, DateTime? date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 10,
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
              Expanded(
                child: Text(
                  nama,
                  style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(15),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ],
          ),
          if (date != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.neutral500),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id').format(date),
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBar(int percentage) {
    return ClipRRect(
      borderRadius: AppRadius.radiusFull,
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: 8,
        backgroundColor: AppColors.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(
          percentage >= 75 ? AppColors.success : (percentage >= 50 ? AppColors.warning : AppColors.error),
        ),
      ),
    );
  }
}
