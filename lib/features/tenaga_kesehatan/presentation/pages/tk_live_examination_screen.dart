import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';

class TkLiveExaminationScreen extends StatefulWidget {
  const TkLiveExaminationScreen({super.key});

  @override
  State<TkLiveExaminationScreen> createState() =>
      _TkLiveExaminationScreenState();
}

class _TkLiveExaminationScreenState extends State<TkLiveExaminationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _catatanController = TextEditingController();
  final _tindakanController = TextEditingController();
  final _obatController = TextEditingController();

  Patient? _selectedPatient;
  List<Patient> _searchResults = [];
  bool _isSearching = false;

  String _hasil = 'Layak Kegiatan';
  double _suhuTubuh = 36.5;
  int _sistole = 120;
  int _diastole = 80;
  int _denyutNadi = 80;
  int _spO2 = 98;
  double _tinggiBadan = 170;
  double _beratBadan = 60;

  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _keluhanController.dispose();
    _catatanController.dispose();
    _tindakanController.dispose();
    _obatController.dispose();
    super.dispose();
  }

  double get _bmi {
    if (_tinggiBadan <= 0) return 0;
    final tinggiMeter = _tinggiBadan / 100;
    return _beratBadan / (tinggiMeter * tinggiMeter);
  }

  Future<void> _searchPatients(String query) async {
    if (query.length < 3) return;
    setState(() => _isSearching = true);
    try {
      final results = await context.read<TkPatientProvider>().searchPatients(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _submitExamination() async {
    if (_selectedPatient == null) {
      AppSnackbar.showError(context, 'Pilih pasien terlebih dahulu');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TkPatientProvider>();
    final recordId = await provider.createScreening(
      patientId: _selectedPatient!.id,
      tinggiBadan: _tinggiBadan,
      beratBadan: _beratBadan,
      sistole: _sistole,
      diastole: _diastole,
      suhuTubuh: _suhuTubuh,
      denyutNadi: _denyutNadi,
      respirationRate: 20,
      spO2: _spO2,
      hasil: _hasil,
      keluhan: _keluhanController.text.isNotEmpty ? _keluhanController.text : null,
      catatan: _catatanController.text.isNotEmpty ? _catatanController.text : null,
      tindakanDiberikan: _tindakanController.text.isNotEmpty ? _tindakanController.text : null,
      obatDiberikan: _obatController.text.isNotEmpty ? _obatController.text : null,
    );

    setState(() => _isSaving = false);

    if (recordId != null && mounted) {
      AppSnackbar.showSuccess(context, 'Pemeriksaan berhasil disimpan');
      context.pop();
    } else if (mounted) {
      AppSnackbar.showError(context, provider.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(
        title: 'Pemeriksaan Langsung',
        variant: AppBarVariant.nakes,
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Patient Search
            _buildSectionTitle('Identifikasi Pasien'),
            const SizedBox(height: AppSpacing.sm),
            BkuTextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Nama atau NIM...',
                hintStyle: TextStyle(color: AppColors.neutral400),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.neutral500),
                filled: true,
                fillColor: AppColors.neutral50,
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
                  borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
                ),
              ),
              onChanged: _searchPatients,
            ),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              ),
            if (_selectedPatient != null)
              _buildSelectedPatient(),
            if (_searchResults.isNotEmpty && _selectedPatient == null) ...[
              const SizedBox(height: AppSpacing.md),
              ..._searchResults.take(5).map(
                (p) => ListTile(
                  onTap: () {
                    setState(() {
                      _selectedPatient = p;
                      _searchResults = [];
                      _searchController.text = p.nama;
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.neutral200,
                    child: Text(p.initials),
                  ),
                  title: Text(p.nama),
                  subtitle: Text('${p.nim} • ${p.prodi}'),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                    side: BorderSide(color: AppColors.neutral200),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Vitals
            _buildSectionTitle('Tanda Vital'),
            const SizedBox(height: AppSpacing.md),
            _buildVitalGrid(),

            const SizedBox(height: AppSpacing.xl),

            // Subjective
            _buildSectionTitle('Data Subjektif'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField('Keluhan Utama', _keluhanController, maxLines: 3),

            const SizedBox(height: AppSpacing.xl),

            // Status
            _buildSectionTitle('Status Pemeriksaan'),
            const SizedBox(height: AppSpacing.md),
            _buildStatusOptions(),

            const SizedBox(height: AppSpacing.xl),

            // Actions
            _buildSectionTitle('Tindakan'),
            const SizedBox(height: AppSpacing.md),
            _buildTextField('Tindakan Diberikan', _tindakanController),
            const SizedBox(height: AppSpacing.md),
            _buildTextField('Obat Diberikan', _obatController),
            const SizedBox(height: AppSpacing.md),
            _buildTextField('Catatan', _catatanController, maxLines: 3),

            const SizedBox(height: AppSpacing.xxl),

            // Submit
            BkuButton(
              text: 'Simpan Pemeriksaan',
              variant: BkuButtonVariant.primary,
              isLoading: _isSaving,
              onPressed: _submitExamination,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPatient() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: context.appColors.success.withAlpha(100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.appColors.success.withAlpha(30),
            child: Text(
              _selectedPatient!.initials,
              style: TextStyle(
                color: context.appColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPatient!.nama,
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedPatient!.nim} • ${_selectedPatient!.prodi}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedPatient = null;
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        _buildVitalInput('Tinggi', '${_tinggiBadan.round()}', 'cm', (v) {
          setState(() => _tinggiBadan = double.tryParse(v) ?? 0);
        }),
        _buildVitalInput('Berat', '${_beratBadan.round()}', 'kg', (v) {
          setState(() => _beratBadan = double.tryParse(v) ?? 0);
        }),
        _buildVitalInput('Sistolik', '$_sistole', 'mmHg', (v) {
          setState(() => _sistole = int.tryParse(v) ?? 0);
        }),
        _buildVitalInput('Diastolik', '$_diastole', 'mmHg', (v) {
          setState(() => _diastole = int.tryParse(v) ?? 0);
        }),
        _buildVitalInput('Suhu', _suhuTubuh.toStringAsFixed(1), '°C', (v) {
          setState(() => _suhuTubuh = double.tryParse(v) ?? 0);
        }),
        _buildVitalInput('SpO2', '$_spO2', '%', (v) {
          setState(() => _spO2 = int.tryParse(v) ?? 0);
        }),
        _buildVitalInput('Nadi', '$_denyutNadi', 'bpm', (v) {
          setState(() => _denyutNadi = int.tryParse(v) ?? 0);
        }),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
              ),
              const Spacer(),
              Text(
                _bmi.toStringAsFixed(1),
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalInput(String label, String value, String unit, Function(String) onChanged) {
    final controller = TextEditingController(text: value);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
          ),
          Row(
            children: [
              Expanded(
                child: BkuTextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
                  onChanged: onChanged,
                ),
              ),
              Text(unit, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Row(
      children: [
        _buildStatusChip('Layak Kegiatan', context.appColors.success),
        const SizedBox(width: AppSpacing.sm),
        _buildStatusChip('Perlu Perhatian', context.appColors.warning),
        const SizedBox(width: AppSpacing.sm),
        _buildStatusChip('Tidak Layak', context.appColors.error),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = _hasil == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _hasil = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(20) : AppColors.neutral50,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: isSelected ? color : AppColors.neutral200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? color : AppColors.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLg.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral800,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600)),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Masukkan $label...',
            hintStyle: TextStyle(color: AppColors.neutral400),
            filled: true,
            fillColor: AppColors.neutral50,
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
              borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
