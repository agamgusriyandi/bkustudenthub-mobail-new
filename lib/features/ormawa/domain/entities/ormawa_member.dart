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
  final String? prodi;

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
    this.prodi,
  });

  String get initial {
    if (name.trim().isEmpty) return 'M';
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0].length > 1 ? parts[0].substring(0, 2).toUpperCase() : parts[0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
