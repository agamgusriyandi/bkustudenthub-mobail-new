class OrmawaMember {
  final String id;
  final String mahasiswaId;
  final String name;
  final String nim;
  final String role;
  final String division;
  final String status;
  final String? email;
  final String? phone;
  final DateTime? joinedAt;
  final String? fotoUrl;
  final String? periode;

  OrmawaMember({
    required this.id,
    required this.mahasiswaId,
    required this.name,
    required this.nim,
    required this.role,
    required this.division,
    required this.status,
    this.email,
    this.phone,
    this.joinedAt,
    this.fotoUrl,
    this.periode,
  });

  String get initial {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}
