import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';

class SessionNoteScreen extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String? bookingId;
  final int? sessionNumber;

  const SessionNoteScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    this.bookingId,
    this.sessionNumber,
  });

  @override
  State<SessionNoteScreen> createState() => _SessionNoteScreenState();
}

class _SessionNoteScreenState extends State<SessionNoteScreen> {
  final _tujuanCtrl = TextEditingController();
  final _riwayatKeluhanCtrl = TextEditingController();
  final _aspekKognitifCtrl = TextEditingController();
  final _aspekEmosionalCtrl = TextEditingController();
  final _aspekPerilakuCtrl = TextEditingController();
  final _rekMahasiswaCtrl = TextEditingController();
  final _rekProdiCtrl = TextEditingController();
  final _rekOrangTuaCtrl = TextEditingController();
  final _kesimpulanCtrl = TextEditingController();

  final _rujukanPihakCtrl = TextEditingController();
  final _rujukanEmailCtrl = TextEditingController();

  DateTime _tanggalAsesmen = DateTime.now();
  String _selectedMood = 'Stabil';
  String _rujukanTipe = 'Medis';

  bool? _tindakLanjutTuntas;
  bool? _tindakLanjutLanjutan;
  bool? _tindakLanjutRujuk;

  bool _isSaving = false;

  final List<String> _moods = [
    'Stabil',
    'Cemas',
    'Depresi',
    'Netral',
    'Membaik',
  ];

