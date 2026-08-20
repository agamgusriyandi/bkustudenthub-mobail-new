class OrmawaRole {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;

  OrmawaRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });
}