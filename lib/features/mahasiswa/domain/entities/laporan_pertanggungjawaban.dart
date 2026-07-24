import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal.dart';

class LaporanPertanggungjawaban extends Equatable {
  final String? catatan;
  final String? createdAt;
  final String? fileUrl;
  final int? id;
  final Proposal? proposal;
  final int? proposalId;
  final double? realisasiAnggaran;
  final String? status;
  final String? updatedAt;

  const LaporanPertanggungjawaban({
    this.catatan,
    this.createdAt,
    this.fileUrl,
    this.id,
    this.proposal,
    this.proposalId,
    this.realisasiAnggaran,
    this.status,
    this.updatedAt,
  });

  factory LaporanPertanggungjawaban.fromJson(Map<String, dynamic> json) {
    return LaporanPertanggungjawaban(
      catatan: json['catatan'],
      createdAt: json['created_at'],
      fileUrl: json['fileURL'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      proposal:
          json['proposal'] != null ? Proposal.fromJson(json['proposal']) : null,
      proposalId:
          json['proposalID'] != null
              ? int.tryParse(json['proposalID'].toString()) ??
                  json['proposalID']
              : null,
      realisasiAnggaran: json['realisasiAnggaran'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catatan': catatan,
      'created_at': createdAt,
      'fileURL': fileUrl,
      'id': id,
      'proposal': proposal?.toJson(),
      'proposalID': proposalId,
      'realisasiAnggaran': realisasiAnggaran,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    catatan,
    createdAt,
    fileUrl,
    id,
    proposal,
    proposalId,
    realisasiAnggaran,
    status,
    updatedAt,
  ];
}
