import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:intl/intl.dart';

class AssignmentScreen extends StatefulWidget {
  final Mission mission;

  const AssignmentScreen({super.key, required this.mission});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  Map<String, dynamic>? _assignmentData;
  Map<String, dynamic>? _submissionData;

  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isFileUploading = false;

  @override
  void initState() {
    super.initState();
    _loadAssignment();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignment() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final id = widget.mission.id;
      final response = await ApiClient().client.get(
        '/kencana-student/assignments/$id',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        setState(() {
          _assignmentData = data['assignment'] as Map<String, dynamic>?;
          _submissionData = data['submission'] as Map<String, dynamic>?;

          if (_submissionData != null && _submissionData!['id'] != 0) {
            _answerController.text = _submissionData!['answer_text'] ?? '';
            _linkController.text = _submissionData!['link_url'] ?? '';
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = response.data['message'] ?? 'Gagal memuat tugas';
          _isLoading = false;
        });
      }
    } catch (e) {
      String errorMessage = 'Tidak dapat terhubung ke server.';
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'].toString();
        } else {
          errorMessage = 'Dio Error: ${e.response?.statusCode}';
        }
      }
      setState(() {
        _errorMsg = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'mp4'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadFile(PlatformFile file) async {
    try {
      setState(() {
        _isFileUploading = true;
      });
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await ApiClient().client.post(
        '/kencana-student/upload',
        data: formData,
      );
      setState(() {
        _isFileUploading = false;
      });

      if (response.data != null && response.data['success'] == true) {
        return response.data['url']?.toString();
      }
      return null;
    } catch (e) {
      setState(() {
        _isFileUploading = false;
      });
      return null;
    }
  }

  Future<void> _submitAssignment() async {
    final type = _assignmentData?['submission_type'] ?? 'text';

    if (type == 'text' && _answerController.text.trim().isEmpty) {
      _showError('Jawaban teks tidak boleh kosong');
      return;
    }
    if (type == 'link' && _linkController.text.trim().isEmpty) {
      _showError('Tautan tidak boleh kosong');
      return;
    }
    if ((type == 'file' || type == 'media') &&
        _selectedFile == null &&
        (_submissionData == null || _submissionData!['file_url'] == '')) {
      _showError('Pilih file terlebih dahulu');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String fileUrl = _submissionData?['file_url'] ?? '';
      if ((type == 'file' || type == 'media') && _selectedFile != null) {
        final uploadedUrl = await _uploadFile(_selectedFile!);
        if (uploadedUrl == null) {
          _showError('Gagal mengunggah file. Silakan coba lagi.');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        fileUrl = uploadedUrl;
      }

      final payload = {
        'answer_text': type == 'text' ? _answerController.text.trim() : '',
        'file_url': (type == 'file' || type == 'media') ? fileUrl : '',
        'link_url': type == 'link' ? _linkController.text.trim() : '',
        'checklist': true,
      };

      final id = widget.mission.id;
      final response = await ApiClient().client.post(
        '/kencana-student/assignments/$id/submit',
        data: payload,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (response.data['success'] == true) {
        if (!mounted) return;
        AppSnackbar.showSuccess(context, 'Tugas berhasil dikumpulkan');
        Navigator.pop(context, true);
      } else {
        _showError(response.data['message'] ?? 'Gagal mengumpulkan tugas');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError('Terjadi kesalahan koneksi');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    AppSnackbar.showError(context, msg);
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '-';
    try {
      final dt = DateTime.parse(dateTime.toString()).toLocal();
      if (dt.hour == 0 && dt.minute == 0) {
        return DateFormat('dd MMM yyyy').format(dt);
      }
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return dateTime.toString();
    }
  }

  bool _isPastDue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Detail Tugas',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: BkuShimmerList(itemCount: 4, itemHeight: 100),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: context.appColors.error,
                size: 60,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _errorMsg!,
                style: AppTextStyles.labelLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s20),
              BkuButton(
                onPressed: _loadAssignment,
                icon: Icons.refresh_rounded,
                text: 'Coba Lagi',
              ),
            ],
          ),
        ),
      );
    }

