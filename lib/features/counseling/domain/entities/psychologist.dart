import 'package:equatable/equatable.dart';

class Psychologist extends Equatable {
  final String id;
  final String name;
  final String nidn;
  final String specialization;
  final String profileImageUrl;
  final bool isAvailable;
  final String email;
  final String phone;
  final String bio;
  final String location;
  final String languages;
  final int fee;

  const Psychologist({
    required this.id,
    required this.name,
    this.nidn = '',
    this.specialization = '',
    this.profileImageUrl = '',
    this.isAvailable = true,
    this.email = '',
    this.phone = '',
    this.bio = '',
    this.location = '',
    this.languages = '',
    this.fee = 0,
  });

  factory Psychologist.fromJson(Map<String, dynamic> json) {
    final userMap =
        (json['user'] is Map ? json['user'] : null) ??
        (json['User'] is Map ? json['User'] : null) ??
        (json['pengguna'] is Map ? json['pengguna'] : null) ??
        (json['Pengguna'] is Map ? json['Pengguna'] : null);

    final parsedName =
        (userMap != null ? (userMap['name'] ?? userMap['nama']) : null) ??
        json['Nama'] ??
        json['nama'] ??
        json['name'] ??
        '';

    return Psychologist(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      name: parsedName,
      nidn: json['NIDN'] ?? json['nidn'] ?? '',
      specialization:
          json['Spesialisasi'] ??
          json['spesialisasi'] ??
          json['specialization'] ??
          '',
      profileImageUrl: () {
        final possibleUrls = [
          json['FotoURL'],
          json['foto_url'],
          json['photo_url'],
          json['foto'],
          json['profileImageUrl'],
          json['profile_image_url'],
          json['avatar'],
          json['profile_photo'],
          json['foto_profil'],
          if (userMap != null) userMap['avatar_url'],
          if (userMap != null) userMap['foto'],
          if (userMap != null) userMap['profile_image_url'],
          if (userMap != null) userMap['avatar'],
          if (userMap != null) userMap['profile_photo'],
          if (userMap != null) userMap['foto_profil'],
        ];
        for (final url in possibleUrls) {
          if (url != null && url.toString().trim().isNotEmpty) {
            return url.toString();
          }
        }
        return '';
      }(),
      isAvailable:
          json['IsAktif'] ??
          json['is_aktif'] ??
          json['is_active'] ??
          json['isAvailable'] ??
          true,
      email:
          json['Email'] ??
          json['email'] ??
          (userMap != null ? userMap['email'] : null) ??
          '',
      phone:
          json['NoHP'] ??
          json['no_hp'] ??
          json['phone'] ??
          (userMap != null ? userMap['phone'] : null) ??
          '',
      bio: json['Bio'] ?? json['bio'] ?? '',
      location: json['Lokasi'] ?? json['lokasi'] ?? json['location'] ?? '',
      languages: json['Bahasa'] ?? json['bahasa'] ?? json['languages'] ?? '',
      fee: (json['Tarif'] ?? json['tarif'] ?? json['fee'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': name,
      'email': email,
      'no_hp': phone,
      'spesialisasi': specialization,
      'bio': bio,
      'lokasi': location,
      'bahasa': languages,
      'tarif': fee,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nidn,
    specialization,
    profileImageUrl,
    isAvailable,
    email,
    phone,
    bio,
    location,
    languages,
    fee,
  ];
}
