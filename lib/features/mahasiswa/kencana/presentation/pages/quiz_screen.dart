import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';

class QuizScreen extends StatefulWidget {
  final Mission mission;

  const QuizScreen({super.key, required this.mission});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // State mesin kuis
  bool _isLoadingSoal = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  List<Map<String, dynamic>> _questions = [];
  String _quizTitle = 'Kuis Evaluasi';
  int _durasiMenit = 30;
  int _passingGrade = 70;
  int _currentQuestionIndex = 0;
  final Map<String, int> _jawaban = {};
  final Map<String, String> _jawabanEssay = {};
  late final TextEditingController _essayController = TextEditingController();
  int? _attemptId;

  Timer? _timer;
  int _timeLeft = 0;

  bool _isFinished = false;
  double _nilaiAkhir = 0;
  bool _lulus = false;
  int _jumlahBenar = 0;
  int _jumlahSalah = 0;
  double _nilaiKumulatif = 0;
  int _attemptsUsed = 0;
  int _maxAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _essayController.dispose();
    super.dispose();
  }

  // ─── Load soal dari API ──────────────────────────────────────────────────

  Future<void> _loadSoal() async {
    setState(() {
      _isLoadingSoal = true;
      _errorMsg = null;
    });
    try {
      final kuisId = widget.mission.id;
      final response = await ApiClient().client.get(
        '/kencana-student/quizzes/$kuisId',
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final rawSoal = data['questions'] as List? ?? [];

        setState(() {
          _quizTitle =
              data['title']?.toString() ??
              widget.mission.title ??
              'Kuis Evaluasi';
          _durasiMenit = (data['duration_minutes'] as num?)?.toInt() ?? 30;
          _passingGrade = (data['passing_grade'] as num?)?.toInt() ?? 70;
          _timeLeft = _durasiMenit * 60;
          _questions = List<Map<String, dynamic>>.from(rawSoal);
          if (_questions.isNotEmpty) {
            final firstQ = _questions[0];
            if (firstQ['question_type']?.toString().toLowerCase() == 'essay') {
              _essayController.text = '';
            }
          }
        });

        final maxAttempts = (data['max_attempts'] as num?)?.toInt() ?? 0;
        final attemptsUsed = (data['attempts_used'] as num?)?.toInt() ?? 0;
        final lastAttempt =
            data['last_attempt'] as Map<String, dynamic>? ??
            data['latest_attempt'] as Map<String, dynamic>?;

        if (attemptsUsed > 0 && lastAttempt != null) {
          setState(() {
            _nilaiAkhir = (lastAttempt['score'] as num?)?.toDouble() ?? 0.0;
            _lulus = lastAttempt['passed'] == true;
            _jumlahBenar = (lastAttempt['correct_count'] as num?)?.toInt() ?? 0;
            final totalQuestions =
                (lastAttempt['total_questions'] as num?)?.toInt() ?? 0;
            _jumlahSalah = totalQuestions - _jumlahBenar;
            _nilaiKumulatif = _nilaiAkhir;

            _attemptsUsed = attemptsUsed;
            _maxAttempts = maxAttempts;
            _isFinished = true;
            _isLoadingSoal = false;
          });
          return;
        }

        final canStart = data['can_start'] == true;
        if (!canStart) {
          setState(() {
            _errorMsg =
                data['lock_reason']?.toString() ?? 'Kuis tidak dapat dimulai.';
            _isLoadingSoal = false;
          });
          return;
        }

        // Start attempt
        final attemptResponse = await ApiClient().client.post(
          '/kencana-student/quizzes/$kuisId/start',
        );
        if (attemptResponse.data['success'] == true) {
          setState(() {
            _attemptId =
                attemptResponse.data['data']['ID'] ??
                attemptResponse.data['data']['id'];
            _attemptsUsed = attemptsUsed + 1;
            _maxAttempts = maxAttempts;
            _isLoadingSoal = false;
          });
          _startTimer();
        } else {
          setState(() {
            _errorMsg =
                attemptResponse.data['message'] ??
                'Gagal memulai percobaan kuis';
            _isLoadingSoal = false;
          });
        }
      } else {
        setState(() {
          _errorMsg = response.data['message'] ?? 'Gagal memuat soal';
          _isLoadingSoal = false;
        });
      }
    } catch (e) {
      String errorMessage =
          'Tidak dapat terhubung ke server. Pastikan Anda sudah terdaftar atau sesi sedang aktif.';
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'].toString();
        } else {
          errorMessage =
              'Dio Error: ${e.response?.statusCode} - ${e.response?.data}';
        }
      } else {
        errorMessage = 'Error: $e';
      }
      setState(() {
        _errorMsg = errorMessage;
        _isLoadingSoal = false;
      });
    }
  }

  // ─── Timer ──────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitKuis(); // Otomatis kumpul saat waktu habis
      }
    });
  }

  String _getFormattedTime() {
    final m = (_timeLeft / 60).floor();
    final s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isTimeAlmostUp => _timeLeft <= 60 && _timeLeft > 0;

  // ─── Submit ke API ───────────────────────────────────────────────────────

  Future<void> _submitKuis() async {
    _timer?.cancel();
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      if (_attemptId == null) {
        _showError('Sesi ujian tidak valid.');
        setState(() => _isSubmitting = false);
        return;
      }

      final answers =
          _questions.map((q) {
            final qId = q['id'].toString();
            final isEssay =
                q['question_type']?.toString().toLowerCase() == 'essay';
            if (isEssay) {
              return {
                'question_id': int.tryParse(qId) ?? 0,
                'selected_option_id': null,
                'answer_text': _jawabanEssay[qId] ?? '',
              };
            } else {
              return {
                'question_id': int.tryParse(qId) ?? 0,
                'selected_option_id': _jawaban[qId],
                'answer_text': '',
              };
            }
          }).toList();

      final response = await ApiClient().client.post(
        '/kencana-student/quiz-attempts/$_attemptId/submit',
        data: {'answers': answers},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final nilai = (data['nilai'] ?? 0.0).toDouble();
        final lulus = data['lulus'] == true;
        final jumlahBenar = (data['jumlah_benar'] ?? 0) as int;
        final nilaiKumulatif =
            (data['nilai_kumulatif_terbaru'] ?? 0.0).toDouble();

        // Update provider agar progress kencana refresh
        if (mounted) {
          context.read<StudentProvider>().loadAllData();
        }

        setState(() {
          _nilaiAkhir = nilai;
          _lulus = lulus;
          _jumlahBenar = jumlahBenar;
          _jumlahSalah = _questions.length - jumlahBenar;
          _nilaiKumulatif = nilaiKumulatif;
          _isFinished = true;
          _isSubmitting = false;
        });
      } else {
        _showError(response.data['message'] ?? 'Gagal mengumpulkan kuis');
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      _showError('Gagal mengirim jawaban. Periksa koneksi internet kamu.');
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    AppSnackbar.showSuccess(context, msg);
  }

  // ─── Navigasi soal ───────────────────────────────────────────────────────

  void _updateQuestionIndex(int newIndex) {
    setState(() {
      _currentQuestionIndex = newIndex;
      final nextQ = _questions[newIndex];
      final nextQId = nextQ['id'].toString();
      final isEssay =
          nextQ['question_type']?.toString().toLowerCase() == 'essay';
      if (isEssay) {
        _essayController.text = _jawabanEssay[nextQId] ?? '';
      }
    });
  }

  void _handleNext() {
    final currentQ = _questions[_currentQuestionIndex];
    final qId = currentQ['id'].toString();
    final isEssay =
        currentQ['question_type']?.toString().toLowerCase() == 'essay';

    if (isEssay) {
      final answer = _jawabanEssay[qId] ?? '';
      if (answer.trim().isEmpty) {
        AppSnackbar.showError(context, 'Tulis jawaban essay terlebih dahulu.');
        return;
      }
    } else {
      if (_jawaban[qId] == null) {
        AppSnackbar.showError(
          context,
          'Pilih salah satu jawaban terlebih dahulu.',
        );
        return;
      }
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _updateQuestionIndex(_currentQuestionIndex + 1);
    } else {
      _submitKuis();
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSoal) return _buildLoading();
    if (_errorMsg != null) return _buildError();
    if (_isFinished) return _buildResultView();
    if (_questions.isEmpty) return _buildEmptySoal();

    final currentQ = _questions[_currentQuestionIndex];
    final qId = currentQ['id'].toString();
    final opts =
        (currentQ['options'] as List? ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: _quizTitle,
            info: '${_questions.length} Pertanyaan • $_durasiMenit Menit',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: nomor soal + timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withAlpha(60),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Text(
                          'Soal ${_currentQuestionIndex + 1}/${_questions.length}',
                          style: AppTextStyles.labelSm.copyWith(
                            color:
                                context.appColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _isTimeAlmostUp
                                  ? AppColors.error.withAlpha(15)
                                  : Colors.transparent,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color:
                                  _isTimeAlmostUp
                                      ? AppColors.error
                                      : context.appColors.outline,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              _getFormattedTime(),
                              style: AppTextStyles.labelMd.copyWith(
                                color:
                                    _isTimeAlmostUp
                                        ? AppColors.error
                                        : AppColors.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Progress bar
                  ClipRRect(
                    borderRadius: AppRadius.radiusXs,
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      backgroundColor: AppColors.neutral200,
                      color: AppColors.neutral600,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Pertanyaan
                  Text(
                    currentQ['question_text']?.toString() ?? '',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Opsi jawaban / Essay field
                  if (currentQ['question_type']?.toString().toLowerCase() ==
                      'essay')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentQ['answer_guidance'] != null &&
                            currentQ['answer_guidance']
                                .toString()
                                .trim()
                                .isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: context.appColors.infoContainer,
                              border: Border.all(color: context.appColors.info.withAlpha(60)),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: context.appColors.onInfo,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Panduan Jawaban',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.onInfo,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s2),
                                      Text(
                                        currentQ['answer_guidance'].toString(),
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: context.appColors.onInfo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        TextField(
                          controller: _essayController,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onChanged: (val) {
                            _jawabanEssay[qId] = val;
                          },
                          decoration: InputDecoration(
                            hintText: 'Tulis jawaban Anda di sini...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withAlpha(120),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusLg,
                              borderSide: BorderSide(
                                color: AppColors.neutral600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                            contentPadding: const EdgeInsets.all(AppSpacing.lg),
                          ),
                          style: AppTextStyles.bodyMd,
                        ),
                      ],
                    )
                  else
                    ...opts.map((opt) {
                      final optId = (opt['id'] as num).toInt();
                      final isSelected = _jawaban[qId] == optId;
                      return _buildOption(
                        qId: qId,
                        optId: optId,
                        text: opt['option_text']?.toString() ?? '',
                        isSelected: isSelected,
                      );
                    }),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Tombol lanjut / kumpul
                  BkuButton(
                    onPressed: _handleNext,
                    text:
                        _currentQuestionIndex == _questions.length - 1
                            ? 'Selesai & Kumpulkan'
                            : 'Pertanyaan Selanjutnya',
                    isLoading: _isSubmitting,
                    variant: BkuButtonVariant.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Navigasi soal (dot row)
                  _buildDotNavigation(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String qId,
    required int optId,
    required String text,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () => setState(() => _jawaban[qId] = optId),
        borderRadius: AppRadius.radiusLg,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? context.appColors.primary.withAlpha(15)
                                        : context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color:
                  isSelected
                      ? context.appColors.primary
                      : AppColors.neutral200,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? context.appColors.primary
                            : AppColors.neutral300,
                    width: 2,
                  ),
                  color:
                      isSelected
                          ? context.appColors.primary
                          : Colors.transparent,
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, color: context.appColors.surface, size: 14)
                        : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.primary,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotNavigation() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_questions.length, (i) {
          final qId = (_questions[i]['id'] ?? '').toString();
          final isEssay =
              (_questions[i]['question_type'] ?? '').toString().toLowerCase() ==
              'essay';
          final answered =
              isEssay
                  ? (_jawabanEssay[qId]?.trim().isNotEmpty ?? false)
                  : _jawaban.containsKey(qId);
          final isCurrent = i == _currentQuestionIndex;
          return GestureDetector(
            onTap: () => _updateQuestionIndex(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: isCurrent ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color:
                    isCurrent
                        ? context.appColors.primary
                        : answered
                        ? context.appColors.primary.withAlpha(60)
                        : AppThemeColors.surfaceContainerHighest,
                borderRadius: AppRadius.radiusXs,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Layar loading, error, hasil ────────────────────────────────────────

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'MEMUAT KUIS',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
            showNotification: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.s20),
                  const BkuShimmerList(itemCount: 4, itemHeight: 72),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final msg = _errorMsg?.toLowerCase() ?? '';
    final isClosed =
        msg.contains('tutup') ||
        msg.contains('ditutup') ||
        msg.contains('selesai') ||
        msg.contains('lock') ||
        msg.contains('berakhir');

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: BkuStaticAppBar(
        title: isClosed ? 'Kuis Sudah Ditutup' : 'Evaluasi Kuis',
        variant: AppBarVariant.student,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color:
                        isClosed
                            ? AppColors.neutral100
                            : context.appColors.errorContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isClosed
                              ? AppColors.neutral400
                              : context.appColors.error.withAlpha(150),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isClosed
                        ? Icons.lock_clock_rounded
                        : Icons.error_outline_rounded,
                    size: 44,
                    color:
                        isClosed
                            ? AppColors.neutral700
                            : context.appColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  isClosed ? 'Kuis Sudah Ditutup' : 'Gagal Memuat Kuis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  _errorMsg ??
                      'Batas waktu pengerjaan kuis ini telah selesai atau kuis sudah ditutup oleh panitia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (isClosed)
                  SizedBox(
                    width: double.infinity,
                    child: BkuButton(
                      onPressed: () => Navigator.pop(context),
                      text: 'Kembali',
                      variant: BkuButtonVariant.primary,
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: BkuButton(
                          onPressed: () => Navigator.pop(context),
                          text: 'Kembali',
                          variant: BkuButtonVariant.outline,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BkuButton(
                          onPressed: _loadSoal,
                          icon: Icons.refresh_rounded,
                          text: 'Coba Lagi',
                          variant: BkuButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySoal() {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 72,
              color: context.appColors.outline.withAlpha(80),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Soal belum tersedia',
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNewAttempt() async {
    setState(() {
      _isLoadingSoal = true;
      _errorMsg = null;
      _isFinished = false;
      _jawaban.clear();
      _jawabanEssay.clear();
      _currentQuestionIndex = 0;
    });
    try {
      final kuisId = widget.mission.id;
      final attemptResponse = await ApiClient().client.post(
        '/kencana-student/quizzes/$kuisId/start',
      );
      if (attemptResponse.data['success'] == true) {
        setState(() {
          _attemptId =
              attemptResponse.data['data']['ID'] ??
              attemptResponse.data['data']['id'];
          _attemptsUsed++;
          _isLoadingSoal = false;
        });
        _startTimer();
      } else {
        setState(() {
          _errorMsg = attemptResponse.data['message'] ?? 'Gagal memulai kuis';
          _isLoadingSoal = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memulai kuis: $e';
        _isLoadingSoal = false;
      });
    }
  }

  Widget _buildResultView() {
    final lulus = _lulus;
    final skor = _nilaiAkhir.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon hasil
              Container(
                padding: AppSpacing.padding28,
                decoration: BoxDecoration(
                  color: (lulus ? AppColors.success : AppColors.warning)
                      .withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  lulus ? Icons.verified_rounded : Icons.emoji_events_outlined,
                  color: lulus ? AppColors.success : AppColors.warning,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                lulus ? 'Selamat, Kamu Lulus! 🎉' : 'Kuis Selesai',
                style: AppTextStyles.display.copyWith(
                  color: context.appColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                lulus
                    ? 'Kamu berhasil melewati batas minimum nilai $_passingGrade.'
                    : 'Nilai minimum adalah $_passingGrade. Kamu masih bisa mencoba lagi.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.appColors.outline,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Kartu skor
              Container(
                width: double.infinity,
                padding: AppSpacing.padding28,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: AppColors.neutral200.withAlpha(150),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'SKOR KAMU',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      skor,
                      style: AppTextStyles.display.copyWith(
                        color: lulus ? AppColors.success : AppColors.warning,
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'dari 100',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultStat(
                          '$_jumlahBenar',
                          'Jawaban\nBenar',
                          Icons.check_circle_outline_rounded,
                          AppColors.success,
                        ),
                        _buildResultStat(
                          '$_jumlahSalah',
                          'Jawaban\nSalah',
                          Icons.cancel_outlined,
                          AppColors.error,
                        ),
                        _buildResultStat(
                          _nilaiKumulatif.toStringAsFixed(0),
                          'Nilai\nKumulatif',
                          Icons.analytics_rounded,
                          context.appColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              if (_maxAttempts == 0 || _attemptsUsed < _maxAttempts) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BkuButton(
                    onPressed: _startNewAttempt,
                    text:
                        _maxAttempts > 0
                            ? 'Kerjakan Ulang (Sisa: ${_maxAttempts - _attemptsUsed})'
                            : 'Kerjakan Ulang',
                    variant: BkuButtonVariant.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BkuButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Kembali ke Journey',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.titleLg.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
