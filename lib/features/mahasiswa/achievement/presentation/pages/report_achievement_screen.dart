import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/achievement.dart';

class ReportAchievementScreen extends StatefulWidget {
  final Achievement? achievement;
  const ReportAchievementScreen({super.key, this.achievement});

  @override
  State<ReportAchievementScreen> createState() => _ReportAchievementScreenState();
}

class _ReportAchievementScreenState extends State<ReportAchievementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _danaDiajukanController = TextEditingController();
  final _cabangController = TextEditingController();
  final _urlPesertaController = TextEditingController();
  final _urlSertifikatController = TextEditingController();
  final _urlFotoUppController = TextEditingController();
  final _urlDokumenUndanganController = TextEditingController();
  final _jumlahUnitPesertaController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _anggotaMahasiswaController = TextEditingController();
  final _dosenSearchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String _selectedTipe = 'Prestasi Mandiri';
  String _selectedOrgId = '';
  String _selectedKategori = 'RISNOV';
  String _selectedJenisRekognisi = 'SERKOM';
  String _selectedTingkat = 'NAS';
  String _selectedPeringkat = 'JUARA1';
  String _selectedKelompokPrestasi = 'INDIVIDU';
  String _selectedBentuk = 'LURING';

  String? _selectedBuktiPath;
  String? _selectedBuktiName;
  String? _selectedSuratTugasPath;
  String? _selectedSuratTugasName;

  List<Map<String, dynamic>> _orgList = [];
  List<Map<String, dynamic>> _dosenOptions = [];
  List<Map<String, dynamic>> _selectedDosenList = [];
  bool _isLoadingInitial = false;
  bool _isDosenListOpen = true;
  String _dosenSearchQuery = '';

  final Map<String, String> _tipeLabels = {
    'Prestasi Mandiri': 'Prestasi Mandiri',
    'Sertifikasi': 'Sertifikasi Kompetensi',
    'Rekognisi': 'Rekognisi Akademik / Non-Akademik',
    'Pengajuan Dana': 'Pengajuan Dana Lomba',
  };

  final Map<String, String> _tingkatLabels = {
    'KAB': 'Kabupaten / Kota',
    'PROV': 'Provinsi',
    'NAS': 'Nasional',
    'INT': 'Internasional',
  };

  final Map<String, String> _peringkatLabels = {
    'JUARA1': 'Juara I',
    'JUARA2': 'Juara II',
    'JUARA3': 'Juara III',
    'HARAPAN1': 'Harapan I',
    'HARAPAN2': 'Harapan II',
    'HARAPAN3': 'Harapan III',
    'APRESIASI': 'Apresiasi Kejuaraan / Penghargaan Tambahan',
    'PESERTA': 'Peserta / Finalis',
  };

  final Map<String, String> _kategoriLabels = {
    'RISNOV': 'Riset dan Inovasi : STEM',
    'RISNOVSSH': 'Riset dan Inovasi : SSH',
    'SENBUD': 'Seni dan Budaya',
    'OLAHRAGA': 'Olahraga',
    'MINAT': 'Minat Khusus',
  };

  final Map<String, String> _rekognisiLabels = {
    'SERKOM': 'Sertifikat Kompetensi',
    'JURIOR': 'Juri/Pelatih/Wasit Olahraga',
    'JURINOR': 'Juri/Pelatih/Wasit Non Olahraga',
    'KEYCONF': 'Keynote speaker conference',
    'KEYWORK': 'Keynote speaker workshop/pelatihan/bimtek',
    'PAMERAN': 'Pameran karya seni',
    'KARYA': 'Karya cipta lagu dan/atau seni tari',
    'BUKU': 'Penulis buku',
    'PATEN': 'Paten/Paten Sederhana',
    'PUB': 'Publikasi artikel ilmiah',
    'DUTA': 'Duta (Brand Ambassador)',
    'PTG': 'Produk Teknologi tepat guna',
    'PSB': 'Produk Seni dan Budaya',
    'PKD': 'Produk Kreatif Dunia Usaha dan Industri',
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    if (widget.achievement != null) {
      final a = widget.achievement!;
      _titleController.text = a.title;
      _organizerController.text = a.organizer;
      _selectedDate = a.date;

      if (_tipeLabels.containsKey(a.tipe)) {
        _selectedTipe = a.tipe!;
      } else if (a.tipe == 'Laporan Prestasi') {
        _selectedTipe = 'Prestasi Mandiri';
      }

      if (_tingkatLabels.containsKey(a.level)) {
        _selectedTingkat = a.level;
      }

      if (_peringkatLabels.containsKey(a.rank)) {
        _selectedPeringkat = a.rank;
      }

      if (_kategoriLabels.containsKey(a.kategori)) {
        _selectedKategori = a.kategori!;
      }

      if (_rekognisiLabels.containsKey(a.jenisRekognisi)) {
        _selectedJenisRekognisi = a.jenisRekognisi!;
      }

      _danaDiajukanController.text = a.danaDiajukan ?? '';
      _cabangController.text = a.cabang ?? '';
      _urlPesertaController.text = a.urlPeserta ?? '';
      _urlSertifikatController.text = a.certificateUrl ?? '';
      _urlFotoUppController.text = a.urlFotoUpp ?? '';
      _urlDokumenUndanganController.text = a.urlDokumenUndangan ?? '';
      _jumlahUnitPesertaController.text = a.jumlahUnitPeserta ?? '';
      _keteranganController.text = a.keterangan ?? '';

      if (a.kelompokPrestasi != null && a.kelompokPrestasi!.toUpperCase() == 'KELOMPOK') {
        _selectedKelompokPrestasi = 'KELOMPOK';
      } else {
        _selectedKelompokPrestasi = 'INDIVIDU';
      }

      if (a.bentuk != null && a.bentuk!.toUpperCase() == 'DARING') {
        _selectedBentuk = 'DARING';
      } else {
        _selectedBentuk = 'LURING';
      }

      if (a.anggotaMahasiswa != null && a.anggotaMahasiswa!.isNotEmpty) {
        _anggotaMahasiswaController.text = a.anggotaMahasiswa!.join(', ');
      }

      if (a.pembimbingDosen != null && a.pembimbingDosen!.isNotEmpty) {
        _selectedDosenList = a.pembimbingDosen!
            .map((item) => item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{})
            .where((m) => m.isNotEmpty)
            .toList();
      }
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingInitial = true);
    try {
      try {
        final resDosen = await ApiClient().client.get('/master/dosen');
        if (resDosen.data != null && resDosen.data['data'] is List) {
          final List list = resDosen.data['data'];
          _dosenOptions = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
      } catch (e) {
        log('Error fetching dosen: $e');
      }

      try {
        final resOrg = await ApiClient().client.get('/organisasi/');
        if (resOrg.data != null && resOrg.data['data'] is List) {
          final List list = resOrg.data['data'];
          _orgList = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
      } catch (e) {
        log('Error fetching org: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _danaDiajukanController.dispose();
    _cabangController.dispose();
    _urlPesertaController.dispose();
    _urlSertifikatController.dispose();
    _urlFotoUppController.dispose();
    _urlDokumenUndanganController.dispose();
    _jumlahUnitPesertaController.dispose();
    _keteranganController.dispose();
    _anggotaMahasiswaController.dispose();
    _dosenSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.achievement != null;
    final isSimkatmawa = _selectedTipe == 'Prestasi Mandiri' || _selectedTipe == 'Sertifikasi';

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: BkuStaticAppBar(
        title: isEditing
            ? 'Edit Prestasi Mahasiswa'
            : (_selectedTipe == 'Pengajuan Dana' ? 'Pengajuan Dana Lomba' : 'Lapor Prestasi Baru'),
        subtitle: 'Daftarkan capaian perlombaan, sertifikasi, atau permohonan dana lomba',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepCard(
                stepNumber: '1',
                title: 'Tipe & Informasi Utama Pengajuan',
                subtitle: 'Pilih kategori laporan prestasi dan isi nama kegiatan yang diikuti',
                children: [
                  _buildUppercaseLabel('Tipe Pengajuan', required: true),
                  _buildDropdown(
                    items: _tipeLabels.keys.toList(),
                    itemLabels: _tipeLabels,
                    value: _selectedTipe,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTipe = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildUppercaseLabel('Terkait Organisasi Mahasiswa (Opsional)'),
                  _buildOrgDropdown(),
                  const SizedBox(height: AppSpacing.md),

                  _buildUppercaseLabel(
                    _selectedTipe == 'Sertifikasi'
                        ? 'Nama Sertifikasi'
                        : _selectedTipe == 'Rekognisi'
                            ? 'Nama Rekognisi'
                            : 'Nama Lomba / Kegiatan',
                    required: true,
                  ),
                  BkuTextField(
                    controller: _titleController,
                    hint: _selectedTipe == 'Sertifikasi'
                        ? 'Contoh: Sertifikat Kompetensi BNSP Web Developer'
                        : 'Contoh: Gemastik XV 2026',
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama kegiatan wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (_selectedTipe == 'Prestasi Mandiri') ...[
                    _buildUppercaseLabel('Kategori Prestasi', required: true),
                    _buildDropdown(
                      items: _kategoriLabels.keys.toList(),
                      itemLabels: _kategoriLabels,
                      value: _selectedKategori,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedKategori = val);
                      },
                    ),
                  ] else if (_selectedTipe == 'Rekognisi') ...[
                    _buildUppercaseLabel('Jenis Rekognisi', required: true),
                    _buildDropdown(
                      items: _rekognisiLabels.keys.toList(),
                      itemLabels: _rekognisiLabels,
                      value: _selectedJenisRekognisi,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedJenisRekognisi = val);
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildStepCard(
                stepNumber: '2',
                title: 'Tingkat & Hasil Capaian',
                subtitle: 'Skop pelaksanaan kejuaraan, instansi penyelenggara, dan hasil yang diraih',
                children: [
                  _buildUppercaseLabel('Tingkat Pelaksanaan', required: true),
                  _buildDropdown(
                    items: _tingkatLabels.keys.toList(),
                    itemLabels: _tingkatLabels,
                    value: _selectedTingkat,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTingkat = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildUppercaseLabel('Penyelenggara', required: true),
                  BkuTextField(
                    controller: _organizerController,
                    hint: 'Contoh: Kemendikbudristek / Pusprestnas / Universitas X',
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Penyelenggara wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildUppercaseLabel('Tanggal Pelaksanaan', required: true),
                  _buildDatePicker(),
                  const SizedBox(height: AppSpacing.md),

                  if (_selectedTipe == 'Prestasi Mandiri') ...[
                    _buildUppercaseLabel('Peringkat Diraih', required: true),
                    _buildDropdown(
                      items: _peringkatLabels.keys.toList(),
                      itemLabels: _peringkatLabels,
                      value: _selectedPeringkat,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPeringkat = val);
                      },
                    ),
                  ] else if (_selectedTipe == 'Pengajuan Dana') ...[
                    _buildUppercaseLabel('Dana yang Diajukan (Rp)', required: true),
                    BkuTextField(
                      controller: _danaDiajukanController,
                      hint: 'Contoh: 1500000',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (_selectedTipe == 'Pengajuan Dana' && (val == null || val.trim().isEmpty)) {
                          return 'Dana diajukan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildUppercaseLabel('Keterangan Kebutuhan Dana'),
                    BkuTextField(
                      controller: _keteranganController,
                      hint: 'Jelaskan estimasi rincian biaya pendaftaran, akomodasi, dll.',
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              if (isSimkatmawa) ...[
                _buildStepCard(
                  stepNumber: '3',
                  title: 'Informasi Tambahan SIMKATMAWA',
                  subtitle: 'Metadata pendukung untuk pelaporan SIMKATMAWA Belmawa Diktiristek',
                  badgeColor: BkuTheme.amber,
                  badgeBg: BkuTheme.amberSoft,
                  children: [
                    _buildLabel('Cabang Lomba'),
                    BkuTextField(
                      controller: _cabangController,
                      hint: 'Contoh: Lomba Esai / Mobile App Development',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('Kepesertaan'),
                    _buildDropdown(
                      items: const ['INDIVIDU', 'KELOMPOK'],
                      itemLabels: const {'INDIVIDU': 'Individu', 'KELOMPOK': 'Kelompok / Tim'},
                      value: _selectedKelompokPrestasi,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedKelompokPrestasi = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('Bentuk Kompetisi'),
                    _buildDropdown(
                      items: const ['LURING', 'DARING'],
                      itemLabels: const {'LURING': 'Luring (Tatap Muka)', 'DARING': 'Daring (Online)'},
                      value: _selectedBentuk,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBentuk = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('URL Web Kompetisi'),
                    BkuTextField(
                      controller: _urlPesertaController,
                      hint: 'https://...',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('URL Dokumen Sertifikat Online'),
                    BkuTextField(
                      controller: _urlSertifikatController,
                      hint: 'https://...',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('URL Foto Serah Terima / Podium'),
                    BkuTextField(
                      controller: _urlFotoUppController,
                      hint: 'https://...',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('URL Surat Undangan'),
                    BkuTextField(
                      controller: _urlDokumenUndanganController,
                      hint: 'https://...',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('Jumlah Perguruan Tinggi / Negara Peserta'),
                    BkuTextField(
                      controller: _jumlahUnitPesertaController,
                      hint: 'Contoh: 15',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('Keterangan Catatan Tambahan'),
                    BkuTextField(
                      controller: _keteranganController,
                      hint: 'Keterangan pendukung...',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildLabel('ID Mahasiswa Anggota Tim (Pisahkan koma)'),
                    BkuTextField(
                      controller: _anggotaMahasiswaController,
                      hint: 'Contoh: 101, 102, 103',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildUppercaseLabel('Dosen Pembimbing Lomba / Kegiatan', optionalText: '(Pilih dari direktori akademik)'),
                    _buildDosenInlineSelector(),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              _buildStepCard(
                stepNumber: isSimkatmawa ? '4' : '3',
                title: 'Upload File Sertifikat & Dokumen Pendukung',
                subtitle: 'Unggah berkas bukti keabsahan prestasi dalam format PDF, JPG, atau PNG (Maks. 5MB)',
                children: [
                  _buildUppercaseLabel(
                    _selectedTipe == 'Pengajuan Dana' ? 'Upload Proposal / Dokumen Pendukung' : 'Upload Sertifikat / Bukti Prestasi',
                    required: !isEditing,
                  ),
                  _buildUploadBox(
                    fileName: _selectedBuktiName,
                    hasExistingFile: widget.achievement?.certificateUrl != null && widget.achievement!.certificateUrl!.isNotEmpty,
                    hint: 'Pilih Berkas Bukti Prestasi',
                    subHint: 'PDF, JPG, PNG (Maks. 5MB)',
                    isBlue: false,
                    existingUrl: widget.achievement?.certificateUrl,
                    onTap: () => _pickFile(isSuratTugas: false),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildUppercaseLabel(
                    'Upload Surat Tugas Dosen Pembimbing',
                    optionalText: '(SK / Surat Tugas)',
                  ),
                  _buildUploadBox(
                    fileName: _selectedSuratTugasName,
                    hasExistingFile: widget.achievement?.urlDokumenUndangan != null && widget.achievement!.urlDokumenUndangan!.isNotEmpty,
                    hint: 'Pilih Surat Tugas Pembimbing',
                    subHint: 'PDF, JPG, PNG (Maks. 5MB)',
                    isBlue: true,
                    existingUrl: widget.achievement?.urlDokumenUndangan,
                    onTap: () => _pickFile(isSuratTugas: true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildGuidanceCard(),
              const SizedBox(height: AppSpacing.lg),

              _buildTermsCard(),
              const SizedBox(height: AppSpacing.xl),

              _buildBottomActionButtons(isEditing),
              const SizedBox(height: AppSpacing.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required List<Widget> children,
    Color? badgeColor,
    Color? badgeBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeBg ?? BkuTheme.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      color: badgeColor ?? BkuTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: BkuTheme.textCardSubtitle.copyWith(
                        fontSize: 11,
                        color: BkuTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: BkuTheme.borderSubtle),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUppercaseLabel(String text, {bool required = false, String? optionalText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontSize: 12,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
              ),
            if (optionalText != null)
              TextSpan(
                text: ' $optionalText',
                style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.normal, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: RichText(
        text: TextSpan(
          text: text,
          style: BkuTheme.textCardSubtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: BkuTheme.textHeading,
            fontSize: 12,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: BkuTheme.rose, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: BkuTheme.scaffoldBg,
        borderRadius: BkuTheme.r12,
        border: Border.all(color: BkuTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedOrgId.isNotEmpty ? _selectedOrgId : null,
          hint: Text(
            '-- Tidak Terkait Organisasi --',
            style: BkuTheme.textCardSubtitle.copyWith(fontSize: 13),
          ),
          items: [
            DropdownMenuItem<String>(
              value: '',
              child: Text('-- Tidak Terkait Organisasi --', style: BkuTheme.textBodyRegular.copyWith(fontSize: 13)),
            ),
            ..._orgList.map((org) {
              final orgId = (org['id'] ?? org['ID'] ?? '').toString();
              final orgName = org['nama_organisasi'] ?? org['NamaOrganisasi'] ?? org['nama'] ?? 'Organisasi';
              final orgType = org['tipe'] ?? org['Tipe'] ?? 'ORM';
              return DropdownMenuItem<String>(
                value: orgId,
                child: Text(
                  '$orgName ($orgType)',
                  style: BkuTheme.textBodyRegular.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (val) {
            setState(() => _selectedOrgId = val ?? '');
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required Map<String, String> itemLabels,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return BkuDropdown<String>(
      value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
      items: items.map((val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(
            itemLabels[val] ?? val,
            style: BkuTheme.textBodyRegular.copyWith(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2015),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      borderRadius: BkuTheme.r12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
        decoration: BoxDecoration(
          color: BkuTheme.scaffoldBg,
          borderRadius: BkuTheme.r12,
          border: Border.all(color: BkuTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
              style: BkuTheme.textBodyRegular.copyWith(fontSize: 13),
            ),
            const Icon(Icons.calendar_today_rounded, color: BkuTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDosenInlineSelector() {
    final filtered = _dosenOptions.where((d) {
      final name = (d['nama'] ?? d['Nama'] ?? '').toString().toLowerCase();
      final nidn = (d['nidn'] ?? d['NIDN'] ?? '').toString().toLowerCase();
      final prodi = (d['ProgramStudi']?['nama'] ?? '').toString().toLowerCase();
      final q = _dosenSearchQuery.toLowerCase();
      return name.contains(q) || nidn.contains(q) || prodi.contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOSEN PEMBIMBING TERPILIH (${_selectedDosenList.length})',
            style: BkuTheme.textCaption.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BkuTheme.scaffoldBg,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.borderSubtle),
            ),
            child: _selectedDosenList.isEmpty
                ? Text(
                    'Belum ada dosen pembimbing yang dipilih. Centang nama dosen di bawah...',
                    style: BkuTheme.textCardSubtitle.copyWith(fontSize: 11.5, color: BkuTheme.textPlaceholder),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _selectedDosenList.map((d) {
                      final name = d['nama_dosen'] ?? d['nama'] ?? d['Nama'] ?? '';
                      final nidn = d['nidn'] ?? d['NIDN'] ?? '';
                      return Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 70),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: BkuTheme.amberSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BkuTheme.amberBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: BkuTheme.textBadge.copyWith(
                                  color: BkuTheme.amber,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (nidn.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text('($nidn)', style: BkuTheme.textCaption.copyWith(fontSize: 9.5)),
                            ],
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDosenList.remove(d);
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14, color: BkuTheme.amber),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),

          InkWell(
            onTap: () => setState(() => _isDosenListOpen = !_isDosenListOpen),
            borderRadius: BkuTheme.r12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: BkuTheme.scaffoldBg,
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_search_rounded, color: BkuTheme.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _isDosenListOpen ? 'Sembunyikan Daftar Dosen' : 'Tampilkan / Cari Daftar Dosen',
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: BkuTheme.cardSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BkuTheme.borderSubtle),
                    ),
                    child: Text(
                      '${_dosenOptions.length} Dosen',
                      style: BkuTheme.textCaption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isDosenListOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: BkuTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          if (_isDosenListOpen) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _dosenSearchController,
              onChanged: (val) => setState(() => _dosenSearchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama dosen, NIDN, atau prodi...',
                hintStyle: BkuTheme.textCardSubtitle.copyWith(fontSize: 12, color: BkuTheme.textPlaceholder),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true,
                fillColor: BkuTheme.scaffoldBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BkuTheme.r12,
                  borderSide: const BorderSide(color: BkuTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: BkuTheme.scaffoldBg,
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.borderSubtle),
              ),
              child: _isLoadingInitial
                  ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Dosen tidak ditemukan', style: BkuTheme.textCardSubtitle),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: BkuTheme.borderSubtle),
                          itemBuilder: (_, index) {
                            final d = filtered[index];
                            final dId = (d['id'] ?? d['ID'] ?? '').toString();
                            final name = d['nama'] ?? d['Nama'] ?? '';
                            final nidn = d['nidn'] ?? d['NIDN'] ?? '';
                            final prodi = d['ProgramStudi'] != null ? (d['ProgramStudi']['nama'] ?? '') : '';

                            final isSelected = _selectedDosenList.any((x) => (x['dosen_id'] ?? x['id'] ?? x['ID'] ?? '').toString() == dId);

                            return CheckboxListTile(
                              value: isSelected,
                              activeColor: BkuTheme.amber,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(name, style: BkuTheme.textCardTitle.copyWith(fontSize: 12)),
                              subtitle: Text(
                                [if (nidn.isNotEmpty) 'NIDN: $nidn', if (prodi.isNotEmpty) prodi].join(' • '),
                                style: BkuTheme.textCaption.copyWith(fontSize: 10),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedDosenList.add({
                                      'dosen_id': dId,
                                      'id': dId,
                                      'nama_dosen': name,
                                      'nama': name,
                                      'nidn': nidn,
                                    });
                                  } else {
                                    _selectedDosenList.removeWhere((x) => (x['dosen_id'] ?? x['id'] ?? x['ID'] ?? '').toString() == dId);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required String? fileName,
    required bool hasExistingFile,
    required String hint,
    required String subHint,
    required bool isBlue,
    required VoidCallback onTap,
    String? existingUrl,
  }) {
    final bool hasNewFile = fileName != null;
    final bool hasAnyFile = hasNewFile || hasExistingFile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: hasAnyFile ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAnyFile ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasAnyFile ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasAnyFile
                    ? Icons.check_circle_rounded
                    : (isBlue ? Icons.description_rounded : Icons.cloud_upload_rounded),
                size: 26,
                color: hasAnyFile ? const Color(0xFF16A34A) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName ?? (hasExistingFile ? 'Berkas sudah terunggah di server' : hint),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: hasAnyFile ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasAnyFile ? 'Ketuk untuk mengganti berkas lampiran' : subHint,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            if (hasExistingFile && !hasNewFile && existingUrl != null && existingUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(existingUrl);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  'Lihat Berkas Server Saat Ini',
                  style: TextStyle(
                    color: Color(0xFF0284C7),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile({required bool isSuratTugas}) async {
    FocusScope.of(context).unfocus();

    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: isSuratTugas ? 'Pilih Surat Tugas Pembimbing' : 'Pilih Sertifikat / Bukti Prestasi',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF475569), size: 20),
            ),
            title: const Text(
              'Ambil Foto Kamera',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickCamera(isSuratTugas: isSuratTugas);
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_rounded, color: Color(0xFF475569), size: 20),
            ),
            title: const Text(
              'Pilih Berkas / PDF / Gambar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickFiles(isSuratTugas: isSuratTugas);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _pickCamera({required bool isSuratTugas}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (isSuratTugas) {
            _selectedSuratTugasPath = image.path;
            _selectedSuratTugasName = image.name;
          } else {
            _selectedBuktiPath = image.path;
            _selectedBuktiName = image.name;
          }
        });
      }
    } catch (e) {
      log('Error picking camera: $e');
    }
  }

  Future<void> _pickFiles({required bool isSuratTugas}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        withReadStream: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isSuratTugas) {
            _selectedSuratTugasPath = result.files.single.path;
            _selectedSuratTugasName = result.files.single.name;
          } else {
            _selectedBuktiPath = result.files.single.path;
            _selectedBuktiName = result.files.single.name;
          }
        });
      }
    } catch (e) {
      log('Error picking file: $e');
    }
  }

  Widget _buildGuidanceCard() {
    final steps = [
      {'title': 'Isi Formulir Lengkap', 'desc': 'Pilih tipe pengajuan (Prestasi Mandiri, Rekognisi, Sertifikasi, atau Pengajuan Dana).'},
      {'title': 'Review Kemahasiswaan', 'desc': 'Tim verifikator akan memvalidasi keabsahan dokumen dan bukti prestasi.'},
      {'title': 'Sinkronisasi SIMKATMAWA', 'desc': 'Prestasi yang telah disetujui akan otomatis dicatat dalam portofolio dan SKPI mahasiswa.'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline_rounded, color: BkuTheme.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PANDUAN',
                    style: BkuTheme.textCaption.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
                  ),
                  Text(
                    'Alur Verifikasi Prestasi',
                    style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20, color: BkuTheme.borderSubtle),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: BkuTheme.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: TextStyle(
                          color: BkuTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item['desc']!,
                          style: BkuTheme.textCaption.copyWith(fontSize: 10.5, color: BkuTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feed_outlined, color: BkuTheme.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'KETENTUAN BERKAS LAMPIRAN',
                style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Divider(height: 20, color: BkuTheme.borderSubtle),
          _buildTermItem('Format berkas: PDF, JPG, PNG dengan ukuran maksimal 5 MB.'),
          const SizedBox(height: 8),
          _buildTermItem('Pastikan sertifikat memuat nama Anda dan tanda tangan/stempel penyelenggara resmi.'),
          const SizedBox(height: 8),
          _buildTermItem('Surat tugas pembimbing bersifat opsional namun dianjurkan untuk sinkronisasi SIMKATMAWA.'),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: BkuTheme.emerald, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: BkuTheme.textCaption.copyWith(fontSize: 11, color: BkuTheme.textHeading, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: BkuTheme.border),
                shape: RoundedRectangleBorder(borderRadius: BkuTheme.r12),
              ),
              child: Text(
                'Batal',
                style: BkuTheme.textButton.copyWith(color: BkuTheme.textMuted, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: BkuButton(
              onPressed: _handleSubmit,
              variant: BkuButtonVariant.primary,
              text: isEditing
                  ? 'Simpan Perubahan'
                  : (_selectedTipe == 'Pengajuan Dana' ? 'Kirim Pengajuan Dana' : 'Kirim Laporan Prestasi'),
              icon: isEditing ? Icons.save_rounded : Icons.send_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isEditing = widget.achievement != null;

    if (!isEditing && (_selectedBuktiPath == null || _selectedBuktiPath!.isEmpty)) {
      await BkuDialog.show(
        context: context,
        type: BkuDialogType.warning,
        title: 'Berkas Wajib Diunggah',
        message: 'Silakan pilih berkas sertifikat / bukti keabsahan prestasi terlebih dahulu.',
        primaryButtonText: 'OK',
        onPrimaryPressed: () => context.pop(),
      );
      return;
    }

    List<int>? anggotaPayload;
    if (_anggotaMahasiswaController.text.trim().isNotEmpty) {
      anggotaPayload = _anggotaMahasiswaController.text
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
    }

    final achievementObj = Achievement(
      id: isEditing ? widget.achievement!.id : '',
      title: _titleController.text.trim(),
      organizer: _organizerController.text.trim(),
      level: _selectedTingkat,
      rank: _selectedPeringkat,
      date: _selectedDate,
      status: isEditing ? widget.achievement!.status : 'Menunggu',
      isSynced: isEditing ? widget.achievement!.isSynced : false,
      certificateUrl: isEditing ? widget.achievement!.certificateUrl : null,
      filePath: _selectedBuktiPath,
      suratTugasPath: _selectedSuratTugasPath,
      kategori: _selectedKategori,
      tipe: _selectedTipe,
      danaDiajukan: _selectedTipe == 'Pengajuan Dana' ? _danaDiajukanController.text.trim() : '0',
      cabang: _cabangController.text.trim(),
      jumlahUnitPeserta: _jumlahUnitPesertaController.text.trim(),
      kelompokPrestasi: _selectedKelompokPrestasi,
      bentuk: _selectedBentuk,
      urlPeserta: _urlPesertaController.text.trim(),
      urlFotoUpp: _urlFotoUppController.text.trim(),
      urlDokumenUndangan: _urlDokumenUndanganController.text.trim(),
      jenisRekognisi: _selectedJenisRekognisi,
      keterangan: _keteranganController.text.trim(),
      pembimbingDosen: _selectedDosenList.isNotEmpty ? _selectedDosenList : null,
      anggotaMahasiswa: anggotaPayload,
    );

    try {
      BkuLoadingDialog.show(context);

      if (isEditing) {
        await context.read<AcademicProvider>().updateAchievement(
              widget.achievement!.id,
              achievementObj,
            );
      } else {
        await context.read<AcademicProvider>().addAchievement(
              achievementObj,
            );
      }

      if (mounted) BkuLoadingDialog.hide(context);
      if (!mounted) return;

      await BkuDialog.show(
        context: context,
        type: BkuDialogType.success,
        title: isEditing ? 'Prestasi Diperbarui' : 'Prestasi Berhasil Diajukan',
        message: isEditing
            ? 'Perubahan data laporan prestasi berhasil disimpan.'
            : 'Laporan prestasi berhasil dikirim dan masuk antrean verifikasi Admin Kemahasiswaan.',
        primaryButtonText: 'Kembali ke Daftar Prestasi',
        onPrimaryPressed: () {
          context.pop();
          context.pop();
        },
      );
    } catch (e) {
      if (mounted) BkuLoadingDialog.hide(context);
      if (!mounted) return;

      await BkuDialog.show(
        context: context,
        type: BkuDialogType.error,
        title: 'Gagal Menyimpan Prestasi',
        message: ErrorHandler.getMessage(e),
        primaryButtonText: 'Tutup',
        onPrimaryPressed: () => context.pop(),
      );
    }
  }
}
