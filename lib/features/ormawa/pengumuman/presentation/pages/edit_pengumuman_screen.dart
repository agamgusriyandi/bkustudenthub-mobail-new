import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class EditPengumumanScreen extends StatefulWidget {
  final OrmawaAnnouncement announcement;

  const EditPengumumanScreen({super.key, required this.announcement});

  @override
  State<EditPengumumanScreen> createState() => _EditPengumumanScreenState();
}

class _EditPengumumanScreenState extends State<EditPengumumanScreen> {
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;
  late final TextEditingController _lampiranController;

  late String _selectedCategory;
  late String _selectedTargetAudiens;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'umum',
      'label': 'Umum',
      'desc': 'Informasi umum & keorganisasian',
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFF475569),
      'bgColor': const Color(0xFFF1F5F9),
    },
    {
      'id': 'kegiatan',
      'label': 'Info Kegiatan',
      'desc': 'Agenda acara, webinar & workshop',
      'icon': Icons.event_rounded,
      'color': const Color(0xFF0284C7),
      'bgColor': const Color(0xFFE0F2FE),
    },
    {
      'id': 'penting',
      'label': 'Penting & Urgen',
      'desc': 'Pemberitahuan mendesak & wajib',
      'icon': Icons.priority_high_rounded,
      'color': const Color(0xFFE11D48),
      'bgColor': const Color(0xFFFFE4E6),
    },
    {
      'id': 'prestasi',
      'label': 'Kabar Prestasi',
      'desc': 'Apresiasi & capaian mahasiswa',
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFEF3C7),
    },
  ];

  final List<String> _audiensOptions = [
    'Semua Mahasiswa',
    'Khusus Mahasiswa Fakultas',
    'Anggota Internal',
    'Umum / Publik',
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.announcement.judul);
    _isiController = TextEditingController(text: widget.announcement.isi);
    _lampiranController = TextEditingController(text: widget.announcement.lampiranUrl ?? '');

    final kat = widget.announcement.kategori.toLowerCase();
    if (kat.contains('prestasi')) {
      _selectedCategory = 'prestasi';
    } else if (kat.contains('penting') || kat.contains('urgen')) {
      _selectedCategory = 'penting';
    } else if (kat.contains('kegiatan') || kat.contains('event')) {
      _selectedCategory = 'kegiatan';
    } else {
      _selectedCategory = 'umum';
    }

    _selectedTargetAudiens = widget.announcement.targetAudiens.isNotEmpty
        ? widget.announcement.targetAudiens
        : 'Semua Mahasiswa';
    if (!_audiensOptions.contains(_selectedTargetAudiens)) {
      _selectedTargetAudiens = 'Semua Mahasiswa';
    }

    _tanggalMulai = widget.announcement.tanggalMulai ?? DateTime.now();
    _tanggalSelesai = widget.announcement.tanggalSelesai;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _lampiranController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (_tanggalMulai ?? DateTime.now()) : (_tanggalSelesai ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: OrmawaTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
                        textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: OrmawaTheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_judulController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Judul pengumuman wajib diisi');
      return;
    }
    if (_isiController.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Isi pesan pengumuman wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'Judul': _judulController.text.trim(),
        'Isi': _isiController.text.trim(),
        'Kategori': _selectedCategory,
        'Target': _selectedCategory,
        'TargetAudiens': _selectedTargetAudiens,
        'LampiranUrl': _lampiranController.text.trim(),
        'TanggalMulai': _tanggalMulai?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
        if (_tanggalSelesai != null)
          'TanggalSelesai': _tanggalSelesai!.toUtc().toIso8601String(),
      };

      await context.read<OrmawaProvider>().updateAnnouncement(
        widget.announcement.id,
        payload,
      );

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengumuman berhasil diperbarui!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memperbarui pengumuman: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = OrmawaTheme.primary;

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Edit Pengumuman',
        subtitle: 'Siaran Informasi Ormawa',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Kategori & Klasifikasi Siaran',
              subtitle: 'Perbarui kategori dan sasaran penerima pengumuman.',
              icon: Icons.category_rounded,
              primaryColor: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PILIH KATEGORI SIARAN *',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat['id'];
                      final color = cat['color'] as Color;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat['id'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withAlpha(15) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryColor : cat['bgColor'] as Color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      size: 16,
                                      color: isSelected ? Colors.white : color,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Terpilih',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat['label'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? primaryColor : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    cat['desc'] as String,
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInput(
                          label: 'Tgl. Mulai Terbit',
                          date: _tanggalMulai,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateInput(
                          label: 'Tgl. Selesai (Opsional)',
                          date: _tanggalSelesai,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'TARGET AUDIENS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTargetAudiens,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        items: _audiensOptions.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(
                              opt,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTargetAudiens = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Konten & Teks Pengumuman',
              subtitle: 'Ubah judul siaran atau isi pengumuman.',
              icon: Icons.article_rounded,
              primaryColor: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JUDUL PENGUMUMAN *',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _judulController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Masukkan judul pengumuman...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'ISI PESAN PENGUMUMAN *',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _isiController,
                    maxLines: 7,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan rincian pengumuman, agenda, instruksi, dan narahubung...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Lampiran & Tautan Pendukung',
              subtitle: 'Lampirkan Google Drive, formulir pendaftaran, atau flyer.',
              icon: Icons.link_rounded,
              primaryColor: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TAUTAN DOKUMEN / DRIVE (OPSIONAL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF475569),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_lampiranController.text.trim().startsWith('http'))
                        InkWell(
                          onTap: () async {
                            final uri = Uri.tryParse(_lampiranController.text.trim());
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                'Buka Tautan',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.open_in_new_rounded, size: 12, color: primaryColor),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _lampiranController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'https://drive.google.com/... atau https://forms.gle/...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 16),
                label: Text(
                  _isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDateInput({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd MMM yyyy', 'id').format(date) : 'Pilih tgl...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: date != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}