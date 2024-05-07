class MobileToken {
  final int? id;
  final String user;
  final String token;

  MobileToken({this.id, required this.user, required this.token});

  factory MobileToken.fromJson(Map<String, dynamic> json) {
    return MobileToken(
      id: json['id'],
      user: json['user'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['token'] = this.token;
    return data;
  }
}
