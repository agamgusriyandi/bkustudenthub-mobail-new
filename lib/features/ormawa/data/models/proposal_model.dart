class ProposalModel {
  final int id;

  ProposalModel({required this.id});

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
