class ProposalRiwayatModel {
  final int id;

  ProposalRiwayatModel({required this.id});

  factory ProposalRiwayatModel.fromJson(Map<String, dynamic> json) {
    return ProposalRiwayatModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}