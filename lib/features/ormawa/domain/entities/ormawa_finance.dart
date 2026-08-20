class OrmawaFinance {
  final String id;
  final String type;
  final double nominal;
  final String category;
  final String description;
  final DateTime date;
  final String sumber;

  OrmawaFinance({
    required this.id,
    required this.type,
    required this.nominal,
    required this.category,
    required this.description,
    required this.date,
    required this.sumber,
  });

  factory OrmawaFinance.fromJson(Map<String, dynamic> json) {
    return OrmawaFinance(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      type: json['Tipe'] ?? json['type'] ?? '',
      nominal: ((json['Nominal'] ?? json['nominal'] ?? 0.0) as num).toDouble(),
      category: json['Kategori'] ?? json['category'] ?? '',
      description: json['Deskripsi'] ?? json['description'] ?? '',
      date:
          DateTime.tryParse(json['Tanggal'] ?? json['tanggal'] ?? '') ??
          DateTime.now(),
      sumber: json['Sumber'] ?? json['sumber'] ?? 'organisasi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'Tipe': type,
      'Nominal': nominal,
      'Kategori': category,
      'Deskripsi': description,
      'Tanggal': date.toIso8601String(),
      'Sumber': sumber,
    };
  }
}