    if (_assignmentData == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    final title = _assignmentData!['title'] ?? 'Tugas';
    final desc = _assignmentData!['description'] ?? '';
    final dueDateStr = _assignmentData!['due_date'];
    final subType = _assignmentData!['submission_type'] ?? 'text';

    DateTime? dueDate;
    if (dueDateStr != null) {
      try {
        dueDate = DateTime.parse(dueDateStr.toString()).toLocal();
      } catch (_) {}
    }

    final subStatus = _submissionData?['status'] ?? 'not_submitted';
    final bool isSubmitted =
        subStatus == 'submitted' ||
        subStatus == 'late' ||
        subStatus == 'graded';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Clean
          Text(
            title,
            style: BkuTheme.textPageTitle.copyWith(fontSize: 19),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color:
                    _isPastDue(dueDate)
                        ? AppColors.error
                        : BkuTheme.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tenggat: ${_formatDateTime(dueDateStr)}',
                style: BkuTheme.textCardTitle.copyWith(
                  fontSize: 12,
                  color:
                      _isPastDue(dueDate)
                          ? AppColors.error
                          : BkuTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          if (desc.isNotEmpty) ...[
            Text(
              'Deskripsi Tugas',
              style: BkuTheme.textSectionTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              desc,
              style: BkuTheme.textBodyRegular.copyWith(height: 1.6),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          Text(
            'Pengumpulan',
            style: BkuTheme.textSectionTitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (isSubmitted)
            _buildSubmittedState(subStatus)
          else
            _buildInputArea(subType),

          const SizedBox(height: AppSpacing.xxxl),

          if (!isSubmitted)
            BkuButton(
              onPressed: _submitAssignment,
              text: _submissionData != null && _submissionData!['status'] != null ? 'Update Tugas' : 'Kumpulkan Tugas',
              isLoading: _isSubmitting || _isFileUploading,
              variant: BkuButtonVariant.primary,
              customBgColor: _submissionData != null && _submissionData!['status'] != null ? AppColors.warning : null,
            ),
        ],
      ),
    );
  }

  Widget _buildSubmittedState(String status) {
    Color statusColor = AppColors.success;
    String statusText = 'Sudah Dikumpulkan';
    if (status == 'late') {
      statusColor = AppColors.warning;
      statusText = 'Dikumpulkan Terlambat';
    } else if (status == 'graded') {
      statusColor = context.appColors.primary;
      statusText = 'Sudah Dinilai';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: statusColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                ),
                if (status == 'graded' &&
                    _submissionData?['score'] != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Nilai: ${_submissionData!['score']}',
                    style: BkuTheme.textCaption.copyWith(
                      color: BkuTheme.primary,
                      fontWeight: FontWeight.w700,
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

  Widget _buildInputArea(String type) {
    if (type == 'text') {
      return BkuTextField(
        controller: _answerController,
        minLines: 6,
        maxLines: 6,
        hint: 'Ketik jawaban Anda di sini...',
      );
    } else if (type == 'link') {
      return BkuTextField(
        controller: _linkController,
        hint: 'https://...',
        prefixIcon: const Icon(Icons.link_rounded),
      );
    } else if (type == 'file' || type == 'media') {
      return InkWell(
        onTap: _pickFile,
        borderRadius: BkuTheme.r16,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xxl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: _selectedFile != null
                ? BkuTheme.primarySoft
                : BkuTheme.cardSurface,
            borderRadius: BkuTheme.r16,
            border: Border.all(
              color: _selectedFile != null
                  ? BkuTheme.primary
                  : BkuTheme.border,
              width: _selectedFile != null ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? BkuTheme.primarySoft
                      : BkuTheme.slateSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedFile != null
                      ? Icons.file_present_rounded
                      : Icons.cloud_upload_rounded,
                  size: 28,
                  color: _selectedFile != null
                      ? BkuTheme.primary
                      : BkuTheme.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _selectedFile != null
                    ? _selectedFile!.name
                    : 'Pilih file untuk diunggah',
                style: BkuTheme.textCardTitle.copyWith(
                  color:
                      _selectedFile != null
                          ? BkuTheme.primary
                          : BkuTheme.textHeading,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFile == null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Format: PDF, DOCX, JPG, PNG, MP4',
                  style: BkuTheme.textCaption,
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return const Text('Tipe pengumpulan tidak dikenali');
    }
  }
}
