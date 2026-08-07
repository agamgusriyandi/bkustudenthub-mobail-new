import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
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
  bool _essayGraded = true;
  bool _hasStarted = false;
  int _jumlahBenar = 0;
  int _jumlahSalah = 0;
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
            _essayGraded = lastAttempt['essay_graded'] == true || lastAttempt['essay_graded'] == null;

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

        setState(() {
          _isLoadingSoal = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasStarted && !_isFinished) {
            _showQuizStartDialog();
          }
        });
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

  Future<void> _startKuis() async {
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
          _hasStarted = true;
        });
        _startTimer();
      }
    } catch (e) {
      _showError('Gagal memulai kuis');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitKuis();
      }
    });
  }

  String _getFormattedTime() {
    final m = (_timeLeft / 60).floor();
    final s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isTimeAlmostUp => _timeLeft <= 60 && _timeLeft > 0;

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

        setState(() {
          _nilaiAkhir = nilai;
          _lulus = lulus;
          _jumlahBenar = jumlahBenar;
          _jumlahSalah = _questions.length - jumlahBenar;
          _isFinished = true;
          _isSubmitting = false;
          _essayGraded = data['essay_graded'] == true || data['essay_graded'] == null;
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
    AppSnackbar.showError(context, msg);
  }

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
      final int totalDijawab = _jawaban.length + _jawabanEssay.length;
      if (totalDijawab < _questions.length) {
        AppSnackbar.showError(
          context,
          'Anda belum mengisi SELURUH SOAL. Pastikan semua soal terjawab sebelum mengumpulkan.',
        );
        return;
      }
      _submitKuis();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSoal) return _buildLoading();
    if (_errorMsg != null) return _buildError();
    if (_isFinished) return _buildResultView();
    if (_questions.isEmpty) return _buildEmptySoal();
    if (!_hasStarted) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentQ = _questions[_currentQuestionIndex];
    final qId = currentQ['id'].toString();
    final opts =
        (currentQ['options'] as List? ?? []).cast<Map<String, dynamic>>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: context.appColors.surface,
        body: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: _quizTitle,
              info: '${_questions.length} Pertanyaan • $_durasiMenit Menit',
              variant: AppBarVariant.secondary,
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
                            ).colorScheme.outlineVariant.withValues(alpha: 0.24),
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
                                    ? AppColors.error.withValues(alpha: 0.06)
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
                    Text(
                      currentQ['question_text']?.toString() ?? '',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (currentQ['question_type']?.toString().toLowerCase() ==
                        'essay')
                      TextField(
                        controller: _essayController,
                        maxLines: 6,
                        onChanged: (val) {
                          _jawabanEssay[qId] = val;
                        },
                        decoration: InputDecoration(
                          hintText: 'Tulis jawaban Anda di sini...',
                          border: OutlineInputBorder(borderRadius: AppRadius.radiusLg),
                        ),
                      )
                    else
                      ...opts.map((opt) {
                        final optId = (opt['id'] as num).toInt();
                        return _buildOption(
                          qId: qId,
                          optId: optId,
                          text: opt['option_text']?.toString() ?? '',
                          isSelected: _jawaban[qId] == optId,
                        );
                      }),
                    const SizedBox(height: AppSpacing.xxxl),
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
                    _buildDotNavigation(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar Kuis?',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Waktu akan terus berjalan jika Anda keluar. Anda yakin ingin kembali?',
          style: AppTextStyles.bodySm.copyWith(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.labelLg.copyWith(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Ya, Keluar', style: AppTextStyles.labelLg.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showQuizStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(AppSpacing.xxl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fact_check_outlined, color: Colors.blue, size: 40),
            const SizedBox(height: AppSpacing.xl),
            Text('Mulai $_quizTitle?', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal'))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: BkuButton(text: 'Mulai', onPressed: () { Navigator.pop(ctx); _startKuis(); })),
              ],
            ),
          ],
        ),
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: isSelected ? context.appColors.primary.withValues(alpha: 0.06) : context.appColors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: isSelected ? context.appColors.primary : AppColors.neutral200),
          ),
          child: Row(
            children: [
              Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: context.appColors.primary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text(text)),
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
          final isEssay = (_questions[i]['question_type'] ?? '').toString().toLowerCase() == 'essay';
          final answered = isEssay ? (_jawabanEssay[qId]?.trim().isNotEmpty ?? false) : _jawaban.containsKey(qId);
          final isCurrent = i == _currentQuestionIndex;
          return GestureDetector(
            onTap: () => _updateQuestionIndex(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: isCurrent ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isCurrent ? context.appColors.primary : (answered ? context.appColors.primary.withValues(alpha: 0.24) : AppColors.neutral200),
                borderRadius: AppRadius.radiusXs,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading() => const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _buildError() => Scaffold(body: Center(child: Text(_errorMsg!)));

  Widget _buildEmptySoal() => const Scaffold(body: Center(child: Text('Soal tidak ditemukan')));


  Widget _buildResultView() {
    final isPending = !_essayGraded;
    final lulus = _lulus;
    final skor = _nilaiAkhir.toStringAsFixed(0);
    
    final color = isPending ? Colors.orange : (lulus ? context.appColors.success : context.appColors.error);
    final icon = isPending ? Icons.more_horiz : (lulus ? Icons.check_circle_outline : Icons.cancel_outlined);
    final title = isPending ? 'Menunggu Penilaian Essay' : (lulus ? 'Selamat!' : 'Oops!');
    final subtitle = isPending
        ? 'Jawaban Anda sedang menunggu penilaian oleh fasilitator.'
        : (lulus
            ? 'Anda telah berhasil lulus dari kuis ini.'
            : 'Nilai Anda belum mencapai batas kelulusan.');

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            title: 'Hasil Kuis',
            variant: AppBarVariant.secondary,
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 40),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    title,
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.appColors.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  if (isPending) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade800),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Kuis ini mengandung soal essay yang memerlukan penilaian manual oleh fasilitator. Hasil akhir dan nilai Anda akan muncul setelah dinilai.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: Colors.orange.shade900,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'MENUNGGU KONFIRMASI',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Nilai Anda',
                            style: AppTextStyles.labelLg.copyWith(
                              color: context.appColors.outline,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            skor,
                            style: AppTextStyles.display.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const Divider(),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildResultStat(
                                '$_jumlahBenar',
                                'Benar',
                                Icons.check_circle_outline,
                                context.appColors.success,
                              ),
                              _buildResultStat(
                                '$_jumlahSalah',
                                'Salah',
                                Icons.cancel_outlined,
                                context.appColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: BkuButton(
                      text: 'Kembali ke Beranda',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!isPending && !lulus && _attemptsUsed < _maxAttempts)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: BkuButton(
                        text: 'Ulangi Kuis',
                        onPressed: () {
                          setState(() {
                            _isFinished = false;
                            _hasStarted = false;
                          });
                          _loadSoal();
                        },
                        variant: BkuButtonVariant.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
