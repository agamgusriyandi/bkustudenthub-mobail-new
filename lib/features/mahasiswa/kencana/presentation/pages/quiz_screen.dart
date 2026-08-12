import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import "package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart";

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
    if (!_hasStarted) return const Scaffold(body: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()));

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Soal ${_currentQuestionIndex + 1}/${_questions.length}',
                            style: const TextStyle(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isTimeAlmostUp
                                    ? AppColors.error.withValues(alpha: 0.06)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color:
                                    _isTimeAlmostUp
                                        ? AppColors.error
                                        : AppColors.neutral600,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getFormattedTime(),
                                style: TextStyle(
                                  color:
                                      _isTimeAlmostUp
                                          ? AppColors.error
                                          : AppColors.neutral900,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: AppColors.neutral200,
                        color: AppColors.success,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentQ['question_text']?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (currentQ['question_type']?.toString().toLowerCase() ==
                        'essay')
                      BkuTextField(
                        controller: _essayController,
                        maxLines: 6,
                        onChanged: (val) {
                          _jawabanEssay[qId] = val;
                        },
                        hint: 'Tulis jawaban Anda di sini...',
                      )
                    else
                      ...opts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final opt = entry.value;
                        final optId = (opt['id'] as num).toInt();
                        final optionLetter = String.fromCharCode(65 + index);
                        return _buildOption(
                          qId: qId,
                          optId: optId,
                          text: opt['option_text']?.toString() ?? '',
                          letter: optionLetter,
                          isSelected: _jawaban[qId] == optId,
                        );
                      }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: BkuButton.success(
                        isLoading: _isSubmitting,
                        onPressed: _handleNext,
                        text: _currentQuestionIndex == _questions.length - 1
                            ? 'Selesai & Kumpulkan'
                            : 'Pertanyaan Selanjutnya',
                      ),
                    ),
                    const SizedBox(height: 16),
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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keluar Ujian?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Waktu pengerjaan akan terus berjalan jika Anda keluar. Yakin ingin meninggalkan kuis ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.neutral400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BkuButton.danger(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      text: 'Ya, Keluar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: AppColors.info,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mulai $_quizTitle?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan koneksi internet Anda lancar. Waktu pengerjaan akan langsung berjalan secara otomatis setelah Anda menekan tombol Mulai.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: AppColors.info),
                        const SizedBox(width: 6),
                        Text(
                          '$_durasiMenit Menit',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 16, color: AppColors.neutral400),
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 6),
                        Text(
                          '${_questions.length} Soal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.neutral400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BkuButton.primary(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startKuis();
                      },
                      text: 'Ya, Mulai',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String qId,
    required int optId,
    required String text,
    required String letter,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _jawaban[qId] = optId),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.success : AppColors.neutral300,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.success : AppColors.neutral200,
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.neutral400, width: 1),
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.neutral900 : const Color(0xFF334155),
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
          final isEssay = (_questions[i]['question_type'] ?? '').toString().toLowerCase() == 'essay';
          final answered = isEssay ? (_jawabanEssay[qId]?.trim().isNotEmpty ?? false) : _jawaban.containsKey(qId);
          final isCurrent = i == _currentQuestionIndex;
          return GestureDetector(
            onTap: () => _updateQuestionIndex(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.success
                    : (answered ? const Color(0xFF86EFAC) : AppColors.neutral300),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading() => const Scaffold(body: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()));

  Widget _buildError() => Scaffold(body: Center(child: Text(_errorMsg!)));

  Widget _buildEmptySoal() => const Scaffold(body: Center(child: Text('Soal tidak ditemukan')));


  Widget _buildResultView() {
    final isPending = !_essayGraded;
    final lulus = _lulus;
    final skor = _nilaiAkhir.toStringAsFixed(0);

    final mainColor = isPending
        ? AppColors.success
        : (lulus ? AppColors.success : const Color(0xFFEF4444));
    final icon = isPending
        ? Icons.hourglass_top_rounded
        : (lulus ? Icons.verified_rounded : Icons.cancel_rounded);
    final title = isPending ? 'Menunggu Penilaian' : (lulus ? 'Selamat!' : 'Oops!');
    final subtitle = isPending
        ? 'Jawaban Anda sedang menunggu penilaian oleh fasilitator.'
        : (lulus
            ? 'Anda telah berhasil lulus dari kuis ini.'
            : 'Nilai Anda belum mencapai batas kelulusan.');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const BkuAppBar(
            title: 'Hasil Kuis',
            variant: AppBarVariant.student,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.neutral300, width: 1.5),
                      ),
                      child: Icon(icon, color: AppColors.neutral900, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.neutral900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (isPending) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.neutral300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status Evaluasi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.neutral300),
                                  ),
                                  child: const Text(
                                    'Menunggu Konfirmasi',
                                    style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.neutral200),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.neutral600,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Kuis ini mengandung soal essay yang memerlukan penilaian manual oleh fasilitator.',
                                    style: TextStyle(
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.neutral300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'NILAI AKHIR',
                              style: TextStyle(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              skor,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(height: 1, color: AppColors.neutral200),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildResultStat(
                                    '$_jumlahBenar',
                                    'Jawaban Benar',
                                    Icons.check_circle_rounded,
                                    AppColors.success,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 44,
                                  color: AppColors.neutral200,
                                ),
                                Expanded(
                                  child: _buildResultStat(
                                    '$_jumlahSalah',
                                    'Jawaban Salah',
                                    Icons.cancel_rounded,
                                    const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: BkuButton.success(
                        onPressed: () => Navigator.pop(context),
                        text: 'Kembali ke Beranda',
                      ),
                    ),
                    if (!isPending && !lulus && _attemptsUsed < _maxAttempts) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.neutral200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isFinished = false;
                              _hasStarted = false;
                            });
                            _loadSoal();
                          },
                          child: const Text(
                            'Ulangi Kuis',
                            style: TextStyle(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.titleLg.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
