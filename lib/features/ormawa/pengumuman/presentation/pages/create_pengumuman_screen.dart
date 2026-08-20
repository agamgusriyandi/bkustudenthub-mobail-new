import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class CreatePengumumanScreen extends StatefulWidget {
  const CreatePengumumanScreen({super.key});

  @override
  State<CreatePengumumanScreen> createState() => _CreatePengumumanScreenState();
}

class _CreatePengumumanScreenState extends State<CreatePengumumanScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _lampiranController = TextEditingController();

  String _selectedCategory = 'umum';
  String _selectedTargetAudiens = 'Semua Mahasiswa';
  DateTime? _tanggalMulai = DateTime.now();
  DateTime? _tanggalSelesai;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'umum',
      'label': 'Umum',
      'desc': 'Informasi umum & keorganisasian',
      'icon': Icons.campaign_rounded,
      'color': BkuTheme.textBody,
      'bgColor': BkuTheme.borderSubtle,
    },
    {
      'id': 'kegiatan',
      'label': 'Info Kegiatan',
      'desc': 'Agenda acara, webinar & workshop',
      'icon': Icons.event_rounded,
      'color': BkuTheme.primary,
      'bgColor': BkuTheme.primarySoft,
    },
    {
      'id': 'penting',
      'label': 'Penting & Urgen',
      'desc': 'Pemberitahuan mendesak & wajib',
      'icon': Icons.priority_high_rounded,
      'color': BkuTheme.rose,
      'bgColor': BkuTheme.roseSoft,
    },
    {
      'id': 'prestasi',
      'label': 'Kabar Prestasi',
      'desc': 'Apresiasi & capaian mahasiswa',
      'icon': Icons.emoji_events_rounded,
      'color': BkuTheme.amber,
      'bgColor': BkuTheme.amberSoft,
    },
  ];

  final List<String> _audiensOptions = [
    'Semua Mahasiswa',
    'Khusus Mahasiswa Fakultas',
    'Anggota Internal',
    'Umum / Publik',
  ];

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
              primary: BkuTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: BkuTheme.textHeading,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: BkuTheme.primary,
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
      final ormawaId = context.read<OrmawaProvider>().ormawaId;
      final payload = {
        'OrmawaID': int.parse(ormawaId ?? '0'),
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

      await context.read<OrmawaProvider>().createAnnouncement(payload);

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pengumuman baru berhasil diterbitkan!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menerbitkan pengumuman: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Buat Pengumuman',
        subtitle: 'Siaran Informasi Ormawa',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.s100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Kategori & Klasifikasi Siaran',
              subtitle: 'Tentukan kategori dan sasaran penerima pengumuman.',
              icon: Icons.category_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PILIH KATEGORI SIARAN *',
                    style: BkuTheme.textBadge.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textMuted,
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
                            color: isSelected ? BkuTheme.primarySoft : BkuTheme.cardSurface,
                            borderRadius: BkuTheme.r16,
                            border: Border.all(
                              color: isSelected ? BkuTheme.primary : BkuTheme.border,
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
                                      color: isSelected ? BkuTheme.primary : cat['bgColor'] as Color,
                                      borderRadius: BkuTheme.r10,
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
                                        color: BkuTheme.primary,
                                        borderRadius: BkuTheme.r8,
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
                                    style: BkuTheme.textCardTitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? BkuTheme.primaryDark : BkuTheme.textHeading,
                                    ),
                                  ),
                                  Text(
                                    cat['desc'] as String,
                                    style: BkuTheme.textCaption.copyWith(fontSize: 9, color: BkuTheme.textMuted, height: 1.2),
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
                  Text(
                    'Target Audiens',
                    style: BkuTheme.textBadge.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textHeading,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BkuDropdown<String>(
                    value: _selectedTargetAudiens,
                    isExpanded: true,
                    items: _audiensOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(
                          opt,
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTargetAudiens = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Konten & Teks Pengumuman',
              subtitle: 'Tuliskan judul siaran dan uraikan pesan secara lengkap.',
              icon: Icons.article_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkuTextField(
                    controller: _judulController,
                    label: 'Judul Pengumuman *',
                    hint: 'Contoh: Pendaftaran Open Recruitment Panitia...',
                  ),
                  const SizedBox(height: 14),
                  BkuTextField(
                    controller: _isiController,
                    label: 'Isi Pesan Pengumuman *',
                    hint: 'Tuliskan rincian pengumuman, agenda, instruksi, dan narahubung...',
                    maxLines: 7,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Lampiran & Tautan Pendukung',
              subtitle: 'Lampirkan Google Drive, formulir pendaftaran, atau flyer.',
              icon: Icons.link_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tautan Dokumen / Drive (Opsional)',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.textHeading,
                          letterSpacing: 0.3,
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
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF0F172A)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BkuTextField(
                    controller: _lampiranController,
                    onChanged: (_) => setState(() {}),
                    hint: 'https://drive.google.com/... atau https://forms.gle/...',
                    prefixIcon: const Icon(Icons.link_rounded, size: 18, color: BkuTheme.textPlaceholder),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          border: const Border(top: BorderSide(color: BkuTheme.border)),
          boxShadow: BkuTheme.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: BkuButton.outline(
                onPressed: () => Navigator.pop(context),
                text: 'Batal',
                height: 46,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: BkuButton.primary(
                onPressed: _isSubmitting ? null : _handleSave,
                isLoading: _isSubmitting,
                icon: Icons.send_rounded,
                text: 'Terbitkan Siaran',
                height: 46,
                fontSize: 12,
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
    required Widget child,
  }) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r10,
                ),
                child: Icon(icon, color: BkuTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BkuTheme.textCardTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: BkuTheme.textCaption.copyWith(
                        fontSize: 10,
                        color: BkuTheme.textMuted,
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
          style: BkuTheme.textBadge.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: BkuTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BkuTheme.r12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: BkuTheme.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd MMM yyyy', 'id').format(date) : 'Pilih tgl...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: date != null ? BkuTheme.textHeading : BkuTheme.textPlaceholder,
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