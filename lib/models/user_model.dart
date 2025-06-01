// lib/models/user_model.dart
import 'package:real/services/api_constants.dart'; // Pastikan ada

class User {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String phone;
  final String profileImage; // Ini SEHARUSNYA sudah berisi URL lengkap dari backend
  final String? token; // Token didapat dari respons login, bukan dari model user di DB

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    this.bio = '', // Nilai default untuk bio jika tidak ada
    this.token,
  });

  // Getter 'fullProfileImageUrl' bisa dihapus jika backend sudah benar
  // atau biarkan seperti ini untuk menangani jika suatu saat path relatif datang lagi
  String get fullProfileImageUrl {
    if (profileImage.isEmpty) return '';
    if (profileImage.startsWith('http')) return profileImage; // Sudah URL lengkap

    // Fallback jika backend TIDAK mengirim URL lengkap (sebaiknya backend yang diperbaiki)
    String baseUrl = ApiConstants.laravelApiBaseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - '/api'.length);
    }
    return '$baseUrl$profileImage'; 
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '', // Menangani '_id' atau 'id'
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '', // Mengambil 'bio', default string kosong jika null
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'] ?? '', // Terima URL lengkap
      token: json['token'], // Token biasanya ada di level atas respons login, atau di dalam data user
    );
  }

  // Method copyWith untuk memudahkan update objek user secara immutable
  // Ini sangat penting untuk memperbarui state di AuthProvider
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? phone,
    String? profileImage,
    // token biasanya tidak di-copyWith karena dikelola terpisah atau hanya ada saat login
    // Jika token ada di objek User dan ingin dipertahankan, gunakan: String? token = this.token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      token: token, // Pertahankan token yang ada pada objek User ini
    );
  }

  // Opsional: toJson untuk debugging atau jika perlu mengirim seluruh objek user
  // Untuk update profil, kita biasanya hanya mengirim field yang diubah.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'phone': phone,
      'profile_image': profileImage,
      'token': token,
    };
  }
}