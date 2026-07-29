import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import '../../../../../core/error/error_handler.dart';

class ReportHealthScreen extends StatefulWidget {
  const ReportHealthScreen({super.key});

  @override
  State<ReportHealthScreen> createState() => _ReportHealthScreenState();
}

class _ReportHealthScreenState extends State<ReportHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _sugarController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedBloodType = 'A';

  double _currentBMI = 0;
  String _bmiStatus = '-';
  Color _bmiColor = AppColors.outline;

  // Gaya Hidup
  String _selectedSleepHours = '8';
  String _selectedExerciseFreq = '2';
  String _selectedWaterLitres = '2.0';
  String _selectedSmoking = 'Tidak';

  // Mental
  double _selectedStressLevel = 5.0;
  String _selectedMood = 'Biasa Saja';
  String _selectedMotivation = 'Biasa Saja';

  // Keluhan
  bool _keluhanSakitKepala = false;
  bool _keluhanPusing = false;
  bool _keluhanLelah = false;
  bool _keluhanNyeri = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateBMI);
    _weightController.addListener(_calculateBMI);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final student = Provider.of<StudentProvider>(context, listen: false);
      final latest = student.latestHealthRecord;
      if (latest != null) {
        setState(() {
          _heightController.text = latest.height.toString();
          _weightController.text = latest.weight.toString();
          if (latest.bloodPressure.contains('/')) {
            final bpParts = latest.bloodPressure.split('/');
            if (bpParts.length == 2) {
              _sysController.text = bpParts[0];
              _diaController.text = bpParts[1];
            }
          }
          if (latest.gulaDarah != null) {
            _sugarController.text = latest.gulaDarah.toString();
          }
          _selectedDate = latest.date;
          if (['A', 'B', 'AB', 'O'].contains(latest.bloodType)) {
            _selectedBloodType = latest.bloodType;
          }

          // Try parsing JSON from notes
          try {
            final parsedNotes =
                jsonDecode(latest.notes) as Map<String, dynamic>;
            if (parsedNotes['is_screening_realistis'] == true) {
              _selectedSleepHours = (parsedNotes['jam_tidur'] ?? 8).toString();
              _selectedExerciseFreq = (parsedNotes['olahraga'] ?? 2).toString();
              _selectedWaterLitres =
                  (parsedNotes['konsumsi_air'] ?? 2.0).toString();
              _selectedSmoking = parsedNotes['merokok'] ?? 'Tidak';
              _selectedStressLevel =
                  (parsedNotes['tingkat_stres'] ?? 5.0).toDouble();
              _selectedMood = parsedNotes['mood'] ?? 'Biasa Saja';
              _selectedMotivation =
                  parsedNotes['motivasi_belajar'] ?? 'Biasa Saja';

              final keluhanList = List<String>.from(
                parsedNotes['daftar_keluhan'] ?? [],
              );
              _keluhanSakitKepala = keluhanList.contains('Sakit Kepala');
              _keluhanPusing = keluhanList.contains('Pusing');
              _keluhanLelah = keluhanList.contains('Lelah / Lemas');
              _keluhanNyeri = keluhanList.contains('Nyeri Sendi');

              _notesController.text = parsedNotes['catatan_tambahan'] ?? '';
            } else {
              _notesController.text = latest.notes;
            }
          } catch (e) {
            // Fallback for non-JSON notes
            _notesController.text = latest.notes;
          }
        });
        _calculateBMI();
      }
    });
  }

  void _calculateBMI() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      double h = double.tryParse(_heightController.text) ?? 0;
      double w = double.tryParse(_weightController.text) ?? 0;
      if (h > 0 && w > 0) {
        double bmi = w / ((h / 100) * (h / 100));
        setState(() {
          _currentBMI = bmi;
          if (bmi < 18.5) {
            _bmiStatus = 'Underweight';
            _bmiColor = AppColors.info;
          } else if (bmi < 25) {
            _bmiStatus = 'Normal';
            _bmiColor = AppColors.success;
          } else if (bmi < 30) {
            _bmiStatus = 'Overweight';
            _bmiColor = AppColors.warning;
          } else {
            _bmiStatus = 'Obese';
            _bmiColor = AppColors.error;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _sysController.dispose();
    _diaController.dispose();
    _sugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: context.appColors.onPrimary,
              onSurface: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const BkuStaticAppBar(
        title: 'Input Data Kesehatan',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBMIPreview(),
              const SizedBox(height: AppSpacing.xxl),

              // 1. Fisik
              _buildInputCard(
                '1. Kategori Fisik',
                Icons.accessibility_new_rounded,
                AppColors.info,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          _heightController,
                          'Tinggi (cm)',
                          Icons.height_rounded,
                          '170',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildInputField(
                          _weightController,
                          'Berat (kg)',
                          Icons.monitor_weight_rounded,
                          '65',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Gaya Hidup
              _buildInputCard(
                '2. Gaya Hidup (Self-report)',
                Icons.sports_gymnastics_rounded,
                context.appColors.info,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          'Jam Tidur / Hari',
                          Icons.bedtime_rounded,
                          ['4', '5', '6', '7', '8', '9'],
                          _selectedSleepHours,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedSleepHours = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildDropdownField(
                          'Olahraga / Minggu',
                          Icons.fitness_center_rounded,
                          ['0', '1', '2', '3', '4'],
                          _selectedExerciseFreq,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedExerciseFreq = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          'Konsumsi Air (L)',
                          Icons.water_drop_rounded,
                          ['1.0', '1.5', '2.0', '2.5', '3.0'],
                          _selectedWaterLitres,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedWaterLitres = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildDropdownField(
                          'Apakah Merokok?',
                          Icons.smoke_free_rounded,
                          ['Tidak', 'Ya'],
                          _selectedSmoking,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedSmoking = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Mental
              _buildInputCard(
                '3. Kategori Mental (Self-report)',
                Icons.psychology_rounded,
                Colors.purple,
                [
                  Text(
                    'Tingkat Stres (1-10)',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.purple,
                            inactiveTrackColor: Colors.purple.withAlpha(50),
                            thumbColor: Colors.purple,
                            overlayColor: Colors.purple.withAlpha(30),
                          ),
                          child: Slider(
                            value: _selectedStressLevel,
                            min: 1.0,
                            max: 10.0,
                            divisions: 9,
                            onChanged:
                                (val) =>
                                    setState(() => _selectedStressLevel = val),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(30),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          '${_selectedStressLevel.toInt()}',
                          style: AppTextStyles.labelMd.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          'Mood Minggu Ini',
                          Icons.mood_rounded,
                          [
                            'Sangat Baik',
                            'Baik',
                            'Biasa Saja',
                            'Buruk',
                            'Sangat Buruk',
                          ],
                          _selectedMood,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedMood = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildDropdownField(
                          'Motivasi Belajar',
                          Icons.auto_stories_rounded,
                          [
                            'Sangat Tinggi',
                            'Tinggi',
                            'Biasa Saja',
                            'Rendah',
                            'Sangat Rendah',
                          ],
                          _selectedMotivation,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedMotivation = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 4. Keluhan
              _buildInputCard(
                '4. Kategori Keluhan (Bila Ada)',
                Icons.medical_information_rounded,
                AppColors.error,
                [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: [
                      _buildKeluhanChip(
                        'Sakit Kepala',
                        _keluhanSakitKepala,
                        (v) => setState(() => _keluhanSakitKepala = v),
                      ),
                      _buildKeluhanChip(
                        'Pusing',
                        _keluhanPusing,
                        (v) => setState(() => _keluhanPusing = v),
                      ),
                      _buildKeluhanChip(
                        'Lelah / Lemas',
                        _keluhanLelah,
                        (v) => setState(() => _keluhanLelah = v),
                      ),
                      _buildKeluhanChip(
                        'Nyeri Sendi',
                        _keluhanNyeri,
                        (v) => setState(() => _keluhanNyeri = v),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 5. Opsional
              _buildInputCard(
                '5. Kategori Opsional (Alat/Klinik)',
                Icons.query_stats_rounded,
                Colors.blueGrey,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          _sysController,
                          'Sistolik (mmHg)',
                          Icons.arrow_upward_rounded,
                          '120',
                          isRequired: false,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildInputField(
                          _diaController,
                          'Diastolik (mmHg)',
                          Icons.arrow_downward_rounded,
                          '80',
                          isRequired: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          _sugarController,
                          'Gula Darah (mg/dL)',
                          Icons.water_drop_rounded,
                          '90',
                          isRequired: false,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildDropdownField(
                          'Golongan Darah',
                          Icons.bloodtype_rounded,
                          ['A', 'B', 'AB', 'O', '-'],
                          _selectedBloodType,
                          (val) {
                            if (val != null) {
                              setState(() => _selectedBloodType = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDateField(
                    context,
                    'Tanggal Pengukuran',
                    Icons.calendar_today_rounded,
                    _selectedDate,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Catatan Tambahan
              _buildInputCard(
                'Catatan Tambahan',
                Icons.sticky_note_2_rounded,
                context.appColors.info,
                [
                  _buildTextAreaField(
                    _notesController,
                    'Keluhan / Catatan Lain (Opsional)',
                    Icons.description_rounded,
                    'Ceritakan kondisi kesehatanmu atau keluhan yang dirasakan...',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s48),
              _buildSubmitButton(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bmiColor.withAlpha(200), _bmiColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: _bmiColor.withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.speed_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.s20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prediksi BMI Kamu',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  _currentBMI > 0 ? _currentBMI.toStringAsFixed(1) : '--',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Text(
              _bmiStatus,
              style: AppTextStyles.labelSm.copyWith(
                color: _bmiColor,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildKeluhanChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: AppRadius.radiusLg,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.error.withAlpha(25)
                  : Theme.of(context).colorScheme.surface.withAlpha(150),
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.error.withAlpha(120)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 16,
              color:
                  isSelected
                      ? AppColors.error
                      : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected
                          ? AppColors.error
                          : Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.outline.withAlpha(100),
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withAlpha(150),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return 'Wajib isi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    IconData icon,
    DateTime selectedDate,
  ) {
    final formattedDate =
        "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: AppRadius.radiusLg,
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(150),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary.withAlpha(150),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          onChanged: onChanged,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.s6),
              child: Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.primary.withAlpha(150),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withAlpha(150),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BkuTextField(
          controller: controller,
          maxLines: 3,
          style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.outline.withAlpha(100),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withAlpha(150),
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withAlpha(150),
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXl,
        gradient: LinearGradient(
          colors: context.read<ThemeProvider>().primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _submitForm(),

        child: Text(
          'Simpan Data Kesehatan',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w900,
            color: context.appColors.onPrimary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    BkuLoadingDialog.show(context);

    try {
      final Map<String, dynamic> notesPayload = {
        'is_screening_realistis': true,
        'jam_tidur': int.tryParse(_selectedSleepHours) ?? 8,
        'olahraga': int.tryParse(_selectedExerciseFreq) ?? 0,
        'konsumsi_air': double.tryParse(_selectedWaterLitres) ?? 2.0,
        'merokok': _selectedSmoking,
        'tingkat_stres': _selectedStressLevel.toInt(),
        'mood': _selectedMood,
        'motivasi_belajar': _selectedMotivation,
        'daftar_keluhan': [
          if (_keluhanSakitKepala) 'Sakit Kepala',
          if (_keluhanPusing) 'Pusing',
          if (_keluhanLelah) 'Lelah / Lemas',
          if (_keluhanNyeri) 'Nyeri Sendi',
        ],
        'catatan_tambahan': _notesController.text,
      };

      final jsonStr = jsonEncode(notesPayload);
      final sysVal =
          _sysController.text.isNotEmpty ? _sysController.text : '120';
      final diaVal =
          _diaController.text.isNotEmpty ? _diaController.text : '80';

      final record = HealthRecord(
        id: 'H${DateTime.now().millisecondsSinceEpoch}',
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bloodPressure: '$sysVal/$diaVal',
        heartRate: 72,
        temperature: 36.5,
        date: _selectedDate,
        bloodType: _selectedBloodType,
        notes: jsonStr,
        gulaDarah:
            _sugarController.text.isNotEmpty
                ? int.tryParse(_sugarController.text)
                : null,
      );

      await context.read<StudentProvider>().addHealthRecord(record);
      if (!mounted) return;
      BkuLoadingDialog.hide(
        context,
      ); // Hide loading BEFORE showing success dialog
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      BkuLoadingDialog.hide(context); // Hide loading BEFORE showing error
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    }
  }

  int _calculateScore(HealthRecord r) {
    double score = 100;

    // BMI deductions
    double bmi = r.bmi;
    if (bmi >= 30) {
      score -= 25;
    } else if (bmi >= 25 || bmi < 18.5) {
      score -= 12;
    }

    // BP deductions
    final parts = r.bloodPressure.split('/');
    if (parts.length == 2) {
      int sys = int.tryParse(parts[0]) ?? 120;
      int dia = int.tryParse(parts[1]) ?? 80;
      if (sys >= 140 || dia >= 90) {
        score -= 18;
      } else if (sys >= 130 || dia >= 80) {
        score -= 10;
      }
    }

    // Lifestyle & mental deductions from notes json
    if (r.notes.startsWith('{')) {
      try {
        final data = jsonDecode(r.notes);

        // sleep
        int sleep = data['jam_tidur'] ?? 8;
        if (sleep < 7) {
          score -= (7 - sleep) * 4;
        } else if (sleep > 9) {
          score -= (sleep - 9) * 4;
        }

        // water
        double water = double.tryParse(data['konsumsi_air'].toString()) ?? 2.0;
        if (water < 2.0) {
          score -= ((2.0 - water) / 0.5) * 5;
        }

        // sports
        int sports = data['olahraga'] ?? 0;
        if (sports < 2) {
          score -= (2 - sports) * 6;
        }

        // stress
        int stress = data['tingkat_stres'] ?? 5;
        if (stress > 4) {
          score -= (stress - 4) * 4;
        }

        // smoking
        String smoking = data['merokok'] ?? 'Tidak';
        if (smoking.toLowerCase() == 'ya') {
          score -= 15;
        }

        // symptoms
        final symptoms = data['daftar_keluhan'] as List?;
        if (symptoms != null) {
          score -= symptoms.length * 6;
        }
      } catch (_) {}
    }

    if (score < 10) score = 10;
    if (score > 100) score = 100;
    return score.toInt();
  }

  Map<String, dynamic>? _getDelta(HealthRecord cur, HealthRecord? prev) {
    if (prev == null) {
      return {
        'type': 'info',
        'message':
            'Skrining pertamamu berhasil disimpan! Lakukan secara rutin setiap minggu untuk memantau perkembangan kesehatanmu.',
      };
    }

    double wDiff = cur.weight - prev.weight;
    double curBmi = cur.bmi;

    if (curBmi >= 25) {
      // overweight
      if (wDiff < 0) {
        return {
          'type': 'success',
          'message':
              'Berat badanmu turun ${wDiff.abs().toStringAsFixed(1)} kg dari bulan lalu. Ini progres bagus untuk menuju berat badan ideal!',
        };
      } else if (wDiff > 0) {
        return {
          'type': 'warning',
          'message':
              'Berat badanmu naik ${wDiff.toStringAsFixed(1)} kg. Disarankan untuk membatasi kalori harian dan meningkatkan latihan fisik kardio.',
        };
      }
    } else if (curBmi < 18.5) {
      // underweight
      if (wDiff > 0) {
        return {
          'type': 'success',
          'message':
              'Berat badanmu naik ${wDiff.toStringAsFixed(1)} kg. Bagus! Tingkatkan konsumsi protein dan latihan angkat beban.',
        };
      } else if (wDiff < 0) {
        return {
          'type': 'warning',
          'message':
              'Berat badanmu menyusut ${wDiff.abs().toStringAsFixed(1)} kg. Pastikan kamu mendapat asupan kalori & nutrisi makro yang cukup.',
        };
      }
    } else {
      // normal
      if (wDiff.abs() <= 1.0) {
        return {
          'type': 'success',
          'message':
              'Berat badanmu sangat stabil (selisih ${wDiff.toStringAsFixed(1)} kg). Menjaga kestabilan tubuh adalah tanda metabolisme yang prima!',
        };
      } else {
        return {
          'type': 'info',
          'message':
              'Berat badanmu bergeser ${wDiff.toStringAsFixed(1)} kg. Masih dalam batas wajar, pastikan tetap aktif dan tidur cukup.',
        };
      }
    }
    return null;
  }

  void _showSuccessDialog() {
    final provider = context.read<StudentProvider>();
    final records = provider.healthRecords;

    final currentRecord = records.isNotEmpty ? records.first : null;
    final previousRecord = records.length > 1 ? records[1] : null;

    if (currentRecord == null) return;

    final score = _calculateScore(currentRecord);
    final delta = _getDelta(currentRecord, previousRecord);

    // Check if needs counseling (stressLevel >= 7 or BMI obese)
    int stressLevel = 0;
    if (currentRecord.notes.startsWith('{')) {
      try {
        final parsed = jsonDecode(currentRecord.notes);
        stressLevel = parsed['tingkat_stres'] ?? 0;
      } catch (_) {}
    }

    final needsCounseling = stressLevel >= 7 || currentRecord.bmi >= 30;

    Color ringColor = AppColors.success;
    if (score < 70) {
      ringColor = AppColors.error;
    } else if (score < 85) {
      ringColor = AppColors.warning;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: context.read<ThemeProvider>().primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radius28),
                  topRight: Radius.circular(AppRadius.radius28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Data Kesehatan Disimpan!',
                          style: AppTextStyles.titleLg.copyWith(
                            color: context.appColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Hasil analisis kebugaran & gaya hidup',
                          style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circular Score Widget
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withAlpha(120),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 68,
                                      height: 68,
                                      child: CircularProgressIndicator(
                                        value: score / 100.0,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              ringColor,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$score',
                                          style: TextStyle(
                                            color: ringColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const Text(
                                          'SKOR',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        score >= 85
                                            ? 'Prima & Sangat Sehat'
                                            : score >= 70
                                            ? 'Kondisi Cukup Baik'
                                            : 'Perlu Perhatian Ekstra',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        delta?['message'] ??
                                            'Terus pertahankan pola tidur dan makan yang teratur!',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Delta Card
                          if (delta != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color:
                                    delta['type'] == 'success'
                                        ? AppColors.success.withAlpha(20)
                                        : delta['type'] == 'warning'
                                        ? AppColors.error.withAlpha(20)
                                        : AppColors.info.withAlpha(20),
                                borderRadius: AppRadius.radiusXl,
                                border: Border.all(
                                  color:
                                      delta['type'] == 'success'
                                          ? AppColors.success.withAlpha(50)
                                          : delta['type'] == 'warning'
                                          ? AppColors.error.withAlpha(50)
                                          : AppColors.info.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    delta['type'] == 'success'
                                        ? Icons.check_circle_rounded
                                        : delta['type'] == 'warning'
                                        ? Icons.warning_amber_rounded
                                        : Icons.info_outline_rounded,
                                    color:
                                        delta['type'] == 'success'
                                            ? AppColors.success
                                            : delta['type'] == 'warning'
                                            ? AppColors.error
                                            : AppColors.info,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Perbandingan Kesehatan',
                                          style: TextStyle(
                                            color:
                                                delta['type'] == 'success'
                                                    ? const Color(0xFF14532D)
                                                    : delta['type'] == 'warning'
                                                    ? const Color(0xFF7F1D1D)
                                                    : const Color(0xFF1E3A8A),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          delta['message'],
                                          style: TextStyle(
                                            color:
                                                delta['type'] == 'success'
                                                    ? const Color(0xFF166534)
                                                    : delta['type'] == 'warning'
                                                    ? const Color(0xFF991B1B)
                                                    : const Color(0xFF1E40AF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // Counseling Recommendation
                          if (needsCounseling) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: AppRadius.radiusXl,
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: AppSpacing.padding6,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.support_agent_rounded,
                                          color: context.appColors.onPrimary,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s10),
                                      const Text(
                                        'Rekomendasi Ahli',
                                        style: TextStyle(
                                          color: AppColors.info,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Tingkat stresmu atau BMI terdeteksi memerlukan perhatian khusus. Kamu bisa menjadwalkan konseling psikologis gratis & rahasia.',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(
                                        context,
                                      ); // close report screen
                                      context.push(AppRoutes.studentCounseling);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Jadwalkan Konseling Sekarang',
                                          style: TextStyle(
                                            color: const Color(0xFF1E3A8A),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 10,
                                          color: const Color(0xFF1E3A8A),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: BkuButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        text: 'Paham, Kembali',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
