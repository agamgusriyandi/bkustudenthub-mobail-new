enum ScreeningLevel { normal, mild, moderate, severe }

class ScreeningQuestion {
  final int id;
  final String question;

  const ScreeningQuestion({required this.id, required this.question});
}

class ScreeningResult {
  final int score;
  final ScreeningLevel level;
  final String description;
  final DateTime createdAt;

  const ScreeningResult({
    required this.score,
    required this.level,
    required this.description,
    required this.createdAt,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    return ScreeningResult(
      score: json['score'] ?? 0,
      level: _parseLevel(json['level']),
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static ScreeningLevel _parseLevel(dynamic value) {
    if (value == null) return ScreeningLevel.normal;
    switch (value.toString().toLowerCase()) {
      case 'normal':
        return ScreeningLevel.normal;
      case 'mild':
        return ScreeningLevel.mild;
      case 'moderate':
        return ScreeningLevel.moderate;
      case 'severe':
        return ScreeningLevel.severe;
      default:
        return ScreeningLevel.normal;
    }
  }

  static ScreeningLevel calculateLevel(int score) {
    if (score <= 4) return ScreeningLevel.normal;
    if (score <= 9) return ScreeningLevel.mild;
    if (score <= 14) return ScreeningLevel.moderate;
    return ScreeningLevel.severe;
  }

  String get levelLabel {
    switch (level) {
      case ScreeningLevel.normal:
        return 'Normal';
      case ScreeningLevel.mild:
        return 'Ringan';
      case ScreeningLevel.moderate:
        return 'Sedang';
      case ScreeningLevel.severe:
        return 'Berat';
    }
  }

  String get levelDescription {
    switch (level) {
      case ScreeningLevel.normal:
        return 'Kondisi kesehatan mental Anda dalam batas normal. Pertahankan pola hidup sehat dan aktifitas positif.';
      case ScreeningLevel.mild:
        return 'Terdapat gejala gangguan kesehatan mental ringan. Disarankan untuk berkonsultasi dengan tenaga kesehatan.';
      case ScreeningLevel.moderate:
        return 'Gejala gangguan kesehatan mental cukup signifikan. Sangat disarankan untuk segera berkonsultasi dengan psikolog.';
      case ScreeningLevel.severe:
        return 'Gejala gangguan kesehatan mental cukup berat. Segera konsultasikan dengan tenaga kesehatan atau psikolog.';
    }
  }

  static const List<ScreeningQuestion> srq20Questions = [
    ScreeningQuestion(
      id: 1,
      question: 'Apakah Anda sering mengalami sakit kepala?',
    ),
    ScreeningQuestion(
      id: 2,
      question:
          'Apakah Anda kehilangan nafsu makan? Apakah berat badan Anda berkurang tanpa sebab yang jelas?',
    ),
    ScreeningQuestion(
      id: 3,
      question:
          'Apakah Anda mengalami gangguan tidur (sulit tidur atau sering terbangun)?',
    ),
    ScreeningQuestion(
      id: 4,
      question:
          'Apakah Anda mudah merasa takut atau cemas tanpa alasan yang jelas?',
    ),
    ScreeningQuestion(
      id: 5,
      question:
          'Apakah Anda merasa gelisah, tegang, atau sulit rileks?',
    ),
    ScreeningQuestion(
      id: 6,
      question:
          'Apakah Anda mudah merasa sedih atau murung?',
    ),
    ScreeningQuestion(
      id: 7,
      question:
          'Apakah Anda merasa lemah atau lesu sepanjang waktu?',
    ),
    ScreeningQuestion(
      id: 8,
      question:
          'Apakah Anda sulit berkonsentrasi dalam melakukan aktivitas sehari-hari?',
    ),
    ScreeningQuestion(
      id: 9,
      question:
          'Apakah Anda merasa tidak berharga atau rendah diri?',
    ),
    ScreeningQuestion(
      id: 10,
      question:
          'Apakah Anda merasa tidak mampu mengatasi masalah yang dihadapi?',
    ),
    ScreeningQuestion(
      id: 11,
      question:
          'Apakah Anda merasa putus asa tentang masa depan?',
    ),
    ScreeningQuestion(
      id: 12,
      question:
          'Apakah Anda merasa hidup tidak berarti atau kosong?',
    ),
    ScreeningQuestion(
      id: 13,
      question:
          'Apakah Anda merasa lelah sepanjang waktu?',
    ),
    ScreeningQuestion(
      id: 14,
      question:
          'Apakah Anda mengalami ketidaknyamanan pada perut atau pencernaan?',
    ),
    ScreeningQuestion(
      id: 15,
      question:
          'Apakah Anda merasa mudah tersinggung atau marah tanpa sebab?',
    ),
    ScreeningQuestion(
      id: 16,
      question:
          'Apakah Anda sulit mengambil keputusan dalam aktivitas sehari-hari?',
    ),
    ScreeningQuestion(
      id: 17,
      question:
          'Apakah Anda merasa sulit untuk melakukan aktivitas sehari-hari karena masalah kesehatan mental?',
    ),
    ScreeningQuestion(
      id: 18,
      question:
          'Apakah Anda merasa tidak ada yang peduli terhadap Anda?',
    ),
    ScreeningQuestion(
      id: 19,
      question:
          'Apakah Anda mengalami kehilangan minat dalam hal-hal yang sebelumnya Anda nikmati?',
    ),
    ScreeningQuestion(
      id: 20,
      question:
          'Apakah Anda merasa ingin menyakiti diri sendiri?',
    ),
  ];
}
