import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaJadwalDetailScreen extends StatelessWidget {
  final dynamic kegiatan;

  const OrmawaJadwalDetailScreen({super.key, required this.kegiatan});

  String _formatRp(double? val) {
    if (val == null || val == 0.0) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
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

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return const Color(0xFFFEF3C7);
      case 'selesai':
      case 'terlaksana':
        return const Color(0xFFD1FAE5);
      case 'dibatalkan':
      case 'batal':
        return const Color(0xFFFFE4E6);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'berlangsung':
        return const Color(0xFFB45309);
      case 'selesai':
      case 'terlaksana':
        return const Color(0xFF047857);
      case 'dibatalkan':
      case 'batal':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF1D4ED8);
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
    final k = kegiatan;
    final String title = (k is OrmawaAgenda ? k.title : k.judul ?? k.title ?? 'Detail Kegiatan');
    final String desc = (k is OrmawaAgenda ? k.description : k.deskripsi ?? k.description ?? '');
    final String status = (k is OrmawaAgenda ? k.status : k.status ?? 'Terjadwal');
    final String loc = (k is OrmawaAgenda ? k.location : k.lokasi ?? k.location ?? '');
    final dynamic startDate = (k is OrmawaAgenda ? k.date : k.tanggalMulai ?? k.date);
    final dynamic endDate = (k is OrmawaAgenda ? k.endDate : k.tanggalSelesai ?? k.endDate);
    final double? dana = (k is OrmawaAgenda ? k.estimasiDana : (k.estimasiDana != null ? (k.estimasiDana as num).toDouble() : null));
    final String pj = (k is OrmawaAgenda ? (k.pjKegiatan ?? '') : (k.pjKegiatan ?? k.pj_kegiatan ?? ''));
    final String mitra = (k is OrmawaAgenda ? (k.mitra ?? '') : (k.mitra ?? ''));
    final String bentuk = (k is OrmawaAgenda ? (k.bentukKegiatan ?? '') : (k.bentukKegiatan ?? k.bentuk_kegiatan ?? ''));
    final String sumberDana = (k is OrmawaAgenda ? (k.sumberDana ?? '') : (k.sumberDana ?? k.sumber_dana ?? ''));
    final String jadwalSpesifik = (k is OrmawaAgenda ? (k.jadwalPelaksanaan ?? '') : (k.jadwalPelaksanaan ?? k.jadwal_pelaksanaan ?? ''));
    final String landasan = (k is OrmawaAgenda ? (k.landasanKegiatan ?? '') : (k.landasanKegiatan ?? k.landasan_kegiatan ?? ''));
    final String latar = (k is OrmawaAgenda ? (k.latarBelakang ?? '') : (k.latarBelakang ?? k.latar_belakang ?? ''));
    final String sasaran = (k is OrmawaAgenda ? (k.sasaranKegiatan ?? '') : (k.sasaranKegiatan ?? k.sasaran_kegiatan ?? ''));
    final String indikator = (k is OrmawaAgenda ? (k.indikatorKeberhasilan ?? '') : (k.indikatorKeberhasilan ?? k.indikator_keberhasilan ?? ''));
    final String id = (k is OrmawaAgenda ? k.id : k.id?.toString() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail Kegiatan',
            subtitle: 'Informasi Jadwal',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: _getStatusTextColor(status)),
                              ),
                            ),
                          ],
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            desc,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _buildMetricCard('Mulai', _formatDate(startDate), Icons.calendar_today_rounded, OrmawaTheme.primary),
                      const SizedBox(width: 8),
                      _buildMetricCard('Selesai', _formatDate(endDate), Icons.event_available_rounded, OrmawaTheme.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMetricCard('Lokasi', loc.isNotEmpty ? loc : 'Belum ditentukan', Icons.location_on_outlined, OrmawaTheme.primary),
                      const SizedBox(width: 8),
                      _buildMetricCard('Estimasi Dana', _formatRp(dana), Icons.payments_outlined, const Color(0xFF059669)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: OrmawaTheme.border),
                      boxShadow: OrmawaTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment_outlined, size: 16, color: OrmawaTheme.primary),
                            const SizedBox(width: 8),
                            Text('Rincian Teknis & Pelaksanaan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: OrmawaTheme.textHeading)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildInfoTile('Penanggung Jawab (PJ)', pj.isNotEmpty ? pj : '—'),
                        _buildInfoTile('Mitra / Kolaborator', mitra.isNotEmpty ? mitra : '—'),
                        _buildInfoTile('Bentuk Kegiatan', bentuk.isNotEmpty ? bentuk : '—'),
                        _buildInfoTile('Sumber Pendanaan', sumberDana.isNotEmpty ? sumberDana : '—'),
                        if (jadwalSpesifik.isNotEmpty) _buildInfoTile('Jadwal Spesifik', jadwalSpesifik),
                        if (landasan.isNotEmpty) _buildInfoTile('Landasan Kegiatan', landasan),
                        if (latar.isNotEmpty) _buildInfoTile('Latar Belakang', latar),
                        if (sasaran.isNotEmpty) _buildInfoTile('Sasaran Kegiatan', sasaran),
                        if (indikator.isNotEmpty) _buildInfoTile('Indikator Keberhasilan', indikator),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context, id, title),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditKegiatanScreen(kegiatan: k),
                              ),
                            );
                          },
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
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class EditKegiatanScreen extends StatefulWidget {
  final dynamic kegiatan;
  const EditKegiatanScreen({super.key, required this.kegiatan});

  @override
  State<EditKegiatanScreen> createState() => _EditKegiatanScreenState();
}

