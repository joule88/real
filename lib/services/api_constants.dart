class ApiConstants {
  static const String laravelApiBaseUrl = 'http://10.10.183.27:8000/api';

  // --- Flask API Prediksi ---
  static const String flaskApiBaseUrl = 'http://10.10.183.27:5000';

  // Endpoint untuk API Laravel
  static const String propertiesEndpoint = '/properties';
  static const String userPropertiesEndpoint = '/user/properties';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String userProfileEndpoint = '/profile';
  static const String changePasswordEndpoint = '/profile/change-password';
  static const String publicPropertiesEndpoint = '/properties/public';
  static const String forgotPasswordEndpoint = '/forgot-password'; // Tetap
  static const String verifyCodeEndpoint = '/verify-password-code'; // Baru
  static const String resetPasswordWithCodeEndpoint = '/reset-password-with-code'; // Baru

  // Endpoint untuk API Flask Prediksi (akan digabung dengan flaskApiBaseUrl)
  static const String predictPriceEndpoint = '/prediksi/create';
}