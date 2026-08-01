import 'dart:convert';

import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const List<String> kAkademikOptions = [
  'Kesulitan mengatur waktu belajar',
  'Kesulitan merencanakan studi',
  'Kesulitan dalam menyusun makalah, laporan, dan tugas akhir',
  'Kesulitan mempelajari referensi pembelajaran',
  'Kurang motivasi atau semangat belajar',
  'Kurangnya minat terhadap profesi',
];

const List<String> kNonAkademikOptions = [
  'Kesulitan menyesuaikan diri dengan teman mahasiswa / konflik dengan teman',
  'Kesulitan karena masalah-masalah keluarga',
  'Cemas / Depresi / Stres',
  'Masalah kepercayaan diri',
  'Home sickness (ingat rumah)',
  'Putus asa',
  'Manajemen keuangan',
  'Konflik dengan pasangan (pacar/istri/suami)',
  'Kesepian',
];

const List<String> kPekerjaanOrtuOptions = [
  'BUMN',
  'ASN',
  'Pegawai Swasta',
  'Wirausaha',
  'Tidak Bekerja',
  'Lainnya',
];

const List<String> kStatusPernikahanOptions = [
  'Belum menikah',
  'Menikah',
  'Pernah menikah (Cerai Hidup/Cerai Mati)',
];

class BookCounselingScreen extends StatefulWidget {
  final String topic;
  final Psychologist? psychologist;

  const BookCounselingScreen({
    super.key,
    required this.topic,
    this.psychologist,
  });

  @override
  State<BookCounselingScreen> createState() => _BookCounselingScreenState();
}

class _BookCounselingScreenState extends State<BookCounselingScreen> {
  static const int _totalSteps = 4;
  int _step = 0;

  Map<String, dynamic>? _selectedSlot;
  DateTime? _selectedDate;
  String _selectedTime = '';
  String _mode = 'Tatap Muka';

  final _noHpDosenPaCtrl = TextEditingController();
  String _statusPernikahan = 'Belum menikah';
  int _anakKe = 1;
  int _jumlahBersaudara = 1;
  bool _pernahSakitKeras = false;
  final _detailSakitKerasCtrl = TextEditingController();
  final _namaOrtuCtrl = TextEditingController();
  final _noHpOrtuCtrl = TextEditingController();
  String _pekerjaanOrtu = 'Pegawai Swasta';

  final Set<String> _subAkademik = {};
  final Set<String> _subNonAkademik = {};
  final _subLainnyaCtrl = TextEditingController();

  final _keluhanCtrl = TextEditingController();
  final _harapanCtrl = TextEditingController();
  bool _privacyAgreed = false;