  @override
  void dispose() {
    _tujuanCtrl.dispose();
    _riwayatKeluhanCtrl.dispose();
    _aspekKognitifCtrl.dispose();
    _aspekEmosionalCtrl.dispose();
    _aspekPerilakuCtrl.dispose();
    _rekMahasiswaCtrl.dispose();
    _rekProdiCtrl.dispose();
    _rekOrangTuaCtrl.dispose();
    _kesimpulanCtrl.dispose();
    _rujukanPihakCtrl.dispose();
    _rujukanEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAsesmen,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggalAsesmen = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Catatan Sesi',
            info: 'Electronic Health Record',
            variant: AppBarVariant.psychologist,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfidentialBanner(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStudentInfo(),
                  const SizedBox(height: AppSpacing.xl),

                  // I. Informasi Asesmen
                  _buildSectionHeader('I. Informasi Asesmen'),
                  _buildInput(
                    'Tujuan Pemeriksaan',
                    'Misal: Evaluasi Layanan Konseling Akademik',
                    _tujuanCtrl,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Asesmen',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: AppRadius.radiusLg,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_tanggalAsesmen),
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildInput(
                    'Riwayat Keluhan',
                    'Deskripsikan riwayat keluhan pasien...',
                    _riwayatKeluhanCtrl,
                    lines: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInput(
                    'Aspek Kognitif',
                    'Observasi aspek kognitif...',
                    _aspekKognitifCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInput(
                    'Aspek Emosional',
                    'Observasi aspek emosional...',
                    _aspekEmosionalCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInput(
                    'Aspek Perilaku',
                    'Observasi aspek perilaku...',
                    _aspekPerilakuCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // II. Rekomendasi Layanan
                  _buildSectionHeader('II. Rekomendasi Layanan'),
                  _buildInput(
                    'Rekomendasi Mahasiswa',
                    'Rekomendasi bagi mahasiswa...',
                    _rekMahasiswaCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInput(
                    'Rekomendasi Program Studi',
                    'Rekomendasi bagi Prodi...',
                    _rekProdiCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInput(
                    'Rekomendasi Orang Tua/Wali',
                    'Rekomendasi bagi Orang tua...',
                    _rekOrangTuaCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // III. Tindak Lanjut & Kesimpulan
                  _buildSectionHeader('III. Tindak Lanjut & Kesimpulan'),

                  _buildYesNoToggle(
                    '1. Sesi Tuntas *',
                    _tindakLanjutTuntas,
                    (val) => setState(() => _tindakLanjutTuntas = val),
                  ),
                  if (_tindakLanjutTuntas == true)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
                      child: Text(
                        '⚠️ Booking akan dikunci setelah disimpan',
                        style: AppTextStyles.caption.copyWith(
                          color: context.watch<ThemeProvider>().primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildYesNoToggle(
                    '2. Konseling Lanjutan',
                    _tindakLanjutLanjutan,
                    (val) => setState(() => _tindakLanjutLanjutan = val),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildYesNoToggle(
                    '3. Rujuk Klinis',
                    _tindakLanjutRujuk,
                    (val) => setState(() => _tindakLanjutRujuk = val),
                  ),
                  if (_tindakLanjutRujuk == true)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
                      child: Text(
                        '→ Surat rujukan otomatis dibuat & dikirim ke Referral',
                        style: AppTextStyles.caption.copyWith(
                          color: context.appColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  if (_tindakLanjutRujuk == true) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(10),
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: Column(
                        children: [
                          _buildDropdown(
                            'Tipe Rujukan',
                            ['Medis', 'Akademik'],
                            _rujukanTipe,
                            (v) => setState(() => _rujukanTipe = v!),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildInput(
                            'Pihak / Instansi Tujuan',
                            'Misal: RS Pusat, Dekan FT',
                            _rujukanPihakCtrl,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildInput(
                            'Email Tujuan',
                            'email@tujuan.com',
                            _rujukanEmailCtrl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  _buildInput(
                    'Kesimpulan',
                    'Tulis kesimpulan umum asesmen konseling...',
                    _kesimpulanCtrl,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildDropdown(
                    'Status Mood / Kondisi Emosional Saat Sesi',
                    _moods,
                    _selectedMood,
                    (v) => setState(() => _selectedMood = v!),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  _buildSaveButton(),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMd.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildConfidentialBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(10),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.error.withAlpha(30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'DOKUMEN RAHASIA: Catatan ini hanya dapat diakses oleh Psikolog yang berwenang.',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    final sessionNum = widget.sessionNumber ?? '?';
    final today = DateTime.now();
    final dateStr =
        '${today.day.toString().padLeft(2, '0')} '
        '${_monthName(today.month)} ${today.year}';

    return BkuCard(
      backgroundColor: AppColors.neutral100,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, color: context.appColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'NIM: ${widget.studentId}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Sesi #$sessionNum',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateStr,
                style: AppTextStyles.labelSm.copyWith(
                   color: context.appColors.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    TextEditingController ctrl, {
    int lines = 1,
  }) {
    return BkuTextField(
      label: label,
      hint: hint,
      controller: ctrl,
      maxLines: lines,
    );
  }

  Widget _buildYesNoToggle(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: value == true ? primaryColor : AppColors.neutral100,
                    borderRadius: AppRadius.radiusLg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Ya',
                    style: AppTextStyles.labelLg.copyWith(
                      color:
                          value == true ? context.appColors.onPrimary : AppColors.neutral700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        value == false ? AppColors.error : AppColors.neutral100,
                    borderRadius: AppRadius.radiusLg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Tidak',
                    style: AppTextStyles.labelLg.copyWith(
                      color:
                          value == false ? context.appColors.onPrimary : AppColors.neutral700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusLg,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              items:
                  items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BkuButton(
      text: 'Simpan Catatan Asesmen',
      onPressed: _submit,
      isLoading: _isSaving,
      icon: Icons.save_rounded,
      variant: BkuButtonVariant.success,
      height: 48,
    );
  }

  Future<void> _submit() async {
    if (_riwayatKeluhanCtrl.text.trim().isEmpty) {
      AppSnackbar.showWarning(context, 'Riwayat keluhan wajib diisi');
      return;
    }
    if (_tindakLanjutTuntas == null) {
      AppSnackbar.showError(
        context,
        'Harap pilih status Sesi Tuntas (Ya/Tidak)',
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<CounselingProvider>();

    final combinedObservation =
        'Kognitif: ${_aspekKognitifCtrl.text}\nEmosional: ${_aspekEmosionalCtrl.text}\nPerilaku: ${_aspekPerilakuCtrl.text}';
    final combinedRecommendation =
        'Mhs: ${_rekMahasiswaCtrl.text}\nProdi: ${_rekProdiCtrl.text}\nOrangTua: ${_rekOrangTuaCtrl.text}';

    final data = {
      'tujuan_pemeriksaan': _tujuanCtrl.text.trim(),
      'tanggal_asesmen': DateFormat('yyyy-MM-dd').format(_tanggalAsesmen),
      'riwayat_keluhan': _riwayatKeluhanCtrl.text.trim(),
      'aspek_kognitif': _aspekKognitifCtrl.text.trim(),
      'aspek_emosional': _aspekEmosionalCtrl.text.trim(),
      'aspek_perilaku': _aspekPerilakuCtrl.text.trim(),
      'rekomendasi_mahasiswa': _rekMahasiswaCtrl.text.trim(),
      'rekomendasi_prodi': _rekProdiCtrl.text.trim(),
      'rekomendasi_orang_tua': _rekOrangTuaCtrl.text.trim(),
      'tindak_lanjut_tuntas': _tindakLanjutTuntas,
      'tindak_lanjut_lanjutan': _tindakLanjutLanjutan ?? false,
      'tindak_lanjut_rujuk': _tindakLanjutRujuk ?? false,
      'kesimpulan': _kesimpulanCtrl.text.trim(),
      'rujukan_tipe': _rujukanTipe,
      'rujukan_pihak_tujuan': _rujukanPihakCtrl.text.trim(),
      'rujukan_email_tujuan': _rujukanEmailCtrl.text.trim(),
      'mood': _selectedMood,
      'type': 'Konseling Baru',
      'status': 'Selesai',

      // Compatibility fields for backend mapping logic
      'complaint': _riwayatKeluhanCtrl.text.trim(),
      'observation': combinedObservation,
      'recommendation': combinedRecommendation,

      if (widget.bookingId != null && widget.bookingId!.isNotEmpty)
        'booking_id': int.tryParse(widget.bookingId!) ?? 0,
    };

    final success = await provider.createSessionNote(widget.studentId, data);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Catatan sesi berhasil disimpan!');
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan catatan. Coba lagi.');
      }
      if (success) {
        provider.loadMedicalRecord(widget.studentId);
        provider.loadBookings(silent: true);
        context.read<PsychologistDashboardProvider>().loadDashboardData(
          silent: true,
        );
        Navigator.pop(context);
      }
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
