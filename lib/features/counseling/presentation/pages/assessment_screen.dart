import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class _AssessmentQuestion {
  final String text;
  final String dimension;

  const _AssessmentQuestion({
    required this.text,
    required this.dimension,
  });
}

class _AssessmentResultData {
  final String overallLevel;
  final int totalScore;
  final Map<String, dynamic> subScores;
  final String recommendation;

  const _AssessmentResultData({
    required this.overallLevel,
    required this.totalScore,
    required this.subScores,
    required this.recommendation,
  });
}

class _AssessmentType {
  final String name;
  final String kategori;
  final String deskripsi;
  final String estimasi;
  final List<_AssessmentQuestion> questions;
  final List<String> options;
  final _AssessmentResultData Function(Map<int, int> answers) evaluate;

  const _AssessmentType({
    required this.name,
    required this.kategori,
    required this.deskripsi,
    required this.estimasi,
    required this.questions,
    required this.options,
    required this.evaluate,
  });
}

final _dass21 = _AssessmentType(
  name: 'DASS-21',
  kategori: 'Kesehatan Mental',
  deskripsi:
      'Depression Anxiety Stress Scale 21 item terstandar untuk evaluasi tingkat depresi, kecemasan, dan stres.',
  estimasi: '3 - 5 menit',
  options: [
    'Tidak Pernah',
    'Kadang-kadang',
    'Sering',
    'Hampir Selalu',
  ],
  questions: const [
    _AssessmentQuestion(
      text: 'Saya merasa sulit untuk tenang setelah sesuatu membuat saya kesal.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya menyadari mulut saya terasa kering.',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya tidak dapat merasakan perasaan positif sama sekali.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya mengalami kesulitan bernapas (napas cepat atau terengah-engah tanpa aktivitas fisik).',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa sulit untuk berinisiatif melakukan sesuatu.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya cenderung bereaksi berlebihan terhadap situasi yang terjadi.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa gemetar (misalnya pada bagian tangan).',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa banyak menggunakan energi saraf atau merasa tegang.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya khawatir tentang situasi di mana saya mungkin panik dan mempermalukan diri sendiri.',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa tidak ada hal baik yang bisa saya nantikan di masa depan.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya mendapati diri saya mudah gelisah dan tidak tenang.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa sangat sulit untuk rileks atau bersantai.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa sedih, putus asa, dan tertekan.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya tidak sabar dengan hal-hal yang menghalangi atau memperlambat pekerjaan saya.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa hampir panik dalam beberapa situasi.',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa tidak bisa antusias terhadap hal apa pun.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa bahwa saya tidak berharga sebagai seorang manusia.',
      dimension: 'Depresi',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa mudah tersinggung dan sangat sensitif.',
      dimension: 'Stres',
    ),
    _AssessmentQuestion(
      text: 'Saya menyadari detak jantung saya berdegup kencang tanpa adanya aktivitas fisik.',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa takut tanpa alasan yang jelas atau masuk akal.',
      dimension: 'Kecemasan',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa bahwa hidup ini tidak ada artinya lagi.',
      dimension: 'Depresi',
    ),
  ],
  evaluate: (answers) {
    final depressionIndices = [2, 4, 9, 12, 15, 16, 20];
    final anxietyIndices = [1, 3, 6, 8, 14, 18, 19];
    final stressIndices = [0, 5, 7, 10, 11, 13, 17];

    int dSum = 0;
    for (final i in depressionIndices) {
      dSum += answers[i] ?? 0;
    }
    final dScore = dSum * 2;

    int aSum = 0;
    for (final i in anxietyIndices) {
      aSum += answers[i] ?? 0;
    }
    final aScore = aSum * 2;

    int sSum = 0;
    for (final i in stressIndices) {
      sSum += answers[i] ?? 0;
    }
    final sScore = sSum * 2;

    String dLevel = 'Normal';
    if (dScore >= 28) {
      dLevel = 'Berat';
    } else if (dScore >= 21) {
      dLevel = 'Tinggi';
    } else if (dScore >= 14) {
      dLevel = 'Sedang';
    } else if (dScore >= 10) {
      dLevel = 'Ringan';
    }

    String aLevel = 'Normal';
    if (aScore >= 20) {
      aLevel = 'Berat';
    } else if (aScore >= 15) {
      aLevel = 'Tinggi';
    } else if (aScore >= 10) {
      aLevel = 'Sedang';
    } else if (aScore >= 8) {
      aLevel = 'Ringan';
    }

    String sLevel = 'Normal';
    if (sScore >= 34) {
      sLevel = 'Berat';
    } else if (sScore >= 26) {
      sLevel = 'Tinggi';
    } else if (sScore >= 19) {
      sLevel = 'Sedang';
    } else if (sScore >= 15) {
      sLevel = 'Ringan';
    }

    final levelRank = {
      'Normal': 0,
      'Ringan': 1,
      'Sedang': 2,
      'Tinggi': 3,
      'Berat': 4,
    };

    String overall = 'Normal';
    int maxRank = levelRank[dLevel]!;
    if (levelRank[aLevel]! > maxRank) {
      maxRank = levelRank[aLevel]!;
      overall = aLevel;
    } else {
      overall = dLevel;
    }
    if (levelRank[sLevel]! > maxRank) {
      maxRank = levelRank[sLevel]!;
      overall = sLevel;
    }

    String reco =
        'Kondisi kesehatan mental Anda berada dalam batas normal. Pertahankan pola hidup sehat dan manajemen waktu yang baik.';
    if (overall == 'Ringan' || overall == 'Sedang') {
      reco =
          'Terindikasi adanya ketegangan atau kecemasan tingkat $overall. Disarankan mengambil waktu jeda, latihan pernapasan, atau menjadwalkan konsultasi awal dengan konselor BKU.';
    } else if (overall == 'Tinggi' || overall == 'Berat') {
      reco =
          'Terindikasi tingkat ketegangan psikologis yang cukup tinggi. Sangat disarankan untuk segera berkonsultasi langsung dengan psikolog klinis BKU Care.';
    }

    return _AssessmentResultData(
      overallLevel: overall,
      totalScore: dScore + aScore + sScore,
      subScores: {
        'depresi': {'score': dScore, 'level': dLevel},
        'kecemasan': {'score': aScore, 'level': aLevel},
        'stres': {'score': sScore, 'level': sLevel},
      },
      recommendation: reco,
    );
  },
);

