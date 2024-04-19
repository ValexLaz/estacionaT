class Parking {
  int? id;
  String? name;
  int? capacity;
  String? phone;
  String? email;
  int? userId;
  int? spacesAvailable;
  String? urlImage;
  String? description;

  Parking({
    this.id,
    this.name,
    this.capacity,
    this.phone,
    this.email,
    this.userId,
    this.spacesAvailable,
    this.urlImage,
    this.description,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      phone: json['phone'],
      email: json['email'],
      userId: json['user'],
      spacesAvailable: json['spaces_available'],
      urlImage: json['url_image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'phone': phone,
      'email': email,
      'user': userId,
      'spaces_available': spacesAvailable,
      'url_image': urlImage,
      'description': description,
    };
  }
}
