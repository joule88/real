class ApiConstants {
  static const String laravelApiBaseUrl = 'http://127.0.0.1:8000/api';

  // --- Flask API Prediksi ---
  static const String flaskApiBaseUrl = 'http://127.0.0.1:5000';

  // Endpoint untuk API Laravel
  static const String propertiesEndpoint = '/properties';
  static const String userPropertiesEndpoint = '/user/properties';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';

  // --- TAMBAHKAN ENDPOINT UNTUK PROFIL PENGGUNA ---
  // Ini bisa digunakan untuk GET (ambil profil) dan PUT/POST (update profil)
  static const String userProfileEndpoint = '/user/profile';

  // Endpoint untuk API Flask Prediksi (akan digabung dengan flaskApiBaseUrl)
  static const String predictPriceEndpoint = '/prediksi/create';
}