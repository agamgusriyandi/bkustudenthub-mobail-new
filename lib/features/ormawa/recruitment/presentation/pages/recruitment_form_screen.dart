import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_form_field.dart';

class RecruitmentFormScreen extends StatefulWidget {
  const RecruitmentFormScreen({super.key});

  @override
  State<RecruitmentFormScreen> createState() => _RecruitmentFormScreenState();
}

class _RecruitmentFormScreenState extends State<RecruitmentFormScreen> {
  final List<RecruitmentFormField> _fields = [];
  bool _isLoading = false;

  final List<String> _fieldTypes = [
    'Teks Singkat',
    'Paragraf',
    'Dropdown',
    'Pilihan Ganda',
    'Upload File',
  ];

  @override
  void initState() {
    super.initState();
    _loadFormFields();
  }

  Future<void> _loadFormFields() async {
    final provider = context.read<OrmawaProvider>();
    await provider.getRecruitmentFormFields();

    final fields = provider.recruitmentFormFields;
    if (fields.isNotEmpty && mounted) {
      setState(() {
        _fields.clear();
        for (var i = 0; i < fields.length; i++) {
          final f = fields[i];
          String displayType = 'Teks Singkat';
          final typeVal = (f['type'] ?? '').toString().toLowerCase();
          switch (typeVal) {
            case 'text':
              displayType = 'Teks Singkat';
              break;
            case 'paragraph':
              displayType = 'Paragraf';
              break;
            case 'select':
              displayType = 'Dropdown';
              break;
            case 'checkbox':
              displayType = 'Pilihan Ganda';
              break;
            case 'file':
              displayType = 'Upload File';
              break;
            default:
              if (_fieldTypes.contains(f['type'])) {
                displayType = f['type'];
              } else {
                displayType = 'Teks Singkat';
              }
          }
          _fields.add(
            RecruitmentFormField(
              id: i,
              label: f['label'] ?? '',
              type: displayType,
              options: f['options'] ?? '',
              required: f['required'] ?? false,
            ),
          );
        }
      });
    }
  }

  void _removeField(int index) {
    setState(() => _fields.removeAt(index));
  }

  Future<void> _saveForm() async {
    setState(() => _isLoading = true);
    try {
      final fieldsData =
          _fields.map((f) {
            String dbType = 'text';
            switch (f.type) {
              case 'Teks Singkat':
                dbType = 'text';
                break;
              case 'Paragraf':
                dbType = 'paragraph';
                break;
              case 'Dropdown':
                dbType = 'select';
                break;
              case 'Pilihan Ganda':
                dbType = 'checkbox';
                break;
              case 'Upload File':
                dbType = 'file';
                break;
              default:
                dbType = f.type.toLowerCase();
            }
            return {
              'label': f.label,
              'type': dbType,
              'options': f.options,
              'required': f.required,
            };
          }).toList();

      await context.read<OrmawaProvider>().saveRecruitmentFormFields(
        fieldsData,
      );
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Form berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddFieldSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s20),
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              Text(
                'Pilih Jenis Pertanyaan',
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._fieldTypes.map(
                (type) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Icon(
                      type == 'Teks Singkat'
                          ? Icons.short_text_rounded
                          : type == 'Paragraf'
                          ? Icons.notes_rounded
                          : type == 'Dropdown'
                          ? Icons.arrow_drop_down_circle_rounded
                          : type == 'Pilihan Ganda'
                          ? Icons.check_box_rounded
                          : Icons.upload_file_rounded,
                      color: context.appColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    context.pop();
                    setState(() {
                      _fields.add(
                        RecruitmentFormField(
                          id: DateTime.now().millisecondsSinceEpoch,
                          label: '',
                          type: type,
                          options: '',
                          required: false,
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: const BkuStaticAppBar(title: 'Form Builder'),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    _fields.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.dynamic_form_rounded,
                                size: 64,
                                color: AppColors.neutral300,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Belum ada field',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.neutral600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Tekan tombol + di bawah untuk membuat formulir',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ReorderableListView.builder(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.s20,
                            right: AppSpacing.s20,
                            top: AppSpacing.lg,
                            bottom: AppSpacing.s100,
                          ),
                          itemCount: _fields.length,
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final item = _fields.removeAt(oldIndex);
                              _fields.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              key: ValueKey(_fields[index].id),
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _buildFieldCard(_fields[index], index),
                            );
                          },
                        ),
              ),
              if (_fields.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.onSurface.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,

                      child:
                          _isLoading
                              ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: context.appColors.onPrimary,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Simpan Form',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: _fields.isEmpty ? 20 : 100,
            child: FloatingActionButton(
              heroTag: 'add_field_fab',
              backgroundColor: context.appColors.primary,
              foregroundColor: context.appColors.onPrimary,
              elevation: 4,
              onPressed: _showAddFieldSheet,
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(RecruitmentFormField field, int index) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: context.appColors.outline.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.drag_indicator_rounded,
                  color: AppColors.neutral500,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusXs,
                  ),
                  child: Text(
                    'Field ${index + 1}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _removeField(index),
                  child: Container(
                    padding: AppSpacing.padding6,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: field.label)
                    ..selection = TextSelection.collapsed(
                      offset: field.label.length,
                    ),
                  decoration: InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (value) => field.label = value,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: field.type,
                  decoration: InputDecoration(
                    labelText: 'Tipe Field',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  items:
                      _fieldTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    setState(() => field.type = value!);
                  },
                ),
                if (field.type == 'Dropdown' ||
                    field.type == 'Pilihan Ganda') ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: TextEditingController(text: field.options)
                      ..selection = TextSelection.collapsed(
                        offset: field.options.length,
                      ),
                    decoration: InputDecoration(
                      labelText: 'Opsi (pisahkan dengan koma)',
                      hintText: 'Opsi 1, Opsi 2, Opsi 3',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    onChanged: (value) => field.options = value,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Switch(
                      value: field.required,
                      onChanged: (val) {
                        setState(() => field.required = val);
                      },
                      activeThumbColor: context.appColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Wajib diisi',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

