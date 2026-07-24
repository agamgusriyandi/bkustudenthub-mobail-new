import 'package:equatable/equatable.dart';

class TkProfile extends Equatable {
  final int id;
  final int userId;
  final String nama;
  final String email;
  final String noHP;
  final String spesialisasi;
  final String fotoURL;
  final String lokasi;
  final bool isAktif;

  const TkProfile({
    required this.id,
    required this.userId,
    required this.nama,
    required this.email,
    required this.noHP,
    required this.spesialisasi,
    required this.fotoURL,
    required this.lokasi,
    required this.isAktif,
  });

  factory TkProfile.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] : null;

    String parsedNama =
        (userMap != null ? (userMap['name'] ?? userMap['nama']) : null) ??
        json['nama'] ??
        json['Nama'] ??
        '';
    if (parsedNama.isEmpty || parsedNama.toLowerCase().contains('dummy')) {
      parsedNama =
          (userMap != null ? (userMap['name'] ?? userMap['nama']) : null) ??
          parsedNama;
    }
    if (parsedNama.isEmpty) parsedNama = 'Tenaga Kesehatan';

    String parsedFotoUrl = '';
    final possibleFotoUrls = [
      json['foto_url'],
      json['FotoURL'],
      json['avatar_url'],
      json['avatar'],
      json['foto'],
      if (userMap != null) ...[
        userMap['avatar_url'],
        userMap['avatar'],
        userMap['foto'],
        userMap['foto_url'],
      ],
    ];
    for (final url in possibleFotoUrls) {
      if (url != null && url.toString().trim().isNotEmpty) {
        parsedFotoUrl = url.toString();
        break;
      }
    }
    if (parsedFotoUrl.isEmpty) {
      parsedFotoUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(parsedNama)}&background=003399&color=fff&size=128';
    }

    return TkProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nama: parsedNama,
      email:
          json['email'] ??
          json['Email'] ??
          (userMap != null ? userMap['email'] : null) ??
          '',
      noHP:
          json['no_hp'] ??
          json['NoHP'] ??
          (userMap != null ? (userMap['no_hp'] ?? userMap['phone']) : null) ??
          '',
      spesialisasi:
          json['spesialisasi'] ?? json['Spesialisasi'] ?? 'Pemeriksaan Umum',
      fotoURL: parsedFotoUrl,
      lokasi: json['lokasi'] ?? json['Lokasi'] ?? 'Klinik Kampus BKU',
      isAktif: json['is_aktif'] ?? json['IsAktif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'email': email,
      'no_hp': noHP,
      'spesialisasi': spesialisasi,
      'foto_url': fotoURL,
      'lokasi': lokasi,
      'is_aktif': isAktif,
    };
  }

  String get initials {
    if (nama.isEmpty) return 'TK';
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  TkProfile copyWith({
    int? id,
    int? userId,
    String? nama,
    String? email,
    String? noHP,
    String? spesialisasi,
    String? fotoURL,
    String? lokasi,
    bool? isAktif,
  }) {
    return TkProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHP: noHP ?? this.noHP,
      spesialisasi: spesialisasi ?? this.spesialisasi,
      fotoURL: fotoURL ?? this.fotoURL,
      lokasi: lokasi ?? this.lokasi,
      isAktif: isAktif ?? this.isAktif,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    nama,
    email,
    noHP,
    spesialisasi,
    fotoURL,
    lokasi,
    isAktif,
  ];
}
