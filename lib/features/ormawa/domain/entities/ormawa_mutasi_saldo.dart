import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class OrmawaMutasiSaldo extends Equatable {
  final String? createdAt;
  final String? deskripsi;
  final int? id;
  final String? kategori;
  final double? nominal;
  final Ormawa? ormawa;
  final int? ormawaId;
  final Proposal? proposal;
  final int? proposalId;
  final String? sumber;
  final String? tanggal;
  final String? tipe;
  final String? updatedAt;

  const OrmawaMutasiSaldo({
    this.createdAt,
    this.deskripsi,
    this.id,
    this.kategori,
    this.nominal,
    this.ormawa,
    this.ormawaId,
    this.proposal,
    this.proposalId,
    this.sumber,
    this.tanggal,
    this.tipe,
    this.updatedAt,
  });

  factory OrmawaMutasiSaldo.fromJson(Map<String, dynamic> json) {
    return OrmawaMutasiSaldo(
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      kategori: json['kategori'],
      nominal: json['nominal'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      proposal:
          json['proposal'] != null ? Proposal.fromJson(json['proposal']) : null,
      proposalId:
          json['proposalID'] != null
              ? int.tryParse(json['proposalID'].toString()) ??
                  json['proposalID']
              : null,
      sumber: json['sumber'],
      tanggal: json['tanggal'],
      tipe: json['tipe'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'id': id,
      'kategori': kategori,
      'nominal': nominal,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'proposal': proposal?.toJson(),
      'proposalID': proposalId,
      'sumber': sumber,
      'tanggal': tanggal,
      'tipe': tipe,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    deskripsi,
    id,
    kategori,
    nominal,
    ormawa,
    ormawaId,
    proposal,
    proposalId,
    sumber,
    tanggal,
    tipe,
    updatedAt,
  ];
}
