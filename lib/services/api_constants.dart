// lib/services/api_constants.dart
class ApiConstants {
  // Base URL untuk API Laravel Utama (misalnya untuk submit properti, auth, dll.)
  static const String laravelApiBaseUrl = 'http://127.0.0.1:8000/api';

  // --- Base URL BARU untuk Flask API Prediksi ---
  static const String flaskApiBaseUrl = 'http://127.0.0.1:5000'; // Sesuai dengan tempat Flask app berjalan

  // Endpoint untuk API Laravel (akan digabung dengan laravelApiBaseUrl)
  static const String propertiesEndpoint = '/properties';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';

  // Endpoint untuk API Flask Prediksi (akan digabung dengan flaskApiBaseUrl)
  static const String predictPriceEndpoint = '/prediksi/create';
}