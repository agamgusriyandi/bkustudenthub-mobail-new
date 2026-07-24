import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/counseling_session.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _sessionMethod = 'Tatap Muka (Offline)';
  String _genderPreference = 'Bebas';
  DateTime? _selectedDate;
  String _selectedTime = '10:00 - 11:00';

  List<Map<String, dynamic>> _loadedSlots = [];
  bool _isLoadingSlots = false;
  Map<String, dynamic>? _selectedSlot;
  final bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.psychologist != null) {
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });
    try {
      final slots = await context
          .read<StudentProvider>()
          .getPsychologistSchedules(widget.psychologist!.id);
      if (mounted) {
        setState(() {
          _loadedSlots = slots;
          if (slots.isNotEmpty) {
            _selectedSlot = slots.first;
            _selectedTime = "${slots.first['start']} - ${slots.first['end']}";
            if (slots.first['next_date'] != null) {
              _selectedDate = DateTime.parse(slots.first['next_date']);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading dynamic slots: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSlots = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const BkuStaticAppBar(
        title: 'Form Pendaftaran Sesi',
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
              _buildTopicBanner(),
              const SizedBox(height: 32),
              _buildSectionTitle('Detail Keluhan'),
              const SizedBox(height: 12),
              _buildTextArea(
                _descriptionController,
                'Ceritakan sedikit apa yang sedang kamu rasakan atau apa yang ingin kamu bahas...',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Preferensi Sesi'),
              const SizedBox(height: 12),
              _buildLabel('Metode Sesi'),
              _buildDropdown(
                ['Tatap Muka (Offline)', 'Daring (Online via Zoom)'],
                _sessionMethod,
                (val) => setState(() => _sessionMethod = val!),
              ),
              const SizedBox(height: 20),
              _buildLabel('Preferensi Gender Psikolog'),
              _buildDropdown(
                ['Bebas', 'Laki-laki', 'Perempuan'],
                _genderPreference,
                (val) => setState(() => _genderPreference = val!),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Pilih Jadwal'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildTimeSelector(),
              const SizedBox(height: 48),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicBanner() {
    return Column(
      children: [
        if (widget.psychologist != null) ...[
          BkuCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipOval(
                    child: Image.network(
                      ApiGate.getImageUrl(widget.psychologist!.profileImageUrl),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.neutral100,
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.neutral600,
                              size: 28,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Psikolog Pilihan',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      Text(
                        widget.psychologist!.name,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.psychologist!.specialization,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topik Konseling',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    Text(
                      widget.topic,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLg.copyWith(fontSize: 18));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint) {
    return BkuTextField(
      controller: controller,
      maxLines: 5,
      style: AppTextStyles.labelMd,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.neutral50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? 'Mohon isi detail keluhan kamu'
                  : null,
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: AppTextStyles.labelMd),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Pilih Tanggal Sesi'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: AppTextStyles.labelMd.copyWith(
                color:
                    _selectedDate == null
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    if (_isLoadingSlots) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neutral800,
            ),
          ),
        ),
      );
    }

    if (_loadedSlots.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _loadedSlots.map((slot) {
                  final slotTime = "${slot['start']} - ${slot['end']}";
                  final slotDisplay = slot['display'] ?? slotTime;
                  final isSelected = _selectedSlot?['id'] == slot['id'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSlot = slot;
                        _selectedTime = slotTime;
                        if (slot['next_date'] != null) {
                          _selectedDate = DateTime.parse(slot['next_date']);
                        }
                      });
                    },
                    borderRadius: AppRadius.radiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neutral100 : Colors.white,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.neutral800
                                  : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        slotDisplay,
                        style: AppTextStyles.labelSm.copyWith(
                          color:
                              isSelected
                                  ? AppColors.neutral800
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedSlot != null && _selectedSlot!['location'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.neutral600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lokasi Sesi: ${_selectedSlot!['location']}',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    final times = [
      '09:00 - 10:00',
      '10:00 - 11:00',
      '13:00 - 14:00',
      '14:00 - 15:00',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          times.map((t) {
            bool isSelected = _selectedTime == t;
            return InkWell(
              onTap: () => setState(() => _selectedTime = t),
              borderRadius: AppRadius.radiusMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neutral100 : Colors.white,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.neutral800
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  t,
                  style: AppTextStyles.labelSm.copyWith(
                    color:
                        isSelected
                            ? AppColors.neutral800
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 44,
        child: BkuButton(
          onPressed: _submitForm,
          text: 'Lanjutkan Booking',
          isLoading: _isSubmitting,
          height: 44,
          variant: BkuButtonVariant.success,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      BkuLoadingDialog.show(context);
      try {
        final packedId =
            widget.psychologist != null
                ? "${widget.psychologist!.id}:${_selectedSlot != null ? _selectedSlot!['id'] : ''}"
                : 'UNASSIGNED';

        final newSession = CounselingSession(
          id: 'C${DateTime.now().millisecondsSinceEpoch}',
          psychologistId: packedId,
          psychologistName:
              widget.psychologist?.name ??
              'Psikolog Pilihan (Menunggu Konfirmasi)',
          topic: widget.topic,
          date: _selectedDate!,
          time: _selectedTime,
          location:
              _selectedSlot != null
                  ? _selectedSlot!['location']
                  : 'Gedung Rektorat Lt. 2 (Ruang Konseling)',
          status: 'Scheduled',
          notes: _descriptionController.text,
        );
        await context.read<StudentProvider>().bookCounseling(newSession);
        if (!mounted) return;
        _showSuccessDialog();
      } catch (e) {
        if (!mounted) return;
        AppSnackbar.showError(context, ErrorHandler.getMessage(e));
      } finally {
        if (mounted) {
          BkuLoadingDialog.hide(context);
        }
      }
    } else if (_selectedDate == null) {
      AppSnackbar.showWarning(
        context,
        'Mohon pilih tanggal sesi terlebih dahulu',
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomDialog(
            title: 'Pendaftaran Berhasil!',
            content:
                'Sesi konseling kamu telah dijadwalkan. Mohon tunggu konfirmasi psikolog melalui notifikasi aplikasi.',
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
