class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '', // Fallback ke string kosong jika null
      name: json['name'] ?? '', // Fallback ke string kosong jika null
      email: json['email'] ?? '', // Fallback ke string kosong jika null
      role: json['role'] ?? '', // Fallback ke string kosong jika null
      phone: json['phone'] ?? '', // Fallback ke string kosong jika null
      profileImage: json['profile_image'] ?? '', // Fallback ke string kosong jika null
    );
  }
}