final _stressCheck = _AssessmentType(
  name: 'Tes Stres Akademik',
  kategori: 'Kesehatan Mental',
  deskripsi:
      'Mengukur tingkat tekanan psikologis yang berkaitan langsung dengan perkuliahan, tugas, dan ujian.',
  estimasi: '2 - 3 menit',
  options: [
    'Tidak Pernah',
    'Jarang',
    'Sering',
    'Selalu',
  ],
  questions: const [
    _AssessmentQuestion(
      text: 'Saya merasa tertekan dengan beban tugas dan tenggat waktu kuliah.',
      dimension: 'Beban Tugas',
    ),
    _AssessmentQuestion(
      text:
          'Saya kesulitan membagi waktu antara kuliah, tugas, dan waktu istirahat.',
      dimension: 'Manajemen Waktu',
    ),
    _AssessmentQuestion(
      text: 'Saya sering kurang tidur atau begadang karena memikirkan tugas/ujian.',
      dimension: 'Pola Tidur',
    ),
    _AssessmentQuestion(
      text: 'Saya merasa cemas nilai akademik atau IPK saya menurun.',
      dimension: 'Performa Akademik',
    ),
    _AssessmentQuestion(
      text: 'Saya khawatir berlebihan mengenai masa depan karir setelah lulus.',
      dimension: 'Karir',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa terbebani oleh ekspektasi dosen atau orang tua terhadap prestasi saya.',
      dimension: 'Ekspektasi',
    ),
    _AssessmentQuestion(
      text:
          'Saya sulit berkonsentrasi saat belajar atau saat dosen menjelaskan materi.',
      dimension: 'Konsentrasi',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa lelah secara emosional dan fisik akibat rutinitas perkuliahan.',
      dimension: 'Burnout',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa tidak memiliki waktu luang untuk diri sendiri atau hobi.',
      dimension: 'Work-Life Balance',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa terisolasi atau kesulitan bekerja sama dengan teman kelompok.',
      dimension: 'Hubungan Sosial',
    ),
  ],
  evaluate: (answers) {
    int total = 0;
    answers.forEach((_, v) => total += v);

    String level = 'Normal';
    if (total >= 23) {
      level = 'Tinggi';
    } else if (total >= 16) {
      level = 'Sedang';
    } else if (total >= 10) {
      level = 'Ringan';
    }

    String reco =
        'Tingkat stres akademik Anda berada pada level wajar dan terkendali.';
    if (level == 'Ringan' || level == 'Sedang') {
      reco =
          'Anda mengalami stres akademik tingkat $level. Coba buat jadwal belajar terstruktur dan luangkan waktu relaksasi.';
    } else if (level == 'Tinggi') {
      reco =
          'Tingkat stres akademik Anda tinggi dan berpotensi memicu kejenuhan (burnout). Disarankan menjadwalkan konsultasi dengan konselor akademik/psikolog BKU.';
    }

    return _AssessmentResultData(
      overallLevel: level,
      totalScore: total,
      subScores: {
        'skor_total': {'score': total, 'level': level},
      },
      recommendation: reco,
    );
  },
);