class _EditKegiatanScreenState extends State<EditKegiatanScreen> {
  late final TextEditingController _judulController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _pjController;
  late final TextEditingController _estimasiDanaController;
  late final TextEditingController _sumberDanaController;
  late final TextEditingController _bentukKegiatanController;
  late final TextEditingController _mitraController;
  late final TextEditingController _sasaranController;
  late final TextEditingController _indikatorController;
  late final TextEditingController _landasanController;
  late final TextEditingController _latarBelakangController;
  late final TextEditingController _tujuanController;
  late final TextEditingController _jadwalPelaksanaanController;

  late String _selectedStatus;
  late DateTime _tanggalMulai;
  late DateTime _tanggalSelesai;
  bool _isSubmitting = false;

  final List<Map<String, String>> _statuses = [
    {'value': 'Planned', 'label': 'Terjadwal (Planned)'},
    {'value': 'berlangsung', 'label': 'Sedang Berlangsung'},
    {'value': 'selesai', 'label': 'Selesai Terlaksana'},
    {'value': 'dibatalkan', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    final k = widget.kegiatan;
    _judulController = TextEditingController(text: k is OrmawaAgenda ? k.title : k.judul ?? k.title ?? '');
    _lokasiController = TextEditingController(text: k is OrmawaAgenda ? k.location : k.lokasi ?? k.location ?? '');
    _deskripsiController = TextEditingController(text: k is OrmawaAgenda ? k.description : k.deskripsi ?? k.description ?? '');
    _pjController = TextEditingController(text: k is OrmawaAgenda ? (k.pjKegiatan ?? '') : (k.pjKegiatan ?? k.pj_kegiatan ?? ''));
    _estimasiDanaController = TextEditingController(text: k is OrmawaAgenda ? (k.estimasiDana != null ? k.estimasiDana!.toStringAsFixed(0) : '') : (k.estimasiDana != null ? k.estimasiDana.toString() : ''));
    _sumberDanaController = TextEditingController(text: k is OrmawaAgenda ? (k.sumberDana ?? '') : (k.sumberDana ?? k.sumber_dana ?? ''));
    _bentukKegiatanController = TextEditingController(text: k is OrmawaAgenda ? (k.bentukKegiatan ?? '') : (k.bentukKegiatan ?? k.bentuk_kegiatan ?? ''));
    _mitraController = TextEditingController(text: k is OrmawaAgenda ? (k.mitra ?? '') : (k.mitra ?? ''));
    _sasaranController = TextEditingController(text: k is OrmawaAgenda ? (k.sasaranKegiatan ?? '') : (k.sasaranKegiatan ?? k.sasaran_kegiatan ?? ''));
    _indikatorController = TextEditingController(text: k is OrmawaAgenda ? (k.indikatorKeberhasilan ?? '') : (k.indikatorKeberhasilan ?? k.indikator_keberhasilan ?? ''));
    _landasanController = TextEditingController(text: k is OrmawaAgenda ? (k.landasanKegiatan ?? '') : (k.landasanKegiatan ?? k.landasan_kegiatan ?? ''));
    _latarBelakangController = TextEditingController(text: k is OrmawaAgenda ? (k.latarBelakang ?? '') : (k.latarBelakang ?? k.latar_belakang ?? ''));
    _tujuanController = TextEditingController(text: k is OrmawaAgenda ? (k.tujuanKegiatan ?? '') : (k.tujuanKegiatan ?? k.tujuan_kegiatan ?? ''));
    _jadwalPelaksanaanController = TextEditingController(text: k is OrmawaAgenda ? (k.jadwalPelaksanaan ?? '') : (k.jadwalPelaksanaan ?? k.jadwal_pelaksanaan ?? ''));

    _selectedStatus = k is OrmawaAgenda ? k.status : (k.status ?? 'Planned');
    _tanggalMulai = k is OrmawaAgenda ? k.date : (k.tanggalMulai != null ? DateTime.parse(k.tanggalMulai.toString()) : DateTime.now());
    _tanggalSelesai = k is OrmawaAgenda ? k.endDate : (k.tanggalSelesai != null ? DateTime.parse(k.tanggalSelesai.toString()) : DateTime.now());
  }

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _pjController.dispose();
    _estimasiDanaController.dispose();
    _sumberDanaController.dispose();
    _bentukKegiatanController.dispose();
    _mitraController.dispose();
    _sasaranController.dispose();
    _indikatorController.dispose();
    _landasanController.dispose();
    _latarBelakangController.dispose();
    _tujuanController.dispose();
    _jadwalPelaksanaanController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _tanggalMulai, end: _tanggalSelesai),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              onSurface: OrmawaTheme.textHeading,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _tanggalMulai = range.start;
        _tanggalSelesai = range.end;
      });
    }
  }

  void _handleSubmit() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Nama kegiatan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final double? parsedDana = double.tryParse(_estimasiDanaController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));
      final String id = widget.kegiatan is OrmawaAgenda ? widget.kegiatan.id : widget.kegiatan.id?.toString() ?? '';

      final payload = {
        'Judul': _judulController.text.trim(),
        'Lokasi': _lokasiController.text.trim(),
        'Deskripsi': _deskripsiController.text.trim(),
        'Status': _selectedStatus,
        'TanggalMulai': _tanggalMulai.toIso8601String(),
        'TanggalSelesai': _tanggalSelesai.toIso8601String(),
        'landasan_kegiatan': _landasanController.text.trim(),
        'bentuk_kegiatan': _bentukKegiatanController.text.trim(),
        'mitra': _mitraController.text.trim(),
        'latar_belakang': _latarBelakangController.text.trim(),
        'tujuan_kegiatan': _tujuanController.text.trim(),
        'jadwal_pelaksanaan': _jadwalPelaksanaanController.text.trim(),
        'sasaran_kegiatan': _sasaranController.text.trim(),
        'indikator_keberhasilan': _indikatorController.text.trim(),
        'sumber_dana': _sumberDanaController.text.trim(),
        'estimasi_dana': parsedDana ?? 0.0,
        'pj_kegiatan': _pjController.text.trim(),
      };

      await context.read<OrmawaProvider>().updateAgenda(id, payload);
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Perubahan kegiatan berhasil disimpan');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Edit Jadwal Kegiatan',
            subtitle: 'Perbarui Informasi Agenda',
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
                  _buildFormSection(
                    title: 'Informasi Utama Agenda',
                    icon: Icons.info_outline_rounded,
                    children: [
                      _buildTextField(label: 'NAMA KEGIATAN', controller: _judulController, hint: 'Nama Kegiatan', isRequired: true),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'LOKASI PELAKSANAAN', controller: _lokasiController, hint: 'Lokasi', prefixIcon: Icons.location_on_outlined),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PERIODE PELAKSANAAN *', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _pickDateRange,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 14, color: OrmawaTheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${DateFormat('dd MMM yyyy', 'id').format(_tanggalMulai)} s/d ${DateFormat('dd MMM yyyy', 'id').format(_tanggalSelesai)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATUS AGENDA', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _statuses.any((s) => s['value'] == _selectedStatus) ? _selectedStatus : 'Planned',
                                isExpanded: true,
                                items: _statuses.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s['value'],
                                    child: Text(s['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedStatus = v ?? 'Planned'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'DESKRIPSI KEGIATAN', controller: _deskripsiController, hint: 'Deskripsi...', maxLines: 3),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Teknis & Anggaran',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      _buildTextField(label: 'PENANGGUNG JAWAB (PJ)', controller: _pjController, hint: 'Nama PJ...', prefixIcon: Icons.person_outline_rounded),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'ESTIMASI DANA (RP)', controller: _estimasiDanaController, hint: 'Contoh: 5000000', keyboardType: TextInputType.number, prefixIcon: Icons.payments_outlined),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'SUMBER PENDANAAN', controller: _sumberDanaController, hint: 'Sumber Dana...'),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'BENTUK KEGIATAN', controller: _bentukKegiatanController, hint: 'Bentuk Kegiatan...'),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'MITRA / KOLABORATOR', controller: _mitraController, hint: 'Mitra...'),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'WAKTU PELAKSANAAN SPESIFIK', controller: _jadwalPelaksanaanController, hint: 'Waktu spesifik...'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFormSection(
                    title: 'Landasan & Sasaran Strategis',
                    icon: Icons.track_changes_rounded,
                    children: [
                      _buildTextField(label: 'SASARAN KEGIATAN', controller: _sasaranController, hint: 'Sasaran...', maxLines: 2),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'INDIKATOR KEBERHASILAN', controller: _indikatorController, hint: 'Indikator...', maxLines: 3),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'LANDASAN KEGIATAN', controller: _landasanController, hint: 'Landasan...', maxLines: 2),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'LATAR BELAKANG', controller: _latarBelakangController, hint: 'Latar belakang...', maxLines: 3),
                      const SizedBox(height: 10),
                      _buildTextField(label: 'TUJUAN KEGIATAN', controller: _tujuanController, hint: 'Tujuan...', maxLines: 2),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Simpan Perubahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrmawaTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
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

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: OrmawaTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: OrmawaTheme.textHeading)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 12, color: OrmawaTheme.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: OrmawaTheme.textMuted,
                letterSpacing: 0.3,
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFE11D48))),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: OrmawaTheme.textHeading),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 11, color: OrmawaTheme.textPlaceholder, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OrmawaTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OrmawaTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OrmawaTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