  String _filterHari = 'Semua';
  String _filterKonselor = 'Semua';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StudentCounselingProvider>();
      if (widget.psychologist != null) {
        await provider.loadPsychologistSchedules(widget.psychologist!.id);
      } else {
        await provider.loadAvailableSchedules();
      }
      if (!mounted) return;
      final student = context.read<StudentProvider>();
      if (_namaOrtuCtrl.text.isEmpty && student.name.isNotEmpty) {
        // Auto-fill if possible; rawProfileData may carry parent info
        final raw = student.rawProfileData;
        final namaOrtu = raw['nama_ortu_wali'] ?? raw['nama_ayah'] ?? raw['nama_ibu'];
        final hpOrtu = raw['kontak_darurat'] ?? raw['no_hp_ortu'];
        if (namaOrtu != null && namaOrtu.toString().trim().isNotEmpty) {
          _namaOrtuCtrl.text = namaOrtu.toString();
        }
        if (hpOrtu != null && hpOrtu.toString().trim().isNotEmpty) {
          _noHpOrtuCtrl.text = hpOrtu.toString();
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _noHpDosenPaCtrl.dispose();
    _detailSakitKerasCtrl.dispose();
    _namaOrtuCtrl.dispose();
    _noHpOrtuCtrl.dispose();
    _subLainnyaCtrl.dispose();
    _keluhanCtrl.dispose();
    _harapanCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _slotsForCurrentStep(StudentCounselingProvider p) {
    return widget.psychologist != null
        ? p.psychologistSlots
        : p.availableSchedules;
  }

  String _hariName(dynamic tanggal) {
    if (tanggal == null) return '';
    try {
      final d = DateTime.parse(tanggal.toString());
      const names = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      return names[d.weekday % 7];
    } catch (_) {
      return '';
    }
  }

  String _longDate(DateTime? date) {
    if (date == null) return '-';
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentCounselingProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: BkuStaticAppBar(
        title: 'Form SPMI Konseling',
        subtitle: 'No.Dok: 02.01.00/FRM-4/KKA-SPMI',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: IndexedStack(
              index: _step,
              children: [
                _buildStep1Schedule(provider),
                _buildStep2Identity(),
                _buildStep3Checklist(),
                _buildStep4Keluhan(provider),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final labels = ['Jadwal & Metode', 'Identitas & Ortu', 'Checklist SPMI', 'Keluhan & Harapan'];
    final icons = [
      Icons.calendar_today_rounded,
      Icons.badge_rounded,
      Icons.checklist_rounded,
      Icons.edit_note_rounded,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      color: context.appColors.surface,
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i == _step;
          final done = i < _step;
          final color = active
              ? context.appColors.primary
              : done
                  ? context.appColors.success
                  : context.appColors.outline;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i < _step) {
                  setState(() => _step = i);
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? context.appColors.primary
                                : AppColors.surfaceContainerHighest,
                            borderRadius: AppRadius.radiusXs,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          done ? Icons.check_rounded : icons[i],
                          size: 14,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          '${i + 1}. ${labels[i]}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: active
                                ? context.appColors.onSurface
                                : context.appColors.outline,
                            fontWeight: active ? FontWeight.w900 : FontWeight.bold,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    final canGoNext = _validateCurrentStep();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(
          top: BorderSide(color: context.appColors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: BkuButton(
                text: 'Kembali',
                icon: Icons.arrow_back_rounded,
                variant: BkuButtonVariant.outline,
                onPressed: () => setState(() => _step -= 1),
                height: 48,
              ),
            ),
          if (_step > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: BkuButton(
              text: _step < _totalSteps - 1
                  ? 'Lanjut'
                  : 'Kirim Form SPMI',
              icon: _step < _totalSteps - 1
                  ? Icons.arrow_forward_rounded
                  : Icons.send_rounded,
              onPressed: !canGoNext
                  ? null
                  : () {
                      if (_step < _totalSteps - 1) {
                        setState(() => _step += 1);
                      } else {
                        _submit();
                      }
                    },
              variant: BkuButtonVariant.primary,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        return _selectedSlot != null;
      case 1:
        return _namaOrtuCtrl.text.trim().isNotEmpty &&
            _noHpOrtuCtrl.text.trim().isNotEmpty;
      case 2:
        return true;
      case 3:
        return _keluhanCtrl.text.trim().length >= 10 &&
            _harapanCtrl.text.trim().isNotEmpty &&
            _privacyAgreed;
      default:
        return true;
    }
  }

  // ─── STEP 1 ──────────────────────────────────────────────────────────────
  Widget _buildStep1Schedule(StudentCounselingProvider provider) {
    final allSlots = _slotsForCurrentStep(provider);
    final loading = widget.psychologist != null
        ? provider.psychologistDetailLoading
        : provider.schedulesLoading;

    final uniqueHari = <String>{
      for (final s in allSlots) _hariName(s['Tanggal'] ?? s['date']),
    }.where((e) => e.isNotEmpty).toList()
      ..sort();
    final uniqueKonselor = <String>{
      for (final s in allSlots)
        (s['NamaKonselor'] ?? s['psychologist_name'] ?? '').toString(),
    }.where((e) => e.isNotEmpty).toList()
      ..sort();

    var filtered = allSlots;
    if (_filterHari != 'Semua') {
      filtered = filtered.where((s) => _hariName(s['Tanggal'] ?? s['date']) == _filterHari).toList();
    }
    if (_filterKonselor != 'Semua') {
      filtered = filtered
          .where((s) => (s['NamaKonselor'] ?? s['psychologist_name'] ?? '').toString() == _filterKonselor)
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPsychologistBanner(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Pilih Slot Jadwal Konselor'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Hari',
                  _filterHari,
                  ['Semua', ...uniqueHari],
                  (v) => setState(() => _filterHari = v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildFilterDropdown(
                  'Konselor',
                  _filterKonselor,
                  ['Semua', ...uniqueKonselor],
                  (v) => setState(() => _filterKonselor = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (filtered.isEmpty)
            _buildEmpty('Belum ada jadwal tersedia')
          else
            ...filtered.map((s) => _buildSlotCard(s)),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Metode Konseling'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMethodOption(
                  'Tatap Muka',
                  'Konseling langsung di ruang BK',
                  Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMethodOption(
                  'Online',
                  'Konseling daring via Zoom',
                  Icons.videocam_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildPsychologistBanner() {
    if (widget.psychologist == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Row(
          children: [
            Icon(Icons.psychology_rounded, color: AppColors.neutral600, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Topik: ${widget.topic}',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final photo = widget.psychologist!.profileImageUrl;
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: ClipOval(
              child: photo.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiGate.getImageUrl(photo),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.neutral100,
                        child: const Icon(Icons.person_rounded, size: 28),
                      ),
                      placeholder: (_, __) => Container(color: AppColors.neutral200),
                    )
                  : Container(
                      color: AppColors.neutral200,
                      child: const Icon(Icons.person_rounded, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.psychologist!.name,
                  style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  widget.psychologist!.specialization,
                  style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final id = (slot['SlotID'] ?? slot['id']).toString();
    final selected = _selectedSlot != null &&
        (_selectedSlot!['SlotID'] ?? _selectedSlot!['id']).toString() == id;
    final start = (slot['JamMulai'] ?? slot['start'] ?? '').toString();
    final end = (slot['JamSelesai'] ?? slot['end'] ?? '').toString();
    final counselor =
        (slot['NamaKonselor'] ?? slot['psychologist_name'] ?? '-').toString();
    final tipe = (slot['Tipe'] ?? slot['type'] ?? '').toString();
    final sisaKuota = slot['SisaKuota'];
    final isFull = sisaKuota == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: isFull
            ? null
            : () {
                setState(() {
                  _selectedSlot = slot;
                  _selectedTime = end.isNotEmpty ? '$start - $end' : start;
                  final dateStr = slot['Tanggal'] ?? slot['date'];
                  if (dateStr != null) {
                    try {
                      _selectedDate = DateTime.parse(dateStr.toString());
                    } catch (_) {}
                  }
                });
              },
        borderRadius: AppRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? context.appColors.primaryContainer.withValues(alpha: 0.08)
                : context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: selected
                  ? context.appColors.primary
                  : context.appColors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selected
                      ? context.appColors.primary
                      : context.appColors.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 18,
                  color: selected
                      ? context.appColors.onPrimary
                      : context.appColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counselor,
                      style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_hariName(slot['Tanggal'] ?? slot['date'])} • ${start.substring(0, start.length > 5 ? 5 : start.length)} - ${end.substring(0, end.length > 5 ? 5 : end.length)}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tipe.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          tipe,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (sisaKuota != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? context.appColors.errorContainer
                        : context.appColors.successContainer,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    isFull ? 'Penuh' : 'Sisa $sisaKuota',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isFull
                          ? context.appColors.error
                          : context.appColors.success,
                    ),
                  ),
                ),
              if (selected) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.check_circle_rounded, color: context.appColors.primary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOption(String value, String desc, IconData icon) {
    final selected = _mode == value;
    return InkWell(
      onTap: () => setState(() => _mode = value),
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? context.appColors.primaryContainer.withValues(alpha: 0.08)
              : context.appColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: selected
                ? context.appColors.primary
                : context.appColors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? context.appColors.primary : context.appColors.outline,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected ? context.appColors.primary : null,
                    ),
                  ),
                  Text(
                    desc,
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 2 ──────────────────────────────────────────────────────────────
  Widget _buildStep2Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identitas Mahasiswa & Data Keluarga'),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _noHpDosenPaCtrl,
            label: 'No. HP Dosen Wali / PA',
            hint: '08xxxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdownField(
            label: 'Status Pernikahan',
            value: _statusPernikahan,
            options: kStatusPernikahanOptions,
            onChanged: (v) => setState(() => _statusPernikahan = v),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: TextEditingController(text: _anakKe.toString()),
                  label: 'Saya Anak Ke-',
                  onChanged: (v) {
                    final n = int.tryParse(v) ?? 1;
                    _anakKe = n.clamp(1, 99);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildNumberField(
                  controller: TextEditingController(text: _jumlahBersaudara.toString()),
                  label: 'Dari Bersaudara',
                  onChanged: (v) {
                    final n = int.tryParse(v) ?? 1;
                    _jumlahBersaudara = n.clamp(1, 99);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildYesNo(
            label: 'Pernah Sakit Keras?',
            value: _pernahSakitKeras,
            onChanged: (v) => setState(() => _pernahSakitKeras = v),
          ),
          if (_pernahSakitKeras) ...[
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _detailSakitKerasCtrl,
              label: 'Sebutkan jenis penyakit',
              hint: 'Misal: Demam Berdarah, Tifus, dll.',
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _namaOrtuCtrl,
            label: 'Nama Orangtua / Wali',
            hint: 'Nama lengkap',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _noHpOrtuCtrl,
            label: 'No. HP / WA Orangtua / Wali',
            hint: '08xxxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDropdownField(
            label: 'Pekerjaan Orangtua / Wali',
            value: _pekerjaanOrtu,
            options: kPekerjaanOrtuOptions,
            onChanged: (v) => setState(() => _pekerjaanOrtu = v),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ─── STEP 3 ──────────────────────────────────────────────────────────────
  Widget _buildStep3Checklist() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Checklist Jenis Layanan Konseling (Form SPMI)'),
          const SizedBox(height: AppSpacing.md),
          _buildChecklistGroup(
            'Masalah Akademik',
            Icons.school_rounded,
            context.appColors.primary,
            kAkademikOptions,
            _subAkademik,
            (item) {
              setState(() {
                _subAkademik.contains(item)
                    ? _subAkademik.remove(item)
                    : _subAkademik.add(item);
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildChecklistGroup(
            'Masalah Non-Akademik',
            Icons.psychology_rounded,
            const Color(0xFF7C3AED),
            kNonAkademikOptions,
            _subNonAkademik,
            (item) {
              setState(() {
                _subNonAkademik.contains(item)
                    ? _subNonAkademik.remove(item)
                    : _subNonAkademik.add(item);
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionTitle('Layanan Konseling Lainnya'),
          const SizedBox(height: AppSpacing.sm),
          _buildTextField(
            controller: _subLainnyaCtrl,
            label: 'Layanan Lainnya',
            hint: 'Konseling Beasiswa, Konseling Karir, dll.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildChecklistGroup(
    String title,
    IconData icon,
    Color accent,
    List<String> items,
    Set<String> selected,
    void Function(String) onToggle,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...items.map(
            (item) => _buildChecklistRow(item, selected.contains(item), accent, onToggle),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(
    String label,
    bool checked,
    Color accent,
    void Function(String) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: AppRadius.radiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) => onTap(label),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: accent,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: checked ? FontWeight.w900 : FontWeight.w600,
                  color: checked ? accent : context.appColors.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 4 ──────────────────────────────────────────────────────────────
  Widget _buildStep4Keluhan(StudentCounselingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Deskripsi Masalah & Harapan'),
          const SizedBox(height: AppSpacing.md),
          _buildTextArea(
            controller: _keluhanCtrl,
            label: 'Deskripsikan Masalah yang Dialami',
            hint: 'Ceritakan gambaran masalah yang Anda hadapi secara jujur dan jelas...',
            minLines: 5,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextArea(
            controller: _harapanCtrl,
            label: 'Harapan Setelah Mendapatkan Layanan Konseling',
            hint: 'Apa hasil atau bantuan yang Anda harapkan setelah sesi konseling ini selesai...',
            minLines: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateSummary(),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => setState(() => _privacyAgreed = !_privacyAgreed),
            borderRadius: AppRadius.radiusMd,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: context.appColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _privacyAgreed,
                    onChanged: (v) => setState(() => _privacyAgreed = v ?? false),
                    activeColor: context.appColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Saya memahami bahwa sesi ini bersifat rahasia, sukarela, dan data saya hanya dapat diakses oleh tim konselor resmi Universitas Bhakti Kencana.',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.appColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDateSummary() {
    final slot = _selectedSlot;
    final counselor = (slot?['NamaKonselor'] ?? widget.psychologist?.name ?? '-').toString();
    final topic = widget.topic;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: context.appColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Konselor', counselor),
          _buildSummaryRow('Topik', topic),
          _buildSummaryRow('Metode', _mode),
          _buildSummaryRow('Tanggal', _longDate(_selectedDate)),
          _buildSummaryRow('Jam', _selectedTime),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLg.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: context.appColors.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.contains(value) ? value : options.first,
                isExpanded: true,
                items: options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppTextStyles.labelSm)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: context.appColors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppTextStyles.labelMd)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYesNo({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            _buildRadioPill('Ya', value, () => onChanged(true)),
            const SizedBox(width: AppSpacing.sm),
            _buildRadioPill('Tidak', !value, () => onChanged(false)),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioPill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? context.appColors.primaryContainer.withValues(alpha: 0.12)
              : AppColors.neutral50,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: selected
                ? context.appColors.primary
                : context.appColors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            color: selected ? context.appColors.primary : context.appColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    String? hint,
    int minLines = 4,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines + 3,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: context.appColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: context.appColors.outlineVariant),
      ),
      child: Center(
        child: Text(
          msg,
          style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
        ),
      ),
    );
  }

  // ─── Submit ──────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_selectedSlot == null) return;
    if (_keluhanCtrl.text.trim().length < 10) {
      AppSnackbar.showWarning(context, 'Keluhan minimal 10 karakter');
      return;
    }
    if (!_privacyAgreed) {
      AppSnackbar.showWarning(context, 'Harap setujui pernyataan privasi');
      return;
    }
    BkuLoadingDialog.show(context);
    try {
      final psikologId = (widget.psychologist?.id ??
              _selectedSlot!['PsikologID'] ??
              _selectedSlot!['psikolog_id'] ??
              '0')
          .toString();
      final slotId = (_selectedSlot!['SlotID'] ?? _selectedSlot!['id'] ?? '0')
          .toString();
      final dateStr = (_selectedDate ?? DateTime.now()).toIso8601String().substring(0, 10);
      final start = (_selectedSlot!['JamMulai'] ?? _selectedSlot!['start'] ?? '00:00')
          .toString();
      final end = (_selectedSlot!['JamSelesai'] ?? _selectedSlot!['end'] ?? '00:00')
          .toString();

      final spmi = <String, dynamic>{
        'pendaftar_type': 'Mahasiswa',
        'no_hp_dosen_pa': _noHpDosenPaCtrl.text.trim(),
        'status_pernikahan': _statusPernikahan,
        'anak_ke': _anakKe,
        'jumlah_bersaudara': _jumlahBersaudara,
        'pernah_sakit_keras': _pernahSakitKeras,
        'detail_sakit_keras': _detailSakitKerasCtrl.text.trim(),
        'nama_ortu_wali': _namaOrtuCtrl.text.trim(),
        'no_hp_ortu_wali': _noHpOrtuCtrl.text.trim(),
        'pekerjaan_ortu_wali': _pekerjaanOrtu,
        'sub_kategori_akademik': jsonEncode(_subAkademik.toList()),
        'sub_kategori_non_akademik': jsonEncode(_subNonAkademik.toList()),
        'sub_kategori_lainnya': _subLainnyaCtrl.text.trim(),
        'harapan_konseling': _harapanCtrl.text.trim(),
      };

      final ok = await context.read<StudentCounselingProvider>().createBooking(
            psikologId: psikologId,
            slotId: slotId,
            date: dateStr,
            start: start,
            end: end,
            topic: widget.topic,
            complaint: _keluhanCtrl.text.trim(),
            mode: _mode,
            spmi: spmi,
          );

      if (!mounted) return;
      BkuLoadingDialog.hide(context);

      if (ok) {
        _showSuccessDialog();
      } else {
        AppSnackbar.showError(
          context,
          context.read<StudentCounselingProvider>().bookingError ??
              'Gagal melakukan pendaftaran',
        );
      }
    } catch (e) {
      if (!mounted) return;
      BkuLoadingDialog.hide(context);
      AppSnackbar.showError(context, ErrorHandler.getMessage(e));
    } finally {
      // Nothing needed here since dialog is hidden
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        title: 'Pendaftaran Berhasil!',
        content:
            'Form SPMI kamu telah dikirim. Mohon tunggu konfirmasi psikolog melalui notifikasi aplikasi.',
        isSuccess: true,
        cancelText: '',
        confirmText: 'Tutup',
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onCancel: () {},
      ),
    );
  }
}
