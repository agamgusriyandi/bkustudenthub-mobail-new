import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/widgets/icd10_search_delegate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkScreeningInputScreen extends StatefulWidget {
  final int? patientId;

  const TkScreeningInputScreen({super.key, this.patientId});

  @override
  State<TkScreeningInputScreen> createState() => _TkScreeningInputScreenState();
}

class _TkScreeningInputScreenState extends State<TkScreeningInputScreen> {
  late final PageController _pageController;
  late int _currentStep;

  // Form Controllers
  final _searchController = TextEditingController();

  // Controllers for Vitals
  late final TextEditingController _tinggiController;
  late final TextEditingController _beratController;
  late final TextEditingController _gulaController;
  late final TextEditingController _sistoleController;
  late final TextEditingController _diastoleController;
  late final TextEditingController _suhuController;
  late final TextEditingController _nadiController;
  late final TextEditingController _rrController;
  late final TextEditingController _spo2Controller;

  // Step 2: Vital Signs
  DateTime _tanggalScreening = DateTime.now();
  String _jenisPemeriksaan = 'Pemeriksaan Reguler';
  String _sumberPemeriksaan = 'Klinik Kampus';
  double _tinggiBadan = 170;
  double _beratBadan = 60;
  int _gulaDarah = 90;
  String _golonganDarah = 'O';
  String _tesButaWarna = 'Normal';
  int _sistole = 120;
  int _diastole = 80;
  double _suhuTubuh = 36.5;
  int _denyutNadi = 80;
  int _respirationRate = 20;
  int _spO2 = 98;

