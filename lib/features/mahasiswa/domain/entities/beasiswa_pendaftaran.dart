import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/beasiswa.dart';

class BeasiswaPendaftaran extends Equatable {
  final Beasiswa? beasiswa;
  final int? beasiswaId;
  final String? buktiUrl;
  final String? catatan;
  final String? createdAt;
  final String? customAnswers;
  final int? id;
  final String? ktmKtpUrl;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? motivasi;
  final String? rubrikAnswers;
  final String? rubrikScores;
  final String? sertifikatUrl;
  final String? status;
  final double? totalSkor;
  final String? transkripUrl;
  final String? updatedAt;

  const BeasiswaPendaftaran({
    this.beasiswa,
    this.beasiswaId,
    this.buktiUrl,
    this.catatan,
    this.createdAt,
    this.customAnswers,
    this.id,
    this.ktmKtpUrl,
    this.mahasiswa,
    this.mahasiswaId,
    this.motivasi,
    this.rubrikAnswers,
    this.rubrikScores,
    this.sertifikatUrl,
    this.status,
    this.totalSkor,
    this.transkripUrl,
    this.updatedAt,
  });

  factory BeasiswaPendaftaran.fromJson(Map<String, dynamic> json) {
    return BeasiswaPendaftaran(
      beasiswa:
          json['beasiswa'] != null ? Beasiswa.fromJson(json['beasiswa']) : null,
      beasiswaId:
          json['beasiswaID'] != null
              ? int.tryParse(json['beasiswaID'].toString()) ??
                  json['beasiswaID']
              : null,
      buktiUrl: json['buktiURL'],
      catatan: json['catatan'],
      createdAt: json['created_at'],
      customAnswers: json['custom_answers'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      ktmKtpUrl: json['ktm_ktp_url'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      motivasi: json['motivasi'],
      rubrikAnswers: json['rubrik_answers'],
      rubrikScores: json['rubrik_scores'],
      sertifikatUrl: json['sertifikat_url'],
      status: json['status'],
      totalSkor: json['total_skor'],
      transkripUrl: json['transkrip_url'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beasiswa': beasiswa?.toJson(),
      'beasiswaID': beasiswaId,
      'buktiURL': buktiUrl,
      'catatan': catatan,
      'created_at': createdAt,
      'custom_answers': customAnswers,
      'id': id,
      'ktm_ktp_url': ktmKtpUrl,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'motivasi': motivasi,
      'rubrik_answers': rubrikAnswers,
      'rubrik_scores': rubrikScores,
      'sertifikat_url': sertifikatUrl,
      'status': status,
      'total_skor': totalSkor,
      'transkrip_url': transkripUrl,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    beasiswa,
    beasiswaId,
    buktiUrl,
    catatan,
    createdAt,
    customAnswers,
    id,
    ktmKtpUrl,
    mahasiswa,
    mahasiswaId,
    motivasi,
    rubrikAnswers,
    rubrikScores,
    sertifikatUrl,
    status,
    totalSkor,
    transkripUrl,
    updatedAt,
  ];
}
