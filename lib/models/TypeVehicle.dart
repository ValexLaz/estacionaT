class TypeVehicle {
  final int id;
  final String name;
  final String description;

  TypeVehicle({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TypeVehicle.fromJson(Map<String, dynamic> json) {
    return TypeVehicle(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