  @override
  void initState() {
    super.initState();
    _currentStep = 0;
    _pageController = PageController(initialPage: _currentStep);

    _tinggiController = TextEditingController(
      text: _tinggiBadan.toStringAsFixed(0),
    );
    _beratController = TextEditingController(
      text: _beratBadan.toStringAsFixed(0),
    );
    _gulaController = TextEditingController(text: _gulaDarah.toString());
    _sistoleController = TextEditingController(text: _sistole.toString());
    _diastoleController = TextEditingController(text: _diastole.toString());
    _suhuController = TextEditingController(text: _suhuTubuh.toString());
    _nadiController = TextEditingController(text: _denyutNadi.toString());
    _rrController = TextEditingController(text: _respirationRate.toString());
    _spo2Controller = TextEditingController(text: _spO2.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.patientId != null) {
        final provider = context.read<TkPatientProvider>();
        if (provider.selectedPatient != null &&
            provider.selectedPatient!.id == widget.patientId) {
          // Patient already selected, do nothing
        } else {
          final idx = provider.patients.indexWhere(
            (p) => p.id == widget.patientId,
          );
          if (idx != -1) {
            provider.selectPatient(provider.patients[idx]);
          } else {
            provider.loadPatientMedicalRecord(widget.patientId!);
          }
        }
      }
    });
  }

  // Step 3: Subjective
  String _keluhan = '';
  int _skalaNyeri = 0;
  String _riwayatPenyakit = '';
  String _alergiObat = '';
  String _konsumsiObatTerkini = '';
  String _kondisiPsikologis = 'Normal';

  // Step 4: Actions
  String _tindakanDiberikan = '';
  String _obatDiberikan = '';
  String _catatan = '';
  String _rekomendasi = '';
  bool _eskalasiPsikolog = false;
  bool _eskalasiFaskes = false;

  // Step 5: Status
  String _hasil = 'Layak Kegiatan';

  String _faskesTujuan = 'Klinik UBK';
  String _faskesTujuanLainnya = '';
  String _alasanRujukan = 'Penanganan Lanjutan';
  String _alasanRujukanLainnya = '';
  String _keluhanUtamaRujukan = '';
  String _diagnosisSementara = '';
  String _rekomendasiAsuransi = 'BKU_Assurance';

  bool _isSaving = false;

  // Psikolog Referral State
  int? _selectedPsikologId;
  int? _selectedPsikologSlotId;

  void _checkVitalsWarning() {
    if (_suhuTubuh > 38.0 || _spO2 < 92) {
      if (_hasil != 'Tidak Layak') {
        setState(() {
          _hasil = 'Tidak Layak';
        });
        AppSnackbar.showError(
          context,
          'Peringatan: Parameter vital kritis terdeteksi! Status otomatis diubah menjadi Tidak Layak.',
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _tinggiController.dispose();
    _beratController.dispose();
    _gulaController.dispose();
    _sistoleController.dispose();
    _diastoleController.dispose();
    _suhuController.dispose();
    _nadiController.dispose();
    _rrController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  double get _bmi {
    if (_tinggiBadan <= 0 || _beratBadan <= 0) return 0;
    final tinggiMeter = _tinggiBadan / 100;
    return _beratBadan / (tinggiMeter * tinggiMeter);
  }

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Kekurangan BB';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Kelebihan BB';
    return 'Obesitas';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TkPatientProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.neutral100,
          appBar: BkuStaticAppBar(
            title: 'Input Screening',
            variant: AppBarVariant.nakes,
            showBackButton: true,
            onBack: () {
              if (_currentStep > 0) {
                _goToPrevStep();
              } else {
                _showExitConfirmation();
              }
            },
          ),
          body:
              provider.isLoadingRecord &&
                      widget.patientId != null &&
                      provider.selectedPatient == null
                  ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  )
                  : Column(
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),

                      // Page Content
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentStep = index);
                          },
                          children: [
                            _buildPatientSelectionStep(provider),
                            _buildVitalSignsStep(),
                            _buildSubjectiveStep(),
                            _buildActionsStep(),
                            _buildStatusStep(),
                          ],
                        ),
                      ),

                      // Navigation Buttons
                      _buildNavigationButtons(provider),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
                  color: context.appColors.surface,
                  child: Row(
                    children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? context.appColors.success : AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? Icon(
                              Icons.check_rounded,
                              color: context.appColors.onPrimary,
                              size: 16,
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isActive
                              ? context.appColors.onPrimary
                              : AppColors.neutral500,
                              ),
                            ),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          isCompleted
                              ? context.appColors.success
                              : AppColors.neutral200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPatientSelectionStep(TkPatientProvider provider) {
    final selectedPatient = provider.selectedPatient;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (selectedPatient != null) ...[
          _buildSectionTitle('Pasien Terpilih'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: context.appColors.success.withAlpha(50), width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.appColors.success.withAlpha(20),
                  child: Text(
                    selectedPatient.initials,
                    style: TextStyle(
                      color: context.appColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPatient.nama,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${selectedPatient.nim} • ${selectedPatient.prodi}',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: context.appColors.error,
                  ),
                  onPressed: () {
                    provider.clearSelection();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        _buildSectionTitle('Identifikasi Pasien'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Cari pasien berdasarkan Nama atau NIM',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.lg),

        // QR Scan Button
        GestureDetector(
          onTap: () => context.push('/tk/qr-scan'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral200),
              boxShadow: [
                BoxShadow(
                  color: context.appColors.onSurface.withAlpha(5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withAlpha(26),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: context.appColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan QR Code',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Arahkan kamera ke kartu mahasiswa',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.neutral600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Divider with text
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.neutral200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'atau cari manual',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.neutral200)),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Search Field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ketik Nama atau NIM...',
            hintStyle: TextStyle(color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(
                color: context.appColors.success,
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500),
          ),
          onChanged: (value) async {
            if (value.length >= 3) {
              await context.read<TkPatientProvider>().searchPatients(value);
            }
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Consumer<TkPatientProvider>(
          builder: (context, provider, child) {
            if (provider.patients.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Pencarian',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...provider.patients.take(5).map((patient) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      onTap: () {
                        provider.selectPatient(patient);
                        _goToNextStep();
                      },
                      leading: Builder(
                        builder: (context) {
                          final String? foto = patient.fotoURL;
                          final bool hasFoto =
                              foto != null &&
                              foto.trim().isNotEmpty &&
                              foto.trim().toLowerCase() != 'null';

                          Widget initialsWidget = CircleAvatar(
                            backgroundColor: AppColors.neutral200,
                            child: Text(
                              patient.initials,
                              style: TextStyle(
                                color: AppColors.neutral700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );

                          if (!hasFoto) {
                            return initialsWidget;
                          }

                          return SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipOval(
                              child: CachedNetworkImage(imageUrl: 
                                ApiGate.getImageUrl(foto),
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return initialsWidget;
                                },
                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                              ),
                            ),
                          );
                        },
                      ),
                      title: Text(patient.nama),
                      subtitle: Text('${patient.nim} • ${patient.prodi}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                        side: BorderSide(color: AppColors.neutral200),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridInputCard({
    required String title,
    required Widget inputWidget,
    required IconData icon,
    required Color iconColor,
    String? unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: inputWidget),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    unit,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: context.appColors.primary, width: 2),
            ),
          ),
          items:
              items
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildVitalSignsStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSectionTitle('Info Pemeriksaan'),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Tanggal Screening',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                subtitle: Text(
                  '${_tanggalScreening.day}/${_tanggalScreening.month}/${_tanggalScreening.year}',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.neutral800,
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _tanggalScreening,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _tanggalScreening = date);
                },
              ),
              const Divider(height: 24, color: AppColors.neutral200),
              _buildDropdownField(
                'Jenis Pemeriksaan',
                _jenisPemeriksaan,
                [
                  'Pemeriksaan Reguler',
                  'Pemeriksaan Insidental',
                  'Tindak Lanjut',
                ],
                (v) => setState(() => _jenisPemeriksaan = v!),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDropdownField(
                'Sumber Pemeriksaan',
                _sumberPemeriksaan,
                ['Klinik Kampus', 'Luar Kampus', 'Rujukan'],
                (v) => setState(() => _sumberPemeriksaan = v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionTitle('Data Vital (BMI)'),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withAlpha(3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: TextStyle(fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color:
                      _bmiCategory == 'Normal'
                          ? context.appColors.success
                          : context.appColors.warning,
                  borderRadius: AppRadius.radiusXl,
                ),
                child: Text(
                  _bmiCategory,
                  style: TextStyle(
                    color: context.appColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionTitle('Pengukuran Fisik & Vital'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildGridInputCard(
              title: 'Tinggi Badan',
              icon: Icons.height_rounded,
              iconColor: AppColors.neutral600,
              unit: 'cm',
              inputWidget: TextField(
                controller: _tinggiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _tinggiBadan = double.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Berat Badan',
              icon: Icons.monitor_weight_outlined,
              iconColor: AppColors.neutral600,
              unit: 'kg',
              inputWidget: TextField(
                controller: _beratController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _beratBadan = double.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Sistolik',
              icon: Icons.favorite_rounded,
              iconColor: AppColors.neutral600,
              unit: 'mmHg',
              inputWidget: TextField(
                controller: _sistoleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _sistole = int.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Diastolik',
              icon: Icons.favorite_border_rounded,
              iconColor: AppColors.neutral600,
              unit: 'mmHg',
              inputWidget: TextField(
                controller: _diastoleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _diastole = int.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Suhu Tubuh',
              icon: Icons.thermostat_rounded,
              iconColor: AppColors.neutral600,
              unit: '°C',
              inputWidget: TextField(
                controller: _suhuController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _suhuTubuh = double.tryParse(v) ?? 0;
                    _checkVitalsWarning();
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Denyut Nadi',
              icon: Icons.monitor_heart_rounded,
              iconColor: AppColors.neutral600,
              unit: 'bpm',
              inputWidget: TextField(
                controller: _nadiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _denyutNadi = int.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'RR',
              icon: Icons.air_rounded,
              iconColor: AppColors.neutral600,
              unit: 'x/mnt',
              inputWidget: TextField(
                controller: _rrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _respirationRate = int.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'SpO2',
              icon: Icons.opacity_rounded,
              iconColor: context.appColors.info,
              unit: '%',
              inputWidget: TextField(
                controller: _spo2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _spO2 = int.tryParse(v) ?? 0;
                    _checkVitalsWarning();
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Gula Darah',
              icon: Icons.water_drop_rounded,
              iconColor: context.appColors.warning,
              unit: 'mg/dL',
              inputWidget: TextField(
                controller: _gulaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  setState(() {
                    _gulaDarah = int.tryParse(v) ?? 0;
                  });
                },
              ),
            ),
            _buildGridInputCard(
              title: 'Goldar',
              icon: Icons.bloodtype_rounded,
              iconColor: context.appColors.error,
              inputWidget: DropdownButton<String>(
                value: _golonganDarah,
                underline: const SizedBox(),
                isExpanded: true,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800,
                ),
                items:
                    ['A', 'B', 'AB', 'O'].map((e) {
                      return DropdownMenuItem<String>(value: e, child: Text(e));
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    _golonganDarah = v!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: context.appColors.info.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.visibility_rounded, color: context.appColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tes Buta Warna',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _tesButaWarna,
                      underline: const SizedBox(),
                      isExpanded: true,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral800,
                      ),
                      items:
                          [
                            'Normal',
                            'Buta Warna Parsial',
                            'Buta Warna Total',
                          ].map((e) {
                            return DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _tesButaWarna = v!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectiveStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSectionTitle('Data Subjektif'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Informasi dari keluhan pasien',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Keluhan
        _buildTextArea(
          'Keluhan Utama',
          _keluhan,
          (v) => _keluhan = v,
          hint: 'Ceritakan keluhan yang dirasakan...',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Skala Nyeri
        _buildSectionTitle('Skala Nyeri'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _skalaNyeri.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: context.appColors.success,
                onChanged: (v) => setState(() => _skalaNyeri = v.round()),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNyeriColor(_skalaNyeri),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Center(
                child: Text(
                  '$_skalaNyeri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Riwayat Penyakit
        _buildTextArea(
          'Riwayat Penyakit',
          _riwayatPenyakit,
          (v) => _riwayatPenyakit = v,
          hint: 'Asma, Diabetes, Jantung, dll',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Alergi Obat
        _buildTextArea(
          'Alergi Obat',
          _alergiObat,
          (v) => _alergiObat = v,
          hint: 'Daftar alergi obat jika ada',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Konsumsi Obat Terkini
        _buildTextArea(
          'Konsumsi Obat Terkini',
          _konsumsiObatTerkini,
          (v) => _konsumsiObatTerkini = v,
          hint: 'Obat rutin yang sedang dikonsumsi...',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Kondisi Psikologis
        _buildSectionTitle('Kondisi Psikologis'),
        const SizedBox(height: AppSpacing.s10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildPsychologicalCard(
              title: 'Normal',
              icon: Icons.sentiment_satisfied_alt_rounded,
              activeColor: context.appColors.success,
              activeBg: context.appColors.success.withAlpha(15),
              activeBorder: context.appColors.success.withAlpha(50),
            ),
            _buildPsychologicalCard(
              title: 'Cemas',
              icon: Icons.warning_amber_rounded,
              activeColor: context.appColors.warning,
              activeBg: context.appColors.warning.withAlpha(15),
              activeBorder: context.appColors.warning.withAlpha(50),
            ),
            _buildPsychologicalCard(
              title: 'Stres',
              icon: Icons.error_outline_rounded,
              activeColor: context.appColors.warning,
              activeBg: context.appColors.warning.withAlpha(15),
              activeBorder: context.appColors.warning.withAlpha(50),
            ),
            _buildPsychologicalCard(
              title: 'Perlu Rujukan Psikolog',
              icon: Icons.psychology_alt_rounded,
              activeColor: context.appColors.info,
              activeBg: context.appColors.info.withAlpha(15),
              activeBorder: context.appColors.info.withAlpha(50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSectionTitle('Tindakan & Penanganan'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Input tindakan yang diberikan',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Tindakan
        _buildTextArea(
          'Tindakan Diberikan',
          _tindakanDiberikan,
          (v) => _tindakanDiberikan = v,
          hint: 'Misal: Istirahat di UKS, Kompres air hangat',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Obat
        _buildTextArea(
          'Obat Diberikan',
          _obatDiberikan,
          (v) => _obatDiberikan = v,
          hint: 'Nama obat dan dosis',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Catatan
        _buildTextArea(
          'Catatan Tenaga Kesehatan',
          _catatan,
          (v) => _catatan = v,
          hint: 'Observasi objektif...',
        ),
        const SizedBox(height: AppSpacing.lg),

        // Rekomendasi
        _buildTextArea(
          'Rekomendasi',
          _rekomendasi,
          (v) => _rekomendasi = v,
          hint: 'Saran tindak lanjut...',
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildStatusStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSectionTitle('Status Akhir'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tentukan status kesehatan pasien',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Status Options
            _buildStatusOption(
          'Layak Kegiatan',
          'Pasien dapat mengikuti kegiatan',
          context.appColors.success,
          Icons.verified_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStatusOption(
          'Perlu Perhatian',
          'Perlu pantauan dan tindak lanjut',
          context.appColors.warning,
          Icons.warning_amber_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildStatusOption(
          'Tidak Layak',
          'Tidak dapat mengikuti kegiatan',
          context.appColors.error,
          Icons.cancel_rounded,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Eskalasi
        _buildSectionTitle('Rujukan & Alur Eskalasi'),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          title: const Text('Rujuk ke Psikolog'),
          subtitle: const Text('Kirim notifikasi ke psikolog'),
          value: _eskalasiPsikolog,
          onChanged: (v) {
            setState(() => _eskalasiPsikolog = v);
            if (v) {
              context.read<TkPatientProvider>().loadPsychologists();
            } else {
              _selectedPsikologId = null;
              _selectedPsikologSlotId = null;
            }
          },
          activeThumbColor: context.appColors.success,
        ),
        if (_eskalasiPsikolog)
          Consumer<TkPatientProvider>(
            builder: (context, provider, _) {
              if (provider.error != null && provider.psychologists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    'Gagal memuat psikolog: ${provider.error}',
                    style: TextStyle(
                      color: context.appColors.error,
                    ),
                  ),
                );
              }
              if (provider.psychologists.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    'Memuat daftar psikolog...',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral500),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Psikolog',
                      ),
                      initialValue: _selectedPsikologId,
                      items:
                          provider.psychologists.map((p) {
                            return DropdownMenuItem<int>(
                              value: p['id'] as int,
                              child: Text(
                                p['name'] ?? p['nama'] ?? 'Tanpa Nama',
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPsikologId = val;
                          _selectedPsikologSlotId = null;
                        });
                        if (val != null) {
                          provider.loadPsychologistSchedules(val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_selectedPsikologId != null)
                      if (provider.psychologistSchedules.isEmpty)
                        Text(
                          'Tidak ada jadwal tersedia atau sedang memuat.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Pilih Jadwal Sesi',
                          ),
                          initialValue: _selectedPsikologSlotId,
                          items:
                              provider.psychologistSchedules.map((s) {
                                return DropdownMenuItem<int>(
                                  value: s['id'] as int,
                                  child: Text(
                                    '${s['hari'] ?? s['day'] ?? s['day_of_week'] ?? ''} ${s['jam_mulai'] ?? s['start'] ?? s['start_time'] ?? ''} - ${s['jam_selesai'] ?? s['end'] ?? s['end_time'] ?? ''}',
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPsikologSlotId = val;
                            });
                          },
                        ),
                  ],
                ),
              );
            },
          ),
        // Eskalasi Faskes Lanjutan / Superadmin
        SwitchListTile(
          title: const Text('Rujuk ke Faskes / Lapor Superadmin'),
          subtitle: const Text(
            'Buat surat rujukan medis resmi untuk penanganan lanjutan',
          ),
          value: _eskalasiFaskes,
          onChanged: (v) => setState(() => _eskalasiFaskes = v),
          activeThumbColor: context.appColors.error,
        ),
        if (_eskalasiFaskes)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Data Surat Rujukan Medis'),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdownField(
                  'Fasilitas Kesehatan Tujuan',
                  _faskesTujuan,
                  ['Klinik UBK', 'RSUD', 'Puskesmas', 'Lainnya'],
                  (v) => setState(() => _faskesTujuan = v!),
                ),
                if (_faskesTujuan == 'Lainnya')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: _buildTextArea(
                      'Nama Faskes',
                      _faskesTujuanLainnya,
                      (v) => _faskesTujuanLainnya = v,
                      hint: 'Sebutkan nama faskes',
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdownField(
                  'Alasan Rujukan',
                  _alasanRujukan,
                  [
                    'Penanganan Lanjutan',
                    'Pemeriksaan Penunjang',
                    'Gawat Darurat',
                    'Lainnya',
                  ],
                  (v) => setState(() => _alasanRujukan = v!),
                ),
                if (_alasanRujukan == 'Lainnya')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: _buildTextArea(
                      'Alasan',
                      _alasanRujukanLainnya,
                      (v) => _alasanRujukanLainnya = v,
                      hint: 'Sebutkan alasan',
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _buildTextArea(
                  'Keluhan Utama (Penyerta Rujukan)',
                  _keluhanUtamaRujukan,
                  (v) => _keluhanUtamaRujukan = v,
                  hint: 'Jelaskan keluhan utama...',
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diagnosis Sementara',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => Icd10SearchBottomSheet(
                                onSelected: (item) {
                                  setState(() {
                                    _diagnosisSementara =
                                        '[${item.code}] ${item.name}';
                                  });
                                },
                              ),
                        );
                      },
                      icon: Icon(
                        Icons.search,
                        size: 16,
                        color: context.appColors.primary,
                      ),
                      label: Text(
                        'Pilih Kode ICD-10',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                _buildTextArea(
                  '',
                  _diagnosisSementara,
                  (v) => _diagnosisSementara = v,
                  hint: 'Sebutkan diagnosis klinis...',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdownField(
                  'Saran Asuransi (Klaim)',
                  _rekomendasiAsuransi,
                  [
                    'BKU_Assurance',
                    'BPJS_Kesehatan',
                    'Asuransi_Swasta',
                    'Mandiri',
                  ],
                  (v) => setState(() => _rekomendasiAsuransi = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: context.appColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Data TTV akan ditarik otomatis. Surat memerlukan ACC dari Superadmin.',
                        style: AppTextStyles.bodySm.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.xxl),

        // Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Screening',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSummaryRow(
                'BMI',
                '${_bmi.toStringAsFixed(1)} ($_bmiCategory)',
              ),
              _buildSummaryRow('Tekanan Darah', '$_sistole/$_diastole mmHg'),
              _buildSummaryRow(
                'Suhu Tubuh',
                '${_suhuTubuh.toStringAsFixed(1)}°C',
              ),
              _buildSummaryRow('Denyut Nadi', '$_denyutNadi bpm'),
              _buildSummaryRow('SpO2', '$_spO2%'),
              if (_alergiObat.isNotEmpty)
                _buildSummaryRow('Alergi', _alergiObat),
              if (_tindakanDiberikan.isNotEmpty)
                _buildSummaryRow('Tindakan', _tindakanDiberikan),
              _buildSummaryRow('Status', _hasil),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(TkPatientProvider provider) {
    final isNextDisabled =
        _currentStep == 0 && provider.selectedPatient == null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: BkuButton(
                  onPressed: _goToPrevStep,
                  text: 'Kembali',
                  variant: BkuButtonVariant.danger,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 2,
              child: BkuButton(
                onPressed:
                    _currentStep == 4
                        ? _handleSubmit
                        : (isNextDisabled ? null : _goToNextStep),
                isLoading: _isSaving,
                text: _currentStep == 4 ? 'Simpan Screening' : 'Lanjut',
                variant: BkuButtonVariant.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSm.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral800,
      ),
    );
  }

  Widget _buildTextArea(
    String label,
    String value,
    Function(String) onChanged, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          initialValue: value,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: AppSpacing.paddingLg,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(
                color: context.appColors.success,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatusOption(
    String status,
    String description,
    Color color,
    IconData icon,
  ) {
    final isSelected = _hasil == status;
    return GestureDetector(
      onTap: () => setState(() => _hasil = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : context.appColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: isSelected ? color : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.padding10,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    description,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.neutral300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: context.appColors.onPrimary,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPsychologicalCard({
    required String title,
    required IconData icon,
    required Color activeColor,
    required Color activeBg,
    required Color activeBorder,
  }) {
    final isSelected = _kondisiPsikologis == title;
    return InkWell(
      onTap: () {
        setState(() => _kondisiPsikologis = title);
        if (title == 'Perlu Rujukan Psikolog') {
          setState(() => _eskalasiPsikolog = true);
          context.read<TkPatientProvider>().loadPsychologists();
        }
      },
      borderRadius: AppRadius.radiusMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : AppColors.neutral100,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isSelected ? activeBorder : AppColors.neutral300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.padding6,
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withAlpha(30) : AppColors.neutral300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? activeColor : AppColors.neutral600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeColor : AppColors.neutral700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNyeriColor(int value) {
    if (value <= 3) return context.watch<ThemeProvider>().colors.success;
    if (value <= 6) return context.watch<ThemeProvider>().colors.warning;
    return context.appColors.error;
  }

  void _goToNextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSubmit() async {
    final provider = context.read<TkPatientProvider>();
    final patient = provider.selectedPatient;

    if (patient == null) {
      AppSnackbar.showWarning(context, 'Pilih pasien terlebih dahulu');
      return;
    }

    setState(() => _isSaving = true);

    final screeningId = await provider.createScreening(
      patientId: patient.id,
      tinggiBadan: _tinggiBadan,
      beratBadan: _beratBadan,
      sistole: _sistole,
      diastole: _diastole,
      suhuTubuh: _suhuTubuh,
      denyutNadi: _denyutNadi,
      respirationRate: 20,
      spO2: _spO2,
      hasil: _hasil,
      keluhan: _keluhan.isNotEmpty ? _keluhan : null,
      skalaNyeri: _skalaNyeri > 0 ? _skalaNyeri : null,
      riwayatPenyakit: _riwayatPenyakit.isNotEmpty ? _riwayatPenyakit : null,
      alergiObat: _alergiObat.isNotEmpty ? _alergiObat : null,
      kondisiPsikologis: _kondisiPsikologis,
      tanggalScreening: _tanggalScreening,
      jenisPemeriksaan: _jenisPemeriksaan,
      sumberPemeriksaan: _sumberPemeriksaan,
      gulaDarah: _gulaDarah,
      golonganDarah: _golonganDarah,
      tesButaWarna: _tesButaWarna,
      konsumsiObatTerkini:
          _konsumsiObatTerkini.isNotEmpty ? _konsumsiObatTerkini : null,
      tindakanDiberikan:
          _tindakanDiberikan.isNotEmpty ? _tindakanDiberikan : null,
      obatDiberikan: _obatDiberikan.isNotEmpty ? _obatDiberikan : null,
      catatan: _catatan.isNotEmpty ? _catatan : null,
      rekomendasi: _rekomendasi.isNotEmpty ? _rekomendasi : null,
      eskalasiPsikolog: _eskalasiPsikolog,
      psikologId: _eskalasiPsikolog ? _selectedPsikologId : null,
      psikologSlotId: _eskalasiPsikolog ? _selectedPsikologSlotId : null,
      eskalasiFakultas: _eskalasiFaskes,
    );

    if (screeningId != null && _eskalasiFaskes) {
      final faskes =
          _faskesTujuan == 'Lainnya' ? _faskesTujuanLainnya : _faskesTujuan;
      final alasan =
          _alasanRujukan == 'Lainnya' ? _alasanRujukanLainnya : _alasanRujukan;

      final referralSuccess = await provider.createReferral(
        patientId: patient.id,
        selfScreeningId: screeningId,
        faskesTujuan: faskes,
        alasanRujukan: alasan,
        keluhanUtama:
            _keluhanUtamaRujukan.isNotEmpty
                ? _keluhanUtamaRujukan
                : 'Tidak ada',
        suhuTubuh: _suhuTubuh,
        sistole: _sistole,
        diastole: _diastole,
        denyutNadi: _denyutNadi,
        respirationRate: _respirationRate,
        spo2: _spO2,
        diagnosis:
            _diagnosisSementara.isNotEmpty ? _diagnosisSementara : 'Suspect',
        rekomendasiAsuransi: _rekomendasiAsuransi,
      );
      if (!referralSuccess && mounted) {
        AppSnackbar.showError(
          context,
          'Screening berhasil, tapi gagal membuat surat rujukan medis.',
        );
      }
    }

    setState(() => _isSaving = false);

    if (screeningId != null && mounted) {
      showDialog(
        context: context,
        builder:
            (ctx) => CustomDialog(
              title: 'Berhasil',
              content: 'Data screening berhasil disimpan',
              cancelText: '',
              confirmText: 'Selesai',
              isSuccess: true,
              onCancel: () {},
              onConfirm: () {
                Navigator.pop(ctx);
                context.pop();
              },
            ),
      );
    } else if (mounted) {
      showDialog(
        context: context,
        builder:
            (ctx) => CustomDialog(
              title: 'Gagal',
              content: provider.error ?? 'Gagal menyimpan data',
              cancelText: '',
              confirmText: 'Tutup',
              onCancel: () {},
              onConfirm: () => Navigator.pop(ctx),
              isDestructive: true,
            ),
      );
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (ctx) => CustomDialog(
            title: 'Batal Screening?',
            content:
                'Data yang sudah Anda masukkan tidak akan disimpan. Lanjutkan batal?',
            cancelText: 'Tidak',
            confirmText: 'Ya, Batal',
            isDestructive: true,
            onCancel: () => Navigator.pop(ctx),
            onConfirm: () {
              Navigator.pop(ctx);
              context.pop();
            },
          ),
    );
  }
}
