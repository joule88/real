class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'] ?? '',
      token: json['token'],
    );
  }
}
