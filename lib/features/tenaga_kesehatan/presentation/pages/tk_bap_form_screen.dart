import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkBapFormScreen extends StatefulWidget {
  final TkBapModel? existingBap;

  const TkBapFormScreen({super.key, this.existingBap});

  @override
  State<TkBapFormScreen> createState() => _TkBapFormScreenState();
}

class _TkBapFormScreenState extends State<TkBapFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _namaController;
  late TextEditingController _tempatController;
  late TextEditingController _waktuMulaiController;
  late TextEditingController _waktuSelesaiController;
  late TextEditingController _pesertaController;
  late TextEditingController _diperiksaController;
  late TextEditingController _layakController;
  late TextEditingController _pantauanController;
  late TextEditingController _tdkLayakController;

  late TextEditingController _ttdKepalaNamaController;
  late TextEditingController _ttdKepalaNikController;
  late TextEditingController _ttdMedisNamaController;
  late TextEditingController _ttdMedisNikController;

  DateTime _selectedDate = DateTime.now();
  String _status = 'DRAFT';
  final List<String> _localPhotoPaths = [];
  final List<String> _uploadedPhotoUrls = [];

  @override
  void initState() {
    super.initState();
    final bap = widget.existingBap;

    if (bap != null && bap.fotoKegiatan != null) {
      try {
        final decoded = jsonDecode(bap.fotoKegiatan!);
        if (decoded is List) {
          _uploadedPhotoUrls.addAll(decoded.map((e) => e.toString()));
        }
      } catch (e) {
        log('Error decoding BAP photos: $e');
      }
    }

    _namaController = TextEditingController(text: bap?.namaKegiatan ?? '');
    _tempatController = TextEditingController(text: bap?.tempat ?? '');
    _waktuMulaiController = TextEditingController(text: bap?.waktuMulai ?? '');
    _waktuSelesaiController = TextEditingController(
      text: bap?.waktuSelesai ?? '',
    );
    _pesertaController = TextEditingController(
      text: bap?.jumlahPeserta.toString() ?? '',
    );
    _diperiksaController = TextEditingController(
      text: bap?.jumlahDiperiksa.toString() ?? '',
    );
    _layakController = TextEditingController(
      text: bap?.totalLayak.toString() ?? '',
    );
    _pantauanController = TextEditingController(
      text: bap?.totalPantauan.toString() ?? '',
    );
    _tdkLayakController = TextEditingController(
      text: bap?.totalTidakLayak.toString() ?? '',
    );

    _ttdKepalaNamaController = TextEditingController(
      text: bap?.ttdKepalaDivisiNama ?? '',
    );
    _ttdKepalaNikController = TextEditingController(
      text: bap?.ttdKepalaDivisiNik ?? '',
    );
    _ttdMedisNamaController = TextEditingController(
      text: bap?.ttdTimMedisNama ?? '',
    );
    _ttdMedisNikController = TextEditingController(
      text: bap?.ttdTimMedisNik ?? '',
    );

    if (bap != null) {
      _selectedDate = bap.tanggalPelaksanaan;
      _status = bap.status;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tempatController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    _pesertaController.dispose();
    _diperiksaController.dispose();
    _layakController.dispose();
    _pantauanController.dispose();
    _tdkLayakController.dispose();
    _ttdKepalaNamaController.dispose();
    _ttdKepalaNikController.dispose();
    _ttdMedisNamaController.dispose();
    _ttdMedisNikController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<TkHealthProvider>();

    if (_localPhotoPaths.isNotEmpty) {
      final newUrls = await provider.uploadBapPhotos(_localPhotoPaths);
      if (newUrls.isEmpty && provider.error != null) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          showDialog(
            context: context,
            builder:
                (context) => CustomDialog(
                  title: 'Gagal Upload Foto',
                  content: provider.error ?? 'Gagal mengunggah foto kegiatan',
                  cancelText: '',
                  confirmText: 'Tutup',
                  isDestructive: true,
                  onCancel: () {},
                  onConfirm: () => Navigator.pop(context),
                ),
          );
        }
        return;
      }
      _uploadedPhotoUrls.addAll(newUrls);
      _localPhotoPaths.clear();
    }

    final data = {
      'nama_kegiatan': _namaController.text,
      'tempat': _tempatController.text,
      'waktu_mulai': _waktuMulaiController.text,
      'waktu_selesai': _waktuSelesaiController.text,
      'jumlah_peserta': int.tryParse(_pesertaController.text) ?? 0,
      'jumlah_diperiksa': int.tryParse(_diperiksaController.text) ?? 0,
      'total_layak': int.tryParse(_layakController.text) ?? 0,
      'total_pantauan': int.tryParse(_pantauanController.text) ?? 0,
      'total_tidak_layak': int.tryParse(_tdkLayakController.text) ?? 0,
      'status': _status,
      'tanggal_pelaksanaan': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'ttd_kepala_divisi_nama': _ttdKepalaNamaController.text,
      'ttd_kepala_divisi_nik': _ttdKepalaNikController.text,
      'ttd_tim_medis_nama': _ttdMedisNamaController.text,
      'ttd_tim_medis_nik': _ttdMedisNikController.text,
      'foto_kegiatan': jsonEncode(_uploadedPhotoUrls),
    };

    bool success;

    if (widget.existingBap == null) {
      success = await provider.createBAP(data);
    } else {
      success = await provider.updateBAP(widget.existingBap!.id, data);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (success && mounted) {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Berhasil',
              content: 'BAP berhasil disimpan',
              cancelText: '',
              confirmText: 'Tutup',
              isSuccess: true,
              onCancel: () {},
              onConfirm: () => Navigator.pop(context),
            ),
      ).then((_) {
        if (mounted) {
          provider.fetchBAPs();
          context.pop();
        }
      });
    } else if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => CustomDialog(
              title: 'Gagal',
              content: provider.error ?? 'Gagal menyimpan BAP',
              cancelText: '',
              confirmText: 'Tutup',
              isDestructive: true,
              onCancel: () {},
              onConfirm: () => Navigator.pop(context),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyFinal = widget.existingBap?.status == 'FINAL';

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: widget.existingBap == null ? 'Buat BAP Baru' : 'Edit BAP',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        actions: [
          if (widget.existingBap != null && !isAlreadyFinal)
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.appColors.onPrimary),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Informasi Kegiatan'),
              _buildCard(
                child: Column(
                  children: [
                    _buildInput(
                      'Nama Kegiatan',
                      _namaController,
                      isAlreadyFinal,
                      isRequired: true,
                      icon: Icons.event_note_rounded,
                      iconColor: context.appColors.info,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInput(
                      'Tempat Pelaksanaan',
                      _tempatController,
                      isAlreadyFinal,
                      icon: Icons.location_on_rounded,
                      iconColor: context.appColors.success,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDatePicker(isAlreadyFinal),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            'Waktu Mulai',
                            _waktuMulaiController,
                            isAlreadyFinal,
                            icon: Icons.access_time_rounded,
                            iconColor: context.appColors.info,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildTimePicker(
                            'Waktu Selesai',
                            _waktuSelesaiController,
                            isAlreadyFinal,
                            icon: Icons.access_time_filled_rounded,
                            iconColor: context.appColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Statistik Pemeriksaan'),
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            'Total Peserta',
                            _pesertaController,
                            isAlreadyFinal,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildNumberInput(
                            'Jml Diperiksa',
                            _diperiksaController,
                            isAlreadyFinal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            'Layak',
                            _layakController,
                            isAlreadyFinal,
                            color:
                                context.watch<ThemeProvider>().colors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildNumberInput(
                            'Pantauan',
                            _pantauanController,
                            isAlreadyFinal,
                            color:
                                context.watch<ThemeProvider>().colors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildNumberInput(
                            'Tdk Layak',
                            _tdkLayakController,
                            isAlreadyFinal,
                            color: context.appColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Penandatangan BAP'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kepala Divisi / Penanggung Jawab',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInput(
                      'Atas Nama',
                      _ttdKepalaNamaController,
                      isAlreadyFinal,
                      icon: Icons.person_rounded,
                      iconColor: context.appColors.info,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInput(
                      'NIK / NIP',
                      _ttdKepalaNikController,
                      isAlreadyFinal,
                      icon: Icons.badge_rounded,
                      iconColor: AppColors.neutral700,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Tim Medis / Tenaga Kesehatan',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInput(
                      'Atas Nama',
                      _ttdMedisNamaController,
                      isAlreadyFinal,
                      icon: Icons.medical_services_rounded,
                      iconColor: context.appColors.success,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInput(
                      'NIK / SIP',
                      _ttdMedisNikController,
                      isAlreadyFinal,
                      icon: Icons.badge_rounded,
                      iconColor: AppColors.neutral700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              _buildPhotoPickerSection(isAlreadyFinal),

              const SizedBox(height: AppSpacing.xl),
              if (!isAlreadyFinal) ...[
                BkuCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: Text(
                      'Tandai sebagai FINAL',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            _status == 'FINAL'
                                ? context.watch<ThemeProvider>().colors.success
                                : AppColors.neutral800,
                      ),
                    ),
                    subtitle: Text(
                      'BAP yang sudah FINAL tidak bisa diubah lagi dan akan menghasilkan PDF resmi.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    value: _status == 'FINAL',
                    activeThumbColor:
                        context.watch<ThemeProvider>().colors.success,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    onChanged: (val) {
                      setState(() => _status = val ? 'FINAL' : 'DRAFT');
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BkuButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  isLoading: _isSubmitting,
                  icon:
                      _status == 'FINAL'
                          ? Icons.check_circle_rounded
                          : Icons.save_rounded,
                  text:
                      _status == 'FINAL'
                          ? 'Simpan & Finalisasi BAP'
                          : 'Simpan DRAFT',
                  variant:
                      _status == 'FINAL'
                          ? BkuButtonVariant.success
                          : BkuButtonVariant.secondary,
                  height: 46,
                  fontSize: 13,
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.titleSm.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.neutral800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPhotoPickerSection(bool isAlreadyFinal) {
    final picker = ImagePicker();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Dokumentasi Kegiatan'),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isAlreadyFinal)
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() {
                        _localPhotoPaths.add(picked.path);
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Pilih Foto Kegiatan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.info,
                    backgroundColor: context.appColors.info.withAlpha(15),
                    side: BorderSide(color: context.appColors.info.withAlpha(30)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.br10,
                    ),
                  ),
                ),
              if (_localPhotoPaths.isNotEmpty ||
                  _uploadedPhotoUrls.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._uploadedPhotoUrls.map((url) {
                      final fullUrl = ApiGate.getImageUrl(url);
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.radiusMd,
                            child: CachedNetworkImage(imageUrl: 
                              fullUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        color: AppColors.neutral500,
                                        size: 24,
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '404 Not Found',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.neutral600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              placeholder: (context, url) => Container(color: AppColors.neutral200),
                            ),
                          ),
                          if (!isAlreadyFinal)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _uploadedPhotoUrls.remove(url);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: context.appColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    ..._localPhotoPaths.map((path) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.radiusMd,
                            child: Image.file(
                              File(path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        color: AppColors.neutral500,
                                        size: 24,
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'File Error',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.neutral600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (!isAlreadyFinal)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _localPhotoPaths.remove(path);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: context.appColors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'Belum ada foto dokumentasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral500),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return BkuCard(padding: const EdgeInsets.all(AppSpacing.xl), child: child);
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    bool readOnly, {
    bool isRequired = false,
    IconData? icon,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? context.appColors.info;
    return BkuTextField(
      controller: controller,
      readOnly: readOnly,
      style: AppTextStyles.bodyMd.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
        filled: true,
        fillColor: readOnly ? AppColors.neutral100 : context.appColors.surface,
        prefixIcon:
            icon != null
                ? Icon(
                  icon,
                  color: effectiveColor,
                  size: 20,
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(
            color: effectiveColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildTimePicker(
    String label,
    TextEditingController controller,
    bool readOnly, {
    required IconData icon,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              TimeOfDay initialTime = TimeOfDay.now();
              if (controller.text.isNotEmpty) {
                final parts = controller.text.split(':');
                if (parts.length >= 2) {
                  final h = int.tryParse(parts[0]);
                  final m = int.tryParse(parts[1]);
                  if (h != null && m != null) {
                    initialTime = TimeOfDay(hour: h, minute: m);
                  }
                }
              }
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );
              if (picked != null) {
                final formatted =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                setState(() => controller.text = formatted);
              }
            },
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: readOnly ? AppColors.neutral100 : context.appColors.surface,
          border: Border.all(color: AppColors.neutral300),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    controller.text.isEmpty ? '--:--' : controller.text,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: controller.text.isEmpty
                          ? AppColors.neutral400
                          : AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    bool readOnly, {
    Color? color,
  }) {
    return BkuTextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: AppTextStyles.titleLg.copyWith(
        fontWeight: FontWeight.w900,
        color: color ?? AppColors.neutral900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelSm.copyWith(
          color: AppColors.neutral500,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: readOnly ? AppColors.neutral100 : AppColors.neutral50,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(
            color: color ?? context.appColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xl,
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool readOnly) {
    return InkWell(
      onTap:
          readOnly
              ? null
              : () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: context.appColors.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: readOnly ? AppColors.neutral100 : context.appColors.surface,
          border: Border.all(color: AppColors.neutral300),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: context.appColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Pelaksanaan',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Hapus BAP?',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: const Text(
              'Data yang dihapus tidak bisa dikembalikan.',
              style: TextStyle(height: 1.5),
            ),

            actionsPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isSubmitting = true);
                  final provider = context.read<TkHealthProvider>();
                  final success = await provider.deleteBAP(widget.existingBap!.id);
                  if (mounted) {
                    setState(() => _isSubmitting = false);
                    if (success) {
                      provider.fetchBAPs();
                      context.pop();
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (context) => CustomDialog(
                              title: 'Gagal',
                              content: provider.error ?? 'Gagal menghapus BAP',
                              cancelText: '',
                              confirmText: 'Tutup',
                              isDestructive: true,
                              onCancel: () {},
                              onConfirm: () => Navigator.pop(context),
                            ),
                      );
                    }
                  }
                },

                child: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