final _anxietyCheck = _AssessmentType(
  name: 'Tes Kecemasan Sosial',
  kategori: 'Kesehatan Mental',
  deskripsi:
      'Mengukur kenyamanan dan tingkat kecemasan dalam situasi sosial serta interaksi dengan lingkungan kampus.',
  estimasi: '2 menit',
  options: [
    'Tidak Pernah',
    'Kadang-kadang',
    'Sering',
    'Hampir Selalu',
  ],
  questions: const [
    _AssessmentQuestion(
      text:
          'Saya merasa cemas saat harus berbicara atau presentasi di depan kelas.',
      dimension: 'Presentasi',
    ),
    _AssessmentQuestion(
      text:
          'Saya menghindari situasi sosial kampus karena takut dinilai buruk oleh orang lain.',
      dimension: 'Penghindaran',
    ),
    _AssessmentQuestion(
      text:
          'Saya khawatir orang lain memperhatikan kekurangan saya saat berinteraksi.',
      dimension: 'Ketakutan Sosial',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa tegang dan tidak nyaman saat bertemu atau berkenalan dengan orang baru.',
      dimension: 'Interaksi',
    ),
    _AssessmentQuestion(
      text:
          'Saya berulang kali memikirkan perkataan saya setelah berbicara dengan orang lain.',
      dimension: 'Overthinking',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa jantung berdegup kencang saat harus mengutarakan pendapat.',
      dimension: 'Reaksi Fisik',
    ),
    _AssessmentQuestion(
      text:
          'Saya merasa malu atau canggung saat berada di keramaian kampus.',
      dimension: 'Ruang Publik',
    ),
    _AssessmentQuestion(
      text:
          'Saya ragu meminta bantuan kepada teman atau dosen meskipun sangat membutuhkan.',
      dimension: 'Komunikasi',
    ),
  ],
  evaluate: (answers) {
    int total = 0;
    answers.forEach((_, v) => total += v);

    String level = 'Normal';
    if (total >= 17) {
      level = 'Tinggi';
    } else if (total >= 9) {
      level = 'Sedang';
    } else if (total >= 5) {
      level = 'Ringan';
    }

    String reco =
        'Anda memiliki kenyamanan interaksi sosial yang baik di lingkungan kampus.';
    if (level == 'Ringan' || level == 'Sedang') {
      reco =
          'Terdapat sedikit kecemasan sosial. Anda dapat melatih kemampuan komunikasi secara bertahap dalam kelompok kecil.';
    } else if (level == 'Tinggi') {
      reco =
          'Kecemasan sosial dirasakan cukup kuat dan dapat menghambat perkuliahan. Konsultasikan dengan psikolog BKU untuk latihan asertif dan relaksasi.';
    }

    return _AssessmentResultData(
      overallLevel: level,
      totalScore: total,
      subScores: {
        'skor_sosial': {'score': total, 'level': level},
      },
      recommendation: reco,
    );
  },
);

