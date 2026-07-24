class FacultyProgress {
  final String name;
  final int count;
  final double ratio;

  const FacultyProgress({
    required this.name,
    required this.count,
    required this.ratio,
  });

  factory FacultyProgress.fromJson(Map<String, dynamic> json) {
    return FacultyProgress(
      name: json['name']?.toString() ?? '',
      count: json['count'] as int? ?? 0,
      ratio: (json['ratio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
