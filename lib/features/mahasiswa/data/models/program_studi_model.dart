class ProgramStudiModel {
  final int id;

  ProgramStudiModel({required this.id});

  factory ProgramStudiModel.fromJson(Map<String, dynamic> json) {
    return ProgramStudiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
