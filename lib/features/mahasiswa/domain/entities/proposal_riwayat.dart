import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal.dart';

class ProposalRiwayat extends Equatable {
  final String? catatan;
  final int? createdBy;
  final String? createdAt;
  final int? id;
  final Proposal? proposal;
  final int? proposalId;
  final String? status;
  final String? updatedAt;

  const ProposalRiwayat({
    this.catatan,
    this.createdBy,
    this.createdAt,
    this.id,
    this.proposal,
    this.proposalId,
    this.status,
    this.updatedAt,
  });

  factory ProposalRiwayat.fromJson(Map<String, dynamic> json) {
    return ProposalRiwayat(
      catatan: json['catatan'],
      createdBy:
          json['createdBy'] != null
              ? int.tryParse(json['createdBy'].toString()) ?? json['createdBy']
              : null,
      createdAt: json['created_at'],
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
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catatan': catatan,
      'createdBy': createdBy,
      'created_at': createdAt,
      'id': id,
      'proposal': proposal?.toJson(),
      'proposalID': proposalId,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    catatan,
    createdBy,
    createdAt,
    id,
    proposal,
    proposalId,
    status,
    updatedAt,
  ];
}