final List<_AssessmentType> _allAssessments = [
  _dass21,
  _stressCheck,
  _anxietyCheck,
];

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCounselingProvider>().loadMyAssessments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const SliverToBoxAdapter(
            child: BkuStaticAppBar(
              title: 'Tes Kesehatan Mental',
              subtitle: 'Evaluasi & Asesmen Mandiri',
              variant: AppBarVariant.student,
              showBackButton: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: context.appColors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.neutral600,
                labelStyle: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Daftar Tes'),
                  Tab(text: 'Riwayat Saya'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAssessmentListTab(context),
            _buildHistoryTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentListTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildInfoBanner(),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Pilih Instrumen Asesmen',
          style: AppTextStyles.titleMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._allAssessments.map(
          (a) => _buildAssessmentCard(context, a),
        ),
        const SizedBox(height: AppSpacing.s80),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return Consumer<StudentCounselingProvider>(
      builder: (context, provider, _) {
        if (provider.myAssessmentsLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: BkuShimmerList(itemCount: 4, itemHeight: 90),
          );
        }

        final list = provider.myAssessments;
        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.loadMyAssessments(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppColors.neutral400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Belum Ada Riwayat Asesmen',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pilih salah satu instrumen di tab "Daftar Tes" untuk melakukan evaluasi mandiri pertama Anda.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyAssessments(),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = list[index];
              final nama = item['nama'] ?? item['assessment'] ?? 'Asesmen Mandiri';
              final skor = item['skor'] ?? item['score'] ?? 'Selesai';
              final tanggal = item['created_at'] ?? item['tanggal'] ?? '-';
              final kategori =
                  item['kategori'] ?? item['category'] ?? 'Kesehatan Mental';

              Color badgeColor = AppColors.success;
              if (skor == 'Ringan' || skor == 'Sedang') {
                badgeColor = AppColors.warning;
              } else if (skor == 'Tinggi' || skor == 'Berat') {
                badgeColor = AppColors.error;
              }

              return BkuCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(20),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        color: badgeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$kategori • $tanggal',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(20),
                        borderRadius: AppRadius.radiusSm,
                        border: Border.all(color: badgeColor.withAlpha(50)),
                      ),
                      child: Text(
                        skor,
                        style: AppTextStyles.labelSm.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.info.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.info,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kerahasiaan & Standar Klinis',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hasil asesmen ini dihitung otomatis dengan pedoman psikometri klinis terstandar dan bersifat rahasia untuk mendukung kesehatan mental Anda.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    _AssessmentType assessment,
  ) {
    return BkuCard.doubleBezel(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.psychology_alt_rounded,
                  color: context.appColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.appColors.onSurface,
                      ),
                    ),
                    Text(
                      assessment.kategori,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            assessment.deskripsi,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildMetaTag(
                Icons.format_list_numbered_rounded,
                '${assessment.questions.length} Butir Soal',
              ),
              const SizedBox(width: AppSpacing.md),
              _buildMetaTag(Icons.timer_outlined, assessment.estimasi),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BkuButton.pill(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      _AssessmentQuizScreen(assessment: assessment),
                ),
              );
            },
            text: 'Mulai Asesmen',
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral600),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AssessmentQuizScreen extends StatefulWidget {
  final _AssessmentType assessment;
  const _AssessmentQuizScreen({required this.assessment});

  @override
  State<_AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<_AssessmentQuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  List<_AssessmentQuestion> get _questions => widget.assessment.questions;
  List<String> get _options => widget.assessment.options;

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _questions.length;
    final currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BkuStaticAppBar(
              title: widget.assessment.name,
              variant: AppBarVariant.student,
              showBackButton: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressHeader(progress),
                  const SizedBox(height: AppSpacing.xl),
                  _buildQuestionCard(currentQ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOptionList(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildNavButtons(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.radiusSm,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral200,
            color: AppColors.primary,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_AssessmentQuestion q) {
    return BkuCard(
      backgroundColor: AppColors.primary.withAlpha(8),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (q.dimension.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: AppRadius.radiusXs,
              ),
              child: Text(
                'Dimensi: ${q.dimension}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            q.text,
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionList() {
    return Column(
      children: List.generate(_options.length, (index) {
        final isSelected = _answers[_currentIndex] == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            borderRadius: AppRadius.radiusLg,
            onTap: () {
              setState(() {
                _answers[_currentIndex] = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(15)
                    : context.appColors.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.neutral300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _options[index],
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral800,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavButtons() {
    final hasAnswer = _answers.containsKey(_currentIndex);
    final isLast = _currentIndex == _questions.length - 1;

    return Row(
      children: [
        if (_currentIndex > 0) ...[
          Expanded(
            child: BkuButton(
              onPressed: () {
                setState(() {
                  _currentIndex--;
                });
              },
              variant: BkuButtonVariant.outline,
              text: 'Sebelumnya',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          flex: 2,
          child: BkuButton(
            onPressed: hasAnswer
                ? () {
                    if (!isLast) {
                      setState(() {
                        _currentIndex++;
                      });
                    } else {
                      _showResult();
                    }
                  }
                : null,
            text: isLast ? 'Selesai & Lihat Hasil' : 'Selanjutnya',
            icon: isLast
                ? Icons.check_circle_outline_rounded
                : Icons.arrow_forward_rounded,
          ),
        ),
      ],
    );
  }

  void _showResult() {
    final result = widget.assessment.evaluate(_answers);

    Color badgeColor = AppColors.success;
    if (result.overallLevel == 'Ringan' || result.overallLevel == 'Sedang') {
      badgeColor = AppColors.warning;
    } else if (result.overallLevel == 'Tinggi' ||
        result.overallLevel == 'Berat') {
      badgeColor = AppColors.error;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AssessmentResultSheet(
        assessment: widget.assessment,
        result: result,
        answers: _answers,
        badgeColor: badgeColor,
      ),
    );
  }
}

class _AssessmentResultSheet extends StatelessWidget {
  final _AssessmentType assessment;
  final _AssessmentResultData result;
  final Map<int, int> answers;
  final Color badgeColor;

  const _AssessmentResultSheet({
    required this.assessment,
    required this.result,
    required this.answers,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isElevatedRisk = result.overallLevel == 'Tinggi' ||
        result.overallLevel == 'Berat' ||
        result.overallLevel == 'Sedang';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: AppRadius.radiusXs,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: badgeColor,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Hasil Evaluasi ${assessment.name}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(20),
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: badgeColor.withAlpha(60)),
                    ),
                    child: Text(
                      'Tingkat: ${result.overallLevel}',
                      style: AppTextStyles.titleMd.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (result.subScores.isNotEmpty &&
                    assessment.name == 'DASS-21') ...[
                  Text(
                    'Rincian Subskala Klinis',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSubScaleTile('Depresi', result.subScores['depresi']),
                  const SizedBox(height: AppSpacing.xs),
                  _buildSubScaleTile(
                      'Kecemasan', result.subScores['kecemasan']),
                  const SizedBox(height: AppSpacing.xs),
                  _buildSubScaleTile('Stres', result.subScores['stres']),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  'Rekomendasi & Langkah Selanjutnya',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                BkuCard(
                  backgroundColor: AppColors.neutral100,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    result.recommendation,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral800,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isElevatedRisk) ...[
                  SizedBox(
                    width: double.infinity,
                    child: BkuButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        final complaintMsg =
                            'Halo, saya telah menyelesaikan tes ${assessment.name} dengan hasil tingkat ${result.overallLevel}. Saya ingin berkonsultasi mengenai kondisi ini.';
                        context.push(
                          '${AppRoutes.counselingBooking}?category=Kesehatan Mental&complaint=${Uri.encodeComponent(complaintMsg)}',
                        );
                      },
                      text: 'Konsultasi ke Psikolog Sekarang',
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Consumer<StudentCounselingProvider>(
                  builder: (context, provider, _) => SizedBox(
                    width: double.infinity,
                    child: BkuButton(
                      variant: isElevatedRisk
                          ? BkuButtonVariant.outline
                          : BkuButtonVariant.primary,
                      onPressed: provider.assessmentSubmitting
                          ? null
                          : () async {
                              final success =
                                  await provider.submitAssessmentResult(
                                assessmentName: assessment.name,
                                kategori: assessment.kategori,
                                skor: result.overallLevel,
                                answers: answers,
                                subSkor: result.subScores,
                                deskripsi: assessment.deskripsi,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Hasil asesmen berhasil disimpan dan dikirim ke psikolog!'
                                        : 'Hasil disimpan secara lokal. Periksa koneksi internet Anda.',
                                  ),
                                  backgroundColor: success
                                      ? AppColors.primary
                                      : AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                ),
                              );
                              provider.loadMyAssessments();
                            },
                      isLoading: provider.assessmentSubmitting,
                      text: 'Simpan ke Rekam Medis',
                      icon: Icons.save_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                BkuButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  variant: BkuButtonVariant.text,
                  text: 'Tutup',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScaleTile(String title, dynamic data) {
    if (data is! Map) return const SizedBox();
    final level = data['level']?.toString() ?? 'Normal';
    final score = data['score']?.toString() ?? '0';

    Color col = AppColors.success;
    if (level == 'Ringan' || level == 'Sedang') col = AppColors.warning;
    if (level == 'Tinggi' || level == 'Berat') col = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                'Skor: $score',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: col.withAlpha(20),
                  borderRadius: AppRadius.radiusXs,
                ),
                child: Text(
                  level,
                  style: AppTextStyles.labelSm.copyWith(
                    color: col,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
