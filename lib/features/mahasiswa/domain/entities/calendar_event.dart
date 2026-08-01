class CalendarEvent {
  final String judul;
  final String kategori;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;

  const CalendarEvent({
    required this.judul,
    required this.kategori,
    required this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final startStr =
        '${json['tanggal_mulai'] ?? json['tanggal'] ?? json['TanggalMulai'] ?? ''}';
    final endStr =
        '${json['tanggal_selesai'] ?? json['TanggalSelesai'] ?? ''}';
    return CalendarEvent(
      judul: '${json['judul'] ?? json['Judul'] ?? json['nama'] ?? ''}',
      kategori: '${json['kategori'] ?? json['Kategori'] ?? 'kampus'}',
      tanggalMulai: DateTime.tryParse(startStr) ?? DateTime.now(),
      tanggalSelesai: endStr.isEmpty ? null : DateTime.tryParse(endStr),
    );
  }
}
