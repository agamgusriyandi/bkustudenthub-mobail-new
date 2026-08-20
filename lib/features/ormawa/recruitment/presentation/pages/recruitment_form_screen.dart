import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
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
      final fieldsData = _fields.map((f) {
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
        AppSnackbar.showSuccess(context, 'Formulir berhasil disimpan');
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: BkuTheme.border,
                  borderRadius: BkuTheme.r8,
                ),
              ),
              Text(
                'Pilih Jenis Pertanyaan',
                style: BkuTheme.textCardTitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._fieldTypes.map(
                (type) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: BkuTheme.primarySoft,
                      borderRadius: BkuTheme.r8,
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
                      color: BkuTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type,
                    style: BkuTheme.textBodyRegular.copyWith(
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
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Form Builder',
        subtitle: 'Kustomisasi Formulir Pendaftaran',
        variant: AppBarVariant.ormawa,
      ),
      body: Column(
        children: [
          Expanded(
            child: _fields.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: BkuEmptyState(
                        title: 'Belum Ada Field Formulir',
                        message: 'Tambahkan pertanyaan khusus untuk calon pendaftar ormawa.',
                        buttonText: '+ Tambah Field Baru',
                        onButtonPressed: _showAddFieldSheet,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: BkuTheme.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BkuButton.outline(
                      onPressed: _showAddFieldSheet,
                      icon: Icons.add_rounded,
                      text: 'Tambah Field',
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BkuButton.primary(
                      onPressed: _isLoading ? null : _saveForm,
                      isLoading: _isLoading,
                      icon: Icons.save_rounded,
                      text: 'Simpan Form',
                      height: 44,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(RecruitmentFormField field, int index) {
    return BkuCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: BkuTheme.borderSubtle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drag_indicator_rounded,
                  color: BkuTheme.textMuted,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: BkuTheme.primarySoft,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Text(
                    'Field ${index + 1}',
                    style: TextStyle(
                      color: BkuTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _removeField(index),
                  borderRadius: BkuTheme.r8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: BkuTheme.roseSoft,
                      borderRadius: BkuTheme.r8,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: BkuTheme.rose,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BkuTextField(
                  label: 'PERTANYAAN *',
                  hint: 'Tuliskan pertanyaan...',
                  controller: TextEditingController(text: field.label)
                    ..selection = TextSelection.collapsed(
                      offset: field.label.length,
                    ),
                  onChanged: (value) => field.label = value,
                ),
                const SizedBox(height: 10),
                BkuDropdown<String>(
                  label: 'Tipe Field',
                  value: field.type,
                  items: _fieldTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => field.type = value);
                    }
                  },
                ),
                if (field.type == 'Dropdown' || field.type == 'Pilihan Ganda') ...[
                  const SizedBox(height: 10),
                  BkuTextField(
                    label: 'OPSI PILIHAN (PISAHKAN DENGAN KOMA)',
                    hint: 'Opsi 1, Opsi 2, Opsi 3',
                    controller: TextEditingController(text: field.options)
                      ..selection = TextSelection.collapsed(
                        offset: field.options.length,
                      ),
                    onChanged: (value) => field.options = value,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: field.required,
                      onChanged: (val) {
                        setState(() => field.required = val);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: BkuTheme.primary,
                      inactiveThumbColor: BkuTheme.textPlaceholder,
                      inactiveTrackColor: BkuTheme.borderSubtle,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Wajib diisi (Required)',
                      style: BkuTheme.textCaption.copyWith(
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
